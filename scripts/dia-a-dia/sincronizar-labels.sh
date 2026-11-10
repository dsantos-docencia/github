#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · scripts/dia-a-dia/sincronizar-labels.sh
#  Aplica um conjunto padrão de labels a um repositório (cria/atualiza/remove).
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ============================================================================
#  USO   sincronizar-labels.sh DONO/REPO [ARQUIVO.tsv] [--remover-extras [--aplicar]]
#  ARQUIVO.tsv: nome<TAB>cor<TAB>descrição (sem arquivo: o conjunto padrão abaixo)
#  --remover-extras  lista labels do repositório que não estão no conjunto;
#                    só APAGA com --aplicar (apagar label o tira de todos os issues!)
# ============================================================================
set -euo pipefail

repo='' arquivo='' remover=0 aplicar=0
for a in "$@"; do
    case "$a" in
        --remover-extras) remover=1 ;;
        --aplicar) aplicar=1 ;;
        -*) echo "opção desconhecida: $a" >&2; exit 2 ;;
        *)  if [[ -z "$repo" ]]; then repo="$a"; else arquivo="$a"; fi ;;
    esac
done
[[ -n "$repo" ]] || { echo "uso: $0 DONO/REPO [ARQUIVO.tsv] [--remover-extras [--aplicar]]" >&2; exit 2; }

padrao=$'bug\td73a4a\tAlgo não funciona
melhoria\ta2eeef\tNova funcionalidade ou pedido
documentação\t0075ca\tMelhorias na documentação
good first issue\t7057ff\tBom para quem está começando
help wanted\t008672\tPrecisamos de ajuda
segurança\tb60205\tAssunto de segurança
dependências\t0366d6\tAtualização de dependências
ignorar-nas-notas\tededed\tFora das notas de release'
conjunto="$padrao"
if [[ -n "$arquivo" ]]; then
    [[ -f "$arquivo" ]] || { echo "erro: arquivo não encontrado: $arquivo" >&2; exit 1; }
    conjunto="$(grep -vE '^\s*(#|$)' "$arquivo")"
fi

declare -A desejados=()
while IFS=$'\t' read -r nome cor descricao; do
    [[ -n "$nome" ]] || continue
    desejados["$nome"]=1
    gh label create "$nome" --color "$cor" --description "$descricao" --force -R "$repo" >/dev/null
    echo "✔ $nome"
done <<<"$conjunto"

if (( remover )); then
    while IFS= read -r existente; do
        [[ -n "${desejados[$existente]:-}" ]] && continue
        if (( aplicar )); then
            gh label delete "$existente" --yes -R "$repo" >/dev/null && echo "🗑 $existente"
        else
            echo "· sobraria: $existente (use --aplicar para apagar)"
        fi
    done < <(gh label list -R "$repo" --limit 500 --json name --jq '.[].name')
fi
