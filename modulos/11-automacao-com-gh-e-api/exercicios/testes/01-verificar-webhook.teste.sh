# shellcheck shell=bash
# Testes do exercício 11.01 — Verificador de assinatura de webhook
S='segredo-de-teste'
assinar() { printf 'sha256=%s' "$(openssl dgst -sha256 -hmac "$S" < "$1" | awk '{print $NF}')"; }
teste_assinatura_valida() {
    printf '{"action":"opened"}' > corpo.json
    executar "$S" corpo.json "$(assinar corpo.json)"
    afirmar_status 0; afirmar_igual "válida" "$SAIDA"
}
teste_corpo_alterado() {
    printf '{"action":"opened"}' > corpo.json
    local a; a="$(assinar corpo.json)"
    printf '{"action":"closed"}' > corpo.json
    executar "$S" corpo.json "$a"
    afirmar_status 1; afirmar_contem "inválida" "$ERRO"
}
teste_segredo_errado() {
    printf 'x' > corpo.json
    executar "outro-segredo" corpo.json "$(assinar corpo.json)"
    afirmar_status 1
}
teste_byte_a_byte() {
    printf '{"a":1}\n' > corpo.json           # COM \n final: faz parte do corpo
    executar "$S" corpo.json "$(assinar corpo.json)"
    afirmar_status 0 "use os bytes exatos do arquivo"
}
teste_sem_prefixo() {
    printf 'x' > corpo.json
    local a; a="$(assinar corpo.json)"
    executar "$S" corpo.json "${a#sha256=}"
    afirmar_status 1; afirmar_contem "formato inválido" "$ERRO"
}
teste_argumentos() {
    executar "$S"
    afirmar_status 2
    executar "$S" nao-existe.json sha256=abc
    afirmar_status 2
}
