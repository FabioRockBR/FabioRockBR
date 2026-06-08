-- =============================================================================
-- Assistente Jurídico — Modelo de Dados (PostgreSQL + pgvector)
-- =============================================================================
-- Objetivo: estrutura de dados para CONECTAR fontes verificáveis (normas,
-- jurisprudência, doutrina) a CASOS REAIS e ao MÉTODO DE RACIOCÍNIO
-- (tese → antítese → síntese), com camada de JURIMETRIA para estimar
-- probabilidade de êxito — sempre com rastreabilidade de fonte (audit trail).
--
-- Princípios de projeto (espelham o CLAUDE.md):
--   1. Fontes verificáveis, nunca invenção  → tabela `citation` com
--      verification_status; toda afirmação aponta para uma fonte primária.
--   2. Separar mérito de forma              → `legal_issue.dimension`.
--   3. Separar fato de interpretação        → `matter_fact` vs `argument`.
--   4. Avaliação da fonte (parcialidade)    → `source.bias_note` / `independence`.
--   5. Método socrático auditável           → `reasoning_session` / `reasoning_step`.
--   6. Vigência das normas (alvo móvel)     → `norm_version` (validade temporal).
--
-- Dimensão de embedding: assume 1536 (ex.: text-embedding-3-small / Gemini).
-- Ajuste EM TODOS os `vector(1536)` se trocar de modelo de embedding.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;     -- busca textual fuzzy (híbrida com vetorial)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- uuid_generate_v4()

CREATE SCHEMA IF NOT EXISTS legal;
SET search_path TO legal, public;

-- -----------------------------------------------------------------------------
-- Tipos enumerados (domínios controlados)
-- -----------------------------------------------------------------------------
CREATE TYPE legal.practice_area AS ENUM (
  'constitucional', 'administrativo', 'penal', 'processual_penal',
  'civel', 'processual_civel', 'tributario', 'trabalhista', 'empresarial',
  'consumidor', 'ambiental', 'eleitoral', 'regulatorio', 'arbitragem', 'outro'
);

CREATE TYPE legal.source_type AS ENUM (
  'norma',          -- CF, lei, código, decreto, EC
  'jurisprudencia', -- acórdão, súmula, tema de repercussão geral
  'doutrina',       -- livro, artigo, parecer
  'peca_processual',-- petição, sentença, voto
  'documento_caso'  -- prova, contrato, documento do cliente
);

CREATE TYPE legal.court AS ENUM (
  'STF','STJ','TST','TSE','STM','TRF','TJ','TRT','TRE','primeira_instancia','outro'
);

CREATE TYPE legal.issue_dimension AS ENUM (
  'merito',       -- houve ilícito / existe o direito?
  'forma',        -- competência, processo, dosimetria, prazo
  'mista'
);

CREATE TYPE legal.argument_role AS ENUM (
  'tese',      -- Passo 1: posição mais forte
  'antitese',  -- Passo 2: red team / desconstrução
  'sintese'    -- Passo 4: convergência
);

CREATE TYPE legal.verification_status AS ENUM (
  'verificada',     -- conferida em fonte primária
  'pendente',       -- precisa confirmar (conclusão provisória)
  'nao_verificada', -- citada sem confirmação
  'refutada'        -- não confere com a fonte
);

CREATE TYPE legal.matter_status AS ENUM (
  'triagem','em_analise','ativo','suspenso','encerrado','arquivado'
);

CREATE TYPE legal.outcome AS ENUM (
  'procedente','parcialmente_procedente','improcedente',
  'acordo','extinto_sem_merito','pendente'
);

-- =============================================================================
-- CAMADA 1 — CONHECIMENTO (fontes verificáveis para RAG)
-- =============================================================================

-- Fonte canônica: qualquer origem de informação jurídica, com avaliação de viés.
CREATE TABLE legal.source (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  source_type     legal.source_type NOT NULL,
  title           text NOT NULL,
  authority       text,                 -- órgão/autor (STF, Planalto, autor da doutrina)
  url             text,                 -- link para a fonte primária
  official        boolean NOT NULL DEFAULT false, -- fonte oficial (Planalto, DOU, STF)?
  independence    boolean,              -- TRUE = sem vínculo com o caso; NULL = desconhecido
  bias_note       text,                 -- "parte no processo", "militante", "parecer encomendado"
  published_at    date,
  created_at      timestamptz NOT NULL DEFAULT now()
);
COMMENT ON COLUMN legal.source.bias_note IS
  'Princípio "avaliação da fonte": a parcialidade desqualifica a FONTE, não o mérito.';

