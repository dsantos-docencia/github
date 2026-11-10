#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · scripts/actions/limpar-caches.sh
#  Remove caches do Actions que só ocupam espaço (de PRs e antigos).
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
#  USO   limpar-caches.sh DONO/REPO [--dias N] [--aplicar]
#  Candidatos: caches de refs/pull/* (morrem com o PR) e caches sem uso há N
#  dias (padrão 7). SIMULA por padrão; só apaga com --aplicar.
# ============================================================================
set -euo pipefail

repo='' dias=7 aplicar=0
while (( $# )); do
    case "$1" in
        --dias)    dias="${2:?--dias precisa de um número}"; shift ;;
        --aplicar) aplicar=1 ;;
        -*)        echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)         repo="$1" ;;
    esac
    shift
done
[[ -n "$repo" && "$dias" =~ ^[0-9]+$ ]] || { echo "uso: $0 DONO/REPO [--dias N] [--aplicar]" >&2; exit 2; }

limite="$(date -u -d "$dias days ago" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-"${dias}"d +%Y-%m-%dT%H:%M:%SZ)"
total=0 bytes=0
while IFS=$'\t' read -r id chave tamanho; do
    [[ -n "$id" ]] || continue
    total=$((total + 1)); bytes=$((bytes + tamanho))
    if (( aplicar )); then
        gh cache delete "$id" -R "$repo" && echo "🗑 $chave"
    else
        echo "· apagaria: $chave ($((tamanho / 1048576)) MB)"
    fi
done < <(gh cache list -R "$repo" --limit 1000 --json id,key,ref,sizeInBytes,lastAccessedAt \
          --jq ".[] | select((.ref | startswith(\"refs/pull/\")) or .lastAccessedAt < \"$limite\") | \"\(.id)\t\(.key)\t\(.sizeInBytes)\"")

echo "$total cache(s), $((bytes / 1048576)) MB $( (( aplicar )) && echo removidos || echo 'seriam liberados (use --aplicar)')"
