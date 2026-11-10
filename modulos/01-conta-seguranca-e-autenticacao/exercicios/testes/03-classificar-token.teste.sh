# shellcheck shell=bash
# Testes do exercício 01.03 — Classificador de tokens
T_CLASSICO="ghp_abcdefghijklmnopqrstuvwxyz0123456789"
teste_classico() {
    executar "$T_CLASSICO"
    afirmar_status 0; afirmar_igual "pessoal clássico · ghp_abcd…" "$SAIDA"
}
teste_fine_grained() {
    executar "github_pat_11ABCDEFG0123456789_abcdefghijklmnopqrstuvwxyz"
    afirmar_igual "pessoal fine-grained · github_p…" "$SAIDA"
}
teste_oauth_e_apps() {
    executar "gho_1234567890abcdefghij";  afirmar_igual "oauth · gho_1234…" "$SAIDA"
    executar "ghs_1234567890abcdefghij";  afirmar_igual "app servidor-servidor · ghs_1234…" "$SAIDA"
    executar "ghu_1234567890abcdefghij";  afirmar_igual "app usuário-servidor · ghu_1234…" "$SAIDA"
    executar "ghr_1234567890abcdefghij";  afirmar_igual "app refresh · ghr_1234…" "$SAIDA"
}
teste_nunca_vaza_o_token() {
    executar "$T_CLASSICO"
    afirmar_nao_contem "$T_CLASSICO" "$SAIDA$ERRO" "o token inteiro apareceu na saída!"
    afirmar_nao_contem "ijklmnop" "$SAIDA$ERRO" "só os 8 primeiros caracteres podem aparecer"
}
teste_desconhecido() {
    executar "senha123"
    afirmar_status 1; afirmar_contem "desconhecido" "$ERRO"
    afirmar_igual "" "$SAIDA" "nada na saída padrão quando não reconhece"
}
teste_sem_argumento() {
    executar; afirmar_status 2; afirmar_contem "uso" "$ERRO"
}
