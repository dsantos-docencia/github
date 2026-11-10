#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 08 · Uma ação composta, por dentro
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  escrever uma ação composta com entradas e saídas e executar seu step localmente para ver a saída
#  EXECUTE   bash modulos/08-actions-avancado/exemplos/02-acao-composta.sh
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

mkdir -p .github/actions/saudacao
cat > .github/actions/saudacao/action.yml <<'YAML'
name: Saudação
description: Gera uma mensagem de boas-vindas
inputs:
  nome:
    description: Quem saudar
    required: true
outputs:
  mensagem:
    description: A mensagem gerada
    value: ${{ steps.gerar.outputs.mensagem }}
runs:
  using: composite
  steps:
    - id: gerar
      shell: bash
      env:
        NOME: ${{ inputs.nome }}
      run: echo "mensagem=Olá, $NOME! Boas-vindas ao time." >> "$GITHUB_OUTPUT"
YAML

passo "A ação"
cat .github/actions/saudacao/action.yml

passo "Como um workflow usaria"
cat <<'YAML'
      - uses: ./.github/actions/saudacao      # ação local: precisa do checkout antes
        id: oi
        with:
          nome: ${{ github.actor }}
      - run: echo "$MSG"
        env:
          MSG: ${{ steps.oi.outputs.mensagem }}
YAML

passo "Executando o step 'gerar' como o runner faria (NOME vem do input)"
export GITHUB_OUTPUT="$LAB/out"; : > "$GITHUB_OUTPUT"
script="$(python3 "$CURSO/ferramentas/lib/yaml2json.py" .github/actions/saudacao/action.yml | jq -r '.runs.steps[0].run')"
NOME="Bia" bash -c "$script"
echo "GITHUB_OUTPUT → $(cat "$GITHUB_OUTPUT")"
