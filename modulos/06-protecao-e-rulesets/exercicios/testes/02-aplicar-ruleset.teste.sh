# shellcheck shell=bash
# Testes do exercício 06.02 — Aplicar um ruleset sem duplicar
arquivo() { printf '{"name":"%s","target":"branch","enforcement":"active","rules":[{"type":"deletion"}]}\n' "$1" > r.json; }
teste_atualiza_quando_existe() {
    arquivo proteger-main          # o simulador já tem "proteger-main" com id 101
    executar aluno/loja r.json
    afirmar_status 0
    afirmar_chamou_gh 'api -X PUT repos/aluno/loja/rulesets/101 --input r.json*' "deveria atualizar o ruleset 101 com PUT"
    afirmar_nao_chamou_gh 'api -X POST*' "não crie um segundo ruleset com o mesmo nome"
    afirmar_igual "atualizado: proteger-main (101)" "$SAIDA"
}
teste_cria_quando_nao_existe() {
    arquivo tags-protegidas
    simular_gh 'api repos/aluno/loja/rulesets' '[]'
    executar aluno/loja r.json
    afirmar_chamou_gh 'api -X POST repos/aluno/loja/rulesets --input r.json*'
    afirmar_igual "criado: tags-protegidas" "$SAIDA"
}
teste_nome_parecido_nao_conta() {
    arquivo proteger
    executar aluno/loja r.json
    afirmar_chamou_gh 'api -X POST*' "'proteger' é diferente de 'proteger-main': deveria criar"
}
teste_json_invalido() {
    printf '{ isto não é json' > r.json
    executar aluno/loja r.json
    afirmar_status 1
    afirmar_nao_chamou_gh 'api -X *'
}
teste_arquivo_inexistente() {
    executar aluno/loja nao-existe.json
    afirmar_status 1
}
