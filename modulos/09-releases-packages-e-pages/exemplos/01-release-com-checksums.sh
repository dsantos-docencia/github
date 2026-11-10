#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 09 · Uma release com checksums
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  empacotar, gerar SHA256SUMS, publicar com notas automáticas e conferir o download
#  EXECUTE   bash modulos/09-releases-packages-e-pages/exemplos/01-release-com-checksums.sh
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

passo "Projeto com uma tag v1.2.0 publicada"
git init -q --bare servidor.git
git clone -q servidor.git loja 2>/dev/null && cd loja
mkdir -p src && printf 'console.log("loja")\n' > src/app.js
git add . && git commit -q -m "feat: loja" && git tag -a v1.2.0 -m "v1.2.0" && git push -q origin main v1.2.0

passo "Empacotar e gerar checksums"
mkdir -p dist
git archive --format=tar.gz --prefix=loja-1.2.0/ -o dist/loja-1.2.0.tar.gz v1.2.0   # o conteúdo exato da tag
(cd dist && sha256sum ./*.tar.gz > SHA256SUMS && cat SHA256SUMS)

passo "Publicar (--verify-tag: a tag precisa já estar no servidor)"
mostra gh release create v1.2.0 dist/loja-1.2.0.tar.gz dist/SHA256SUMS --title v1.2.0 --generate-notes --verify-tag

passo "Quem baixa confere assim"
mostra gh release download v1.2.0 --pattern '*' --dir baixado
mkdir -p baixado && cp dist/* baixado/     # (no simulado nada é baixado; copiamos para demonstrar)
(cd baixado && sha256sum -c SHA256SUMS)

passo "E se alguém trocar o arquivo?"
printf 'adulterado' >> baixado/loja-1.2.0.tar.gz
(cd baixado && sha256sum -c SHA256SUMS) || echo "→ checksum não confere: NÃO use este arquivo."
