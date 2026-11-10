# shellcheck shell=bash
# Testes do Projeto 03 — triagem automática (eventos de exemplo + gh simulado)
evento() {   # evento TÍTULO CORPO [ASSOCIAÇÃO]
    jq -n --arg t "$1" --arg b "$2" --arg a "${3:-MEMBER}" \
        '{action:"opened", issue:{number:42, title:$t, body:$b, user:{login:"visitante"}, author_association:$a}}' > evento.json
    export GITHUB_EVENT_PATH="$PWD/evento.json" GITHUB_REPOSITORY=aluno/laboratorio
}
teste_bug() {
    evento "Erro 500 ao salvar" "A página quebra."
    executar
    afirmar_status 0
    afirmar_chamou_gh 'issue edit 42 -R aluno/laboratorio --add-label bug'
}
teste_varios_labels_numa_chamada() {
    evento "Como configurar o token?" "Não achei na documentação."
    executar
    afirmar_igual "1" "$(contar_chamadas_gh 'issue edit*')" "uma única chamada de edição"
    afirmar_chamou_gh "issue edit 42 *--add-label 'documentação'*"
    afirmar_chamou_gh "issue edit 42 *--add-label 'segurança'*"
    afirmar_chamou_gh "issue edit 42 *--add-label pergunta*"
}
teste_sem_palavra_chave() {
    evento "Sugestão de cor" "Poderia ser azul."
    executar
    afirmar_chamou_gh 'issue edit 42 -R aluno/laboratorio --add-label triagem'
}
teste_boas_vindas_so_para_novatos() {
    evento "Erro" "x" FIRST_TIME_CONTRIBUTOR
    executar
    afirmar_contem "@visitante" "$(valor_opcao_gh 'issue comment*' --body)"
    gh_simulado_reiniciar
    evento "Erro" "x" MEMBER
    executar
    afirmar_nao_chamou_gh 'issue comment*' "membros do time não recebem boas-vindas"
}
teste_orienta_seguranca() {
    evento "Vulnerabilidade de injeção no login" "detalhes..." MEMBER
    executar
    afirmar_contem "Report a vulnerability" "$(valor_opcao_gh 'issue comment*' --body)"
}
teste_titulo_malicioso_nao_executa() {
    evento '$(touch HACKEADO) `touch HACKEADO2`' 'x"; touch HACKEADO3; echo "'
    executar
    afirmar_status 0
    [[ -e HACKEADO || -e HACKEADO2 || -e HACKEADO3 ]] && _falhar "texto do issue foi executado!"
    return 0
}
teste_fora_do_actions() {
    unset GITHUB_EVENT_PATH
    executar
    afirmar_status_diferente_de_zero
}
