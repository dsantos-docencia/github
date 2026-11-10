#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Projeto 02 · Auditor de repositório
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Dá uma nota de 0 a 10 para a "higiene" de um repositório, só com leituras
#  da API — nada é alterado. Junta os Módulos 02, 05, 06, 10 e 11.
#
#  USO
#    auditor.sh DONO/REPO [--minimo N] [--json]
#      --minimo N   nota mínima para sair com 0 (padrão: 8) — útil no CI
#      --json       saída em JSON (para guardar ou comparar ao longo do tempo)
#
#  ITENS (1 ponto cada)
#    descrição · licença · tópicos · apaga branch após merge · secret scanning
#    push protection · alertas do Dependabot · regras na branch padrão
#    saúde da comunidade ≥ 80% · no máximo 1 admin
# ============================================================================
set -euo pipefail

repo='' minimo=8 json=0
while (( $# )); do
    case "$1" in
        --minimo) minimo="${2:?--minimo precisa de um número}"; shift ;;
        --json)   json=1 ;;
        -h|--help) sed -n '/^#  USO/,/^# ====/p' "$0" | sed '$d; s/^#  \{0,1\}//'; exit 0 ;;
        -*)       echo "opção desconhecida: $1" >&2; exit 2 ;;
        *)        repo="$1" ;;
    esac
    shift
done
[[ "$repo" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || { echo "uso: $0 DONO/REPO [--minimo N] [--json]" >&2; exit 2; }
[[ "$minimo" =~ ^[0-9]+$ ]] || { echo "erro: --minimo precisa ser um número" >&2; exit 2; }

# Coleta: uma chamada por recurso, guardada para consultar várias vezes.
info="$(gh api "repos/$repo")"
padrao="$(jq -r .default_branch <<<"$info")"
regras="$(gh api "repos/$repo/rules/branches/$padrao" 2>/dev/null || echo '[]')"
comunidade="$(gh api "repos/$repo/community/profile" 2>/dev/null || echo '{}')"
colaboradores="$(gh api --paginate "repos/$repo/collaborators" 2>/dev/null || echo '[]')"
# Este endpoint responde 204 (ligado) ou 404 (desligado): o que importa é o status.
if gh api "repos/$repo/vulnerability-alerts" >/dev/null 2>&1; then alertas=true; else alertas=false; fi

itens=()      # "chave|descrição|true/false"
item() { itens+=("$1|$2|$3"); }
sim() { jq -e "$1" >/dev/null 2>&1 <<<"$2" && echo true || echo false; }

item descricao       "descrição preenchida"                  "$(sim '(.description // "") | length > 0' "$info")"
item licenca         "licença definida"                      "$(sim '.license.spdx_id // empty | . != "NOASSERTION"' "$info")"
item topicos         "tópicos para ser encontrado"           "$(sim '(.topics // []) | length > 0' "$info")"
item apaga_branch    "apaga a branch depois do merge"        "$(sim '.delete_branch_on_merge == true' "$info")"
item secret_scanning "secret scanning ligado"                "$(sim '.security_and_analysis.secret_scanning.status == "enabled"' "$info")"
item push_protection "push protection ligada"                "$(sim '.security_and_analysis.secret_scanning_push_protection.status == "enabled"' "$info")"
item dependabot      "alertas do Dependabot ligados"         "$alertas"
item regras          "branch $padrao protegida (exclusão, force push, PR)" \
                     "$(sim '[.[].type] | contains(["deletion","non_fast_forward","pull_request"])' "$regras")"
item comunidade      "saúde da comunidade ≥ 80%"             "$(sim '(.health_percentage // 0) >= 80' "$comunidade")"
item admins          "no máximo 1 admin"                     "$(sim '[.[] | select(.permissions.admin)] | length <= 1' "$colaboradores")"

nota=0
for i in "${itens[@]}"; do [[ "${i##*|}" == true ]] && nota=$((nota + 1)); done

if (( json )); then
    printf '%s\n' "${itens[@]}" | jq -R -s --arg repo "$repo" --argjson nota "$nota" --argjson total "${#itens[@]}" '
        { repo: $repo, nota: $nota, total: $total,
          itens: (split("\n") | map(select(length > 0) | split("|") | {item: .[0], descricao: .[1], ok: (.[2] == "true")})) }'
else
    echo "Auditoria de $repo"
    for i in "${itens[@]}"; do
        IFS='|' read -r _ desc ok <<<"$i"
        if [[ "$ok" == true ]]; then echo "  ✔ $desc"; else echo "  ✘ $desc"; fi
    done
    echo "nota: $nota/${#itens[@]}"
fi
(( nota >= minimo ))
