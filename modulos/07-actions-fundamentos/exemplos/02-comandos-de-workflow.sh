#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 07 · Conversando com o runner
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  usar GITHUB_OUTPUT, GITHUB_ENV, GITHUB_STEP_SUMMARY e comandos ::error:: — emulando o runner localmente
#  EXECUTE   bash modulos/07-actions-fundamentos/exemplos/02-comandos-de-workflow.sh
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

# O runner cria arquivos temporários e passa os caminhos por variáveis.
# Fazemos o mesmo, para ver exatamente o que cada step escreve.
export GITHUB_OUTPUT="$LAB/output" GITHUB_ENV="$LAB/env" GITHUB_STEP_SUMMARY="$LAB/summary.md"
: > "$GITHUB_OUTPUT"; : > "$GITHUB_ENV"; : > "$GITHUB_STEP_SUMMARY"

passo "Step 1 (id: versao) — produz uma saída"
printf '1.4.0-rc.1\n' > VERSION
v="$(cat VERSION)"
echo "versao=$v" >> "$GITHUB_OUTPUT"
[[ "$v" == *-* ]] && echo "prerelease=true" >> "$GITHUB_OUTPUT"
echo "AMBIENTE=homologacao" >> "$GITHUB_ENV"
echo "conteúdo de \$GITHUB_OUTPUT:"; sed 's/^/   /' "$GITHUB_OUTPUT"

passo "No YAML, o próximo step leria assim:"
cat <<'YAML'
      - run: echo "Publicando $VERSAO em $AMBIENTE"
        env:
          VERSAO: ${{ steps.versao.outputs.versao }}
YAML

passo "Step 2 — o runner já carregou o GITHUB_ENV como variáveis de ambiente"
set -a; # shellcheck source=/dev/null
source "$GITHUB_ENV"; set +a
echo "AMBIENTE agora vale: $AMBIENTE"

passo "Comandos de workflow (no GitHub viram anotações e grupos no log)"
echo "::group::Verificando arquivos"
echo "VERSION ok"
echo "::endgroup::"
echo "::warning file=VERSION,line=1::versão de pré-lançamento"
echo "::error title=Exemplo::assim se marca um erro (não interrompe o step sozinho)"

passo "Resumo da execução (Markdown)"
{ echo "### 🚀 Build $v"; echo "| item | valor |"; echo "|---|---|"; echo "| ambiente | $AMBIENTE |"; } >> "$GITHUB_STEP_SUMMARY"
cat "$GITHUB_STEP_SUMMARY"
