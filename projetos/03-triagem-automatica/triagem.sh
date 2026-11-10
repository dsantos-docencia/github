#!/usr/bin/env bash
# ============================================================================
#  Curso de GitHub · Projeto 03 · Triagem automática de issues
#  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
# ----------------------------------------------------------------------------
#  Roda DENTRO do GitHub Actions (veja triagem.yml) quando um issue é aberto:
#  lê o evento, aplica labels por palavras-chave, cumprimenta quem contribui
#  pela primeira vez e orienta relatos de segurança para o canal privado.
#  Junta os Módulos 03, 07, 10 e 11.
#
#  ENTRADAS (o runner já fornece)
#    GITHUB_EVENT_PATH   caminho do JSON do evento
#    GITHUB_REPOSITORY   dono/repo
#    GH_TOKEN            token com issues: write
#
#  SEGURANÇA: o título e o corpo do issue são texto de qualquer pessoa da
#  internet. Eles só são LIDOS com jq e comparados — nunca executados nem
#  colados em comandos sem aspas.
# ============================================================================
set -euo pipefail

: "${GITHUB_EVENT_PATH:?rode no GitHub Actions (ou defina GITHUB_EVENT_PATH)}"
: "${GITHUB_REPOSITORY:?rode no GitHub Actions (ou defina GITHUB_REPOSITORY)}"
[[ -f "$GITHUB_EVENT_PATH" ]] || { echo "evento não encontrado: $GITHUB_EVENT_PATH" >&2; exit 1; }

evento="$GITHUB_EVENT_PATH"
numero="$(jq -r '.issue.number' "$evento")"
titulo="$(jq -r '.issue.title // ""' "$evento")"
corpo="$(jq -r '.issue.body // ""' "$evento")"
autor="$(jq -r '.issue.user.login // "alguém"' "$evento")"
associacao="$(jq -r '.issue.author_association // "NONE"' "$evento")"
[[ "$numero" =~ ^[0-9]+$ ]] || { echo "evento sem número de issue" >&2; exit 1; }

# Comparação sem diferenciar maiúsculas: ${var,,} converte para minúsculas.
texto="${titulo,,} ${corpo,,}"
labels=()
contem() { grep -qiE "$1" <<<"$texto"; }

contem 'erro|falha|bug|quebr|não funciona|nao funciona|exception|crash' && labels+=(bug)
contem 'documenta|readme|docs?\b|tutorial'                              && labels+=('documentação')
contem 'seguran|vulnerab|senha|token|cve-|injeç|injec'                  && labels+=('segurança')
if grep -qE '\?[[:space:]]*$' <<<"$titulo" || contem '^como |dúvida|duvida'; then labels+=(pergunta); fi
(( ${#labels[@]} )) || labels=(triagem)

args=()
for l in "${labels[@]}"; do args+=(--add-label "$l"); done
gh issue edit "$numero" -R "$GITHUB_REPOSITORY" "${args[@]}"
echo "issue #$numero → labels: ${labels[*]}"

case "$associacao" in
    FIRST_TIMER|FIRST_TIME_CONTRIBUTOR|NONE)
        gh issue comment "$numero" -R "$GITHUB_REPOSITORY" \
            --body "Olá, @$autor! 👋 Obrigado pelo seu primeiro issue aqui. Alguém do time vai olhar em breve."
        echo "boas-vindas enviadas a @$autor" ;;
esac

if [[ " ${labels[*]} " == *" segurança "* ]]; then
    gh issue comment "$numero" -R "$GITHUB_REPOSITORY" \
        --body "⚠️ Se isto for uma **vulnerabilidade**, por favor não publique detalhes aqui: use **Security → Report a vulnerability** (relato privado), como explica o SECURITY.md."
    echo "orientação de segurança enviada"
fi
