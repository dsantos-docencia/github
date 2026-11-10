# shellcheck shell=bash
# Testes do exercício 11.02 — Um comando novo para o gh
teste_resumo_com_dados_de_exemplo() {
    executar aluno/laboratorio
    afirmar_status 0
    afirmar_igual "aluno/laboratorio: 4 issues abertas, 3 PRs abertos" "$SAIDA"
}
teste_chamadas() {
    executar aluno/laboratorio
    afirmar_chamou_gh 'issue list -R aluno/laboratorio --state open*'
    afirmar_chamou_gh 'pr list -R aluno/laboratorio --state open*'
    afirmar_igual "1000" "$(valor_opcao_gh 'issue list*' --limit)" "use --limit 1000 (o padrão é 30)"
}
teste_outros_numeros() {
    simular_gh 'issue list*' '[]'
    simular_gh 'pr list*' '[{"number":1}]'
    executar empresa/app
    afirmar_igual "empresa/app: 0 issues abertas, 1 PRs abertos" "$SAIDA"
}
teste_repo_da_pasta_atual() {
    executar
    afirmar_chamou_gh 'repo view --json nameWithOwner*' "sem argumento, descubra o repositório com gh repo view"
    afirmar_contem "aluno/laboratorio:" "$SAIDA"
}
teste_fora_de_repositorio() {
    simular_gh 'repo view*' 'no git remotes found' 1
    executar
    afirmar_status 2
}
