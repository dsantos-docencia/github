#!/usr/bin/env bash
# Curso de GitHub · Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC · não comercial)
# Exercício 01.02 — Um config SSH à prova de firewall · SOLUÇÃO COMENTADA
set -euo pipefail

mkdir -p ssh
# Aspas em 'CFG': o ~ fica literal no arquivo — quem expande é o ssh, na sua máquina.
cat > ssh/config <<'CFG'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
    AddKeysToAgent yes

Host github-443
    HostName ssh.github.com
    Port 443
    User git
    IdentityFile ~/.ssh/id_ed25519_github
CFG
chmod 600 ssh/config
