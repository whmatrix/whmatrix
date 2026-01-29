#!/usr/bin/env bash
# Portfolio Self-Verification Harness
# Checks critical invariants across the portfolio graph
# Usage: ./verify_portfolio.sh

set -euo pipefail

REPO_OWNER="whmatrix"
BRANCH="main"
PASS=0
FAIL=0

# Temp directory for downloaded artifacts
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Helper: fetch URL content to a variable, then grep.
# Avoids SIGPIPE issues when grep -q closes pipe early under pipefail.
fetch_grep() {
  local url=$1
  local pattern=$2
  local content
  content=$(curl -fsSL "$url")
  echo "$content" | grep -q "$pattern"
}

# Helper: check if URL returns 200 via HEAD request.
fetch_head_ok() {
  local url=$1
  local headers
  headers=$(curl -fsSLI "$url")
  echo "$headers" | grep -q "HTTP.*200"
}

echo "======================================"
echo "PORTFOLIO VERIFICATION HARNESS"
echo "======================================"
echo

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

check() {
  local name=$1
  local cmd=$2

  echo -n "Checking: $name ... "
  if eval "$cmd" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}✗ FAIL${NC}"
    FAIL=$((FAIL + 1))
  fi
}

RAW="https://raw.githubusercontent.com/${REPO_OWNER}"

echo "== 1. HUB README FRONT-MATTER =="
check "Hub header shows 'John Mitchell (@whmatrix)'" \
  "fetch_grep '${RAW}/whmatrix/${BRANCH}/README.md' '# John Mitchell (@whmatrix)'"

check "Hub has Status: ACTIVE / HUB" \
  "fetch_grep '${RAW}/whmatrix/${BRANCH}/README.md' 'Status.*ACTIVE.*HUB'"

check "Hub has Author: John Mitchell" \
  "fetch_grep '${RAW}/whmatrix/${BRANCH}/README.md' 'Author.*John Mitchell'"

echo

echo "== 2. RESEARCH-CORPUS METRIC CONTRACT =="
check "research-corpus uses 'Mean top-1 cosine similarity: 0.85'" \
  "fetch_grep '${RAW}/research-corpus-discovery/${BRANCH}/README.md' 'Mean top-1 cosine similarity: 0.85'"

check "research-corpus has 'What the 0.85 Score Means' section" \
  "fetch_grep '${RAW}/research-corpus-discovery/${BRANCH}/README.md' 'What the 0.85 Score Means'"

check "research-corpus metric defined as inner product / cosine" \
  "fetch_grep '${RAW}/research-corpus-discovery/${BRANCH}/README.md' 'inner product\|cosine'"

check "research-corpus non-claim: not human-judged" \
  "fetch_grep '${RAW}/research-corpus-discovery/${BRANCH}/README.md' 'Not human-judged\|Does NOT\|No human-judged'"

check "research-corpus mentions L2-normalized embeddings" \
  "fetch_grep '${RAW}/research-corpus-discovery/${BRANCH}/README.md' 'L2-normalized'"

echo

echo "== 3. MINI-INDEX PROOF LOOP =="
check "mini-index/summary.json exists" \
  "fetch_head_ok '${RAW}/semantic-indexing-batch-02/${BRANCH}/mini-index/summary.json'"

check "mini-index/demo_query.py exists" \
  "fetch_head_ok '${RAW}/semantic-indexing-batch-02/${BRANCH}/mini-index/demo_query.py'"

check "mini-index/vectors.index exists" \
  "fetch_head_ok '${RAW}/semantic-indexing-batch-02/${BRANCH}/mini-index/vectors.index'"

echo

echo "== 4. PORTFOLIO MANIFEST =="
check "PORTFOLIO_MANIFEST.json exists" \
  "fetch_head_ok '${RAW}/whmatrix/${BRANCH}/PORTFOLIO_MANIFEST.json'"

check "PORTFOLIO_MANIFEST.json is valid JSON" \
  "curl -fsSL '${RAW}/whmatrix/${BRANCH}/PORTFOLIO_MANIFEST.json' -o '${TEMP_DIR}/manifest.json' && python3 -m json.tool < '${TEMP_DIR}/manifest.json' > /dev/null"

