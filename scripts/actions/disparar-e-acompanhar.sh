#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · scripts/actions/disparar-e-acompanhar.sh
#  Dispara um workflow manual e acompanha até o fim, saindo com o resultado.
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
#  USO   disparar-e-acompanhar.sh WORKFLOW [-R DONO/REPO] [--ref BRANCH] [-f chave=valor]...
#  ex.:  disparar-e-acompanhar.sh relatorio.yml -f dias=3
#  O workflow precisa ter "on: workflow_dispatch". Sai com 0 só se a execução passar.
# ============================================================================
set -euo pipefail

ESPERA="${ESPERA:-4}"     # segundos para a execução aparecer na lista (a API é assíncrona)
workflow='' repo=() ref=() campos=()
while (( $# )); do
    case "$1" in
        -R)    repo=(-R "${2:?-R precisa de DONO/REPO}"); shift ;;
        --ref) ref=(--ref "${2:?--ref precisa de uma branch}"); shift ;;
        -f)    campos+=(-f "${2:?-f precisa de chave=valor}"); shift ;;
        -*)    echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)     workflow="$1" ;;
    esac
    shift
done
[[ -n "$workflow" ]] || { echo "uso: $0 WORKFLOW [-R DONO/REPO] [--ref BRANCH] [-f chave=valor]..." >&2; exit 2; }

inicio="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
gh workflow run "$workflow" "${repo[@]}" "${ref[@]}" "${campos[@]}"
echo "▶ disparado: $workflow — aguardando a execução aparecer…"
sleep "$ESPERA"

# A execução mais recente desse workflow, disparada manualmente, criada depois do início.
id="$(gh run list --workflow "$workflow" "${repo[@]}" --event workflow_dispatch --limit 5 \
        --json databaseId,createdAt --jq "[.[] | select(.createdAt >= \"$inicio\")][0].databaseId // empty")"
[[ -n "$id" ]] || { echo "✘ não encontrei a execução (tente ESPERA=10)" >&2; exit 1; }

echo "👀 acompanhando a execução $id"
gh run watch "$id" "${repo[@]}" --exit-status
