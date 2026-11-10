#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 06.03 — Auditoria das regras de uma branch · SOLUÇÃO COMENTADA
set -euo pipefail

repo="${1:?uso: $0 <dono/repo> [branch]}"
branch="${2:-main}"
regras="$(gh api "repos/$repo/rules/branches/$branch")"

faltou=0
for tipo in deletion non_fast_forward pull_request required_status_checks; do
    # any(): verdadeiro se ALGUM elemento tem esse type. -e: status 0/1 conforme o resultado.
    if jq -e --arg t "$tipo" 'any(.[]; .type == $t)' >/dev/null <<<"$regras"; then
        echo "✔ $tipo"
    else
        echo "✘ $tipo"; faltou=1
    fi
done
exit "$faltou"
