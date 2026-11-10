# ⚙️ Configuração administrativa do repositório

Algumas configurações exigem **acesso de administrador** e precisam ser aplicadas por você. Há um script pronto que faz tudo de uma vez — e ele mesmo é material do curso: governança **como código**, com **rulesets** (Módulo 06) e os recursos de segurança do Módulo 10.

## Pré-requisitos
- [GitHub CLI](https://cli.github.com) instalado e autenticado: `gh auth login`
- `jq` (na versão Bash)
- você ser admin do repositório

## Rodar

```bash
./ferramentas/configurar-github.sh dsantos-docencia/github            # Bash (Linux, macOS, Git Bash)
```
```powershell
./ferramentas/configurar-github.ps1 -Repo dsantos-docencia/github     # PowerShell (Windows)
```

Os dois são **idempotentes**: rodar de novo atualiza os rulesets existentes em vez de duplicá-los.

## O que é aplicado

**Ruleset `proteger-main`** (branch padrão)
- exige Pull Request com 1 aprovação e revisão do CODEOWNERS
- descarta aprovações obsoletas a cada push; exige conversas resolvidas
- exige o check de CI `verificar` verde, com a branch atualizada
- histórico linear; bloqueia force push e exclusão
- bypass para o papel **Admin**: você continua conseguindo mesclar seus próprios PRs

**Ruleset `proteger-tags`** (`refs/tags/v*`): ninguém apaga nem move uma versão publicada.

**Segurança**
- alertas e correções automáticas do Dependabot
- secret scanning + push protection
- relato privado de vulnerabilidade (botão *Report a vulnerability*, ligado ao [SECURITY.md](SECURITY.md))
- política do Actions: **exigir ações fixadas por SHA**

> ⚠️ Rode **depois** que o check `verificar` tiver rodado ao menos uma vez (por exemplo, no primeiro PR) — senão a regra espera um check que o GitHub ainda não conhece.

> Por que não foi aplicado automaticamente? Configurações administrativas do GitHub não podem ser alteradas de dentro da sessão automatizada: elas dependem do seu token de admin.

<sub>© 2026 Prof. Daniel Santos</sub>
