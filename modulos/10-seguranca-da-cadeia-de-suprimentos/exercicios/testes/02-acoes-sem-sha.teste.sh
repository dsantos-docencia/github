# shellcheck shell=bash
# Testes do exercício 10.02 — Detector de ações não fixadas
SHA=3d3c42e5aac5ba805825da76410c181273ba90b1
montar() {
    mkdir -p wf
    cat > wf/ci.yml <<YAML
jobs:
  a:
    steps:
      - uses: actions/checkout@$SHA # v7.0.1
      - uses: "actions/cache@v6" # cache
      - name: setup
        uses: actions/setup-node@main
      - uses: ./.github/actions/local
      - uses: docker://alpine:3.20
YAML
    cat > wf/outro.yaml <<YAML
jobs:
  b:
    uses: org/workflows/.github/workflows/w.yml@v1
YAML
}
teste_encontra_os_nao_fixados() {
    montar; executar wf
    afirmar_status 1
    afirmar_igual $'wf/ci.yml:5: actions/cache@v6\nwf/ci.yml:7: actions/setup-node@main\nwf/outro.yaml:3: org/workflows/.github/workflows/w.yml@v1' "$SAIDA"
}
teste_ignora_sha_local_e_docker() {
    montar; executar wf
    afirmar_nao_contem "checkout" "$SAIDA" "checkout está fixado por SHA"
    afirmar_nao_contem "./.github" "$SAIDA" "ações locais não têm versão"
    afirmar_nao_contem "docker://" "$SAIDA"
}
teste_tudo_fixado() {
    mkdir -p ok; printf 'jobs:\n  a:\n    steps:\n      - uses: actions/checkout@%s\n' "$SHA" > ok/ci.yml
    executar ok
    afirmar_status 0; afirmar_igual "" "$SAIDA"
}
teste_sha_curto_nao_vale() {
    mkdir -p c; printf '      - uses: actions/checkout@3d3c42e\n' > c/ci.yml
    executar c
    afirmar_status 1 "SHA curto (7 caracteres) não é imutável o suficiente"
}
teste_pasta_padrao_e_inexistente() {
    executar
    afirmar_status 2 "sem .github/workflows, saia com 2"
}
