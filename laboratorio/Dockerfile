# Laboratório do Curso de GitHub — ambiente isolado e reproduzível
# Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
FROM debian:13-slim

ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8

# git, jq, python3-yaml — o mínimo para exemplos e corretor
# shellcheck, bats       — qualidade dos scripts
# openssh-client         — remotos por SSH (Módulo 01)
RUN apt-get update && apt-get install -y --no-install-recommends \
        git bash coreutils findutils grep sed gawk procps less nano \
        jq python3 python3-yaml python3-pip pipx \
        shellcheck bats openssh-client openssl curl ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI pelo repositório OFICIAL (com chave de assinatura): o pacote do
# Debian costuma estar várias versões atrás.
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update && apt-get install -y --no-install-recommends gh \
 && rm -rf /var/lib/apt/lists/*

# act (rodar workflows localmente) — versão FIXA e checksum conferido:
# a mesma disciplina que o Módulo 10 ensina para as actions.
ARG ACT_VERSAO=0.2.97
ARG ACT_SHA256=67b4976a56f33ea7870b798912e738ec44eef38e7578ae7b532f2def1c73a5ad
RUN curl -fsSLo /tmp/act.tgz "https://github.com/nektos/act/releases/download/v${ACT_VERSAO}/act_Linux_x86_64.tar.gz" \
 && echo "${ACT_SHA256}  /tmp/act.tgz" | sha256sum -c - \
 && tar -xzf /tmp/act.tgz -C /usr/local/bin act && rm /tmp/act.tgz

# actionlint e zizmor (linters de workflow), em versões fixas.
RUN PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install actionlint-py==1.7.12.25 \
 && PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install zizmor==1.32.0

RUN useradd -m -s /bin/bash aluno
USER aluno
RUN git config --global init.defaultBranch main \
 && git config --global user.name  "Aluno do Laboratório" \
 && git config --global user.email "aluno@laboratorio.local" \
 && git config --global core.editor nano \
 && git config --global safe.directory /curso
WORKDIR /curso
CMD ["bash"]
