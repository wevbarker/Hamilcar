#!/usr/bin/env bash
set -euo pipefail

# Test script to debug Vim launching issues
# This simulates what hasdrubal does when launching vim

echo "Testing Vim launch..."
echo "Current VIRTUAL_ENV: ${VIRTUAL_ENV:-<not set>}"
echo "Current PATH: $PATH"
echo ""

# Try different approaches
echo "=== Test 1: Direct vim launch ==="
vim --version | head -2
echo ""

echo "=== Test 2: Launch vim with a file (will exit immediately) ==="
echo "Test content" > /tmp/test-vim-launch.txt
vim -c 'quit' /tmp/test-vim-launch.txt 2>&1 || echo "Exit code: $?"
echo ""

echo "=== Test 3: Check if vim has python3 support ==="
vim --version | grep -i python || echo "No Python support found"
echo ""

echo "=== Test 4: Launch vim in clean environment ==="
env -i HOME="$HOME" TERM="$TERM" SHELL="$SHELL" bash -lc 'vim --version | head -2'
echo ""

echo "=== Test 5: Launch with bash -lc (what hasdrubal uses) ==="
bash -lc 'vim --version | head -2'
echo ""

echo "All tests complete. Now testing actual vim launch with .PROMPT.txt..."
echo "Sample prompt" > .PROMPT.txt
echo "Launching vim... (press :q to exit)"
bash -lc 'vim .PROMPT.txt'
