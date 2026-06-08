# Estudo de Formulação — Assistente Jurídico de Alta Eficiência

> Benchmark de escritórios e métodos de elite → tradução em capacidades de produto → arquitetura e estrutura de dados.
> **Escopo:** full-service (constitucional, penal, cível, tributário, trabalhista e correlatos).
> **Data do estudo:** 08/06/2026. **Idioma:** pt-BR.
> **Status das fontes:** pesquisa web realizada nesta data; trechos de redação literal de normas ficam *pendentes* de conferência no Planalto (instabilidade do servidor no momento da pesquisa).

---

## 1. Enquadramento (o problema que estamos resolvendo)

Não queremos um "oráculo que dá a resposta". Queremos uma ferramenta que **reproduza o método de trabalho dos melhores escritórios**: construir tese, submetê-la a *red team*, ancorar cada afirmação em fonte verificável, estimar chances com dados e apontar a próxima prova a buscar. O diferencial competitivo dos escritórios de elite **não é o talento individual** — é o **processo** e a **gestão de conhecimento** que tornam esse talento repetível e auditável. É isso que vamos codificar em dados e fluxo.

---

## 2. Benchmark — quem são as referências e o que copiar

### 2.1 Escritórios full-service de elite (o padrão de processo)

O ranking *Análise Advocacia 500* (eleito por executivos jurídicos de grandes empresas) aponta consistentemente como mais admirados: **Pinheiro Neto, Mattos Filho, Machado Meyer, TozziniFreire e Demarest** ([ConJur](https://www.conjur.com.br/2021-nov-24/analise-advocacia-divulga-ranking-escritorios-admirados/), [ConJur 2017](https://www.conjur.com.br/2017-nov-11/pinheiro-neto-banca-admirada-brasil-2017-publicacao/)). Em porte (nº de advogados), lideram **Nelson Wilians, Siqueira Castro, TozziniFreire, Pinheiro Neto e Mattos Filho** ([Econodata](https://www.econodata.com.br/maiores-empresas/todo-brasil/advocacia)).

**O que extrair:** esses escritórios investem pesado em **gestão de conhecimento (KM)** e **inovação/IA**. O Mattos Filho, por exemplo, mantém produção própria sobre adoção responsável de IA e governança ([Mattos Filho — Guia de IA](https://www.mattosfilho.com.br/unico/inteligencia-artificial-desafios-oportunidades/)). A literatura de KM jurídico é explícita: organizar **decisões, precedentes e experiências anteriores** de forma acessível acelera o trabalho e padroniza qualidade ([Projuris](https://www.projuris.com.br/blog/gestao-do-conhecimento-advocacia/)).

### 2.2 Boutiques de contencioso estratégico (o método de tese)

Sergio Bermudes "moldou o contencioso" brasileiro. Sua metodologia, relatada por discípulos: **partir do texto da lei para construir a tese**, em vez de caçar jurisprudência por palavra-chave — "quem sabe Teoria Geral do Direito pode saber tudo" ([Brazil Journal](https://braziljournal.com/memoria-sergio-bermudes-um-gigante-da-advocacia-que-moldou-o-contencioso/), [Bermudes Advogados](https://bermudes.com.br/)). O contencioso estratégico moderno acrescenta: **monitoramento contínuo de jurisprudência, seleção estratégica de casos e transformação de volume processual em inteligência** ([Jusfy](https://jusfy.com.br/blog/contencioso-estrategico-como-transformar-volume-de-processos-em-inteligencia-juridica/), [Aurum](https://www.aurum.com.br/blog/contencioso-estrategico/)).

**O que extrair:** o motor do produto deve ir **da norma → tese → teste → precedente**, não o contrário. Isso já está no nosso `CLAUDE.md` (Passos 1–5) e agora vira estrutura de dados (`reasoning_session`, `argument`, `citation`).

### 2.3 Advocacia de Supremo e o caso dos "escritórios de ministros do STF"

Aqui é preciso **rigor e honestidade de fonte** (princípio 4 do CLAUDE.md), porque o tema é sensível e frequentemente mal-enquadrado:

- **Ministros em exercício não advogam** — vedação constitucional (art. 95, parágrafo único, I, CF). Logo, "escritório de ministro do STF *em atividade*" não existe como prática lícita de advocacia.
- **Ex-ministros** podem voltar à advocacia consultiva/pareceres: p.ex. **Ayres Britto** (Ayres Britto Consultoria Jurídica e Advocacia, após 2003–2012) ([site oficial](https://ayresbritto.adv.br/)) e, historicamente, **Sepúlveda Pertence** ([ConJur](https://www.conjur.com.br/2023-jul-03/autoridades-comparecem-velorio-sepulveda-pertence-supremo/)).
- **Familiares de ministros** com bancas próprias e a sobreposição com processos na Corte são objeto de reportagem investigativa — pelo menos 31 registros societários envolvendo ministros e parentes ([Revista Oeste](https://revistaoeste.com/politica/stf-31-empresas-tem-ministros-e-familiares-como-socios/), [Gazeta do Povo](https://www.gazetadopovo.com.br/republica/quem-sao-os-ministros-do-stf-com-parentes-advogados-atuando-na-corte/)).

**O que extrair (e o que NÃO):** copiamos a **competência técnica da "advocacia de teses" perante tribunais superiores** (qualidade do parecer, dominação da jurisprudência da Corte, sustentação oral). **Não** copiamos, e na verdade tratamos como *risco a sinalizar*, qualquer vantagem baseada em **vínculo pessoal/conflito de interesse**. Por isso o schema tem `source.independence` e `source.bias_note`: uma fonte parcial pode ser citada, mas **a parcialidade fica registrada** — e ela desqualifica a *fonte*, não decide o *mérito*.

### 2.4 Jurimetria — a camada de "probabilidade de êxito"

A **ABJ (Associação Brasileira de Jurimetria)**, fundada em 2011, define jurimetria como a aplicação de modelos estatísticos a processos, decisões e fatos jurídicos, permitindo análise **descritiva, diagnóstica e preditiva** ([ABJ](https://abj.org.br/sobre/), [ABJ Lab](https://lab.abj.org.br/)). A análise preditiva estima desfechos com base em **dados anteriores** (de análise de sobrevivência a *random forests* e redes neurais) ([ABJ — Jurimetria e IA](https://lab.abj.org.br/posts/2019-08-27-jurimetria-e-inteligncia-artificial/), [Aurum](https://www.aurum.com.br/blog/jurimetria/)).

**O que extrair:** "maiores possibilidades de sucesso" não é promessa retórica — é uma **estimativa estatística com intervalo de confiança e tamanho de amostra** (`prediction.success_prob`, `confidence`, `sample_size`), nunca um veredito.

### 2.5 Padrões internacionais de modelagem de dados jurídicos

Para a estrutura de dados ser interoperável e "à prova de futuro", seguimos os padrões abertos consagrados:

- **Akoma Ntoso (OASIS LegalDocML)** — padrão internacional para representar normas/decisões em XML com granularidade de dispositivo (artigo→parágrafo→inciso) ([Wikipedia](https://en.wikipedia.org/wiki/Akoma_Ntoso)). Inspira nossa tabela `norm_provision` hierárquica.
- **LegalRuleML (OASIS)** — representação de regras jurídicas legível por máquina, com lógica *defeasible* ([Legal XML](https://en.wikipedia.org/wiki/Legal_XML)). Inspira o tratamento de argumento/exceção.

---

## 3. Tradução do benchmark em capacidades do assistente

| Prática de elite | Capacidade no produto | Onde vive nos dados |
|---|---|---|
| KM: precedentes/experiências reaproveitáveis | RAG sobre norma+jurisprudência+doutrina+casos | `document_chunk`, `precedent`, `norm_version` |
| Tese a partir do texto da lei (Bermudes) | Pipeline norma→tese→antítese→síntese | `reasoning_session`, `argument` |
| Monitoramento de jurisprudência | Ingestão contínua + busca vetorial | `precedent` + índices HNSW |
| Avaliação de fonte / conflito de interesse | Sinalização de viés e independência | `source.bias_note`, `source.independence` |
| Separar mérito de forma | Classificação da questão | `legal_issue.dimension` |
| Fato vs. alegação provada | Campo de prova explícito | `matter_fact.proven` |
| Jurimetria preditiva | Probabilidade de êxito + casos análogos | `prediction`, `analogous_case`, `case_outcome` |
| Vigência da norma (ECs) | Versionamento temporal | `norm_version.valid_from/valid_to` |
| Audit trail (cultura de rastreabilidade) | Toda afirmação → fonte | `citation`, `audit_log` |

---

## 4. Pipeline de resolução de um caso real (fluxo)

1. **Ingestão & enquadramento** — registra-se `matter`, `party`, `matter_fact` (com `proven`); identifica-se a `legal_issue` real e sua `dimension` (mérito/forma).
2. **Recuperação (RAG)** — busca vetorial híbrida em `document_chunk`/`precedent`/`norm_version` traz as fontes pertinentes; cada uma com seu viés sinalizado.
3. **Construção (Passo 1)** — gera-se a `argument` (role=`tese`) ancorada em `citation` para dispositivos e precedentes verificados.
4. **Desconstrução (Passo 2)** — `argument` (role=`antitese`); registra-se `weak_premise`; busca-se o caso fácil e o difícil.
5. **Convergência (Passo 4)** — `argument` (role=`sintese`) e `reasoning_session.synthesis` (bloco reaproveitável).
6. **Jurimetria** — `analogous_case` (vizinhança vetorial sobre `case_outcome`) alimenta `prediction.success_prob` com `confidence` e `sample_size`.
7. **Próximo dado (Passo 5)** — `reasoning_session.next_evidence` aponta a fonte primária a buscar; `citation.verification` sai de `pendente` → `verificada`.

---

## 5. Arquitetura técnica (alinhada ao stack do Fabio)

```
Ingestão (n8n)  →  Normalização/Chunking  →  Embeddings  →  Postgres + pgvector
                                                                  │
   Cliente / Telegram / Web  →  API (FastAPI)  →  Agente (RAG + método)  ←──┘
                                                  │
                                       Jurimetria (modelo preditivo)
                                                  │
                                  Audit trail + citações verificáveis
```

- **Postgres + pgvector** como única fonte de verdade (conhecimento + casos + raciocínio + jurimetria).
- **Busca híbrida**: HNSW (vetorial) + `pg_trgm` (lexical) para precisão em termos jurídicos exatos.
- **n8n** para ingestão contínua de normas/jurisprudência e orquestração.
- **Human-in-the-loop**: o assistente instrui o raciocínio; a decisão é do profissional habilitado.

---

## 6. Governança, ética e salvaguardas (inegociáveis)

- **Fonte verificável, nunca invenção.** `citation.verification` separa o que foi conferido em fonte primária do que é provisório. Redação literal de norma só é "autêntica" com `verification = verificada`.
- **Não é veredito.** `prediction` é estimativa com incerteza explícita; nunca afirma culpa/inocência de pessoa real como fato.
- **Conflito de interesse exposto.** Vínculos (parte, parecer encomendado, militância) ficam em `source.bias_note`.
- **Legalidade.** O sistema orienta caminhos institucionais (recurso, ADI, mudança legislativa), nunca o descumprimento.
- **Dados sensíveis.** `client.document_id` e dados de partes restritos ao mínimo necessário e ao que é público/relevante.

---

## 7. Roadmap

- **Fase 1 — Fundção:** aplicar `schema.sql`; ingerir CF/1988 (com vigência por EC) e súmulas/temas de RG do STF/STJ. Validar busca híbrida.
- **Fase 2 — Método:** implementar o pipeline tese/antítese/síntese gravando `reasoning_session`/`argument`/`citation`.
- **Fase 3 — Jurimetria:** popular `case_outcome` com jurisprudência pública; treinar o estimador de `success_prob` por área/tribunal/relator; expor `basis` (explicabilidade).
- **Fase 4 — Operação:** ingestão contínua (n8n), painel de prazos/tarefas, audit trail completo.

---

## 8. Próximos dados a buscar (Passo 5)

1. **Texto consolidado da CF/1988 no Planalto** (estava em 503 na pesquisa) — para popular `norm_version` com redação *verificada*, incluindo a **EC 139/2026** ([Senado](https://www12.senado.leg.br/noticias/materias/2026/05/05/congresso-promulga-emenda-da-essencialidade-dos-tribunais-de-contas)).
2. **Metodologia jurimétrica da ABJ** (livro aberto) para calibrar o modelo preditivo ([livro.abj.org.br](https://livro.abj.org.br/)).
3. **Especificação Akoma Ntoso 1.0** para alinhar o mapeamento de `norm_provision` ao padrão OASIS.

---

*Análise para fins de raciocínio jurídico e de produto; não substitui parecer de profissional habilitado nem decisão judicial. Dados sobre escritórios e pessoas baseados em fontes jornalísticas/oficiais citadas, sujeitos a verificação.*
