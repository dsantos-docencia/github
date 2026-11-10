#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 01 · Quem sou eu para o GitHub
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  consultar o login, escopos e e-mail noreply da conta autenticada
#  EXECUTE   bash modulos/01-conta-seguranca-e-autenticacao/exemplos/03-quem-sou-eu.sh
#            GH_REAL=1 LAB_REPO=seu-usuario/lab-github bash modulos/01-conta-seguranca-e-autenticacao/exemplos/03-quem-sou-eu.sh   (GitHub de verdade)
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

passo "Estado do login"
mostra gh auth status

passo "Meu usuário e ID (a API responde JSON; --jq extrai)"
login="$(gh api user --jq .login)"
id="$(gh api user --jq .id)"
echo "login: $login   id: $id"

passo "Meu e-mail noreply para commits"
echo "git config --global user.email \"$id+$login@users.noreply.github.com\""

passo "O token existe, mas nunca o exiba inteiro"
token="$(gh auth token)"
printf 'token: %s… (%d caracteres)\n' "${token:0:6}" "${#token}"
