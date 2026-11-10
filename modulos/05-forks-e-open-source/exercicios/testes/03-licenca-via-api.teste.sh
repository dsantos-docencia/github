# shellcheck shell=bash
# Testes do exercício 05.03 — Licença oficial via API
teste_cria_licenca_mit() {
    executar mit 2026 "Ana Dev"
    afirmar_status 0
    afirmar_arquivo LICENSE
    afirmar_igual "MIT License" "$(head -1 LICENSE)"
    afirmar_contem "Copyright (c) 2026 Ana Dev" "$(cat LICENSE)"
}
teste_chamou_a_api_certa() {
    executar mit 2026 "Ana Dev"
    afirmar_chamou_gh 'api licenses/mit*'
}
teste_sem_marcadores() {
    executar mit 2030 "Bia"
    afirmar_nao_contem "[year]" "$(cat LICENSE)"; afirmar_nao_contem "[fullname]" "$(cat LICENSE)"
}
teste_nome_com_caracteres_especiais() {
    executar mit 2026 "P&D / Loja do Bairro"
    afirmar_contem "Copyright (c) 2026 P&D / Loja do Bairro" "$(cat LICENSE)"
}
teste_licenca_inexistente() {
    simular_gh 'api licenses/nao-existe*' '{"message":"Not Found"}' 1
    executar nao-existe 2026 "Ana"
    afirmar_status 1
    [[ -e LICENSE ]] && _falhar "não deixe um LICENSE para trás quando a API falha"
    return 0
}
teste_sem_argumentos() {
    executar mit
    afirmar_status 2
}
