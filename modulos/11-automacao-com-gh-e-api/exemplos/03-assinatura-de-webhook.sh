#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 11 · Verificando a assinatura de um webhook
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  calcular e conferir o HMAC-SHA256 que o GitHub envia em X-Hub-Signature-256 — e ver uma falsificação falhar
#  EXECUTE   bash modulos/11-automacao-com-gh-e-api/exemplos/03-assinatura-de-webhook.sh
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

segredo='um-segredo-longo-combinado-com-o-github'
cat > payload.json <<'JSON'
{"action":"opened","issue":{"number":42,"title":"Erro 500"},"repository":{"full_name":"aluno/laboratorio"}}
JSON
assinar() { openssl dgst -sha256 -hmac "$segredo" < "$1" | sed 's/^.* /sha256=/'; }

passo "O GitHub envia o corpo e, no cabeçalho, a assinatura dele"
cabecalho="$(assinar payload.json)"     # aqui fazemos o papel do GitHub
echo "X-Hub-Signature-256: $cabecalho"

passo "Seu servidor recalcula com o MESMO segredo e compara"
[[ "$(assinar payload.json)" == "$cabecalho" ]] && echo "✔ assinatura válida: o evento veio do GitHub"

passo "Um atacante altera o corpo (sem conhecer o segredo)"
sed 's/Erro 500/Pague aqui: link-malicioso/' payload.json > forjado.json
[[ "$(assinar forjado.json)" == "$cabecalho" ]] || echo "✘ assinatura NÃO confere: descarte o evento (HTTP 401)"

echo
echo "Em produção, compare em tempo constante (Python: hmac.compare_digest)."
