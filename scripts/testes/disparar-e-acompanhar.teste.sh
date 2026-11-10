# shellcheck shell=bash
export ESPERA=0
teste_dispara_e_acompanha() {
    simular_gh 'run list*' '[{"databaseId":9100,"createdAt":"2999-01-01T00:00:00Z"}]'
    executar relatorio.yml -R aluno/loja -f dias=3 --ref main
    afirmar_status 0
    afirmar_chamou_gh 'workflow run relatorio.yml -R aluno/loja --ref main -f dias=3'
    afirmar_chamou_gh 'run watch 9100 -R aluno/loja --exit-status'
}
teste_falha_da_execucao_vira_falha_do_script() {
    simular_gh 'run list*' '[{"databaseId":9100,"createdAt":"2999-01-01T00:00:00Z"}]'
    simular_gh 'run watch*' 'X testes failed' 1
    executar ci.yml
    afirmar_status 1
}
teste_execucao_antiga_nao_conta() {
    simular_gh 'run list*' '[{"databaseId":1,"createdAt":"2001-01-01T00:00:00Z"}]'
    executar ci.yml
    afirmar_status 1 "uma execução de antes do disparo não é a nossa"
    afirmar_nao_chamou_gh 'run watch*'
}
teste_sem_workflow() { executar; afirmar_status 2; }
