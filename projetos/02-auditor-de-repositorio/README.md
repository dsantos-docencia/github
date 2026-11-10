# Projeto 02 · Auditor de repositório

**Problema:** a organização tem 40 repositórios. Quais não têm licença? Em quais a `main` aceita force push? Onde o secret scanning está desligado? Quem ainda é admin sem precisar?

**Solução:** [`auditor.sh`](auditor.sh) dá uma **nota de 0 a 10** a um repositório, consultando a API **só para leitura**, e sai com código ≠ 0 abaixo de um mínimo — dá para usar num workflow agendado que audita a organização inteira toda semana.

```bash
./projetos/02-auditor-de-repositorio/auditor.sh dsantos-docencia/github
./projetos/02-auditor-de-repositorio/auditor.sh aluno/loja --minimo 9
./projetos/02-auditor-de-repositorio/auditor.sh aluno/loja --json > auditoria-$(date +%F).json
```

```text
Auditoria de aluno/laboratorio
  ✔ descrição preenchida
  ✔ licença definida
  …
  ✘ saúde da comunidade ≥ 80%
  ✘ no máximo 1 admin
nota: 8/10
```

**Conceitos praticados:** API REST (Módulo 11), rulesets efetivos (Módulo 06), segurança (Módulo 10), papéis (Módulo 02), saúde da comunidade (Módulo 05), status HTTP como informação (`vulnerability-alerts` responde 204 ou 404).

**Desafios para ir além**
1. Rode para **todos** os repositórios de uma organização (`gh repo list ORG --json nameWithOwner`) e gere uma tabela Markdown ordenada pela nota.
2. Crie um workflow agendado que publica essa tabela no `$GITHUB_STEP_SUMMARY`.
3. Adicione itens: “CI com ações fixadas por SHA” (use o exercício 10.02), “tem `SECURITY.md`”, “Dependabot security updates ligado”.
