#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 05 · Saúde da comunidade pela API
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  ler a nota de saúde da comunidade e descobrir quais arquivos faltam no repositório
#  EXECUTE   bash modulos/05-forks-e-open-source/exemplos/02-saude-da-comunidade.sh
#            GH_REAL=1 LAB_REPO=seu-usuario/lab-github bash modulos/05-forks-e-open-source/exemplos/02-saude-da-comunidade.sh   (GitHub de verdade)
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

passo "Nota de saúde (0 a 100)"
mostra gh api "repos/$LAB_REPO/community/profile" --jq '.health_percentage'

passo "O que existe e o que falta"
gh api "repos/$LAB_REPO/community/profile" \
    --jq '.files | to_entries[] | "\(if .value then "✔" else "✘" end) \(.key)"'

passo "Corrigindo uma ausência: licença MIT com os campos preenchidos"
gh api licenses/mit --jq .body | sed -e 's/\[year\]/2026/' -e 's/\[fullname\]/Ana Dev/' > LICENSE
head -3 LICENSE
