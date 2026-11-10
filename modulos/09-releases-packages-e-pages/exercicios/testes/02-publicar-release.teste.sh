# shellcheck shell=bash
# Testes do exercício 09.02 — Publicar uma release com checksums
montar() { mkdir -p src && printf 'app\n' > src/app.js; }
teste_pacote_e_checksum() {
    montar; executar v1.2.0
    afirmar_status 0
    afirmar_arquivo dist/loja-1.2.0.tar.gz
    afirmar_arquivo dist/SHA256SUMS
    (cd dist && sha256sum -c SHA256SUMS >/dev/null 2>&1) || _falhar "cd dist && sha256sum -c SHA256SUMS falhou (caminhos relativos a dist/?)"
    tar -tzf dist/loja-1.2.0.tar.gz | grep -q 'src/app.js' || _falhar "o pacote deveria conter src/app.js"
}
teste_chamada_da_release() {
    montar; executar v1.2.0
    afirmar_chamou_gh 'release create v1.2.0 dist/loja-1.2.0.tar.gz dist/SHA256SUMS *'
    afirmar_igual "v1.2.0" "$(valor_opcao_gh 'release create*' --title)"
    afirmar_chamou_gh 'release create*--generate-notes*'
    afirmar_chamou_gh 'release create*--verify-tag*'
    afirmar_nao_chamou_gh 'release create*--prerelease*' "versão estável não é pré-lançamento"
}
teste_prerelease() {
    montar; executar v2.0.0-rc.1
    afirmar_arquivo dist/loja-2.0.0-rc.1.tar.gz
    afirmar_chamou_gh 'release create v2.0.0-rc.1 *--prerelease*'
}
teste_versao_invalida() {
    montar; executar 1.2.0
    afirmar_status 2 "sem o v não é uma tag válida"
    afirmar_nao_chamou_gh 'release*'
    executar v1.2
    afirmar_status 2
}
