# shellcheck shell=bash
# Testes do exercício 04.01 — CODEOWNERS na ordem certa
regras() { grep -vE '^\s*(#|$)' .github/CODEOWNERS | awk '{$1=$1; print}'; }
teste_arquivo() {
    executar; afirmar_arquivo .github/CODEOWNERS
}
teste_padrao_geral_primeiro() {
    executar
    afirmar_igual "* @aluno" "$(regras | head -1)" "a PRIMEIRA regra deve ser: * @aluno"
}
teste_regras() {
    executar
    local r; r="$(regras)"
    afirmar_contem "*.js @bia-dev" "$r"
    afirmar_contem "/docs/ @org/documentacao" "$r"
    afirmar_contem "/.github/ @aluno @org/plataforma" "$r" "/.github/ tem DOIS donos na mesma linha"
}
teste_quatro_regras() {
    executar
    afirmar_igual "4" "$(regras | wc -l | tr -d ' ')" "exatamente 4 regras (comentários e linhas vazias não contam)"
}
