#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 06 · Lendo os rulesets de um repositório
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  listar rulesets, ver os detalhes de um e descobrir o que vale de fato numa branch
#  EXECUTE   bash modulos/06-protecao-e-rulesets/exemplos/01-ler-rulesets.sh
#            GH_REAL=1 LAB_REPO=seu-usuario/lab-github bash modulos/06-protecao-e-rulesets/exemplos/01-ler-rulesets.sh   (GitHub de verdade)
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

passo "Rulesets do repositório"
mostra gh ruleset list -R "$LAB_REPO"

passo "O mesmo pela API, em formato que dá para processar"
mostra gh api "repos/$LAB_REPO/rulesets" --jq '.[] | "\(.id)\t\(.target)\t\(.enforcement)\t\(.name)"'

passo "Detalhes do primeiro ruleset: quais regras ele tem?"
id="$(gh api "repos/$LAB_REPO/rulesets" --jq '.[0].id // empty')"
if [[ -n "$id" ]]; then
    mostra gh api "repos/$LAB_REPO/rulesets/$id" --jq '[.rules[].type] | join(", ")'
else
    echo "(nenhum ruleset ainda — crie um com o exemplo 02)"
fi

passo "O que vale de fato na branch main (somando TODAS as fontes)"
mostra gh api "repos/$LAB_REPO/rules/branches/main" --jq '.[] | "\(.type)  ← ruleset \(.ruleset_id)"'
