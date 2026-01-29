#!/usr/bin/env bash
# Portfolio Self-Verification Harness
# Checks critical invariants across the portfolio graph
# Usage: ./verify_portfolio.sh

set -euo pipefail

REPO_OWNER="whmatrix"
BRANCH="main"
PASS=0
FAIL=0

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
  "fetch_grep '${RAW}/whmatrix/${BRANCH}/PORTFOLIO_MANIFEST.json' '.' && curl -fsSL '${RAW}/whmatrix/${BRANCH}/PORTFOLIO_MANIFEST.json' | python3 -m json.tool > /dev/null 2>&1"

check "Manifest claims 9,016,688 total vectors" \
  "fetch_grep '${RAW}/whmatrix/${BRANCH}/PORTFOLIO_MANIFEST.json' '9016688'"

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
