#!/bin/ksh
set -eu

codex --version
codex login status
codex features list | grep -E \
    '^code_mode_host[[:space:]]+stable[[:space:]]+true$'
[ -x /usr/local/bin/codex-code-mode-host ]
[ -x /usr/local/libexec/codex/codex-code-mode-host ]

echo "Offline checks passed."
echo "For an authenticated file-edit test, run:"
echo "  mkdir -p /tmp/codex-smoke && cd /tmp/codex-smoke"
echo "  codex exec --skip-git-repo-check 'Create hello.txt containing hello world.'"
