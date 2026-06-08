# Workflows de ingestão (n8n)

Pipelines que populam o modelo de dados ([`../../data/schema.sql`](../../data/schema.sql)) com **normas** e **jurisprudência**, gerando embeddings e fazendo **upsert idempotente** (reexecutável sem duplicar).

| Workflow | Ingere | Tabelas alvo |
|---|---|---|
| [`norm-ingestion.workflow.json`](./norm-ingestion.workflow.json) | Dispositivos de normas (CF/1988 + ECs) | `source`, `norm`, `norm_provision`, `norm_version`, `document_chunk` |
| [`precedent-ingestion.workflow.json`](./precedent-ingestion.workflow.json) | Acórdãos, súmulas, temas de RG | `source`, `precedent`, `document_chunk` |

## Topologia (ambos)

```
Manual / Schedule Trigger → Config → Load (Code) → OpenAI Embeddings (HTTP)
                                                          → Build Upsert Query (Code) → Postgres (executeQuery)
```

O nó **Build Upsert Query** monta um `INSERT ... ON CONFLICT` em CTE e o passa ao nó Postgres via `{{ $json.query }}`. O embedding vem da resposta da OpenAI; os demais campos vêm do item original por **paired-item** (`$('Load …').item`), sem necessidade de nó Merge.

## Pré-requisitos

1. **Aplicar o schema** uma vez:
   ```bash
   psql "$DATABASE_URL" -f ../../data/schema.sql
   ```
   Requer `CREATE EXTENSION vector` (pgvector ≥ 0.5 para índice HNSW).

2. **Credenciais no n8n** (substituir os placeholders nos arquivos ao importar, ou remapear na UI):
   - `openAiApi` → `REPLACE_OPENAI_CRED_ID` (nó *OpenAI Embeddings*).
   - `postgres` → `REPLACE_POSTGRES_CRED_ID` (nó *Postgres*).

3. **Modelo de embedding**: default `text-embedding-3-small` (**1536 dims**, casa com `vector(1536)` no schema). Se trocar de modelo, ajuste a dimensão em **todos** os `vector(1536)` do schema.

## Importar

n8n → *Workflows* → *Import from File* → selecione o `.json`. Remapeie as credenciais e clique em *Execute Workflow* (gatilho manual) para a carga inicial. Os gatilhos *Schedule* fazem a atualização contínua (normas: semanal; jurisprudência: diária).

## Contrato de dados (substituir o array de exemplo por um fetch real)

O nó **Load …** hoje traz um array de amostra. Em produção, troque-o por *HTTP Request → fonte oficial → parser* (ex.: Planalto/LexML em Akoma Ntoso para normas; APIs do STF/STJ para jurisprudência), mantendo o **contrato de saída por item**:

**Normas** — `{ citation_key, label, full_text, amended_by, valid_from (YYYY-MM-DD|null), verification }`
**Jurisprudência** — `{ court, body, case_number, rapporteur, judged_at, headnote, thesis, binding, practice_area, verification, source_title, source_url }`

> `case_number` é a **chave de idempotência** da jurisprudência — preencha sempre com um id estável (nº do processo *ou* enunciado, ex.: `"Súmula Vinculante 11"`).

Exemplos completos em [`../samples/`](../samples/).

## Idempotência e verificação

- Reexecutar **não duplica**: conflitos resolvidos por `source(source_type,url)`, `norm(short_name)`, `norm_provision(norm_id,citation_key)`, `norm_version(provision_id,content_hash)`, `precedent(court,case_number)`, `document_chunk(ref_table,ref_id,chunk_index)`.
- Nova redação (texto diferente) cria **nova** `norm_version` (o `content_hash` muda); a anterior permanece para histórico. *Fechar* a vigência antiga (`valid_to`) é um refinamento da Fase 2.
- `verification` entra como **`pendente`**. Só promova para `verificada` após conferência na **fonte primária** — coerente com o princípio "fontes verificáveis, nunca invenção".

## Segurança

- O nó *Build Upsert Query* faz escaping de aspas simples. Ainda assim, trate as fontes de ingestão como **confiáveis** (são feeds oficiais), não entrada de usuário final.
- Chaves de API e credenciais ficam **apenas** nas credenciais do n8n — nunca nos arquivos do workflow.

## Validação

O SQL gerado por ambos os workflows foi executado contra PostgreSQL 16 + pgvector 0.6.0: schema aplicado, carga rodada **duas vezes** (contagens estáveis = idempotente), escaping de aspas preservado e embeddings com 1536 dimensões.
