# shellcheck shell=bash
# Testes do exercício 03.03 — A fila de triagem
teste_com_dados_de_exemplo() {
    executar aluno/laboratorio
    afirmar_status 0
    afirmar_igual $'#9 Documentar a API de pedidos [documentação, good first issue]\n#10 Botão de login desalinhado no celular [bug]\n#11 Adicionar modo escuro [melhoria]' "$SAIDA"
}
teste_chamada() {
    executar aluno/laboratorio
    afirmar_igual "1" "$(contar_chamadas_gh 'issue list*')" "uma única chamada"
    afirmar_igual "aluno/laboratorio" "$(valor_opcao_gh 'issue list*' -R)"
    afirmar_igual "open" "$(valor_opcao_gh 'issue list*' --state)"
    afirmar_contem "assignees" "$(valor_opcao_gh 'issue list*' --json)"
}
teste_issue_sem_labels() {
    simular_gh 'issue list*' '[{"number":3,"title":"Sem rótulo","assignees":[],"labels":[]}]'
    executar a/b
    afirmar_igual "#3 Sem rótulo []" "$SAIDA"
}
teste_fila_vazia() {
    simular_gh 'issue list*' '[{"number":1,"title":"X","assignees":[{"login":"bia"}],"labels":[]}]'
    executar a/b
    afirmar_igual "fila vazia 🎉" "$SAIDA"
}
