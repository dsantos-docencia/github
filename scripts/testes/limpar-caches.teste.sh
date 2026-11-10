# shellcheck shell=bash
teste_simula_por_padrao() {
    executar aluno/loja
    afirmar_status 0
    afirmar_contem "· apagaria: npm-Linux-old999" "$SAIDA" "cache de refs/pull/5 é candidato"
    afirmar_nao_contem "npm-Linux-abc123" "$SAIDA" "cache recente da main fica"
    afirmar_nao_chamou_gh 'cache delete*'
}
teste_aplicar() {
    executar aluno/loja --aplicar
    afirmar_chamou_gh 'cache delete 70 -R aluno/loja'
    afirmar_nao_chamou_gh 'cache delete 71*'
}
teste_antigos_tambem() {
    simular_gh 'cache list*' '[{"id":1,"key":"velho","ref":"refs/heads/main","sizeInBytes":1048576,"lastAccessedAt":"2020-01-01T00:00:00Z"}]'
    executar aluno/loja --dias 30
    afirmar_contem "· apagaria: velho (1 MB)" "$SAIDA"
}
teste_uso() { executar; afirmar_status 2; executar a/b --dias x; afirmar_status 2; }