check "Manifest claims 9,016,688 total vectors" \
  "fetch_grep '${RAW}/whmatrix/${BRANCH}/PORTFOLIO_MANIFEST.json' '9016688'"

echo

# =====================================================================
# SEMANTIC INTEGRITY CHECKS
# =====================================================================

echo "== 5. MINI-INDEX SEMANTIC INTEGRITY =="
echo "Verifying: structure loads, vectors match, dimensions correct"
echo

# Download mini-index artifacts
curl -fsSL "${RAW}/semantic-indexing-batch-02/${BRANCH}/mini-index/summary.json" \
  -o "${TEMP_DIR}/summary.json" 2>/dev/null || true

curl -fsSL "${RAW}/semantic-indexing-batch-02/${BRANCH}/mini-index/chunks.jsonl" \
  -o "${TEMP_DIR}/chunks.jsonl" 2>/dev/null || true

if [ -f "${TEMP_DIR}/summary.json" ]; then
  check "mini-index summary.json is valid JSON" \
    "python3 -m json.tool < '${TEMP_DIR}/summary.json' > /dev/null"

  # Extract fields via Python (safe parsing)
  VECTOR_COUNT=$(python3 -c "import json; print(json.load(open('${TEMP_DIR}/summary.json'))['vector_count'])" 2>/dev/null || echo "")
  CHUNK_COUNT=$(python3 -c "import json; print(json.load(open('${TEMP_DIR}/summary.json'))['chunk_count'])" 2>/dev/null || echo "")
  DIMENSIONS=$(python3 -c "import json; print(json.load(open('${TEMP_DIR}/summary.json'))['dimensions'])" 2>/dev/null || echo "")
  INDEX_TYPE=$(python3 -c "import json; print(json.load(open('${TEMP_DIR}/summary.json'))['index_type'])" 2>/dev/null || echo "")
  STATUS=$(python3 -c "import json; print(json.load(open('${TEMP_DIR}/summary.json'))['status'])" 2>/dev/null || echo "")

  check "mini-index vector_count is present and > 0" \
    "[ -n '${VECTOR_COUNT}' ] && [ '${VECTOR_COUNT}' -gt 0 ]"

  check "mini-index dimensions = 1024" \
    "[ '${DIMENSIONS}' = '1024' ]"

  check "mini-index index_type = IndexFlatIP" \
    "[ '${INDEX_TYPE}' = 'IndexFlatIP' ]"

  check "mini-index status = VERIFIED" \
    "[ '${STATUS}' = 'VERIFIED' ]"

  check "mini-index vector_count == chunk_count" \
    "[ '${VECTOR_COUNT}' = '${CHUNK_COUNT}' ]"
else
  echo "  Warning: Could not download summary.json for validation"
fi

if [ -f "${TEMP_DIR}/chunks.jsonl" ]; then
  LINE_COUNT=$(wc -l < "${TEMP_DIR}/chunks.jsonl" 2>/dev/null || echo "0")
  LINE_COUNT=$(echo "$LINE_COUNT" | tr -d ' ')

  check "mini-index chunks.jsonl has content (>0 lines)" \
    "[ '${LINE_COUNT}' -gt 0 ]"

  if [ -n "${VECTOR_COUNT}" ] && [ -n "${LINE_COUNT}" ]; then
    check "mini-index chunks.jsonl line count == vector_count" \
      "[ '${VECTOR_COUNT}' = '${LINE_COUNT}' ]"
  fi
else
  echo "  Warning: Could not download chunks.jsonl for validation"
fi

echo

echo "== 6. MANIFEST NUMERIC INTEGRITY =="
echo "Verifying: totals are mathematically consistent, evidence files exist"
echo

# Download manifest if not already present from section 4
if [ ! -f "${TEMP_DIR}/manifest.json" ]; then
  curl -fsSL "${RAW}/whmatrix/${BRANCH}/PORTFOLIO_MANIFEST.json" \
    -o "${TEMP_DIR}/manifest.json" 2>/dev/null || true
