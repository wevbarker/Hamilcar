#!/usr/bin/env bash
set -euo pipefail

# Non-interactive test script to check vim behavior

echo "Testing Vim launch (non-interactive)..."
echo "Current VIRTUAL_ENV: ${VIRTUAL_ENV:-<not set>}"
echo ""

# Create test file
echo "Test prompt content" > /tmp/test-hasdrubal.txt

echo "=== Test 1: vim --version with venv active ==="
vim --version 2>&1 | head -5
echo ""

echo "=== Test 2: Check Python in vim ==="
vim --version 2>&1 | grep -i python
echo ""

echo "=== Test 3: Try to start vim and quit immediately ==="
echo "Launching: vim -c 'quit' /tmp/test-hasdrubal.txt"
vim -c 'quit' /tmp/test-hasdrubal.txt 2>&1
echo "Exit code: $?"
echo ""

echo "=== Test 4: Same but with bash -lc ==="
echo "Launching: bash -lc 'vim -c quit /tmp/test-hasdrubal.txt'"
bash -lc "vim -c 'quit' /tmp/test-hasdrubal.txt" 2>&1
echo "Exit code: $?"
echo ""

echo "=== Test 5: With clean environment ==="
env -i HOME="$HOME" TERM="$TERM" SHELL="$SHELL" vim -c 'quit' /tmp/test-hasdrubal.txt 2>&1
echo "Exit code: $?"

echo ""
echo "Tests complete!"
