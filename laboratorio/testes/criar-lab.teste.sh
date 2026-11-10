# shellcheck shell=bash
# Testes do laboratorio/criar-lab.sh (modo --simular: nada sai da máquina)
teste_cria_repositorio_publico() {
    executar --simular
    afirmar_status 0
    afirmar_chamou_gh 'repo create aluno/lab-github --public *'
}
teste_privado_e_nome() {
    executar --simular --privado --nome meu-lab
    afirmar_chamou_gh 'repo create aluno/meu-lab --private *'
}
teste_labels_e_issues() {
    executar --simular
    afirmar_igual "5" "$(contar_chamadas_gh 'label create*')" "5 labels"
    afirmar_igual "4" "$(contar_chamadas_gh 'issue create*')" "4 issues de exemplo"
    afirmar_chamou_gh "issue create -R aluno/lab-github --title 'Documentar a API de pedidos' *--label 'documentação' --label 'good first issue'"
}
teste_opcao_invalida() {
    executar --xyz
    afirmar_status 2
}