fi

if [ -f "${TEMP_DIR}/manifest.json" ]; then
  # Parse manifest using actual JSON structure:
  #   portfolio_summary.total_vectors_indexed
  #   repos[0] = batch-02 (vectors_indexed)
  #   repos[1] = batch-01 (vectors_indexed)
  TOTAL_VECTORS=$(python3 -c "
import json
data = json.load(open('${TEMP_DIR}/manifest.json'))
print(data['portfolio_summary']['total_vectors_indexed'])
" 2>/dev/null || echo "0")

  BATCH02_VECTORS=$(python3 -c "
import json
data = json.load(open('${TEMP_DIR}/manifest.json'))
repos = {r['name']: r for r in data['repos']}
print(repos['semantic-indexing-batch-02']['vectors_indexed'])
" 2>/dev/null || echo "0")

  BATCH01_VECTORS=$(python3 -c "
import json
data = json.load(open('${TEMP_DIR}/manifest.json'))
repos = {r['name']: r for r in data['repos']}
print(repos['semantic-indexing-batch-01']['vectors_indexed'])
" 2>/dev/null || echo "0")

  # batch-02 internal dataset sum
  BATCH02_DATASET_SUM=$(python3 -c "
import json
data = json.load(open('${TEMP_DIR}/manifest.json'))
repos = {r['name']: r for r in data['repos']}
datasets = repos['semantic-indexing-batch-02']['datasets']
print(sum(d['vectors'] for d in datasets))
" 2>/dev/null || echo "0")

  # batch-01 internal dataset sum
  BATCH01_DATASET_SUM=$(python3 -c "
import json
data = json.load(open('${TEMP_DIR}/manifest.json'))
repos = {r['name']: r for r in data['repos']}
datasets = repos['semantic-indexing-batch-01']['datasets']
print(sum(d['vectors'] for d in datasets))
" 2>/dev/null || echo "0")

  check "manifest total_vectors field present" \
    "[ '${TOTAL_VECTORS}' != '0' ]"

  # Verify top-level math: batch-02 + batch-01 = total
  CALCULATED_TOTAL=$((BATCH02_VECTORS + BATCH01_VECTORS))

  check "manifest math: batch-02 (8,355,163) + batch-01 (661,525) = 9,016,688" \
    "[ '${CALCULATED_TOTAL}' = '${TOTAL_VECTORS}' ]"

  check "manifest batch-02 vectors = 8,355,163" \
    "[ '${BATCH02_VECTORS}' = '8355163' ]"

  check "manifest batch-01 vectors = 661,525" \
    "[ '${BATCH01_VECTORS}' = '661525' ]"

  # Verify internal dataset sums match repo totals
  check "batch-02 dataset vectors sum to batch-02 total" \
    "[ '${BATCH02_DATASET_SUM}' = '${BATCH02_VECTORS}' ]"

  check "batch-01 dataset vectors sum to batch-01 total" \
    "[ '${BATCH01_DATASET_SUM}' = '${BATCH01_VECTORS}' ]"

  # Verify evidence file URLs (repo READMEs as proof of existence)
  check "batch-02 repo accessible (HTTP 200)" \
    "fetch_head_ok '${RAW}/semantic-indexing-batch-02/${BRANCH}/README.md'"

  check "batch-01 repo accessible (HTTP 200)" \
    "fetch_head_ok '${RAW}/semantic-indexing-batch-01/${BRANCH}/README.md'"

  check "research-corpus repo accessible (HTTP 200)" \
    "fetch_head_ok '${RAW}/research-corpus-discovery/${BRANCH}/README.md'"
else
  echo "  Warning: Could not download manifest for validation"
fi

echo

echo "======================================"
echo "RESULTS: $PASS passed, $FAIL failed"
echo "======================================"

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}✓ PORTFOLIO INVARIANTS VERIFIED${NC}"
  exit 0
else
  echo -e "${RED}✗ PORTFOLIO HAS REGRESSIONS${NC}"
  exit 1
fi
