# shellcheck shell=bash
# Testes do exercício 02.03 — Inventário dos repositórios de uma conta
teste_com_dados_de_exemplo() {
    executar aluno
    afirmar_status 0
    afirmar_igual $'públicos: 2\nprivados: 1\narquivados: 1' "$SAIDA"
}
teste_chamada_ao_gh() {
    executar aluno
    afirmar_igual "1" "$(contar_chamadas_gh 'repo list aluno*')" "uma única chamada a gh repo list aluno"
    afirmar_igual "1000" "$(valor_opcao_gh 'repo list*' --limit)" "use --limit 1000 (o padrão do gh é só 30!)"
    afirmar_contem "isArchived" "$(valor_opcao_gh 'repo list*' --json)"
}
teste_com_outros_dados() {
    simular_gh 'repo list*' '[{"name":"a","isPrivate":true,"isArchived":true},{"name":"b","isPrivate":true,"isArchived":false},{"name":"c","isPrivate":true,"isArchived":false}]'
    executar empresa
    afirmar_igual $'públicos: 0\nprivados: 3\narquivados: 1' "$SAIDA"
}
teste_conta_vazia() {
    simular_gh 'repo list*' '[]'
    executar ninguem
    afirmar_igual $'públicos: 0\nprivados: 0\narquivados: 0' "$SAIDA"
}
