#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 02 · Lendo os metadados de um repositório
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  consultar visibilidade, licença, tópicos e configurações pelo gh e pela API REST
#  EXECUTE   bash modulos/02-repositorios/exemplos/02-ler-metadados.sh
#            GH_REAL=1 LAB_REPO=seu-usuario/lab-github bash modulos/02-repositorios/exemplos/02-ler-metadados.sh   (GitHub de verdade)
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

passo "Visão rápida com gh repo view --json"
mostra gh repo view "$LAB_REPO" --json nameWithOwner,visibility,defaultBranchRef,licenseInfo \
    --jq '"\(.nameWithOwner) · \(.visibility) · branch \(.defaultBranchRef.name) · licença \(.licenseInfo.name // "nenhuma")"'

passo "Tópicos"
mostra gh repo view "$LAB_REPO" --json repositoryTopics --jq '[.repositoryTopics[].name] | join(", ")'

passo "Configurações de merge pela API REST (campos que o repo view não mostra)"
mostra gh api "repos/$LAB_REPO" --jq '{squash: .allow_squash_merge, merge: .allow_merge_commit, rebase: .allow_rebase_merge, apaga_branch: .delete_branch_on_merge}'
