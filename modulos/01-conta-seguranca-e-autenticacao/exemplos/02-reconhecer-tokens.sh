#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 01 · Reconhecendo tokens pelo prefixo
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  identificar o tipo de token sem nunca exibi-lo inteiro — e achar tokens esquecidos em arquivos
#  EXECUTE   bash modulos/01-conta-seguranca-e-autenticacao/exemplos/02-reconhecer-tokens.sh
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

# Tokens FALSOS, só para estudo (formato correto, valor inventado).
falsos=(
  "ghp_FAKE0000000000000000000000000000000a"
  "github_pat_11FAKE000000000000000_0000000000000000000000000000000000000000000000000000000"
  "gho_FAKE0000000000000000000000000000000b"
  "ghs_FAKE0000000000000000000000000000000c"
  "senha123"
)
tipo() {
    case "$1" in
        ghp_*)        echo "pessoal clássico" ;;
        github_pat_*) echo "pessoal fine-grained" ;;
        gho_*)        echo "OAuth (ex.: gh auth login)" ;;
        ghu_*)        echo "GitHub App: usuário-para-servidor" ;;
        ghs_*)        echo "GitHub App/Actions: servidor-para-servidor" ;;
        ghr_*)        echo "GitHub App: refresh token" ;;
        *)            echo "não parece token do GitHub" ;;
    esac
}
mascarar() { printf '%s…(%d caracteres)' "${1:0:8}" "${#1}"; }

passo "Classificando (repare: nunca imprimimos o token inteiro)"
for t in "${falsos[@]}"; do
    printf '%-28s → %s\n' "$(mascarar "$t")" "$(tipo "$t")"
done

passo "Procurando tokens esquecidos num projeto"
mkdir -p projeto && cd projeto
printf 'API_URL=https://api.exemplo.dev\nGH_TOKEN=%s\n' "${falsos[0]}" > .env
printf 'echo "deploy"\n' > deploy.sh
# Regex dos formatos atuais; -o mostra só o trecho, -n a linha.
grep -rnoE '(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{60,}' . |
    while IFS=: read -r arq linha achado; do
        printf '⚠ %s:%s  %s\n' "$arq" "$linha" "$(mascarar "$achado")"
    done
echo "→ Achou? Revogue o token no GitHub ANTES de apagar o arquivo."