-- Normas (CF, leis, códigos). A norma é o "container"; o texto vive em norm_version.
CREATE TABLE legal.norm (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  source_id       uuid REFERENCES legal.source(id),
  short_name      text NOT NULL,        -- "CF/1988", "CP", "CPC/2015"
  official_id     text,                 -- "Constituição Federal", "Lei 13.105/2015"
  practice_area   legal.practice_area,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Dispositivo (artigo/§/inciso) — granularidade fina, inspirada em Akoma Ntoso.
-- Estrutura hierárquica via parent_id (artigo → parágrafo → inciso → alínea).
CREATE TABLE legal.norm_provision (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  norm_id         uuid NOT NULL REFERENCES legal.norm(id) ON DELETE CASCADE,
  parent_id       uuid REFERENCES legal.norm_provision(id) ON DELETE CASCADE,
  label           text NOT NULL,        -- "art. 5º", "§ 1º", "inciso LV", "alínea a"
  citation_key    text,                 -- forma canônica: "art. 5º, LV, CF"
  ordinal         integer,              -- ordem para listagem
  UNIQUE (norm_id, citation_key)
);

-- Versão temporal do dispositivo (vigência) — a Constituição é alvo móvel (ECs).
-- Permite responder "o que vigora HOJE" vs "o que vigorava na data do fato".
CREATE TABLE legal.norm_version (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  provision_id    uuid NOT NULL REFERENCES legal.norm_provision(id) ON DELETE CASCADE,
  full_text       text NOT NULL,        -- redação literal (da fonte oficial)
  amended_by      text,                 -- "EC 139/2026", "redação original"
  valid_from      date,                 -- início de vigência
  valid_to        date,                 -- NULL = vigente
  source_id       uuid REFERENCES legal.source(id),
  verification    legal.verification_status NOT NULL DEFAULT 'pendente',
  embedding       vector(1536),
  created_at      timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE legal.norm_version IS
  'Redação literal só deve ser tratada como autêntica quando verification = verificada.';

-- Jurisprudência: acórdãos, súmulas, temas de repercussão geral.
CREATE TABLE legal.precedent (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  source_id       uuid REFERENCES legal.source(id),
  court           legal.court NOT NULL,
  body            text,                 -- órgão julgador (Plenário, 1ª Turma)
  case_number     text,                 -- nº do processo (verificável)
  rapporteur      text,                 -- relator
  judged_at       date,
  headnote        text,                 -- ementa
  thesis          text,                 -- tese firmada / enunciado da súmula
  binding         boolean DEFAULT false,-- vinculante (súmula vinculante, RG)
  practice_area   legal.practice_area,
  verification    legal.verification_status NOT NULL DEFAULT 'pendente',
  embedding       vector(1536),
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Doutrina e pareceres (com sinalização explícita de independência/viés).
CREATE TABLE legal.doctrine (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  source_id       uuid REFERENCES legal.source(id),
  author          text NOT NULL,
  work_title      text,
  excerpt         text,
  practice_area   legal.practice_area,
  embedding       vector(1536),
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Loja genérica de chunks para RAG (qualquer documento ingerido).
-- Une as fontes acima num índice vetorial único e pesquisável.
CREATE TABLE legal.document_chunk (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  source_id       uuid REFERENCES legal.source(id),
  -- referência polimórfica opcional ao objeto de origem:
  ref_table       text,                 -- 'norm_version' | 'precedent' | 'doctrine' | 'document'
  ref_id          uuid,
  chunk_index     integer NOT NULL DEFAULT 0,
  content         text NOT NULL,
  token_count     integer,
  embedding       vector(1536),
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- =============================================================================
-- CAMADA 2 — CASOS REAIS (operacional / matter management)
-- =============================================================================

CREATE TABLE legal.client (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  display_name    text NOT NULL,
  document_id     text,                 -- CPF/CNPJ (dado sensível — restringir acesso)
  notes           text,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE legal.matter (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  client_id       uuid REFERENCES legal.client(id),
  title           text NOT NULL,
  practice_area   legal.practice_area NOT NULL,
  court           legal.court,
  case_number     text,                 -- nº do processo, se houver
  instance        text,                 -- 1ª instância, 2º grau, instância superior
  claim_value     numeric(18,2),        -- valor da causa
  status          legal.matter_status NOT NULL DEFAULT 'triagem',
  summary         text,
  embedding       vector(1536),         -- p/ encontrar casos análogos (jurimetria)
  opened_at       date NOT NULL DEFAULT current_date,
  closed_at       date,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE legal.party (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  matter_id       uuid NOT NULL REFERENCES legal.matter(id) ON DELETE CASCADE,
  name            text NOT NULL,
  role            text NOT NULL,        -- autor, réu, terceiro, amicus curiae, MP
  represented     boolean DEFAULT false -- é nosso cliente?
);

-- Fatos: o que ocorreu. Mantido SEPARADO de argumento (fato ≠ interpretação).
CREATE TABLE legal.matter_fact (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  matter_id       uuid NOT NULL REFERENCES legal.matter(id) ON DELETE CASCADE,
  statement       text NOT NULL,
  proven          boolean,              -- provado? (não confundir alegação com prova)
  evidence_ref    text,                 -- documento/prova que sustenta
  disputed        boolean DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now()
);
COMMENT ON COLUMN legal.matter_fact.proven IS
  '"A defesa alegou X" ≠ "ficou provado X". proven distingue alegação de prova.';

-- Questão jurídica: a PERGUNTA real do caso (Passo 0 — enquadrar).
CREATE TABLE legal.legal_issue (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  matter_id       uuid NOT NULL REFERENCES legal.matter(id) ON DELETE CASCADE,
  question        text NOT NULL,        -- a questão jurídica real
  dimension       legal.issue_dimension NOT NULL DEFAULT 'merito',
  contested       boolean DEFAULT false,-- genuinamente contestada entre juristas sérios?
  embedding       vector(1536),
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- =============================================================================
-- CAMADA 3 — MÉTODO DE RACIOCÍNIO (tese/antítese/síntese auditável)
-- =============================================================================

-- Uma execução do método sobre uma questão (Passos 0–5 do CLAUDE.md).
CREATE TABLE legal.reasoning_session (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  issue_id        uuid NOT NULL REFERENCES legal.legal_issue(id) ON DELETE CASCADE,
  framing         text,                 -- Passo 0: enquadramento
  synthesis       text,                 -- Passo 4: bloco de convergência reaproveitável
  next_evidence   text,                 -- Passo 5: próxima fonte primária a buscar
  model           text,                 -- modelo/versão que conduziu o raciocínio
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Argumentos: tese, antítese e síntese, com força estimada.
CREATE TABLE legal.argument (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id      uuid NOT NULL REFERENCES legal.reasoning_session(id) ON DELETE CASCADE,
  role            legal.argument_role NOT NULL,
  statement       text NOT NULL,
  rationale       text,                 -- fundamentação
  strength        numeric(3,2) CHECK (strength BETWEEN 0 AND 1), -- robustez estimada
  weak_premise    text,                 -- ponto frágil identificado no red team
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Liga cada argumento às FONTES que o sustentam (citação verificável).
-- Núcleo do princípio "fontes verificáveis, nunca invenção".
CREATE TABLE legal.citation (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  argument_id     uuid REFERENCES legal.argument(id) ON DELETE CASCADE,
  -- alvo polimórfico (uma das três deve estar preenchida):
  norm_version_id uuid REFERENCES legal.norm_version(id),
  precedent_id    uuid REFERENCES legal.precedent(id),
  doctrine_id     uuid REFERENCES legal.doctrine(id),
  pinpoint        text,                 -- localização exata ("art. 5º, LV"; "fl. 12 do voto")
  quote           text,                 -- trecho citado
  supports        boolean NOT NULL DEFAULT true, -- TRUE apoia / FALSE contraria a tese
  verification    legal.verification_status NOT NULL DEFAULT 'pendente',
  verified_at     timestamptz,
  CHECK (num_nonnulls(norm_version_id, precedent_id, doctrine_id) = 1)
);

-- =============================================================================
-- CAMADA 4 — JURIMETRIA (probabilidade de êxito a partir de dados)
-- =============================================================================

-- Histórico de desfechos de casos análogos (dado de treino / benchmark).
CREATE TABLE legal.case_outcome (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  precedent_id    uuid REFERENCES legal.precedent(id), -- se vier de jurisprudência pública
  matter_id       uuid REFERENCES legal.matter(id),    -- se vier de caso interno
  practice_area   legal.practice_area,
  court           legal.court,
  rapporteur      text,
  outcome         legal.outcome NOT NULL,
  decided_at      date,
  duration_days   integer,             -- tempo até a decisão
  features        jsonb,               -- variáveis usadas na modelagem
  embedding       vector(1536),        -- p/ vizinhança semântica do caso
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- Casos análogos ao caso atual (vizinhança vetorial materializada + score).
CREATE TABLE legal.analogous_case (
  matter_id       uuid NOT NULL REFERENCES legal.matter(id) ON DELETE CASCADE,
  outcome_id      uuid NOT NULL REFERENCES legal.case_outcome(id) ON DELETE CASCADE,
  similarity      numeric(5,4),        -- 1 - distância de cosseno
  PRIMARY KEY (matter_id, outcome_id)
);

-- Estimativa de probabilidade de êxito (saída do modelo de jurimetria).
CREATE TABLE legal.prediction (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  matter_id       uuid REFERENCES legal.matter(id) ON DELETE CASCADE,
  issue_id        uuid REFERENCES legal.legal_issue(id) ON DELETE CASCADE,
  success_prob    numeric(4,3) CHECK (success_prob BETWEEN 0 AND 1),
  confidence      numeric(4,3) CHECK (confidence BETWEEN 0 AND 1),
  basis           text,                -- explicação / features dominantes (XAI)
  sample_size     integer,             -- nº de casos análogos que embasam
  model           text,
  created_at      timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE legal.prediction IS
  'Estimativa estatística, NÃO veredito. Sempre acompanhada de confidence e sample_size.';

-- =============================================================================
-- CAMADA 5 — GOVERNANÇA / AUDITORIA (toda afirmação tem origem)
-- =============================================================================
CREATE TABLE legal.audit_log (
  id              uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  actor           text NOT NULL,        -- usuário ou agente
  action          text NOT NULL,        -- 'assert', 'cite', 'predict', 'edit', 'verify'
  entity_table    text,
  entity_id       uuid,
  detail          jsonb,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- =============================================================================
-- ÍNDICES
-- =============================================================================
-- Vetoriais (HNSW: boa recuperação + latência; cosseno para textos normalizados).
CREATE INDEX idx_chunk_embedding     ON legal.document_chunk USING hnsw (embedding vector_cosine_ops);
CREATE INDEX idx_normver_embedding   ON legal.norm_version  USING hnsw (embedding vector_cosine_ops);
CREATE INDEX idx_precedent_embedding ON legal.precedent     USING hnsw (embedding vector_cosine_ops);
CREATE INDEX idx_doctrine_embedding  ON legal.doctrine      USING hnsw (embedding vector_cosine_ops);
CREATE INDEX idx_matter_embedding    ON legal.matter        USING hnsw (embedding vector_cosine_ops);
CREATE INDEX idx_issue_embedding     ON legal.legal_issue   USING hnsw (embedding vector_cosine_ops);
CREATE INDEX idx_outcome_embedding   ON legal.case_outcome  USING hnsw (embedding vector_cosine_ops);

-- Texto (busca híbrida vetorial + lexical).
CREATE INDEX idx_normver_text_trgm   ON legal.norm_version USING gin (full_text gin_trgm_ops);
CREATE INDEX idx_precedent_head_trgm ON legal.precedent    USING gin (headnote  gin_trgm_ops);

-- Relacionais frequentes.
CREATE INDEX idx_provision_norm      ON legal.norm_provision (norm_id);
CREATE INDEX idx_normver_provision   ON legal.norm_version   (provision_id);
CREATE INDEX idx_issue_matter        ON legal.legal_issue    (matter_id);
CREATE INDEX idx_argument_session    ON legal.argument       (session_id);
CREATE INDEX idx_citation_argument   ON legal.citation       (argument_id);
CREATE INDEX idx_outcome_area_court  ON legal.case_outcome   (practice_area, court);
CREATE INDEX idx_prediction_matter   ON legal.prediction     (matter_id);

-- Vigência: dispositivos em vigor hoje.
CREATE INDEX idx_normver_valid       ON legal.norm_version   (provision_id, valid_from, valid_to);

-- =============================================================================
-- VIEW DE APOIO — redação vigente de cada dispositivo (texto literal atual)
-- =============================================================================
CREATE VIEW legal.current_provision AS
SELECT p.id              AS provision_id,
       n.short_name,
       p.citation_key,
       v.full_text,
       v.amended_by,
       v.valid_from,
       v.verification
FROM legal.norm_provision p
JOIN legal.norm n        ON n.id = p.norm_id
JOIN legal.norm_version v ON v.provision_id = p.id
WHERE v.valid_to IS NULL;  -- versão vigente
