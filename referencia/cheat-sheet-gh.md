# Cheat sheet do GitHub CLI (`gh`)

> Convenções: `-R dono/repo` escolhe o repositório (sem ele, vale o da pasta atual). Quase todo `list`/`view` aceita `--json campos`, `--jq filtro` e `--web` (abre no navegador). Ajuda de qualquer comando: `gh help <comando>` ou <https://cli.github.com/manual/>.

## Autenticação e configuração (Módulos 00–01)

| Comando | Exemplo | Variações |
|---|---|---|
| `gh auth login` | `gh auth login` | `--hostname empresa.ghe.com` · `--git-protocol ssh` · `--with-token < token.txt` |
| `gh auth status` | `gh auth status` | `--show-token` (cuidado!) · `--active` |
| `gh auth refresh` | `gh auth refresh -s delete_repo` | `-s project` · `-r read:org` (remove escopo) |
| `gh auth setup-git` | `gh auth setup-git` | faz o Git usar o gh como *credential helper* |
| `gh auth token` | `GH_TOKEN=$(gh auth token) script.sh` | nunca imprima em log |
| `gh config set` | `gh config set git_protocol ssh` | `editor "code --wait"` · `prompt disabled` · `pager "less -R"` |
| `gh alias set` | `gh alias set prs 'pr list --author @me'` | `--shell` para encadear com pipes · `gh alias list` · `gh alias delete` |
| `gh ssh-key add` | `gh ssh-key add ~/.ssh/id_ed25519.pub --title notebook` | `--type signing` (assinar commits) |

## Repositórios (Módulo 02)

| Comando | Exemplo | Variações |
|---|---|---|
| `gh repo create` | `gh repo create loja --private --source . --push` | `--public` · `--clone` · `--template dono/modelo` · `--add-readme --license mit --gitignore Node` |
| `gh repo clone` | `gh repo clone aluno/loja` | `aluno/loja pasta -- --depth 1` (depois do `--`, opções do git) |
| `gh repo view` | `gh repo view --json visibility,licenseInfo` | `--web` · `dono/repo` |
| `gh repo edit` | `gh repo edit --delete-branch-on-merge --add-topic loja` | `--visibility public --accept-visibility-change-consequences` · `--enable-wiki=false` |
| `gh repo list` | `gh repo list minha-org --limit 1000 --json name` | `--source` · `--fork` · `--archived` · `--language go` |
| `gh repo fork` | `gh repo fork org/projeto --clone` | `--remote` · `--fork-name outro-nome` |
| `gh repo sync` | `gh repo sync aluno/fork --source org/projeto` | `--branch main` · `--force` |
| `gh repo rename / archive / delete` | `gh repo archive aluno/antigo --yes` | `delete` exige `gh auth refresh -s delete_repo` |

## Issues, labels e Projects (Módulo 03)

| Comando | Exemplo | Variações |
|---|---|---|
| `gh issue create` | `gh issue create --title "Bug" --body-file relato.md --label bug` | `--assignee @me` · `--milestone v1.1` · `--project "Sprint 1"` · `--web` |
| `gh issue list` | `gh issue list --label bug --state open` | `--search "no:assignee sort:updated-asc"` · `--assignee @me` · `--limit 200` |
| `gh issue view` | `gh issue view 12 --comments` | `--json title,body,labels` |
| `gh issue edit` | `gh issue edit 12 --add-label urgente` | `--remove-label` · `--add-assignee` · `--milestone` |
| `gh issue comment / close / reopen` | `gh issue close 12 --reason "not planned"` | `--comment "Duplicado de #9"` |
| `gh issue develop` | `gh issue develop 12 --checkout` | cria branch ligada ao issue |
| `gh label create` | `gh label create urgente --color d93f0b --force` | `gh label list` · `gh label clone org/modelo` · `gh label delete` |
| `gh project …` | `gh project item-add 1 --owner @me --url URL` | `create` · `list` · `item-list --format json` (exige escopo `project`) |
| `gh search issues` | `gh search issues --label "good first issue" --language python` | `--owner org` · `--state open` · `--assignee @me` |

## Pull requests (Módulos 04–05)

| Comando | Exemplo | Variações |
|---|---|---|
| `gh pr create` | `gh pr create --base main --fill --draft` | `--title/--body-file` · `--reviewer bia,org/time` · `--repo org/projeto --head voce:branch` |
| `gh pr list` | `gh pr list --search "review-requested:@me"` | `--author @me` · `--state merged` · `--label` |
| `gh pr view / diff` | `gh pr diff 7 --name-only` | `--json files,reviews` · `--comments` |
| `gh pr checkout` | `gh pr checkout 7` | funciona com PRs de forks |
| `gh pr review` | `gh pr review 7 --approve -b "👍"` | `--request-changes` · `--comment` |
| `gh pr checks` | `gh pr checks 7 --watch` | `--required` · `--fail-fast` |
| `gh pr ready / merge` | `gh pr merge 7 --squash --delete-branch` | `--merge` · `--rebase` · `--auto` (espera checks) · `--admin` |
| `gh pr update-branch` | `gh pr update-branch 7` | `--rebase` |
| `gh search prs` | `gh search prs --review-requested=@me --state=open` | `--owner` · `--merged` |

