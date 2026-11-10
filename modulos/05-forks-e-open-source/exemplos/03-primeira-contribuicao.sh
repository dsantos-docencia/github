#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 05 · Uma primeira contribuição, do fork ao PR
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  o roteiro completo de uma contribuição externa com o gh — fork, branch, commit, push e PR para o original
#  EXECUTE   bash modulos/05-forks-e-open-source/exemplos/03-primeira-contribuicao.sh
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

passo "1. Fork + clone (no real, o gh cria o fork e configura origin e upstream)"
mostra gh repo fork org/projeto --clone=false
# No simulado, montamos o clone à mão para seguir o roteiro:
git init -q --bare fork.git
git clone -q fork.git projeto 2>/dev/null && cd projeto
printf '# Projeto\nInstalacao facil.\n' > README.md && git add . && git commit -q -m "docs: base" && git push -q origin main

passo "2. Branch focada numa única mudança"
mostra git switch -c docs/acentuacao
sed -i.bak 's/Instalacao facil/Instalação fácil/' README.md && rm -f README.md.bak
git commit -qam "docs: corrige acentuação no README"

passo "3. Push para o SEU fork e PR para o original"
mostra git push -q -u origin docs/acentuacao
mostra gh pr create --repo org/projeto --head aluno:docs/acentuacao --base main \
    --title "docs: corrige acentuação no README" --body "Correção de acentuação. Sem mudança de código."

chamadas_gh
