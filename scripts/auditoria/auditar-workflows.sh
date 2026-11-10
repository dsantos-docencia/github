#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · scripts/auditoria/auditar-workflows.sh
#  Auditoria de segurança dos workflows do GitHub Actions (sem dependências).
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
#  USO   auditar-workflows.sh [PASTA]      (padrão: .github/workflows)
#  Achados, por gravidade:
#    ALTO   pull_request_target · ${{ campo-do-usuário }} dentro de run: (injeção)
#    MÉDIO  ação sem SHA de 40 caracteres · workflow sem "permissions:"
#    BAIXO  actions/checkout sem persist-credentials: false
#  Sai com 1 se houver achado ALTO ou MÉDIO. Para auditoria completa, use o zizmor.
# ============================================================================
set -euo pipefail
export LC_ALL=C.UTF-8     # ${#var} conta caracteres (não bytes) numa localidade UTF-8

pasta="${1:-.github/workflows}"
[[ -d "$pasta" ]] || { echo "erro: pasta não encontrada: $pasta" >&2; exit 2; }
# Campos que qualquer pessoa controla ao abrir issue/PR/comentário.
perigosos='github\.event\.(issue|pull_request|comment|review|review_comment|discussion|head_commit|commits|pages)[^}]*\.(title|body|message|name|label|ref|page_name)|github\.head_ref'

graves=0
# Alinhamento manual: o printf do Bash mede a largura em BYTES ("MÉDIO" tem 6),
# mas ${#var} conta CARACTERES numa localidade UTF-8.
achado() { printf '%s%*s %s\n' "$1" $((6 - ${#1})) '' "$2"; [[ "$1" != BAIXO ]] && graves=$((graves + 1)); return 0; }

shopt -s nullglob
for wf in "$pasta"/*.yml "$pasta"/*.yaml; do
    nome="${wf#"$pasta"/}"
    grep -qE '^\s*pull_request_target\b|on:.*pull_request_target' "$wf" && achado ALTO "$nome: usa pull_request_target"
    grep -qE '^permissions:' "$wf" || achado MÉDIO "$nome: sem 'permissions:' no topo"

    # Injeção: ${{ campo-perigoso }} numa linha de run: ou dentro de um bloco "run: |".
    # O awk lembra a indentação do run: e considera o bloco até a indentação voltar.
    mapfile -t linhas < <(awk -v re="$perigosos" '
        /^[[:space:]]*(-[[:space:]]*)?run:/ {
            emrun = 1; ind = match($0, /[^ -]/)
            if ($0 ~ "\\$\\{\\{[^}]*(" re ")") print NR
            next
        }
        emrun && match($0, /[^ ]/) <= ind { emrun = 0 }
        emrun && $0 ~ "\\$\\{\\{[^}]*(" re ")" { print NR }' "$wf")
    for n in "${linhas[@]}"; do achado ALTO "$nome:$n: \${{ }} com dado do usuário dentro de run: (injeção)"; done

    while IFS=: read -r n linha; do
        ref="${linha#*uses:}"; ref="${ref%%#*}"; ref="${ref//[\"\' ]/}"
        [[ -z "$ref" || "$ref" == ./* || "$ref" == docker://* ]] && continue
        [[ "${ref##*@}" =~ ^[0-9a-f]{40}$ ]] || achado MÉDIO "$nome:$n: $ref sem SHA fixo"
    done < <(grep -nE '^\s*(-\s*)?uses:' "$wf")

    if grep -qE 'uses:\s*actions/checkout@' "$wf" && ! grep -qE 'persist-credentials:\s*false' "$wf"; then
        achado BAIXO "$nome: checkout sem persist-credentials: false"
    fi
done
echo "—— $graves achado(s) ALTO/MÉDIO"
(( graves == 0 ))