## Regras (Módulo 06)

| Comando | Exemplo | Variações |
|---|---|---|
| `gh ruleset list / view` | `gh ruleset view 101` | `--org minha-org` · `--web` |
| `gh ruleset check` | `gh ruleset check main` | regras que valem numa branch |
| API | `gh api -X POST repos/{owner}/{repo}/rulesets --input r.json` | `PUT .../rulesets/ID` · `GET .../rules/branches/main` |

## Actions (Módulos 07–08)

| Comando | Exemplo | Variações |
|---|---|---|
| `gh workflow list / view` | `gh workflow view ci.yml --yaml` | `--all` (inclui desativados) |
| `gh workflow run` | `gh workflow run deploy.yml -f ambiente=prod --ref main` | `--json < inputs.json` |
| `gh workflow enable / disable` | `gh workflow disable limpeza.yml` | |
| `gh run list` | `gh run list --workflow ci.yml --status failure` | `--branch` · `--event` · `--json databaseId,conclusion` |
| `gh run view` | `gh run view 9000 --log-failed` | `--job ID` · `--log` · `--web` |
| `gh run watch / rerun / cancel` | `gh run rerun 9000 --failed` | `watch --exit-status` · `rerun --debug` |
| `gh run download` | `gh run download 9000 -n relatorio` | `--pattern '*.zip'` |
| `gh cache list / delete` | `gh cache delete --all --ref refs/pull/5/merge` | `list --sort size_in_bytes` |
| `gh secret set / list` | `gh secret set NPM_TOKEN < token.txt` | `--env producao` · `--org org --visibility selected` · `--body` |
| `gh variable set / list` | `gh variable set AMBIENTE --body producao` | `--env` · `--org` |

## Releases, pacotes e atestações (Módulo 09)

| Comando | Exemplo | Variações |
|---|---|---|
| `gh release create` | `gh release create v1.2.0 dist/* --generate-notes --verify-tag` | `--prerelease` · `--draft` · `--latest=false` · `--notes-file` · `--target branch` |
| `gh release list / view` | `gh release view v1.2.0 --json assets` | `--exclude-drafts` |
| `gh release download / upload` | `gh release download v1.2.0 -p '*.tar.gz'` | `upload --clobber` |
| `gh release verify / verify-asset` | `gh release verify v1.2.0` | confere a atestação de releases imutáveis |
| `gh attestation verify` | `gh attestation verify loja.tar.gz -R aluno/loja` | `--owner org` · `oci://ghcr.io/aluno/loja:1.2.0` |

## API e extensões (Módulos 10–11)

| Comando | Exemplo | Variações |
|---|---|---|
| `gh api` (REST) | `gh api repos/{owner}/{repo} --jq .default_branch` | `-X PATCH` · `-f`/`-F` · `--input -` · `--paginate --slurp` · `-H 'X-GitHub-Api-Version: …'` · `--cache 1h` · `-i` |
| `gh api graphql` | `gh api graphql -f query='{ viewer { login } }'` | `-F var=valor` · `--paginate` com `$endCursor` |
| `gh api rate_limit` | `gh api rate_limit --jq .resources.core` | |
| `gh extension` | `gh extension install github/gh-actions-lock` | `create nome` · `list` · `upgrade --all` · `install . ` · `--pin v0.4.0` |
| `gh browse` | `gh browse src/app.js:12` | `--settings` · `--branch` · `-n` (só imprime a URL) |

## Variáveis de ambiente úteis

| Variável | Efeito |
|---|---|
| `GH_TOKEN` | token usado pelo gh (no Actions: `GH_TOKEN: ${{ github.token }}`) |
| `GH_REPO` | repositório padrão (`dono/repo`), como `-R` |
| `GH_HOST` | GitHub Enterprise Server / GHE.com |
| `GH_PROMPT_DISABLED=1` | nunca pergunta nada (scripts) |
| `NO_COLOR=1` · `GH_PAGER=cat` | saída limpa para logs |
| `GH_CONFIG_DIR` | pasta de configuração alternativa (o corretor usa uma temporária) |

<sub>© 2026 Prof. Daniel Santos · Curso de GitHub · CC BY-NC-SA 4.0</sub>
