# shellcheck shell=bash
# Testes do exercício 08.01 — Uma matriz com exclusão e inclusão
W=.github/workflows/matriz.yml
expandir() {   # conta os jobs que a matriz gera (mesma regra do GitHub, simplificada)
    json_de "$W" | python3 -c '
import itertools, json, sys
m = dict(json.load(sys.stdin)["jobs"]["testes"]["strategy"]["matrix"])
exc, inc = m.pop("exclude", []), m.pop("include", [])
ch = list(m); cs = [dict(zip(ch, v)) for v in itertools.product(*m.values())]
cs = [c for c in cs if not any(all(c.get(k) == v for k, v in e.items()) for e in exc)]
for i in inc:
    alvo = [c for c in cs if all(c.get(k) == v for k, v in i.items() if k in ch)]
    [c.update(i) for c in alvo] if alvo else cs.append(dict(i))
print(len(cs), sum(1 for c in cs if c.get("experimental")))'
}
teste_eixos() {
    executar; afirmar_arquivo "$W"
    afirmar_jq "$W" '.jobs.testes.strategy.matrix.os == ["ubuntu-latest","windows-latest"]'
    afirmar_jq "$W" '.jobs.testes.strategy.matrix.node == [20,22,24]' "node: [20, 22, 24] como números"
}
teste_fail_fast() {
    executar; afirmar_jq "$W" '.jobs.testes.strategy."fail-fast" == false'
}
teste_cinco_jobs() {
    executar
    afirmar_igual "5 1" "$(expandir)" "a matriz deve gerar 5 jobs, 1 deles experimental (o include não pode criar job novo)"
}
teste_usa_a_matriz() {
    executar
    afirmar_jq "$W" '.jobs.testes."runs-on" == "${{ matrix.os }}"'
    afirmar_jq "$W" '.jobs.testes."continue-on-error" | tostring | contains("matrix.experimental")'
    afirmar_jq "$W" 'any(.jobs.testes.steps[]; (.uses // "") | test("^actions/setup-node@[0-9a-f]{40}$"))' "setup-node fixado por SHA"
    afirmar_jq "$W" 'any(.jobs.testes.steps[]; .with."node-version" == "${{ matrix.node }}")'
}
teste_actionlint() { executar; afirmar_actionlint "$W"; }
