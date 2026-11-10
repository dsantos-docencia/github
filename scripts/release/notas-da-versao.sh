#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · scripts/release/notas-da-versao.sh
#  Gera as notas de uma versão pela API (as mesmas do botão 'Generate release notes').
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
#  USO   notas-da-versao.sh DONO/REPO TAG [TAG-ANTERIOR] [--saida ARQUIVO]
#  Útil para revisar as notas ANTES de publicar, ou para um CHANGELOG.md.
#  Respeita o .github/release.yml do repositório (categorias por label).
# ============================================================================
set -euo pipefail

args=() saida=''
while (( $# )); do
    case "$1" in
        --saida) saida="${2:?--saida precisa de um arquivo}"; shift ;;
        *)       args+=("$1") ;;
    esac
    shift
done
repo="${args[0]:-}" tag="${args[1]:-}" anterior="${args[2]:-}"
[[ "$repo" == */* && -n "$tag" ]] || { echo "uso: $0 DONO/REPO TAG [TAG-ANTERIOR] [--saida ARQUIVO]" >&2; exit 2; }

campos=(-f tag_name="$tag")
[[ -n "$anterior" ]] && campos+=(-f previous_tag_name="$anterior")
# POST em generate-notes: só GERA o texto, não cria release nenhuma.
notas="$(gh api -X POST "repos/$repo/releases/generate-notes" "${campos[@]}" --jq .body)"

if [[ -n "$saida" ]]; then
    printf '## %s\n\n%s\n' "$tag" "$notas" > "$saida"
    echo "notas de $tag salvas em $saida"
else
    printf '%s\n' "$notas"
fi
