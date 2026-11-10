#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 11 · Paginação: o bug mais comum
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  ver a diferença entre pedir uma página e seguir todas com --paginate, e checar o limite de requisições
#  EXECUTE   bash modulos/11-automacao-com-gh-e-api/exemplos/01-paginacao.sh
#            GH_REAL=1 LAB_REPO=seu-usuario/lab-github bash modulos/11-automacao-com-gh-e-api/exemplos/01-paginacao.sh   (GitHub de verdade)
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

passo "Quanto ainda posso chamar nesta hora?"
mostra gh api rate_limit --jq '.resources.core | "\(.remaining)/\(.limit) restantes"'

passo "Uma página só (padrão: 30 itens) — o jeito ERRADO de contar"
mostra gh api "repos/$LAB_REPO/issues?state=all" --jq 'length'

passo "Todas as páginas, 100 por vez — o jeito certo"
mostra gh api --paginate "repos/$LAB_REPO/issues?state=all&per_page=100" --jq '.[].number' | wc -l

passo "Juntando tudo num array só (--slurp) para processar com o jq local"
gh api --paginate --slurp "repos/$LAB_REPO/issues?state=all&per_page=100" 2>/dev/null \
    | jq 'if type=="array" and (.[0]|type)=="array" then add else . end | map(.title) | .[:3]' \
    || echo "(--slurp exige gh 2.48+)"
