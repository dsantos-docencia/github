#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 11 · Uma consulta GraphQL
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  buscar contagens de issues e PRs numa única ida à API, com variáveis tipadas
#  EXECUTE   bash modulos/11-automacao-com-gh-e-api/exemplos/02-graphql.sh
#            GH_REAL=1 LAB_REPO=seu-usuario/lab-github bash modulos/11-automacao-com-gh-e-api/exemplos/02-graphql.sh   (GitHub de verdade)
# ============================================================================
set -euo pipefail
CURSO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../.." && pwd)"

# --- Laboratório descartável --------------------------------------------------
# Pasta temporária apagada ao final; Git isolado (não lê nem altera o seu
# ~/.gitconfig); identidade fixa para os commits de demonstração.
LAB="$(mktemp -d)"; trap 'rm -rf -- "$LAB"' EXIT; cd "$LAB"
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL="$LAB/.gitconfig-lab" GIT_PAGER=cat
export GIT_AUTHOR_NAME='Ana Dev' GIT_AUTHOR_EMAIL='ana@exemplo.dev'
export GIT_COMMITTER_NAME='Ana Dev' GIT_COMMITTER_EMAIL='ana@exemplo.dev'
git config --global init.defaultBranch main
git config --global advice.detachedHead false

# --- gh: simulado por padrão; o de verdade com GH_REAL=1 ---------------------
# Simulado = offline, sem conta, nada é criado; cada chamada fica registrada.
if [[ "${GH_REAL:-0}" == 1 ]]; then
    : "${LAB_REPO:?defina LAB_REPO=seu-usuario/lab-github (veja laboratorio/)}"
    gh auth status >/dev/null 2>&1 || { echo "rode 'gh auth login' antes" >&2; exit 1; }
else
    # shellcheck source=/dev/null
    source "$CURSO/ferramentas/lib/gh-simulado.sh"
    LAB_REPO='aluno/laboratorio'
fi
passo()  { printf '\n== %s ==\n' "$*"; }
# mostra: exibe o comando (com aspas só onde precisa) e depois o executa
mostra() {
    local a linha='$'
    for a in "$@"; do
        if [[ "$a" =~ [^A-Za-z0-9_./:=@,+%-] ]]; then
            if [[ "$a" == *"'"* || "$a" == *$'\n'* ]]; then printf -v a '%q' "$a"; else a="'$a'"; fi
        fi
        linha+=" $a"
    done
    printf '%s\n' "$linha"; "$@"
}

dono="${LAB_REPO%/*}" nome="${LAB_REPO#*/}"
consulta='
query($dono: String!, $nome: String!) {
  viewer { login repositories { totalCount } }
  repository(owner: $dono, name: $nome) {
    issues(states: OPEN) { totalCount }
    pullRequests(states: OPEN) { totalCount }
  }
}'
passo "A consulta"
echo "$consulta"

passo "Uma chamada, tudo de uma vez"
echo '$ gh api graphql -F dono="$dono" -F nome="$nome" -f query="$consulta" --jq …'
gh api graphql -F dono="$dono" -F nome="$nome" -f query="$consulta" \
    --jq '"\(.data.viewer.login) tem \(.data.viewer.repositories.totalCount) repositórios; \(.data.repository.issues.totalCount) issues e \(.data.repository.pullRequests.totalCount) PRs abertos no laboratório"'
