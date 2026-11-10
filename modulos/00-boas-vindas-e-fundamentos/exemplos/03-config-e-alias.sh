#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 00 · Configuração e aliases do gh
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  configurar o gh (protocolo, editor) e criar atalhos — numa configuração isolada, sem tocar na sua
#  EXECUTE   bash modulos/00-boas-vindas-e-fundamentos/exemplos/03-config-e-alias.sh
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

# Este exemplo usa o gh REAL, mas com GH_CONFIG_DIR temporário (definido pelo
# gh-simulado.sh): nada da sua configuração verdadeira é lido ou alterado.
# Configurar e criar alias não precisam de internet nem de login.
PATH="${PATH//"$GH_SIMULADOR_DIR:"/}"
if ! command -v gh >/dev/null; then
    echo "gh real não instalado — instale (veja laboratorio/) para ver este exemplo funcionando."
    exit 0
fi
echo "configuração temporária em: $GH_CONFIG_DIR"

passo "Protocolo do Git: ssh ou https"
mostra gh config set git_protocol ssh
mostra gh config get git_protocol

passo "Editor para corpos de issue/PR"
mostra gh config set editor "code --wait"
mostra gh config get editor

passo "Aliases: seus próprios comandos"
mostra gh alias set prs 'pr list --author @me'
mostra gh alias set bugs 'issue list --label bug --state open'
# Alias com "!" roda no shell: dá para encadear comandos com pipes.
mostra gh alias set --shell recentes 'gh issue list --limit 5 --json number,title --jq ".[].title"'
mostra gh alias list

passo "Onde isso fica guardado"
ls -1 "$GH_CONFIG_DIR"
sed 's/^/    /' "$GH_CONFIG_DIR/config.yml" | grep -v '^ *#' | sed '/^ *$/d'
