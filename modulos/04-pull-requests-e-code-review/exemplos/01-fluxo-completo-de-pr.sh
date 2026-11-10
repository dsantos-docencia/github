#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 04 · O fluxo completo de um PR
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  branch → commits → push → gh pr create → checks → merge, com um "GitHub" local (repositório bare)
#  EXECUTE   bash modulos/04-pull-requests-e-code-review/exemplos/01-fluxo-completo-de-pr.sh
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

passo "Servidor (bare) e clone — o papel do GitHub aqui é de um repositório bare"
git init -q --bare servidor.git
git clone -q servidor.git loja 2>/dev/null && cd loja
printf 'loja\n' > app.txt && git add . && git commit -q -m "feat: base" && git push -q origin main

passo "1. Branch da funcionalidade, a partir da main atualizada"
git switch -q -c feature/login
printf 'login por e-mail\n' > login.txt && git add . && git commit -q -m "feat: login por e-mail"
printf 'valida e-mail vazio\n' >> login.txt && git commit -qam "test: e-mail vazio"

passo "2. Publicar a branch (-u liga a branch local à remota)"
mostra git push -q -u origin feature/login

passo "3. Abrir o PR como rascunho, ligado ao issue 12"
cat > descricao.md <<'MD'
## O que muda
Login por e-mail e senha.
## Por quê
Pedido de 40% dos clientes no formulário de contato.
## Como testar
`./testes.sh login`
Closes #12
MD
mostra gh pr create --base main --head feature/login --title "feat: login por e-mail" --body-file descricao.md --draft

passo "4. Pronto para revisão; acompanhar o CI; mesclar com squash"
mostra gh pr ready 7
mostra gh pr checks 7
mostra gh pr merge 7 --squash --delete-branch

passo "Registro das chamadas"
chamadas_gh
