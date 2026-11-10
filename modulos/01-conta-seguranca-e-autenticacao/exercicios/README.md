# 🏋️ Exercícios — Módulo 01

Edite os arquivos `.sh` desta pasta e corrija com:

```bash
./ferramentas/corrigir.sh 01        # todos do módulo
./ferramentas/corrigir.sh 01 01     # só o exercício 01
```

Os exercícios treinam a identidade dos commits, a configuração SSH e a higiene com tokens.

O corretor roda cada script numa **pasta temporária vazia**, com identidade Git fixa e um **`gh` simulado** na frente do PATH: ele registra cada chamada que o seu script fizer e responde com dados de exemplo. Nenhum exercício precisa de internet, conta ou token — e nada é criado no seu GitHub. Travou? As soluções comentadas estão em [solucoes/](solucoes/). Tente pelo menos 15 minutos antes de abrir.

---

### 01 — E-mail noreply nos commits · `01-email-noreply.sh`
O script recebe `ID` (numérico) e `USUARIO` e deve configurar, **no nível local** do repositório `projeto` (crie-o com branch `main`):
- `user.name` = `USUARIO`
- `user.email` = `ID+USUARIO@users.noreply.github.com`

Validações:
- faltando argumento → mensagem de uso em stderr e saída **2**;
- `ID` que não seja só dígitos → mensagem em stderr e saída **1** (e não crie nada).

### 02 — Um config SSH à prova de firewall · `02-config-ssh.sh`
Crie o arquivo `ssh/config` (na pasta atual — **não** no seu `~/.ssh`) com dois blocos:

**`Host github.com`** — `HostName github.com`, `User git`, `IdentityFile ~/.ssh/id_ed25519_github`, `IdentitiesOnly yes`, `AddKeysToAgent yes`.

**`Host github-443`** — `HostName ssh.github.com`, `Port 443`, `User git`, `IdentityFile ~/.ssh/id_ed25519_github`.

O arquivo deve ter permissão `600` (o ssh recusa configs que outros podem alterar). Indente as opções com 4 espaços.

### 03 — Classificador de tokens · `03-classificar-token.sh`
O script recebe um token em `$1` e imprime **uma linha** no formato `TIPO · INÍCIO…`, onde `INÍCIO` são os **8 primeiros caracteres** — o token inteiro **nunca** pode aparecer na saída.

| Prefixo | TIPO impresso |
|---|---|
| `ghp_` | `pessoal clássico` |
| `github_pat_` | `pessoal fine-grained` |
| `gho_` | `oauth` |
| `ghu_` | `app usuário-servidor` |
| `ghs_` | `app servidor-servidor` |
| `ghr_` | `app refresh` |

Exemplo: `ghp_abcdefgh123…` → `pessoal clássico · ghp_abcd…`

Prefixo desconhecido → `desconhecido` em stderr e saída **1**. Sem argumento → uso em stderr e saída **2**.

<sub>© 2026 Prof. Daniel Santos · CC BY-NC-SA 4.0</sub>
