# shellcheck shell=bash
# Testes do exercício 04.02 — Template de pull request
T=.github/pull_request_template.md
teste_arquivo() { executar; afirmar_arquivo "$T"; }
teste_secoes_em_ordem() {
    executar
    afirmar_igual $'## O que muda\n## Por quê\n## Como testar' "$(grep -E '^## (O que muda|Por quê|Como testar)$' "$T")" \
        "as três seções, exatamente com esses títulos e nesta ordem"
}
teste_checklist() {
    executar
    grep -q '^## Checklist$' "$T" || _falhar "falta a seção ## Checklist"
    local n; n="$(grep -c '^- \[ \] ' "$T")"
    (( n >= 3 )) || _falhar "a checklist precisa de pelo menos 3 itens '- [ ]' (achei $n)"
}
teste_lembrete_do_issue() {
    executar
    grep -q 'Closes #' "$T" || _falhar "inclua um lembrete com 'Closes #'"
}
