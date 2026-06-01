<div align="center">

# Fabio Silva

### AI Automation & Systems Engineer

*I build reliable AI agents, RAG systems, and n8n automations — the kind you put in production, not just demo. Aviation is my niche; dependable automation is the craft.*

[![Website](https://img.shields.io/badge/Web-aerotechsupport.net-009B3A?style=flat&logo=googlechrome&logoColor=white)](https://aerotechsupport.net)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat&logo=linkedin)](https://linkedin.com/in/fabiosilva)
[![Email](https://img.shields.io/badge/Email-fabiosilva@aerotechsupport.net-EA4335?style=flat&logo=gmail&logoColor=white)](mailto:fabiosilva@aerotechsupport.net)
[![Location](https://img.shields.io/badge/Based_in-Portugal-009B3A?style=flat)](#)

</div>

---

## About

I design and ship **AI automation systems** — n8n workflows, retrieval-augmented agents, MCP servers, and the backend services around them. The kind you put in production and keep running, not the kind that only works in a screen recording.

My deepest work is in **aviation maintenance** — a field where an unreliable system isn't an inconvenience, it's a safety event. My flagship project, **Airtech Support OS**, is a live multi-tenant platform where seven specialist AI coworkers help a maintenance operator turn a message into a documented, compliant, dispatch-ready case — built with audit trails, server-side permission enforcement, durable memory, and a human always holding the final click. That's where I'm building the deepest domain expertise, and where I see my long-term niche.

But the value isn't the domain — it's the **production-tested workflows underneath it.** RAG agents, n8n automations, MCP servers, multi-tenant microservices, self-healing ops: those are domain-agnostic. I adapt them to whatever a client actually needs. Aviation proves the depth; it doesn't define the limit. If your problem looks like "wire an AI agent into our real systems and make it dependable," I've already built that — and I'll reshape it to your stack and your domain.

**What I do:**
- 🤖 **AI agents & RAG** — retrieval over *your* documents, agents that call tools and remember context
- 🔁 **n8n automation** — lead handling, document processing, content pipelines, intelligent routing
- ⚙️ **Backend & infra** — Python/FastAPI microservices, Postgres/Redis, Docker, observability, self-healing ops
- 🔌 **MCP servers** — custom tools that plug AI agents into real APIs and systems
- 🧩 **Multi-tenant platforms** — per-tenant isolation, durable job queues, idempotent migrations, safe rollback

The throughline is reliability: **audit trails, error handling, rollback plans, monitoring** — automation people can actually depend on, in any domain.

---

## Featured Projects

### ✈️ [airtech-support-os](https://github.com/FabioRockBR/airtech-support-os) — *flagship case study*
> Multi-tenant aviation-maintenance AI platform — one operator in command, seven specialist AI coworkers working a case as a crew. **Live in production.**

A maintenance operator opens one conversation and stays in command; behind it, seven specialist coworkers — triage, line maintenance, troubleshooting, AOG authority, planning, quality, parts — work the problem together, sharing one institutional memory and one Google identity. A Telegram message becomes a documented War Room case with a live timeline and a dispatch-ready output. Deterministic n8n orchestration, permissions enforced server-side at the specialist boundary, draft-only Gmail so a human always holds Send, and artefacts that stay in the customer's own Workspace. **Source is proprietary** — this repo is an architecture-and-capability case study. See it live at **[airtechsupport.net](https://airtechsupport.net)**.

`n8n` `FastAPI` `PostgreSQL · pgvector` `Redis` `Google Workspace` `RAG` `Next.js` `Cloudflare` `Aviation`

### 🤖 [n8n-rag-agent-starter](https://github.com/FabioRockBR/n8n-rag-agent-starter)
> A production-shaped RAG agent in n8n — Telegram in, Qdrant-backed answers out

The pattern most "AI chatbot" tutorials skip: **retrieve, reason, remember, record.** Semantic search over a vector store, an AI Agent that knows when to use a tool, durable Postgres memory, and an audit log for every turn. Clone it, point it at your knowledge base, ship it.

`n8n` `RAG` `Qdrant` `PostgreSQL` `AI Agents` `Telegram`

### 🔌 [mcp-servers](https://github.com/FabioRockBR/mcp-servers)
> Three Model Context Protocol servers — geocoding, web search, browser automation

Self-contained MCP servers built on the official SDK, each independently dockerized. How you give an AI agent real capabilities — cleanly, with keys read from the environment, never hardcoded.

`TypeScript` `MCP` `Docker` `Google Maps` `Brave Search` `Playwright`

### 🛰️ [cortana-ai-os](https://github.com/FabioRockBR/cortana-ai-os)
> Self-hosted AI agent platform for airline maintenance — tiered by role

Three isolated deployment tiers (Technician / Operations / Master Chief), each a complete Docker stack with its own AI agent, Qdrant vector DB, and document ingestion. The open-source companion to the Airtech case study above — same ideas, self-hostable.

`Python` `n8n` `Qdrant` `Docker` `RAG` `Aviation`

### 🛠️ [env-tool](https://github.com/FabioRockBR/env-tool)
> One Zod schema, every `.env` artifact — validate, generate, never drift

A small TypeScript CLI that makes a Zod schema the single source of truth for environment config. Validates with masked output, generates JSON schema + templates. The kind of dev-experience tooling that prevents 2am config incidents.

`TypeScript` `Zod` `CLI` `DevEx`

---

## Stack

```
AI & Automation   n8n · RAG pipelines · AI Agents · Qdrant · Pinecone
                  OpenAI · Gemini · Anthropic · Whisper · MCP servers

Backend           Python · FastAPI · PostgreSQL · Redis · Supabase
                  Event-driven (Redis Streams) · REST APIs · multi-tenant

Infra & Ops       Docker · Docker Compose · Cloudflare · Prometheus
                  Grafana · Loki · GitHub Actions CI · self-healing ops

Frontend          Next.js · React · Tailwind CSS · TypeScript

Domain            Aviation maintenance · EASA Part-66 · MRO operations
```

---

## What I can build for you

Available for **freelance / contract** AI-automation work — and not only in aviation. I bring already-built, production-tested systems as starting points and adapt them to your domain. Typical engagements:

- **RAG knowledge agent** — an AI assistant that answers from *your* documents (manuals, policies, contracts, support docs), with sources, memory, and an audit trail
- **n8n workflow automation** — lead capture & qualification, invoice/email/document processing, CRM sync, content pipelines, intelligent routing between systems
- **AI agent integration** — wiring LLMs and tools into your existing stack, with permissions enforced server-side, error handling, and monitoring
- **MCP server development** — custom tools that connect AI agents to your APIs and data
- **Multi-tenant / SaaS backends** — FastAPI services, tenant isolation, job queues, migrations, and the rollback tooling that makes it safe to ship
- **Production hardening** — taking a working prototype and giving it the audit trails, observability, and self-healing it needs to run unattended

Whatever the industry, I start from systems I've already proven in production and reshape them to fit. I optimize for **maintainable and monitored**, not one-off scripts — the kind you keep running, not rebuild every quarter.

📬 **[fabiosilva@aerotechsupport.net](mailto:fabiosilva@aerotechsupport.net)** · **[aerotechsupport.net](https://aerotechsupport.net)**

---

<div align="center">

*Reliable automation, built with the discipline of a field where reliability is the whole job.*

</div>
