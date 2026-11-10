#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 09 · Um site no GitHub Pages
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  montar um site estático, o workflow de publicação, e entender o que cada permissão faz
#  EXECUTE   bash modulos/09-releases-packages-e-pages/exemplos/03-site-no-pages.sh
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

passo "O site"
mkdir -p site
cat > site/index.html <<'HTML'
<!doctype html>
<html lang="pt-BR"><meta charset="utf-8"><title>Loja do Bairro</title>
<link rel="stylesheet" href="estilo.css">   <!-- caminho RELATIVO: funciona em /loja/ -->
<h1>Loja do Bairro</h1><p>Documentação da versão 1.2.0.</p></html>
HTML
printf 'body { font-family: sans-serif; max-width: 40rem; margin: auto; }\n' > site/estilo.css
find site -type f

passo "O workflow (Settings → Pages → Source: GitHub Actions)"
mkdir -p .github/workflows
cp "$CURSO/modulos/09-releases-packages-e-pages/exemplos/workflows/pages.yml" .github/workflows/
python3 "$CURSO/ferramentas/lib/yaml2json.py" .github/workflows/pages.yml |
    jq -r '"permissões: \(.permissions)", "jobs: \(.jobs | keys | join(" → "))", "ambiente do deploy: \(.jobs.deploy.environment.name)"'

passo "Por que cada permissão"
cat <<'TXT'
  contents: read   → o build só lê o código
  pages: write     → o deploy publica no Pages
  id-token: write  → o deploy prova, por OIDC, que vem DESTE workflow (sem token guardado)
TXT

if command -v actionlint >/dev/null; then actionlint .github/workflows/pages.yml && echo "✔ actionlint ok"; fi
echo "Endereço final: https://aluno.github.io/<repositório>/"
