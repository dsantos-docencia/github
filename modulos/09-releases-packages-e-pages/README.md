# Módulo 09 · Releases, Packages e Pages

> **Você vai sair daqui sabendo:** publicar versões com **releases** (notas geradas automaticamente, arquivos anexados, checksums, releases imutáveis), distribuir imagens e pacotes pelo **GitHub Packages** (GHCR) e colocar um site no ar com o **GitHub Pages** — tudo automatizado com Actions.

⏱ 4–5 h · 🧪 [Laboratório](../../laboratorio/) · ✍️ [Exercícios](exercicios/)

---

## 1. Cenário

A versão 1.2.0 da loja está pronta. Quem usa precisa saber **o que mudou**, baixar um arquivo **confiável** (e conferir que ninguém o trocou), e o site de documentação precisa refletir a versão nova. No curso de Git você criou a *tag* `v1.2.0`; agora a plataforma transforma essa tag em uma **entrega**.

## 2. Tag × release

| | Tag (Git) | Release (GitHub) |
|---|---|---|
| O que é | um nome para um commit | uma página **em cima** de uma tag |
| Contém | o ponteiro (e, se anotada, mensagem e autor) | título, notas em Markdown, **arquivos anexados** (binários, `.zip`, checksums), estado (rascunho, pré-lançamento, *latest*) |
| Onde vive | no repositório (vai junto no clone) | no GitHub (não vai no clone) |

```bash
gh release create v1.2.0 dist/*.tar.gz dist/SHA256SUMS \
  --title "v1.2.0" --generate-notes --verify-tag      # --verify-tag: falha se a tag ainda não foi enviada
gh release create v1.3.0-rc.1 --prerelease --generate-notes
gh release create v2.0.0 --draft --notes-file NOTAS.md  # rascunho: só quem tem escrita vê
gh release list
gh release view v1.2.0 --json assets --jq '.assets[].name'
gh release download v1.2.0 --pattern '*.tar.gz' --dir /tmp/loja
gh release upload v1.2.0 dist/manual.pdf --clobber     # anexa (ou substitui) um arquivo
```

## 3. Notas geradas automaticamente

`--generate-notes` (ou o botão **Generate release notes**) lista os PRs mesclados desde a release anterior, com autores e novos contribuidores. O arquivo **`.github/release.yml`** organiza isso por categorias, a partir dos **labels** dos PRs (Módulo 03):

```yaml
changelog:
  exclude:
    labels: [ignorar-nas-notas]
    authors: [dependabot]
  categories:
    - title: 🚀 Novidades
      labels: [feature, melhoria]
    - title: 🐛 Correções
      labels: [bug]
    - title: Outras mudanças
      labels: ["*"]          # “o resto” — precisa ser a ÚLTIMA categoria
```

Um PR entra na **primeira** categoria cujo label ele tiver. É mais um motivo para rotular PRs com disciplina — e para usar Conventional Commits nos títulos.

## 4. Confiança no que se baixa

| Mecanismo | Garante | Como |
|---|---|---|
| **Checksums** (`SHA256SUMS`) | o arquivo baixado é **idêntico** ao publicado | `sha256sum -c SHA256SUMS` |
| **Release imutável** (*Settings → Releases*) | depois de publicada, ninguém troca os anexos nem move a tag | ligar no repositório; o GitHub também gera uma atestação da release |
| **Atestação de proveniência** | o arquivo foi **gerado por aquele workflow**, daquele commit | `actions/attest-build-provenance` + `gh attestation verify arquivo -R dono/repo` |

> 🧠 Checksum sozinho não basta se o atacante puder trocar **o arquivo e o checksum** juntos. Releases imutáveis e atestações fecham essa porta — por isso fazem parte da cadeia de suprimentos (Módulo 10).

## 5. GitHub Packages e o GHCR

O **GitHub Packages** hospeda pacotes ao lado do código: imagens de container (`ghcr.io`), npm, Maven, Gradle, NuGet, RubyGems.

