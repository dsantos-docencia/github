# shellcheck shell=bash
# Testes do exercício 00.01 — README com recursos do GitHub
teste_cria_readme() {
    executar
    afirmar_arquivo README.md "o script deve criar README.md na pasta atual"
}
teste_titulo_h1() {
    executar
    afirmar_casa '(^|'$'\n'')# [^#]' "$(cat README.md)" "falta um título de nível 1 (# Título)"
}
teste_alerta_note() {
    executar
    grep -q '^> \[!NOTE\]' README.md || _falhar "falta o alerta: uma linha exatamente '> [!NOTE]'"
    grep -A1 '^> \[!NOTE\]' README.md | tail -1 | grep -q '^> .' || _falhar "o alerta precisa de uma linha de texto logo abaixo, começando com '> '"
}
teste_lista_de_tarefas() {
    executar
    grep -q '^[-*] \[x\] ' README.md || _falhar "falta um item marcado: - [x] ..."
    grep -q '^[-*] \[ \] ' README.md || _falhar "falta um item pendente: - [ ] ..."
}
teste_tabela() {
    executar
    grep -Eq '^\|.*\|$' README.md || _falhar "falta uma tabela (linhas começando e terminando com |)"
    grep -Eq '^\|[ :]*-{3,}' README.md || _falhar "a tabela precisa da linha separadora |---|"
}
teste_mermaid() {
    executar
    grep -q '^```mermaid' README.md || _falhar 'falta o bloco que começa com ```mermaid'
    afirmar_igual "0" "$(( $(grep -c '^```' README.md) % 2 ))" 'há um bloco de código aberto e não fechado (número ímpar de linhas com ```)'
}
