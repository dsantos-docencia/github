# shellcheck shell=bash
# Testes do exercício 01.01 — E-mail noreply nos commits
teste_configura_email_noreply() {
    executar 1234567 ana-dev
    afirmar_status 0
    afirmar_igual "1234567+ana-dev@users.noreply.github.com" "$(git -C projeto config --local user.email)"
}
teste_configura_nome() {
    executar 1234567 ana-dev
    afirmar_igual "ana-dev" "$(git -C projeto config --local user.name)"
}
teste_nivel_local() {
    executar 99 bia
    afirmar_igual "" "$(git config --global user.email 2>/dev/null)" "não mexa no nível global"
}
teste_commit_usa_o_noreply() {
    executar 42 caio
    unset GIT_AUTHOR_EMAIL GIT_COMMITTER_EMAIL GIT_AUTHOR_NAME GIT_COMMITTER_NAME
    commitar a.txt x "teste" projeto
    afirmar_igual "42+caio@users.noreply.github.com" "$(git -C projeto log -1 --format=%ae)"
}
teste_sem_argumentos_sai_2() {
    executar
    afirmar_status 2; afirmar_contem "uso" "$ERRO"
}
teste_id_invalido_sai_1() {
    executar abc ana
    afirmar_status 1 "ID não numérico deve sair com 1"
    [[ -e projeto ]] && _falhar "com ID inválido nada deve ser criado"
    return 0
}
