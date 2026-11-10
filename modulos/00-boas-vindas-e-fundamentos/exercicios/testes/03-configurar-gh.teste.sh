# shellcheck shell=bash
# Testes do exercício 00.03 — Deixando o gh do seu jeito
teste_git_protocol_ssh() {
    usar_gh_real; executar
    afirmar_status 0 "o script falhou"
    afirmar_igual "ssh" "$(gh config get git_protocol)"
}
teste_prompt_desligado() {
    usar_gh_real; executar
    afirmar_igual "disabled" "$(gh config get prompt)"
}
teste_alias_minhas() {
    usar_gh_real; executar
    afirmar_contem "issue list --assignee @me" "$(gh alias list)" "alias minhas → issue list --assignee @me"
    afirmar_casa 'minhas' "$(gh alias list)"
}
teste_alias_rascunho() {
    usar_gh_real; executar
    afirmar_contem "pr create --draft --fill" "$(gh alias list)" "alias rascunho → pr create --draft --fill"
}
