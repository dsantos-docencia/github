# shellcheck shell=bash
# Testes do exercício 06.03 — Auditoria das regras de uma branch
teste_com_dados_de_exemplo() {
    executar aluno/laboratorio
    afirmar_status 1 "falta required_status_checks nos dados de exemplo"
    afirmar_igual $'✔ deletion\n✔ non_fast_forward\n✔ pull_request\n✘ required_status_checks' "$SAIDA"
}
teste_consulta_a_branch_padrao_main() {
    executar aluno/laboratorio
    afirmar_chamou_gh 'api repos/aluno/laboratorio/rules/branches/main*'
}
teste_outra_branch() {
    executar aluno/laboratorio develop
    afirmar_chamou_gh 'api repos/aluno/laboratorio/rules/branches/develop*'
}
teste_tudo_presente() {
    simular_gh 'api repos/*/rules/branches/*' '[{"type":"pull_request"},{"type":"required_status_checks"},{"type":"deletion"},{"type":"non_fast_forward"},{"type":"required_linear_history"}]'
    executar a/b
    afirmar_status 0
    afirmar_igual $'✔ deletion\n✔ non_fast_forward\n✔ pull_request\n✔ required_status_checks' "$SAIDA"
}
teste_branch_sem_regras() {
    simular_gh 'api repos/*/rules/branches/*' '[]'
    executar a/b
    afirmar_status 1
    afirmar_igual "4" "$(grep -c '^✘' <<<"$SAIDA")"
}
