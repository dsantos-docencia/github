# shellcheck shell=bash
# Testes do exercício 00.02 — O repositório especial de perfil
teste_sem_argumento_sai_2() {
    executar
    afirmar_status 2 "sem argumento, saia com 2 (erro de uso)"
    afirmar_contem "uso" "$ERRO" "mostre uma mensagem de uso em stderr"
}
teste_cria_repositorio_com_o_nome() {
    executar ana-dev
    afirmar_diretorio ana-dev/.git "a pasta ana-dev deveria ser um repositório Git"
    afirmar_igual "refs/heads/main" "$(git -C ana-dev symbolic-ref HEAD)" "branch inicial main"
}
teste_primeira_linha_do_readme() {
    executar ana-dev
    afirmar_igual "### Olá, eu sou @ana-dev 👋" "$(head -1 ana-dev/README.md)"
}
teste_funciona_com_outro_usuario() {
    executar bruno
    afirmar_contem "@bruno" "$(head -1 bruno/README.md)" "use o valor de \$1, não um nome fixo"
}
teste_commit() {
    executar ana-dev
    afirmar_igual "docs: README do perfil" "$(git -C ana-dev log -1 --format=%s 2>/dev/null)"
    afirmar_igual "" "$(git -C ana-dev status --porcelain)" "nada pode ficar fora do commit"
}
