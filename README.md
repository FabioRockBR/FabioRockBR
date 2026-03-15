<div align="center">

# Fabio Silva

### Aviation AI Systems Engineer

*Building intelligent systems at the intersection of aviation maintenance and AI*

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat&logo=linkedin)](https://linkedin.com/in/fabiosilva)
[![Email](https://img.shields.io/badge/Email-fabiosilva@aerotechsupport.net-EA4335?style=flat&logo=gmail)](mailto:fabiosilva@aerotechsupport.net)
[![Location](https://img.shields.io/badge/Location-Portugal-009B3A?style=flat)](https://www.google.com/maps/place/Portugal)

</div>

---

## About

Aviation maintenance professional turned AI systems engineer. I design and build production-grade AI systems for the aviation industry — combining deep domain knowledge of airworthiness, ATA documentation, and maintenance operations with modern AI engineering.

My focus is the gap most teams can't bridge: the one between what aviation maintenance operations actually need and what AI engineers know how to build.

---

## Featured Projects

### ✈️ Cortana — Aviation Maintenance AI Agent
> Production RAG system for aircraft maintenance operations

A voice-enabled AI agent that indexes and retrieves information across aviation technical manuals (AMM, CMM, SRM, IPC, FIM, WDM) using semantic search. Built for hands-free use in hangar environments via Telegram with Whisper STT and Gemini TTS.

**Architecture highlights:**
- Multi-modal vector database (Qdrant) indexing PDFs, wiring diagrams, and images
- Gemini Embedding 2 (`gemini-embedding-2-preview`, 3072 dims) for retrieval
- GCP Cloud Function pipeline for large documents (>20MB)
- Automatic metadata extraction: ATA chapters, document types, source deduplication
- Private media delivery — no public URLs for controlled technical documents
- Voice I/O: OGG → Whisper STT → AI Agent → Gemini TTS → WAV

`Python` `n8n` `Qdrant` `LangChain` `Google Cloud` `Gemini` `OpenAI` `Telegram`

---

### 📈 invest-bot — Algorithmic Trading Platform
> Event-driven microservices with hard-wired risk controls

A 10-service FastAPI platform for algorithmic trading across Binance (crypto testnet) and Alpaca (paper trading). Designed around a pure-function risk engine with a Redis-based kill switch that activates in under 100ms.

**Architecture highlights:**
- Event-driven with Redis Streams (`EventEnvelope` schema)
- Risk engine: pure Python, no I/O — fully unit-tested and deterministic
- Broker abstraction layer (ccxt + Alpaca SDK)
- Kill switch: Redis key `risk:kill_switch` — no restart required
- Observability: Prometheus + Loki + Grafana stack

`Python` `FastAPI` `PostgreSQL` `Redis` `Docker` `Prometheus` `Grafana`

---

## Stack

```
AI & ML          Python · LangChain · Qdrant · Pinecone · RAG pipelines
                 OpenAI · Gemini · Whisper · Vector embeddings

Automation       n8n · Google Cloud Functions · Cloud Run
                 Telegram Bot API · Webhook orchestration

Backend          FastAPI · PostgreSQL · Redis · Supabase
                 Docker · Docker Compose · Nginx

Cloud            Google Cloud Platform · GCP Cloud Functions
                 Supabase · Qdrant Cloud

Domain           Aviation maintenance (Boeing 737, ATA chapters)
                 EASA / FAA regulatory frameworks
                 AMM · CMM · SRM · IPC · FIM · WDM documentation
```

---

## Domain Knowledge

10+ years in aviation maintenance operations. I bring to engineering:

- **ATA chapter structure** — system-level organization of aircraft documentation
- **Airworthiness compliance** — EASA Part-145, FAA AC 43.13 frameworks
- **Maintenance documentation** — how technicians actually use AMM/CMM/SRM in the field
- **MRO operations** — workflow, scheduling, parts, and regulatory sign-off

This domain depth is what allows me to design AI systems that are actually useful in a hangar — not just technically functional.

---

## Currently Building

- Expanding Cortana's knowledge base with FIM and WDM manual sets
- Algorithmic strategy layer for invest-bot (Days 16–45 scope)
- Monitoring and alerting layer for production AI workflows

---

<div align="center">

*Open to AI engineering roles in aviation, aerospace, and industrial verticals*
*Available for consulting on domain-specific AI systems*

</div>
