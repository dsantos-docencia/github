#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 10 · Injeção de script em workflows, ao vivo
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  ver por que ${{ }} dentro de run: é perigoso: simulamos a substituição do GitHub com um título malicioso
#  EXECUTE   bash modulos/10-seguranca-da-cadeia-de-suprimentos/exemplos/01-injecao-de-script.sh
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

# O GitHub resolve ${{ ... }} ANTES de entregar o script ao bash: é uma
# substituição de TEXTO. Reproduzimos isso com o Bash, sem GitHub nenhum.
export GH_TOKEN="ghs_TOKEN-FICTICIO-DO-RUNNER"   # o que um atacante quer roubar
titulo_malicioso='Erro no login"; echo "💥 o atacante executou código e viu o token: $GH_TOKEN"; echo "'

passo "Workflow VULNERÁVEL"
modelo='echo "Novo issue: ${{ github.event.issue.title }}"'
echo "run: $modelo"
script="${modelo//'${{ github.event.issue.title }}'/"$titulo_malicioso"}"
echo
echo "O que o runner recebe depois da substituição:"
echo "   $script"
echo "Executando:"
bash -c "$script" | sed 's/^/   /'

passo "Workflow SEGURO: o título entra como variável de ambiente"
echo 'env:  TITULO: ${{ github.event.issue.title }}'
echo 'run:  echo "Novo issue: $TITULO"'
echo "Executando:"
TITULO="$titulo_malicioso" bash -c 'echo "Novo issue: $TITULO"' | sed 's/^/   /'
echo
echo "→ No seguro, o texto malicioso é só TEXTO. Nenhum comando roda."
