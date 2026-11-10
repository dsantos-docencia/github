# 🧪 Laboratório do Curso de GitHub

Há quatro jeitos de praticar. Os exercícios funcionam em **todos** (o corretor usa o `gh` simulado); os exemplos marcados com `GH_REAL=1` ficam muito mais interessantes no **GitHub de verdade**.

| Opção | Precisa de | Para quê |
|---|---|---|
| [A — GitHub de verdade](#opção-a--github-de-verdade-recomendado) | conta no GitHub, `gh` | viver o fluxo real: issues, PRs, Actions, rulesets |
| [B — Offline, na sua máquina](#opção-b--offline-na-sua-máquina) | Bash, Git, `jq`, `python3` | exercícios e exemplos simulados, sem internet |
| [C — Container pronto](#opção-c--container-pronto-docker) | Docker | ambiente idêntico ao do professor, com `gh`, `act`, actionlint e zizmor |
| [D — Workflows na sua máquina com `act`](#opção-d--rodando-workflows-localmente-com-act) | Docker + `act` | testar workflows do Actions sem fazer push |

Comece conferindo o que você já tem:

```bash
./laboratorio/verificar-ambiente.sh
```

---

## Opção A — GitHub de verdade (recomendado)

### 1. Crie a conta
Acesse <https://github.com/signup>. O **nome de usuário** aparece em tudo o que você fizer (`github.com/seu-usuario`), então escolha um nome profissional. Estudante? Peça os benefícios do [GitHub Education](https://education.github.com).

### 2. Proteja a conta (Módulo 01)
*Settings → Password and authentication*: ative a **autenticação de dois fatores** (app autenticador ou passkey) e **guarde os códigos de recuperação** fora do computador. Em *Settings → Emails*, marque **Keep my email addresses private**.

### 3. Instale Git e GitHub CLI

| Sistema | Comandos |
|---|---|
| **Windows** | `winget install --id Git.Git -e` e `winget install --id GitHub.cli -e` · use o **Git Bash** para os scripts do curso |
| **macOS** | `brew install git gh jq` |
| **Debian/Ubuntu** | `sudo apt install git jq python3-yaml` + o `gh` pelo [repositório oficial](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) (o pacote da distribuição costuma estar desatualizado) |
| **Fedora** | `sudo dnf install git gh jq python3-pyyaml` |

```bash
gh --version          # confira
```

### 4. Faça login com o `gh`

```bash
gh auth login
#  ? Where do you use GitHub?            GitHub.com
#  ? Preferred protocol for Git?         HTTPS   (ou SSH, se já configurou a chave)
#  ? Authenticate Git with your credentials?  Yes
#  ? How would you like to authenticate? Login with a web browser
#  → copie o código de 8 caracteres, cole na página que abrir e autorize
gh auth status
```

### 5. Crie o seu repositório de laboratório

```bash
./laboratorio/criar-lab.sh              # cria seu-usuario/lab-github
./laboratorio/criar-lab.sh --simular    # quer ver antes o que ele faz? (offline)
```

O script cria um repositório **público** com conteúdo fictício: README, CODEOWNERS, um workflow de CI com a ação fixada por SHA, 5 labels e 4 issues, os mesmos dados que o simulador usa. Por que público? Em repositórios públicos, Actions, rulesets e secret scanning são gratuitos, e é isso que os Módulos 06–10 praticam. Para um privado, use `--privado` (alguns recursos exigirão plano pago).

### 6. Rode os exemplos no GitHub de verdade

```bash
export GH_REAL=1 LAB_REPO=seu-usuario/lab-github
bash modulos/02-repositorios/exemplos/02-ler-metadados.sh
bash modulos/03-issues-labels-e-projects/exemplos/01-ciclo-de-um-issue.sh   # este CRIA um issue no seu lab
```

Os exemplos só agem sobre `$LAB_REPO`. Exemplos que não aceitam `GH_REAL` rodam sempre simulados (por exemplo, os que criariam repositórios novos).

### 7. (Opcional) Uma organização de laboratório
Para praticar **times**, papéis e CODEOWNERS com `@org/time`, crie uma organização gratuita em <https://github.com/account/organizations/new> (plano **Free**). Convide um colega e pratique PRs cruzados: um abre, o outro revisa.

### 8. Ao terminar o curso

```bash
gh auth refresh -s delete_repo          # apagar exige um escopo extra, de propósito
./laboratorio/destruir-lab.sh           # pede confirmação digitando o nome
```

---

## Opção B — Offline, na sua máquina

Precisa só de **Bash, Git, `jq` e `python3` com PyYAML**. Todos os exercícios e todos os exemplos rodam assim: o `gh` simulado ([`ferramentas/simulador/gh`](../ferramentas/simulador/gh)) responde no lugar do GitHub.

```bash
bash modulos/04-pull-requests-e-code-review/exemplos/01-fluxo-completo-de-pr.sh
./ferramentas/corrigir.sh 04
```

Curioso para ver o simulador por dentro? Ele tem ~100 linhas comentadas, e as respostas são JSONs legíveis em [`ferramentas/simulador/respostas/`](../ferramentas/simulador/respostas/). Modificar uma resposta e ver o exemplo mudar é um ótimo exercício de `jq`.

---

## Opção C — Container pronto (Docker)

```bash
./laboratorio/entrar.sh                           # constrói a imagem na 1ª vez e abre um terminal
GH_TOKEN=$(gh auth token) ./laboratorio/entrar.sh # repassa o seu login para usar GH_REAL=1 lá dentro
```

A imagem ([Dockerfile](Dockerfile)) traz Git, `gh` (do repositório oficial), `jq`, PyYAML, ShellCheck, Bats, **act**, **actionlint** e **zizmor**, todos em versões fixas. O `act` é baixado com **checksum conferido**: a mesma disciplina que o Módulo 10 ensina para as actions.

---

## Opção D — Rodando workflows localmente com `act`

O [act](https://github.com/nektos/act) lê `.github/workflows/` e executa os jobs em containers Docker, imitando o runner do GitHub. É ótimo para iterar rápido num workflow (Módulos 07–08).

```bash
act -l                                  # lista jobs e eventos
act push                                # simula um push
act pull_request -j testes              # só o job "testes"
act workflow_dispatch --input dias=3    # disparo manual com input
act -s MEU_SEGREDO=valor                # segredos (nunca use segredos reais aqui)
actionlint .github/workflows/*.yml      # antes de tudo: o workflow é válido?
```

Limitações honestas: as imagens padrão do `act` **não** têm tudo o que o `ubuntu-latest` do GitHub tem, e recursos da plataforma (OIDC, ambientes com aprovação, cache e artefatos do GitHub) não existem localmente. Use o `act` para pegar erros cedo; a palavra final é sempre uma execução de verdade.

---

## Problemas comuns

| Sintoma | Causa provável | Solução |
|---|---|---|
| `gh: command not found` | gh não instalado | passo 3 da opção A |
| `HTTP 401` / `gh auth status` falha | token expirou ou foi revogado | `gh auth login` de novo |
| `HTTP 403 ... rate limit` | muitas chamadas sem login | faça login; espere o horário de `gh api rate_limit` |
| `must have admin rights` | ação exige papel Admin | rode no seu `lab-github`, onde você é dono |
| `ModuleNotFoundError: yaml` | falta PyYAML | `pip install pyyaml` ou `apt install python3-yaml` |
| exemplo com `GH_REAL=1` reclama de `LAB_REPO` | variável não definida | `export LAB_REPO=seu-usuario/lab-github` |
| `Permission denied (publickey)` | chave SSH não cadastrada | Módulo 01, seção SSH, ou use HTTPS |

<sub>© 2026 Prof. Daniel Santos · Curso de GitHub · CC BY-NC-SA 4.0</sub>
