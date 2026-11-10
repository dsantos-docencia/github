# shellcheck shell=bash
teste_clona_os_ativos() {
    executar aluno repos
    afirmar_status 0
    afirmar_chamou_gh 'repo clone aluno/laboratorio repos/laboratorio*'
    afirmar_chamou_gh 'repo clone aluno/site-pessoal repos/site-pessoal*'
    afirmar_nao_chamou_gh 'repo clone aluno/projeto-antigo*' "arquivados ficam de fora por padrão"
    afirmar_igual "1000" "$(valor_opcao_gh 'repo list*' --limit)"
}
teste_inclui_arquivados() {
    executar aluno repos --incluir-arquivados
    afirmar_chamou_gh 'repo clone aluno/projeto-antigo*'
}
teste_atualiza_existente() {
    git init -q --bare srv.git; git clone -q srv.git tmp 2>/dev/null
    commitar a.txt 1 "c1" tmp; git -C tmp push -q origin main
    mkdir repos; git clone -q srv.git repos/laboratorio 2>/dev/null
    commitar a.txt 2 "c2" tmp; git -C tmp push -q origin main
    executar aluno repos
    afirmar_nao_chamou_gh 'repo clone aluno/laboratorio*' "já existe: não clone de novo"
    afirmar_igual "$(git -C srv.git rev-parse main)" "$(git -C repos/laboratorio rev-parse HEAD)" "deveria ter feito pull"
    afirmar_contem "1 clonados, 1 atualizados" "$SAIDA"
}
teste_sem_dono() { executar; afirmar_status 2; }
