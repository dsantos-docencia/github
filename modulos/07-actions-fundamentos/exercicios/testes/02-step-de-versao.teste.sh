# shellcheck shell=bash
# Testes do exercício 07.02 — Um step que conversa com o runner
preparar() {
    GITHUB_OUTPUT="$(mktemp)"; GITHUB_STEP_SUMMARY="$(mktemp)"
    printf 'algo=antes\n' > "$GITHUB_OUTPUT"      # outro step já escreveu aqui
    export GITHUB_OUTPUT GITHUB_STEP_SUMMARY
}
teste_versao_estavel() {
    preparar; printf '1.4.0\n' > VERSION; executar
    afirmar_status 0
    afirmar_contem "versao=1.4.0" "$(cat "$GITHUB_OUTPUT")"
    afirmar_contem "prerelease=false" "$(cat "$GITHUB_OUTPUT")"
}
teste_prerelease() {
    preparar; printf '2.0.0-rc.1\n' > VERSION; executar
    afirmar_contem "versao=2.0.0-rc.1" "$(cat "$GITHUB_OUTPUT")"
    afirmar_contem "prerelease=true" "$(cat "$GITHUB_OUTPUT")"
}
teste_acrescenta_sem_apagar() {
    preparar; printf '1.0.0\n' > VERSION; executar
    afirmar_igual "algo=antes" "$(head -1 "$GITHUB_OUTPUT")" "use >> (acrescentar): > apagaria o que outros steps escreveram"
}
teste_resumo() {
    preparar; printf '1.0.0\n' > VERSION; executar
    afirmar_contem "### Versão 1.0.0" "$(cat "$GITHUB_STEP_SUMMARY")"
}
teste_versao_invalida() {
    preparar; printf 'v1.0\n' > VERSION; executar
    afirmar_status 1
    afirmar_contem "::error file=VERSION::versão inválida: v1.0" "$SAIDA"
    afirmar_nao_contem "versao=" "$(cat "$GITHUB_OUTPUT")" "com versão inválida, não escreva saídas"
}
teste_sem_arquivo() {
    preparar; executar
    afirmar_status 1
}
