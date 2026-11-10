#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 10 · Auditando workflows com o zizmor
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  rodar o zizmor num workflow com os erros clássicos e depois na versão corrigida
#  EXECUTE   bash modulos/10-seguranca-da-cadeia-de-suprimentos/exemplos/03-auditar-com-zizmor.sh
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

mkdir -p ruim/.github/workflows bom/.github/workflows
cat > ruim/.github/workflows/ci.yml <<'YAML'
name: CI
on: pull_request_target
jobs:
  testes:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.sha }}
      - run: echo "Testando ${{ github.event.pull_request.title }}"
YAML
cp "$CURSO/modulos/10-seguranca-da-cadeia-de-suprimentos/exemplos/workflows/boas-vindas-seguro.yml" bom/.github/workflows/

passo "Os problemas, um por um, antes de qualquer ferramenta"
cat <<'TXT'
  1. on: pull_request_target  → roda com segredos e token de escrita, inclusive para forks
  2. checkout do head do PR   → traz o código do atacante para esse contexto privilegiado
  3. actions/checkout@v4      → tag mutável (e, na v7, esse checkout seria recusado)
  4. sem permissions:         → token com as permissões padrão
  5. ${{ ...title }} no run   → injeção de script
TXT

if ! command -v zizmor >/dev/null; then
    echo; echo "(zizmor não instalado: pip install zizmor — ou use o container do laboratório)"
    exit 0
fi
passo "zizmor no workflow RUIM"
zizmor --offline --no-progress ruim/.github/workflows 2>&1 | grep -E '^(error|warning|help)\[' | sort | uniq -c || true

passo "zizmor no workflow BOM"
zizmor --offline --no-progress bom/.github/workflows 2>&1 | tail -1 || true
