# System Architecture

## High-Level Data Flow

```
                    INPUT LAYER
                        |
        +---------------+---------------+
        |               |               |
      PDFs          Raw Text        JSONL/Parquet
        |               |               |
        +---------------+---------------+
                        |
                   ACQUISITION
                        |
              pdftotext / direct load
                        |
                   CHUNKING LAYER
                        |
        +---------------+---------------+
        |               |               |
    Section-Aware   Paragraph       Overlap
    Boundaries      Boundaries      Strategy
        |               |               |
        +---------------+---------------+
                        |
                  EMBEDDING LAYER
                        |
              intfloat/e5-large-v2
          (1024-dim vectors, FP16, GPU)
                        |
                   INDEXING LAYER
                        |
        +---------------+---------------+
        |               |               |
    IndexFlatIP     Checkpointing   Metadata
    (exact search)  (every 1M vecs)  (JSONL)
        |               |               |
        +---------------+---------------+
                        |
                   OUTPUT ARTIFACTS
                        |
        +---------------+---------------+
        |               |               |
      FAISS          chunks.jsonl   index_report.json
      Index          metadata.jsonl  (build manifest)
        |               |               |
        +---------------+---------------+
```

## Query Flow

```
    User Query
         |
         +-> Prefix with "query: " (asymmetric encoding)
         |
         +-> Embed with e5-large-v2
         |
         +-> Search FAISS IndexFlatIP
         |   (top-K nearest neighbors by inner product)
         |
         +-> Retrieve chunk metadata
         |   (doc ID, title, year, section, score)
         |
         +-> Format results
         |   (score, source document, text snippet)
         |
         +-> Return to user
```

## Component Responsibilities

### Acquisition Module
- PDF text extraction via `pdftotext -layout`
- SHA-256 hashing for document identity
- Metadata parsing (title, year, DOI from first page)
- Quality classification (empty / low / ok)
- Skip list support for known-bad PDFs

### Chunking Module
- Section-aware splitting using academic header patterns
- Paragraph-boundary alignment (no mid-sentence splits)
- Configurable target size (default 800 tokens)
- Configurable overlap (default 100 tokens)
- Minimum chunk threshold (default 200 tokens)
- Token estimation at 1 token ~ 4 characters

### Embedding Module
- `intfloat/e5-large-v2` (1024-dimensional dense vectors)
- FP16 precision on GPU (< 3 GB VRAM envelope)
- `"passage: "` prefix for document chunks
- `"query: "` prefix for search queries (asymmetric)
- Batch size 1300 (locked, auto-reduces on OOM in batch-02)
- L2-normalized for cosine similarity via inner product

### Indexing Module
- FAISS `IndexFlatIP` (exact inner product search)
- 1:1:1 alignment: vectors <-> chunks <-> metadata
- Integrity verification on every build
- Checkpointing every 1M vectors (batch-02 scale)
- Atomic writes via `.tmp` file swaps (batch-02)

### Query Module
- Same embedding model as build (asymmetric `query:` prefix)
- Configurable top-K results
- GPU preferred, CPU fallback for query-only use
- Output formats: terminal display, JSON

---

## Repository Map

```
universal-protocol-v4.23          <- Spec (what "done" looks like)
        |
        +-> semantic-indexing-batch-01   <- Foundation (661K vectors, 6 datasets)
        |
        +-> semantic-indexing-batch-02   <- Production (8.35M vectors, 3 datasets)
        |       |
        |       +-> Split-merge pattern (5 parallel indexers)
        |       +-> RAM/GPU balancers, signal handling
        |       +-> Checkpointing, atomic writes
        |
        +-> research-corpus-discovery    <- Applied (10 institutions, 4,600+ docs)
                |
                +-> Runnable scripts (build + query)
                +-> Anonymized case studies
                +-> Methodology documentation
```

---

## Scale Reference

| Repository | Vectors | Datasets | Index Type | Notes |
|------------|---------|----------|------------|-------|
| batch-01 | 661,525 | 6 (20 Newsgroups, SimpleWiki, IMDB, StackOverflow, AG News, Disaster Tweets) | IndexFlatIP | Foundational proof |
| batch-02 | 8,355,163 | 3 (Wikipedia, StackExchange, ArXiv) | IndexFlatIP | Production scale |
| research-corpus-discovery | ~75,000 | 10 institutional corpora | IndexFlatIP | Applied methodology |

**Combined: 9M+ vectors indexed across 19 datasets and 10 institutions.**

---

## Validation Pipeline

```
Input Documents
    |
    +-> Format check (PDF native text layer)
    +-> Encoding check (UTF-8 extraction)
    +-> Extraction quality (empty / low / ok)
    |
    +-> Chunk + Embed + Index
    |
    +-> Vector count == chunk count (1:1 alignment)
    +-> No null vectors
    +-> Build report with statistics
    |
    +-> PASS -> Artifact output
```

See [universal-protocol-v4.23](https://github.com/whmatrix/universal-protocol-v4.23) for deliverable contracts and audit checkpoints.

---

## Protocols & Standards

The [Universal Protocol v4.23](https://github.com/whmatrix/universal-protocol-v4.23) defines:
- Deliverable structure (chunks.jsonl, metadata.jsonl, vectors.index, summary.json)
- 1:1:1 alignment requirements (vectors <-> chunks <-> metadata)
- Audit checkpoints and pass/fail gates
- Standardized build reports
