# shellcheck shell=bash
teste_conjunto_padrao() {
    executar aluno/loja
    afirmar_status 0
    afirmar_igual "8" "$(contar_chamadas_gh 'label create*--force*')"
    afirmar_chamou_gh "label create 'help wanted' --color 008672*"
}
teste_arquivo_proprio() {
    printf '# comentário\nurgente\tff0000\tAgora\n\n' > l.tsv
    executar aluno/loja l.tsv
    afirmar_igual "1" "$(contar_chamadas_gh 'label create*')"
}
teste_extras_so_simula() {
    printf 'bug\td73a4a\tx\n' > l.tsv
    executar aluno/loja l.tsv --remover-extras
    afirmar_contem "· sobraria: melhoria" "$SAIDA"
    afirmar_nao_chamou_gh 'label delete*' "sem --aplicar, nada é apagado"
}
teste_extras_aplicar() {
    printf 'bug\td73a4a\tx\n' > l.tsv
    executar aluno/loja l.tsv --remover-extras --aplicar
    afirmar_chamou_gh 'label delete melhoria --yes*'
    afirmar_nao_chamou_gh 'label delete bug*' "bug está no conjunto: fica"
}
teste_sem_repo() { executar; afirmar_status 2; }
