# shellcheck shell=bash
# Testes do exercício 05.02 — Sincronizar o fork com o original
montar() {
    git init -q --bare upstream.git
    git clone -q upstream.git tmp 2>/dev/null
    commitar README.md v1 "docs: v1" tmp; git -C tmp push -q origin main
    git clone -q --bare upstream.git fork.git
    git clone -q fork.git meu-fork 2>/dev/null
    commitar README.md v2 "docs: v2" tmp
    commitar app.txt app "feat: app" tmp; git -C tmp push -q origin main
}
teste_sincroniza() {
    montar; executar "$PWD/upstream.git"
    afirmar_status 0
    afirmar_igual "$(git -C upstream.git rev-parse main)" "$(git -C fork.git rev-parse main)" "a main do fork (no servidor) deveria igualar a do upstream"
    afirmar_contem "fork sincronizado em $(git -C upstream.git rev-parse --short main)" "$SAIDA"
}
teste_remoto_upstream() {
    montar; executar "$PWD/upstream.git"
    afirmar_igual "$PWD/upstream.git" "$(git -C meu-fork remote get-url upstream)"
}
teste_roda_duas_vezes() {
    montar; executar "$PWD/upstream.git"; executar "$PWD/upstream.git"
    afirmar_status 0 "rodar de novo não pode falhar (o remoto upstream já existe)"
}
teste_recusa_se_divergiu() {
    montar
    commitar meu.txt meu "feat: commit na main do fork" meu-fork
    git -C meu-fork push -q origin main
    local antes; antes="$(git -C fork.git rev-parse main)"
    executar "$PWD/upstream.git"
    afirmar_status_diferente_de_zero "com a main do fork divergente, use --ff-only e falhe"
    afirmar_igual "$antes" "$(git -C fork.git rev-parse main)" "nada pode ser enviado ao fork"
}
