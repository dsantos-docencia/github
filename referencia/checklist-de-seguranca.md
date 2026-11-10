# ✅ Checklist de segurança

Use em toda conta, repositório e workflow novo. Entre parênteses, o módulo que explica.

## Conta (01)
- [ ] 2FA ligado (app autenticador ou passkey) e códigos de recuperação guardados offline
- [ ] e-mail privado + “Block command line pushes that expose my email”
- [ ] chave SSH com frase-senha; chave de assinatura cadastrada; vigilant mode ligado
- [ ] tokens fine-grained, com prazo e só nos repositórios necessários; os antigos revogados
- [ ] sessões e aplicativos autorizados revisados (*Settings → Applications*)

## Repositório (02, 05, 06)
- [ ] visibilidade conferida (privado na dúvida); licença definida
- [ ] no máximo 1–2 admins; acesso por times em organizações
- [ ] ruleset na branch padrão: PR obrigatório, aprovação, check do CI, sem force push, sem exclusão
- [ ] ruleset para tags `v*` (ninguém move uma versão publicada)
- [ ] `SECURITY.md` + relato privado de vulnerabilidade ligado
- [ ] CODEOWNERS para as pastas sensíveis (`/.github/`, infraestrutura)

## Dependências e segredos (10)
- [ ] grafo de dependências + Dependabot alerts + security updates ligados
- [ ] `dependabot.yml` com `github-actions` e o ecossistema do projeto, com grupos e cooldown
- [ ] secret scanning + push protection ligados
- [ ] code scanning (CodeQL) no mínimo em *default setup*

## GitHub Actions (07, 08, 10)
- [ ] `permissions:` declarado em todo workflow (`{}` ou `contents: read` no topo)
- [ ] toda ação de terceiros fixada por SHA de 40 caracteres (ou lockfile `actions.lock`)
- [ ] política “exigir SHA” ligada (*Settings → Actions → General*)
- [ ] nenhum `${{ github.event.* }}` controlado por usuário dentro de `run:` — sempre via `env:`
- [ ] sem `pull_request_target` que faça checkout/execução de código do PR
- [ ] `persist-credentials: false` no checkout; `timeout-minutes` em todo job
- [ ] segredos de produção só em **ambientes** com revisores; deploy na nuvem via **OIDC**
- [ ] nada de runner self-hosted em repositório público
- [ ] `actionlint` e `zizmor` no CI

## Releases (09)
- [ ] releases imutáveis ligadas
- [ ] `SHA256SUMS` anexado; atestação de proveniência gerada no workflow
- [ ] `--verify-tag` ao publicar

<sub>© 2026 Prof. Daniel Santos · Curso de GitHub · CC BY-NC-SA 4.0</sub>
