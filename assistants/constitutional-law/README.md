# Assistente Jurídico — Constitucional / Full-service

Ferramenta de raciocínio jurídico que reproduz o **método de trabalho dos escritórios de elite**: construir tese → testar (red team) → convergir, com **fontes verificáveis**, **rastreabilidade** e uma camada de **jurimetria** para estimar probabilidade de êxito.

## Conteúdo

| Arquivo | Descrição |
|---|---|
| [`CLAUDE.md`](./CLAUDE.md) | Definição do assistente: identidade, princípios inegociáveis e método de raciocínio (tese/antítese/síntese). |
| [`docs/01-estudo-e-plano.md`](./docs/01-estudo-e-plano.md) | Estudo de formulação: benchmark de escritórios renomados (full-service, boutiques de contencioso, advocacia de Supremo), jurimetria, e tradução em capacidades de produto. |
| [`docs/02-modelo-de-dados.md`](./docs/02-modelo-de-dados.md) | Dicionário de dados, diagrama ER e padrões de consulta (RAG híbrido + jurimetria). |
| [`data/schema.sql`](./data/schema.sql) | DDL PostgreSQL + pgvector: conhecimento, casos, raciocínio, jurimetria e governança. |

## Princípios (resumo)

1. Fonte verificável, **nunca invenção** — toda afirmação aponta para fonte primária.
2. Separar **mérito de forma** e **fato de interpretação**.
3. **Avaliação da fonte**: parcialidade desqualifica a fonte, não decide o mérito.
4. Jurimetria é **estimativa com incerteza**, nunca veredito.
5. Legalidade: orientar caminhos institucionais, nunca o descumprimento.

## Stack-alvo

PostgreSQL + pgvector · FastAPI · n8n (ingestão/orquestração) · RAG híbrido (HNSW + pg_trgm) · human-in-the-loop.

---

*Material para fins de raciocínio jurídico e de produto; não substitui parecer de profissional habilitado nem decisão judicial.*
