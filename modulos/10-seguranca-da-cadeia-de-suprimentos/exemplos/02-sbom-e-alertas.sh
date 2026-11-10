#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 10 · SBOM e alertas do Dependabot
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  exportar a lista de dependências (SBOM) e priorizar alertas por gravidade
#  EXECUTE   bash modulos/10-seguranca-da-cadeia-de-suprimentos/exemplos/02-sbom-e-alertas.sh
#            GH_REAL=1 LAB_REPO=seu-usuario/lab-github bash modulos/10-seguranca-da-cadeia-de-suprimentos/exemplos/02-sbom-e-alertas.sh   (GitHub de verdade)
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

passo "SBOM: o que este repositório usa (formato SPDX)"
mostra gh api "repos/$LAB_REPO/dependency-graph/sbom" \
    --jq '.sbom.packages[1:][] | "\(.name)@\(.versionInfo)  (\(.licenseConcluded // "?"))"'

passo "Alertas abertos do Dependabot, do mais grave ao menos grave"
gh api "repos/$LAB_REPO/dependabot/alerts?state=open" > alertas.json
jq -r 'def peso: {"critical":0,"high":1,"medium":2,"low":3}[.] // 4;
       sort_by(.security_advisory.severity | peso)[]
       | "\(.security_advisory.severity | ascii_upcase)\t\(.dependency.package.name) → corrigido em \(.security_vulnerability.first_patched_version.identifier // "?")\t\(.security_advisory.cve_id // .security_advisory.ghsa_id)"' alertas.json

passo "Resumo por gravidade"
jq -r 'group_by(.security_advisory.severity) | .[] | "\(.[0].security_advisory.severity): \(length)"' alertas.json
