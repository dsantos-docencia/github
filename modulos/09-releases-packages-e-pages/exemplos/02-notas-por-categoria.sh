#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 09 · Como as notas automáticas são montadas
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  reproduzir a lógica do .github/release.yml: cada PR vai para a primeira categoria cujo label ele tem
#  EXECUTE   bash modulos/09-releases-packages-e-pages/exemplos/02-notas-por-categoria.sh
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

cat > release.yml <<'YAML'
changelog:
  exclude:
    labels: [ignorar-nas-notas]
    authors: [dependabot]
  categories:
    - title: 🚀 Novidades
      labels: [feature, melhoria]
    - title: 🐛 Correções
      labels: [bug]
    - title: Outras mudanças
      labels: ["*"]
YAML
cat > prs.json <<'JSON'
[ {"n":6,"titulo":"feat: exportação CSV","autor":"bia-dev","labels":["feature"]},
  {"n":9,"titulo":"fix: timeout no checkout","autor":"dani-ops","labels":["bug","prioridade:alta"]},
  {"n":10,"titulo":"docs: guia de instalação","autor":"caio-qa","labels":["documentação"]},
  {"n":11,"titulo":"chore(deps): bump express","autor":"dependabot","labels":["dependências"]},
  {"n":12,"titulo":"ci: ajusta cache","autor":"aluno","labels":["ignorar-nas-notas"]} ]
JSON

passo "Notas geradas (mesma regra do GitHub, em jq)"
python3 "$CURSO/ferramentas/lib/yaml2json.py" release.yml > release.json
jq -r --slurpfile cfg release.json '
  ($cfg[0].changelog) as $c
  | map(select((.labels - $c.exclude.labels | length) == (.labels | length)
               and ([.autor] - $c.exclude.authors | length) == 1))
  | . as $prs
  | $c.categories[] as $cat
  | [ $prs[] | select(. as $p | (first($c.categories[] | select(any(.labels[]; . == "*" or (. as $l | $p.labels | index($l))))) .title) == $cat.title) ]
  | select(length > 0)
  | "### \($cat.title)\n" + (map("* \(.titulo) por @\(.autor) em #\(.n)") | join("\n"))
' prs.json
echo
echo "PR 9 tem 'bug' e 'prioridade:alta' → entrou em Correções (primeira categoria que casa)."
echo "PR 11 (dependabot) e PR 12 (ignorar-nas-notas) ficaram de fora."

passo "No GitHub, você só pede:"
mostra gh api "repos/$LAB_REPO/releases/generate-notes" -f tag_name=v1.2.0 -f previous_tag_name=v1.1.0 --jq .body
