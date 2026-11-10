#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 05.01 — Checklist de saúde da comunidade · SOLUÇÃO COMENTADA
set -euo pipefail

raiz="${1:-.}"
[[ -d "$raiz" ]] || { echo "erro: pasta não encontrada: $raiz" >&2; exit 2; }

# existe NOME... → procura cada nome nas três pastas aceitas pelo GitHub.
existe() {
    local nome lugar
    for nome in "$@"; do
        for lugar in "$raiz" "$raiz/docs" "$raiz/.github"; do
            [[ -e "$lugar/$nome" ]] && return 0
        done
    done
    return 1
}

nota=0
verificar() {   # verificar ITEM NOME...
    local item="$1"; shift
    if existe "$@"; then echo "✔ $item"; nota=$((nota + 1)); else echo "✘ $item"; fi
}
verificar README          README.md
verificar LICENSE         LICENSE LICENSE.md
verificar CONTRIBUTING    CONTRIBUTING.md
verificar CODE_OF_CONDUCT CODE_OF_CONDUCT.md
verificar SECURITY        SECURITY.md
verificar ISSUE_TEMPLATE  ISSUE_TEMPLATE
verificar PR_TEMPLATE     pull_request_template.md PULL_REQUEST_TEMPLATE.md
echo "nota: $nota/7"
(( nota == 7 ))
