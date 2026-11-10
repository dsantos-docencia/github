# shellcheck shell=bash
# Testes do exercício 02.02 — Configurar o repositório pelo terminal
teste_edita_o_repositorio_certo() {
    executar aluno/loja
    afirmar_status 0
    afirmar_chamou_gh 'repo edit aluno/loja *' "chame gh repo edit aluno/loja ..."
}
teste_topicos() {
    executar aluno/loja
    afirmar_chamou_gh 'repo edit*--add-topic curso*' "falta --add-topic curso"
    afirmar_chamou_gh 'repo edit*--add-topic github*' "falta --add-topic github"
}
teste_metodos_de_merge() {
    executar aluno/loja
    afirmar_chamou_gh 'repo edit*--enable-merge-commit=false*'
    afirmar_chamou_gh 'repo edit*--enable-squash-merge*'
}
teste_branch_e_wiki() {
    executar aluno/loja
    afirmar_chamou_gh 'repo edit*--delete-branch-on-merge*'
    afirmar_chamou_gh 'repo edit*--enable-wiki=false*'
}
teste_uma_chamada_so() {
    executar aluno/loja
    afirmar_igual "1" "$(contar_chamadas_gh 'repo edit*')" "tudo numa única chamada"
}
teste_validacao() {
    executar
    afirmar_status 2; afirmar_contem "uso" "$ERRO"
    executar "so-um-nome"
    afirmar_status 2 "'so-um-nome' não está no formato dono/repo"
    afirmar_nao_chamou_gh 'repo edit*' "com argumento inválido, não chame o gh"
}
