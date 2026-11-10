#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 07 · O primeiro workflow
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  escrever um workflow, validá-lo com actionlint, ver a pegadinha do "on" no YAML e rodar o step localmente
#  EXECUTE   bash modulos/07-actions-fundamentos/exemplos/01-primeiro-workflow.sh
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

mkdir -p .github/workflows
cp "$CURSO/modulos/07-actions-fundamentos/exemplos/workflows/ci-basico.yml" .github/workflows/ci.yml
printf '#!/usr/bin/env bash\necho "✔ 3 testes passaram"\n' > testes.sh && chmod +x testes.sh

passo "1. O workflow"
grep -v '^#' .github/workflows/ci.yml

passo "2. Validar com actionlint (sintaxe, expressões e ShellCheck nos run:)"
if command -v actionlint >/dev/null; then
    actionlint .github/workflows/ci.yml && echo "✔ actionlint: nenhum problema"
else
    echo "(actionlint não instalado: pip install actionlint-py)"
fi

passo "3. A pegadinha do YAML 1.1: 'on' vira booleano num parser genérico"
python3 -c 'import yaml; d = yaml.safe_load(open(".github/workflows/ci.yml")); print("chaves do topo:", list(d.keys()))'
echo "→ repare no True no lugar de 'on'. O conversor do curso corrige:"
python3 "$CURSO/ferramentas/lib/yaml2json.py" .github/workflows/ci.yml | jq -c '{eventos: (.on | keys)}'

passo "4. Rodando o step 'Rodar os testes' como o runner faria"
GITHUB_STEP_SUMMARY="$LAB/resumo.md"; export GITHUB_STEP_SUMMARY
comando="$(python3 "$CURSO/ferramentas/lib/yaml2json.py" .github/workflows/ci.yml | jq -r '.jobs.testes.steps[] | select(.name=="Rodar os testes") | .run')"
echo "\$ $comando"
bash -c "$comando"
