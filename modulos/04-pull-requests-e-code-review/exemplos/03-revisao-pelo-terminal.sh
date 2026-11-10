#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 04 · Revisão pelo terminal
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  encontrar o que espera sua revisão, ler o PR e registrar a revisão com gh pr review
#  EXECUTE   bash modulos/04-pull-requests-e-code-review/exemplos/03-revisao-pelo-terminal.sh
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

# --- gh simulado (offline): cada chamada é registrada, nada vai à internet ---
# shellcheck source=/dev/null
source "$CURSO/ferramentas/lib/gh-simulado.sh"
export LAB_REPO='aluno/laboratorio'
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

passo "PRs esperando a minha revisão"
mostra gh pr list -R "$LAB_REPO" --search "is:open review-requested:@me" \
    --json number,title,author --jq '.[] | "#\(.number) \(.title) — @\(.author.login)"'

passo "Lendo o PR 7: descrição e arquivos"
mostra gh pr view 7 -R "$LAB_REPO" --json title,body,files \
    --jq '"\(.title)\n\(.body)\n---\n" + ([.files[] | "\(.path) +\(.additions) -\(.deletions)"] | join("\n"))'

passo "Registrando a revisão"
mostra gh pr review 7 -R "$LAB_REPO" --request-changes \
    --body "nit: nome da função. Bloqueante: tratar e-mail vazio (linha 12)."
