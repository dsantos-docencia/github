#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 02.03 — Inventário dos repositórios de uma conta · SOLUÇÃO COMENTADA
set -euo pipefail

dono="${1:?uso: $0 <usuario-ou-org>}"
# Uma única chamada; o JSON fica numa variável e o jq conta três vezes.
json="$(gh repo list "$dono" --limit 1000 --json name,isPrivate,isArchived)"
printf 'públicos: %s\n'   "$(jq 'map(select(.isPrivate | not)) | length' <<<"$json")"
printf 'privados: %s\n'   "$(jq 'map(select(.isPrivate)) | length' <<<"$json")"
printf 'arquivados: %s\n' "$(jq 'map(select(.isArchived)) | length' <<<"$json")"
