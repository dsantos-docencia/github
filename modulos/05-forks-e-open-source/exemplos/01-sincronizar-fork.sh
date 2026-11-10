#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 05 · Mantendo um fork em dia
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  montar upstream, fork e clone locais e trazer as novidades do original com fetch + merge --ff-only
#  EXECUTE   bash modulos/05-forks-e-open-source/exemplos/01-sincronizar-fork.sh
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

passo "O projeto original (upstream) e o seu fork (origin) — os dois são bare, como no GitHub"
git init -q --bare upstream.git
git clone -q upstream.git tmp 2>/dev/null
printf 'v1\n' > tmp/README.md && git -C tmp add . && git -C tmp commit -q -m "docs: v1" && git -C tmp push -q origin main
git clone -q --bare upstream.git fork.git          # "apertar o botão Fork"

passo "Seu clone: origin = fork, upstream = original"
git clone -q fork.git meu-projeto && cd meu-projeto
mostra git remote add upstream ../upstream.git
git remote -v

passo "O original recebe commits novos (de outras pessoas)"
printf 'v2\n' >> ../tmp/README.md && git -C ../tmp commit -qam "docs: v2" && git -C ../tmp push -q origin main
git log --oneline -1 origin/main | sed 's/^/seu fork está em: /'

passo "Sincronizando: fetch upstream → merge --ff-only → push origin"
mostra git fetch -q upstream
mostra git merge --ff-only upstream/main
mostra git push -q origin main
git log --oneline -1 origin/main | sed 's/^/seu fork agora está em: /'

passo "O mesmo, sem baixar nada, direto no GitHub:"
mostra gh repo sync aluno/meu-projeto --source org/projeto --branch main
