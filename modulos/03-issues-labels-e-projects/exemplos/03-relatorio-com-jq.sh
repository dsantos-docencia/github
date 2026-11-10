#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 03 · Relatório de issues com jq
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  transformar a lista de issues em relatório: por label, sem dono, mais antigo aberto
#  EXECUTE   bash modulos/03-issues-labels-e-projects/exemplos/03-relatorio-com-jq.sh
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

# Em vez de pedir ao GitHub cada pergunta, pedimos os dados UMA vez e
# respondemos várias perguntas localmente — economiza tempo e limite de API.
simular_gh 'issue list*--state all*' "$(cat "$CURSO/ferramentas/simulador/respostas/issue-list-todas.json")"
gh issue list -R "$LAB_REPO" --state all --limit 500 \
    --json number,title,state,labels,assignees,createdAt > issues.json

passo "Quantos issues por estado"
jq -r 'group_by(.state) | .[] | "\(.[0].state): \(length)"' issues.json

passo "Abertos por label (um issue pode contar em mais de um)"
jq -r '[.[] | select(.state=="OPEN") | .labels[].name] | group_by(.) | map("\(.[0]): \(length)") | .[]' issues.json

passo "Abertos SEM responsável"
jq -r '.[] | select(.state=="OPEN" and (.assignees|length)==0) | "#\(.number) \(.title)"' issues.json

passo "O issue aberto mais antigo"
jq -r '[.[] | select(.state=="OPEN")] | min_by(.createdAt) | "#\(.number) aberto em \(.createdAt[:10]): \(.title)"' issues.json
