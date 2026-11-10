# shellcheck shell=bash
teste_gera_notas() {
    simular_gh 'api -X POST repos/*/releases/generate-notes*' '{"body":"## O que mudou\n* feat: x"}'
    executar aluno/loja v1.2.0 v1.1.0
    afirmar_status 0
    afirmar_chamou_gh 'api -X POST repos/aluno/loja/releases/generate-notes -f tag_name=v1.2.0 -f previous_tag_name=v1.1.0*'
    afirmar_contem "* feat: x" "$SAIDA"
}
teste_sem_anterior() {
    simular_gh 'api -X POST*' '{"body":"x"}'
    executar aluno/loja v1.0.0
    afirmar_nao_chamou_gh '*previous_tag_name*' "sem tag anterior, o GitHub escolhe a release anterior sozinho"
}
teste_salva_em_arquivo() {
    simular_gh 'api -X POST*' '{"body":"* fix: y"}'
    executar aluno/loja v1.2.0 --saida NOTAS.md
    afirmar_igual $'## v1.2.0\n\n* fix: y' "$(cat NOTAS.md)"
}
teste_uso() { executar aluno/loja; afirmar_status 2; }