```bash
echo "$TOKEN" | docker login ghcr.io -u aluno --password-stdin    # token com read:packages / write:packages
docker build -t ghcr.io/aluno/loja:1.2.0 .
docker push ghcr.io/aluno/loja:1.2.0
```

No Actions, o próprio `GITHUB_TOKEN` publica, com `permissions: packages: write`:

```yaml
permissions:
  contents: read
  packages: write
steps:
  - uses: docker/login-action@<sha>
    with:
      registry: ghcr.io
      username: ${{ github.actor }}
      password: ${{ secrets.GITHUB_TOKEN }}
```

Ligue a imagem ao repositório com o rótulo OCI no `Dockerfile` — a página do pacote passa a mostrar o README e herda as permissões do repositório:

```dockerfile
LABEL org.opencontainers.image.source=https://github.com/aluno/loja
```

## 6. GitHub Pages

Sites estáticos (HTML/CSS/JS) servidos pelo GitHub, com HTTPS:

| Tipo | Endereço | Repositório |
|---|---|---|
| Usuário/organização | `https://aluno.github.io` | `aluno/aluno.github.io` |
| Projeto | `https://aluno.github.io/loja` | qualquer repositório |
| Domínio próprio | `https://docs.loja.exemplo.dev` | qualquer, com registro DNS + domínio verificado |

A forma recomendada hoje é publicar **por GitHub Actions** (*Settings → Pages → Source: GitHub Actions*): o workflow constrói o site e entrega um artefato.

```yaml
permissions:
  contents: read
  pages: write        # publicar
  id-token: write     # o deploy prova sua origem por OIDC
jobs:
  build:   # checkout → gerar _site/ → configure-pages → upload-pages-artifact
  deploy:  # needs: build · environment: github-pages · deploy-pages
```

> ⚠️ Pages é **público** na internet mesmo quando o repositório é privado (exceto em planos Enterprise com controle de acesso). Nada de dados internos em Pages.

## 7. Armadilhas comuns

- **Release sem tag enviada**: sem `--verify-tag`, o `gh` cria a tag no commit atual do servidor — que pode não ser o que você testou.
- **Anexar o mesmo arquivo de novo** sem `--clobber` falha; com release imutável, nem com ele.
- **`latest` errado**: pré-lançamentos e rascunhos não viram *latest*; uma release de manutenção antiga (`v1.9.1` depois da `v2.0.0`) pode virar — use `--latest=false`.
- **Pages com caminhos absolutos** (`/css/app.css`) em site de projeto: o site está em `/loja/`, não na raiz.
- **Token pessoal com `write:packages` e sem validade** em pipeline: use o `GITHUB_TOKEN`.

## 📚 Fontes oficiais

- Sobre releases: <https://docs.github.com/pt/repositories/releasing-projects-on-github/about-releases>
- Notas geradas automaticamente: <https://docs.github.com/pt/repositories/releasing-projects-on-github/automatically-generated-release-notes>
- Releases imutáveis: <https://docs.github.com/pt/code-security/supply-chain-security/understanding-your-software-supply-chain/immutable-releases>
- Atestações de artefatos: <https://docs.github.com/pt/actions/concepts/security/artifact-attestations>
- Container registry (GHCR): <https://docs.github.com/pt/packages/working-with-a-github-packages-registry/working-with-the-container-registry>
- Sobre o GitHub Pages: <https://docs.github.com/pt/pages/getting-started-with-github-pages/what-is-github-pages>
- Publicar Pages com workflow: <https://docs.github.com/pt/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages>
- `gh release`: <https://cli.github.com/manual/gh_release> · `gh attestation`: <https://cli.github.com/manual/gh_attestation>

---

<sub>© 2026 Prof. Daniel Santos · Curso de GitHub · conteúdo sob CC BY-NC-SA 4.0 · <a href="../../NOTICE.md">aviso de direitos</a></sub>
