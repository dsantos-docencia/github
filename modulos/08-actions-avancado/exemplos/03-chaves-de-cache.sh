#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 08 · Como as chaves de cache mudam
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  ver a chave de cache derivada do hash do lockfile mudar — e o restore-keys salvar o dia
#  EXECUTE   bash modulos/08-actions-avancado/exemplos/03-chaves-de-cache.sh
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

SO="Linux"
chave() { printf 'npm-%s-%s' "$SO" "$(sha256sum package-lock.json | cut -c1-12)"; }
declare -A caches=()      # o "armazenamento de cache" do GitHub, simulado

restaurar() {
    local exata="$1" prefixo="$2" k
    if [[ -n "${caches[$exata]:-}" ]]; then echo "   ✔ cache EXATO encontrado: $exata"; return; fi
    for k in "${!caches[@]}"; do
        if [[ "$k" == "$prefixo"* ]]; then echo "   ↺ sem exato; restore-keys achou: $k (instala só a diferença)"; return; fi
    done
    echo "   ✘ nenhum cache: instalação completa (lento)"
}

passo "Execução 1 — lockfile original"
printf '{"lockfileVersion":3,"packages":{"express":"4.21.0"}}\n' > package-lock.json
k1="$(chave)"; echo "   chave: $k1"
restaurar "$k1" "npm-$SO-"; caches[$k1]=1; echo "   (ao fim do job, o cache é salvo com essa chave)"

passo "Execução 2 — nada mudou"
restaurar "$(chave)" "npm-$SO-"

passo "Execução 3 — uma dependência mudou: o hash muda, a chave muda"
printf '{"lockfileVersion":3,"packages":{"express":"4.21.2"}}\n' > package-lock.json
k3="$(chave)"; echo "   chave: $k3"
restaurar "$k3" "npm-$SO-"
