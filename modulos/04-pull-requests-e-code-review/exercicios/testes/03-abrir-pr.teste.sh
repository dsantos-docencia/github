# shellcheck shell=bash
# Testes do exercício 04.03 — Abrir um PR completo pelo terminal
montar() {
    git init -q --bare servidor.git
    git clone -q servidor.git app 2>/dev/null
    commitar app.txt base "feat: base" app
    git -C app push -q origin main
    git -C app switch -q -c feature/frete
    commitar frete.txt "frete" "feat: calcula frete" app
    commitar frete.txt "frete grátis" "feat: frete grátis acima de R\$ 200" app
}
teste_publica_com_upstream() {
    montar; executar 12
    afirmar_status 0
    afirmar_igual "$(git -C app rev-parse HEAD)" "$(git -C servidor.git rev-parse feature/frete 2>/dev/null)" "a branch deveria estar no servidor"
    afirmar_igual "origin/feature/frete" "$(git -C app rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)" "use git push -u para ligar o upstream"
}
teste_pr_base_head_draft() {
    montar; executar 12
    afirmar_igual "main" "$(valor_opcao_gh 'pr create*' --base)"
    afirmar_igual "feature/frete" "$(valor_opcao_gh 'pr create*' --head)"
    afirmar_chamou_gh 'pr create*--draft*' "abra como rascunho (--draft)"
}
teste_titulo_do_ultimo_commit() {
    montar; executar 12
    afirmar_igual 'feat: frete grátis acima de R$ 200' "$(valor_opcao_gh 'pr create*' --title)"
}
teste_corpo_fecha_o_issue() {
    montar; executar 12
    afirmar_contem "Closes #12" "$(valor_opcao_gh 'pr create*' --body)"
    executar 7
    afirmar_contem "Closes #7" "$(valor_opcao_gh 'pr create*' --body)" "use o número recebido em \$1"
}
teste_outra_branch() {
    montar; git -C app switch -q -c fix/cep; commitar cep.txt x "fix: CEP com traço" app
    executar 3
    afirmar_igual "fix/cep" "$(valor_opcao_gh 'pr create*' --head)" "descubra a branch atual em vez de escrever fixo"
}
teste_sem_issue() {
    montar; executar
    afirmar_status 2
    afirmar_nao_chamou_gh 'pr create*'
    git -C servidor.git rev-parse -q --verify feature/frete >/dev/null && _falhar "sem argumento válido, não publique nada"
    return 0
}
