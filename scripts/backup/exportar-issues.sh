#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · scripts/backup/exportar-issues.sh
#  Exporta todos os issues (abertos e fechados) para JSON e um índice em Markdown.
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
#  USO   exportar-issues.sh DONO/REPO [PASTA]
#  Gera PASTA/issues.json (dados completos, reimportáveis por script) e
#  PASTA/issues.md (índice legível). Issues são dados do GitHub, não do Git:
#  NÃO vêm num git clone — por isso merecem backup próprio.
# ============================================================================
set -euo pipefail

repo="${1:-}"
[[ "$repo" == */* ]] || { echo "uso: $0 DONO/REPO [PASTA]" >&2; exit 2; }
destino="${2:-backup-issues-${repo//\//-}-$(date +%F)}"
mkdir -p -- "$destino"

gh issue list -R "$repo" --state all --limit 100000 \
    --json number,title,state,labels,author,assignees,createdAt,closedAt,body,comments,url \
    > "$destino/issues.json"

{
    echo "# Issues de $repo — exportado em $(date +%F)"
    echo
    echo "| # | Estado | Título | Labels | Autor |"
    echo "|---|---|---|---|---|"
    jq -r 'sort_by(.number) | .[] |
        "| [\(.number)](\(.url)) | \(.state | ascii_downcase) | \(.title | gsub("\\|"; "\\|")) | \([.labels[].name] | join(", ")) | @\(.author.login) |"' \
        "$destino/issues.json"
} > "$destino/issues.md"

echo "$(jq length "$destino/issues.json") issues exportados para $destino/"
