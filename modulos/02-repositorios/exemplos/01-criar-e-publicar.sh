#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 02 · Criar e publicar um repositório
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  do git init ao gh repo create --source . --push, e a configuração do repositório pelo terminal
#  EXECUTE   bash modulos/02-repositorios/exemplos/01-criar-e-publicar.sh
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

passo "1. Projeto local com o primeiro commit (sem commit, não há o que publicar)"
git init -q loja-site && cd loja-site
printf '# Loja do Bairro\n' > README.md
printf 'node_modules/\n.env\n' > .gitignore
git add . && git commit -q -m "chore: estrutura inicial"
git log --oneline

passo "2. Publicar como repositório PRIVADO, usando a pasta atual"
mostra gh repo create aluno/loja-site --private --source . --remote origin --push \
    --description "Site da Loja do Bairro"

passo "3. Ajustar as configurações recomendadas"
mostra gh repo edit aluno/loja-site --add-topic site --add-topic loja \
    --enable-merge-commit=false --enable-squash-merge --enable-rebase-merge \
    --delete-branch-on-merge --enable-wiki=false

passo "Registro (no GitHub real, esses comandos criariam e configurariam o repositório)"
chamadas_gh
