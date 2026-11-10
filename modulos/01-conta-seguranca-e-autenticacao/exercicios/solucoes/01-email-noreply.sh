#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 01.01 — E-mail noreply nos commits · SOLUÇÃO COMENTADA
set -euo pipefail

id="${1:-}" usuario="${2:-}"
if [[ -z "$id" || -z "$usuario" ]]; then
    echo "uso: $0 <id-numérico> <usuario>   (descubra com: gh api user --jq .id)" >&2
    exit 2
fi
# =~ com âncoras: a string INTEIRA precisa ser dígitos.
if ! [[ "$id" =~ ^[0-9]+$ ]]; then
    echo "erro: o ID precisa ser numérico (recebi '$id')" >&2
    exit 1
fi
git init -q -b main projeto
git -C projeto config --local user.name "$usuario"
git -C projeto config --local user.email "$id+$usuario@users.noreply.github.com"
