# shellcheck shell=bash
# Testes do exercício 03.02 — Labels padronizados em lote
montar() {
    printf '# nome\tcor\tdescrição\n' > labels.tsv
    printf 'bug\td73a4a\tAlgo não funciona\n' >> labels.tsv
    printf '\n' >> labels.tsv
    printf 'prioridade:alta\td93f0b\tResolver nesta semana\n' >> labels.tsv
    printf 'good first issue\t7057ff\tBom para quem está começando' >> labels.tsv   # sem \n final!
}
teste_cria_todos() {
    montar; executar labels.tsv aluno/loja
    afirmar_status 0
    afirmar_igual "3" "$(contar_chamadas_gh 'label create*')" "3 labels no arquivo (comentário e linha vazia não contam; a última linha não tem \\n)"
}
teste_valores_corretos() {
    montar; executar labels.tsv aluno/loja
    afirmar_chamou_gh "label create prioridade:alta *" "crie o label prioridade:alta"
    afirmar_igual "d93f0b" "$(valor_opcao_gh 'label create prioridade:alta*' --color)"
    afirmar_igual "Resolver nesta semana" "$(valor_opcao_gh 'label create prioridade:alta*' --description)" "a descrição tem espaços: use aspas"
}
teste_nome_com_espacos() {
    montar; executar labels.tsv aluno/loja
    afirmar_chamou_gh "label create 'good first issue' *" "o nome 'good first issue' deve ir como UM argumento"
}
teste_force_e_repo() {
    montar; executar labels.tsv aluno/loja
    afirmar_igual "3" "$(contar_chamadas_gh 'label create*--force*')" "use --force em todas (idempotência)"
    afirmar_igual "aluno/loja" "$(valor_opcao_gh 'label create bug*' -R)"
}
teste_resumo() {
    montar; executar labels.tsv aluno/loja
    afirmar_igual "3 labels sincronizados" "$(tail -1 <<<"$SAIDA")"
}
teste_arquivo_inexistente() {
    executar nao-existe.tsv aluno/loja
    afirmar_status 1
    afirmar_nao_chamou_gh 'label create*'
}
