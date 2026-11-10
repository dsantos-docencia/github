# shellcheck shell=bash
# Testes do exercício 05.01 — Checklist de saúde da comunidade
completo() {
    mkdir -p p/docs p/.github/ISSUE_TEMPLATE
    touch p/README.md p/LICENSE p/docs/CONTRIBUTING.md p/.github/CODE_OF_CONDUCT.md p/SECURITY.md p/.github/pull_request_template.md
}
teste_projeto_completo() {
    completo; executar p
    afirmar_status 0
    afirmar_igual $'✔ README\n✔ LICENSE\n✔ CONTRIBUTING\n✔ CODE_OF_CONDUCT\n✔ SECURITY\n✔ ISSUE_TEMPLATE\n✔ PR_TEMPLATE\nnota: 7/7' "$SAIDA"
}
teste_aceita_docs_e_github() {
    completo; executar p
    afirmar_contem "✔ CONTRIBUTING" "$SAIDA" "CONTRIBUTING.md em docs/ conta"
    afirmar_contem "✔ CODE_OF_CONDUCT" "$SAIDA" "CODE_OF_CONDUCT.md em .github/ conta"
}
teste_faltando() {
    mkdir -p q; touch q/README.md q/LICENSE.md q/PULL_REQUEST_TEMPLATE.md
    executar q
    afirmar_status 1
    afirmar_igual $'✔ README\n✔ LICENSE\n✘ CONTRIBUTING\n✘ CODE_OF_CONDUCT\n✘ SECURITY\n✘ ISSUE_TEMPLATE\n✔ PR_TEMPLATE\nnota: 3/7' "$SAIDA"
}
teste_template_precisa_ser_pasta() {
    mkdir -p r; touch r/ISSUE_TEMPLATE.md
    executar r
    afirmar_contem "✘ ISSUE_TEMPLATE" "$SAIDA" "ISSUE_TEMPLATE é uma pasta, não um arquivo .md"
}
teste_pasta_atual_por_padrao() {
    touch README.md
    executar
    afirmar_contem "✔ README" "$SAIDA" "sem argumento, verifique a pasta atual"
}
teste_pasta_inexistente() {
    executar nao-existe
    afirmar_status 2
}
