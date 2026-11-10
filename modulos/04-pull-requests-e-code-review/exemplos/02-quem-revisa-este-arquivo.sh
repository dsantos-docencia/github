#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Módulo 04 · Quem revisa este arquivo? (CODEOWNERS)
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  OBJETIVO  simular a regra "a última que casar vence" do CODEOWNERS para entender a ordem das linhas
#  EXECUTE   bash modulos/04-pull-requests-e-code-review/exemplos/02-quem-revisa-este-arquivo.sh
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

cat > CODEOWNERS <<'TXT'
# padrão geral primeiro: a ÚLTIMA regra que casar vence
*            @aluno
*.js         @bia-dev
/docs/       @org/documentacao
/.github/    @aluno @org/plataforma
TXT

# Versão simplificada do casamento de padrões do CODEOWNERS (suficiente para
# estudar a ordem; o GitHub implementa a especificação completa).
casa() {   # casa PADRÃO CAMINHO
    local p="$1" c="$2"
    if [[ "$p" == */ ]]; then                       # pasta
        if [[ "$p" == /* ]]; then [[ "/$c" == "$p"* ]]; else [[ "/$c" == *"/$p"* ]]; fi
    elif [[ "$p" == /* ]]; then                     # caminho a partir da raiz
        # shellcheck disable=SC2053
        [[ "/$c" == $p ]]
    else                                            # nome em qualquer pasta
        # shellcheck disable=SC2053
        [[ "${c##*/}" == $p || "$c" == $p ]]
    fi
}
donos_de() {
    local arquivo="$1" padrao resto donos=''
    while read -r padrao resto; do
        [[ -z "$padrao" || "$padrao" == \#* ]] && continue
        casa "$padrao" "$arquivo" && donos="$resto"   # não para: a última vence
    done < CODEOWNERS
    printf '%s' "$donos"
}

passo "Quem é pedido como revisor de cada arquivo"
for f in README.md src/app.js docs/guia.md docs/exemplo.js .github/workflows/ci.yml; do
    printf '%-28s → %s\n' "$f" "$(donos_de "$f")"
done
echo
echo "Repare em docs/exemplo.js: casa com *.js E com /docs/ — vence a linha mais abaixo."
