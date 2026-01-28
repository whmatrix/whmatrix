> **Author:** John Mitchell (@whmatrix)
> **Status:** ACTIVE / HUB
> **Audience:** ML Engineers / Data Architects / Recruiters / Enterprise Clients
> **Environment:** Portfolio routing (no GPU required to browse)
> **Fast Path:** [mini-index demo](https://github.com/whmatrix/semantic-indexing-batch-02/tree/main/mini-index) (60 seconds) or [research-corpus Quick Start](https://github.com/whmatrix/research-corpus-discovery)

# John Mitchell (@whmatrix)

*Semantic Indexing & RAG Infrastructure Engineer*

I build the infrastructure that makes semantic search work at scale:
protocol-driven validation, production-tested indexing pipelines,
and reproducible methodology across real institutional corpora.

---

## Start Here (One-Screen Overview)

```
+-------------------------------------------------------------+
|                      WHMATRIX PORTFOLIO                      |
|                   Semantic Search Stack                      |
+-------------------------------------------------------------+

1. PROTOCOL (Foundation)
   +-> universal-protocol-v4.23
       "Deliverable spec & audit standards"

2. PRODUCTION SCALE (Proof)
   +-> semantic-indexing-batch-01  (661K vectors, 6 datasets)
   +-> semantic-indexing-batch-02  (8.35M vectors, 3 datasets)
       "How to index at scale. With benchmarks."

3. APPLIED METHODOLOGY (Try It)
   +-> research-corpus-discovery
       "10 institutions, 4,600+ docs. Runnable scripts."

4. STRUCTURAL ANALYSIS (Theory)
   +-> comparative-grammar-gpt-vs-claude
   +-> structural-collaboration-primitives
   +-> interaction-mechanics-index
       "Why dialogue structure matters to RAG"

5. PORTFOLIO HUB
   +-> whmatrix.github.io
       "Full stats & routing"
```

---

## What Problem Does This Solve?

Semantic search at scale is hard. You need:
- **Protocol** (so you don't reinvent it)
- **Proof** (that it actually works)
- **Methodology** (reproducible, auditable)
- **Understanding** (why dialogue structure matters)

This portfolio provides all four.

---

## The 60-Second Version

1. **Start with the protocol** — [`universal-protocol-v4.23`](https://github.com/whmatrix/universal-protocol-v4.23)
   - Defines the "RAG-ready index" deliverable spec
   - Validation checkpoints and quality gates
   - Reproducible deliverables

2. **See it at scale** — [`semantic-indexing-batch-02`](https://github.com/whmatrix/semantic-indexing-batch-02)
   - 8.35M+ vectors (Wikipedia, ArXiv, StackExchange)
   - e5-large-v2 embeddings (1024-dim) + FAISS IndexFlatIP
   - Parallel indexing, split-merge patterns, checkpointing

3. **Try it yourself** — [`research-corpus-discovery`](https://github.com/whmatrix/research-corpus-discovery)
   - Applied to 10 real research institutions
   - 4,600+ documents, ~75,000 chunks
   - Runnable scripts, anonymized case studies

4. **Understand the theory** — Dialogue analysis repos
   - Why interaction patterns matter
   - How to structure semantic indices for dialogue

---

## Quickest Path

- **30 seconds:** Read this page
- **5 minutes:** Clone `research-corpus-discovery`, run the [Quick Start](https://github.com/whmatrix/research-corpus-discovery/blob/main/QUICK_START.md)
- **30 minutes:** Read the [protocol spec](https://github.com/whmatrix/universal-protocol-v4.23)
- **2 hours:** Understand the [full architecture](./ARCHITECTURE.md)

---

## All Repositories

| Repository | What It Is | Key Stat |
|------------|-----------|----------|
| [universal-protocol-v4.23](https://github.com/whmatrix/universal-protocol-v4.23) | Protocol spec for RAG deliverables | Deliverable + audit contracts |
| [semantic-indexing-batch-02](https://github.com/whmatrix/semantic-indexing-batch-02) | Production-scale semantic index | 8.35M vectors, 3 domains |
| [semantic-indexing-batch-01](https://github.com/whmatrix/semantic-indexing-batch-01) | Foundational batch (superseded) | 661K vectors, 6 datasets |
| [research-corpus-discovery](https://github.com/whmatrix/research-corpus-discovery) | Applied methodology across institutions | 4,600+ docs, runnable demo |
| [comparative-grammar-gpt-vs-claude](https://github.com/whmatrix/comparative-grammar-gpt-vs-claude) | Dialogue structure analysis | GPT vs Claude grammar comparison |
| [structural-collaboration-primitives](https://github.com/whmatrix/structural-collaboration-primitives) | Interaction primitives | 12 operators defined |
| [interaction-mechanics-index](https://github.com/whmatrix/interaction-mechanics-index) | Dual FAISS indices for dialogue | Semantic + structural retrieval |

---

## What You Get

| Deliverable | Format | Guarantee |
|-------------|--------|-----------|
| Vector index | FAISS IndexFlatIP (exact cosine via L2-normalized inner product) | Deterministic, byte-reproducible |
| Chunk corpus | JSONL with metadata | len(vectors) == len(chunks) == len(metadata) |
| Audit summary | JSON manifest | Pass/fail quality gates per Universal Protocol v4.23 |

**What this is not:** No human-judged relevance labels. No MRR/MAP/NDCG claims. Scores are cosine similarity (vector alignment), not precision or recall. Domain suitability requires independent evaluation.

**Reproduce it:** `git clone https://github.com/whmatrix/semantic-indexing-batch-02 && cd semantic-indexing-batch-02/mini-index && pip install sentence-transformers faiss-cpu && python demo_query.py`

---

## For Recruiters / Clients

- **If you need semantic search infrastructure:** Start with [batch-02](https://github.com/whmatrix/semantic-indexing-batch-02) + [protocol](https://github.com/whmatrix/universal-protocol-v4.23)
- **If you need dialogue-aware RAG:** Start with [comparative-grammar](https://github.com/whmatrix/comparative-grammar-gpt-vs-claude)
- **If you want proof it works on real data:** Start with [research-corpus-discovery](https://github.com/whmatrix/research-corpus-discovery)
- **If you want validation standards:** Start with [universal-protocol](https://github.com/whmatrix/universal-protocol-v4.23)

All repos include non-claims sections, stated limitations, runnable code where applicable, and cross-links to related work.

---

## Architecture Overview

See [ARCHITECTURE.md](./ARCHITECTURE.md) for the full system diagram, data flow, component responsibilities, and scale reference.

---

## Tech Stack

**Core:** Python, FAISS (IndexFlatIP), intfloat/e5-large-v2, PyTorch (FP16/CUDA)
**Infrastructure:** Protocol-driven validation, multi-scale indexing, checkpointing
**Analysis:** Dialogue grammar comparison, interaction primitives, dual-index retrieval

---

## Get Started

```bash
git clone https://github.com/whmatrix/research-corpus-discovery
cd research-corpus-discovery
pip install -r scripts/requirements.txt
python scripts/build_index.py --help
```

See [QUICK_START.md](https://github.com/whmatrix/research-corpus-discovery/blob/main/QUICK_START.md) for a walkthrough.

---

## Expected Output (Mini-Index Demo)

Running `demo_query.py` in [`semantic-indexing-batch-02/mini-index/`](https://github.com/whmatrix/semantic-indexing-batch-02/tree/main/mini-index) produces:

```
Query: 'machine learning and neural networks'
  [1] score=0.878  Neural Networks and Deep Learning...
      doc: doc_01_neural_networks.txt

Query: 'semantic search and vector retrieval'
  [1] score=0.879  Semantic Search and Dense Retrieval...
      doc: doc_03_semantic_search.txt

Query: 'how to build a FAISS index'
  [1] score=0.844  FAISS: Fast Similarity Search at Scale...
      doc: doc_04_faiss_indexing.txt
```

Scores above 0.83 indicate strong semantic alignment. The top-1 result matches the query topic in all cases. Run it yourself:

```bash
git clone https://github.com/whmatrix/semantic-indexing-batch-02
cd semantic-indexing-batch-02/mini-index
pip install sentence-transformers faiss-cpu
python demo_query.py
```

---

## By the Numbers

| Metric | Value | Source |
|--------|-------|--------|
| Vectors indexed | 9,016,688 | batch-01 (661K) + batch-02 (8.36M) |
| Datasets processed | 19 | batch-01 (6) + batch-02 (3) + research-corpus (10) |
| Research documents analyzed | 4,600+ | research-corpus-discovery |
| Institutions validated | 10 | research-corpus-discovery |
| Open-source repos | 9 | This portfolio |

See [`PORTFOLIO_MANIFEST.json`](./PORTFOLIO_MANIFEST.json) for itemized per-dataset vector counts and validation sources.

---

## Public Website

https://whmatrix.github.io
