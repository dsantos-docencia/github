#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · scripts/dia-a-dia/clonar-todos.sh
#  Clona (ou atualiza) todos os repositórios de um usuário ou organização.
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
#  USO   clonar-todos.sh DONO [PASTA] [--incluir-arquivados]
#  • repositório que ainda não existe na pasta → gh repo clone
#  • que já existe → git pull --ff-only (nunca cria merge nem perde trabalho)
#  • arquivados ficam de fora, a menos que você peça
# ============================================================================
set -euo pipefail

dono='' destino='.' arquivados=0
for a in "$@"; do
    case "$a" in
        --incluir-arquivados) arquivados=1 ;;
        -*) echo "opção desconhecida: $a" >&2; exit 2 ;;
        *)  if [[ -z "$dono" ]]; then dono="$a"; else destino="$a"; fi ;;
    esac
done
[[ -n "$dono" ]] || { echo "uso: $0 DONO [PASTA] [--incluir-arquivados]" >&2; exit 2; }
mkdir -p -- "$destino"

filtro='.[] | select(.isArchived | not) | .name'
(( arquivados )) && filtro='.[] | .name'

novos=0 atualizados=0 falhas=0
# --limit alto: o padrão do gh repo list é só 30.
while IFS= read -r nome; do
    alvo="$destino/$nome"
    if [[ -d "$alvo/.git" ]]; then
        if git -C "$alvo" pull -q --ff-only 2>/dev/null; then
            echo "↻ $nome"; atualizados=$((atualizados + 1))
        else
            echo "✘ $nome (não deu para avançar: há commits locais ou divergência)"; falhas=$((falhas + 1))
        fi
    else
        gh repo clone "$dono/$nome" "$alvo" -- -q && echo "＋ $nome" && novos=$((novos + 1))
    fi
done < <(gh repo list "$dono" --limit 1000 --json name,isArchived --jq "$filtro")

echo "$novos clonados, $atualizados atualizados, $falhas com problema"
(( falhas == 0 ))
