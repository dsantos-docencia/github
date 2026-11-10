#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · scripts/dia-a-dia/minha-fila.sh
#  O que está esperando por você: revisões pedidas, PRs seus e issues atribuídos.
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
#  USO   minha-fila.sh [--org ORG]      (sem --org: tudo o que você enxerga)
# ============================================================================
set -euo pipefail

escopo=()
[[ "${1:-}" == "--org" ]] && escopo=(--owner "${2:?--org precisa de um nome}")

secao() {   # secao TÍTULO comando...
    local titulo="$1"; shift
    local linhas
    linhas="$("$@" --json number,title,repository,updatedAt \
        --jq 'sort_by(.updatedAt) | .[] | "  \(.repository.nameWithOwner)#\(.number)  \(.title)"')"
    printf '\n%s (%d)\n' "$titulo" "$(grep -c . <<<"$linhas" || true)"
    [[ -n "$linhas" ]] && printf '%s\n' "$linhas"
    return 0
}
secao "👀 Revisões pedidas a você"  gh search prs --review-requested=@me --state=open "${escopo[@]}"
secao "🚧 Seus PRs abertos"          gh search prs --author=@me --state=open "${escopo[@]}"
secao "📌 Issues atribuídos a você"  gh search issues --assignee=@me --state=open "${escopo[@]}"
