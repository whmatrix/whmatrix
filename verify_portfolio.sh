#!/usr/bin/env bash
# Portfolio Self-Verification Harness
# Checks critical invariants across the portfolio graph
# Usage: ./verify_portfolio.sh

set -euo pipefail

REPO_OWNER="whmatrix"
BRANCH="main"
PASS=0
FAIL=0

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
    ((PASS++))
  else
    echo -e "${RED}✗ FAIL${NC}"
    ((FAIL++))
  fi
}

echo "== 1. HUB README FRONT-MATTER =="
check "Hub header shows 'John Mitchell (@whmatrix)'" \
  'curl -fsSL "https://raw.githubusercontent.com/'$REPO_OWNER'/whmatrix/'$BRANCH'/README.md" | grep -q "# John Mitchell (@whmatrix)"'

check "Hub has Status: ACTIVE / HUB" \
  'curl -fsSL "https://raw.githubusercontent.com/'$REPO_OWNER'/whmatrix/'$BRANCH'/README.md" | grep -q "Status.*ACTIVE.*HUB"'

check "Hub has Author: John Mitchell" \
  'curl -fsSL "https://raw.githubusercontent.com/'$REPO_OWNER'/whmatrix/'$BRANCH'/README.md" | grep -q "Author.*John Mitchell"'

echo

echo "== 2. RESEARCH-CORPUS METRIC CONTRACT =="
check "research-corpus uses 'Mean top-1 cosine similarity: 0.85'" \
  'curl -fsSL "https://raw.githubusercontent.com/'$REPO_OWNER'/research-corpus-discovery/'$BRANCH'/README.md" | grep -q "Mean top-1 cosine similarity: 0.85"'

check "research-corpus has 'What the 0.85 Score Means' section" \
  'curl -fsSL "https://raw.githubusercontent.com/'$REPO_OWNER'/research-corpus-discovery/'$BRANCH'/README.md" | grep -q "What the 0.85 Score Means"'

check "research-corpus metric defined as inner product / cosine" \
  'curl -fsSL "https://raw.githubusercontent.com/'$REPO_OWNER'/research-corpus-discovery/'$BRANCH'/README.md" | grep -q "inner product\|cosine"'

check "research-corpus non-claim: not human-judged" \
  'curl -fsSL "https://raw.githubusercontent.com/'$REPO_OWNER'/research-corpus-discovery/'$BRANCH'/README.md" | grep -q "not human-judged\|does NOT"'

check "research-corpus mentions L2-normalized embeddings" \
  'curl -fsSL "https://raw.githubusercontent.com/'$REPO_OWNER'/research-corpus-discovery/'$BRANCH'/README.md" | grep -q "L2-normalized"'

echo

echo "== 3. MINI-INDEX PROOF LOOP =="
check "mini-index/summary.json exists" \
  'curl -fsSLI "https://raw.githubusercontent.com/'$REPO_OWNER'/semantic-indexing-batch-02/'$BRANCH'/mini-index/summary.json" | grep -q "HTTP.*200"'

check "mini-index/demo_query.py exists" \
  'curl -fsSLI "https://raw.githubusercontent.com/'$REPO_OWNER'/semantic-indexing-batch-02/'$BRANCH'/mini-index/demo_query.py" | grep -q "HTTP.*200"'

check "mini-index/vectors.index exists" \
  'curl -fsSLI "https://raw.githubusercontent.com/'$REPO_OWNER'/semantic-indexing-batch-02/'$BRANCH'/mini-index/vectors.index" | grep -q "HTTP.*200"'

echo

echo "== 4. PORTFOLIO MANIFEST =="
check "PORTFOLIO_MANIFEST.json exists" \
  'curl -fsSLI "https://raw.githubusercontent.com/'$REPO_OWNER'/whmatrix/'$BRANCH'/PORTFOLIO_MANIFEST.json" | grep -q "HTTP.*200"'

check "PORTFOLIO_MANIFEST.json is valid JSON" \
  'curl -fsSL "https://raw.githubusercontent.com/'$REPO_OWNER'/whmatrix/'$BRANCH'/PORTFOLIO_MANIFEST.json" | python3 -m json.tool > /dev/null'

check "Manifest claims 9,016,688 total vectors" \
  'curl -fsSL "https://raw.githubusercontent.com/'$REPO_OWNER'/whmatrix/'$BRANCH'/PORTFOLIO_MANIFEST.json" | grep -q "9016688"'

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
