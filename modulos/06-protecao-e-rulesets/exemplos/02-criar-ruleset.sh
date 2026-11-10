#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 06 · Criando um ruleset como código
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  gerar o JSON de um ruleset, validá-lo com jq e aplicá-lo pela API em modo evaluate
#  EXECUTE   bash modulos/06-protecao-e-rulesets/exemplos/02-criar-ruleset.sh
#            GH_REAL=1 LAB_REPO=seu-usuario/lab-github bash modulos/06-protecao-e-rulesets/exemplos/02-criar-ruleset.sh   (GitHub de verdade)
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

# --- gh: simulado por padrão; o de verdade com GH_REAL=1 ---------------------
# Simulado = offline, sem conta, nada é criado; cada chamada fica registrada.
if [[ "${GH_REAL:-0}" == 1 ]]; then
    : "${LAB_REPO:?defina LAB_REPO=seu-usuario/lab-github (veja laboratorio/)}"
    gh auth status >/dev/null 2>&1 || { echo "rode 'gh auth login' antes" >&2; exit 1; }
else
    # shellcheck source=/dev/null
    source "$CURSO/ferramentas/lib/gh-simulado.sh"
    LAB_REPO='aluno/laboratorio'
fi
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

passo "1. O ruleset como arquivo (vai para o controle de versão, como qualquer código)"
cat > ruleset-main.json <<'JSON'
{
  "name": "proteger-main",
  "target": "branch",
  "enforcement": "evaluate",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    { "type": "pull_request", "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": false,
        "required_review_thread_resolution": true } }
  ]
}
JSON

passo "2. Validar antes de enviar: JSON bem formado e regras essenciais presentes"
jq -e '[.rules[].type] | contains(["deletion","non_fast_forward","pull_request"])' ruleset-main.json >/dev/null \
    && echo "✔ JSON válido com as 3 regras essenciais"

passo "3. Aplicar em modo EVALUATE (registra violações sem bloquear ninguém)"
mostra gh api -X POST "repos/$LAB_REPO/rulesets" --input ruleset-main.json --jq '"criado: id \(.id) (\(.enforcement))"'

echo
echo "Próximo passo no site: Settings → Rules → Rulesets → proteger-main → Rule insights."
echo "Sem surpresas? Troque \"evaluate\" por \"active\" e aplique com -X PUT .../rulesets/ID."
