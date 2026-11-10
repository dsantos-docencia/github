#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 02.02 — Configurar o repositório pelo terminal · SOLUÇÃO COMENTADA
set -euo pipefail

repo="${1:-}"
# Formato dono/repo: um "/" separando duas partes não vazias, sem espaços.
if ! [[ "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
    echo "uso: $0 <dono/repo>" >&2
    exit 2
fi
gh repo edit "$repo" \
    --add-topic curso --add-topic github \
    --enable-merge-commit=false --enable-squash-merge \
    --delete-branch-on-merge \
    --enable-wiki=false
