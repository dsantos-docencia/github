<#
============================================================================
  Curso de GitHub · ferramentas/configurar-github.ps1
  Governança do repositório como CÓDIGO: rulesets + recursos de segurança.
  Prof. Daniel Santos · github.com/dsantos-docencia/github · © 2026 (PolyForm-NC)
----------------------------------------------------------------------------
  Versão PowerShell do configurar-github.sh (mesmo resultado), para quem
  administra pelo Windows. Idempotente: rodar de novo ATUALIZA os rulesets.

  PRÉ-REQUISITOS
    - GitHub CLI instalado e autenticado:  gh auth login
    - você ser ADMIN do repositório

  USO (no PowerShell, na pasta do repositório)
    ./ferramentas/configurar-github.ps1 -Repo dsantos-docencia/github
    ./ferramentas/configurar-github.ps1 -Repo dsantos-docencia/github -CheckCI verificar
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [ValidatePattern('^[^/]+/[^/]+$')] [string]$Repo,
    [string]$CheckCI = 'verificar'
)
$ErrorActionPreference = 'Stop'
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "erro: instale o GitHub CLI (gh) e rode 'gh auth login'." -ForegroundColor Red
    exit 1
}

function Invoke-Gh {
    # Envia um corpo JSON pela entrada padrão (--input -) e falha se o gh falhar.
    param([string[]]$Argumentos, [string]$Corpo)
    if ($Corpo) { $Corpo | gh @Argumentos | Out-Null } else { gh @Argumentos | Out-Null }
    if ($LASTEXITCODE -ne 0) { throw "gh $($Argumentos -join ' ') falhou" }
}

function Set-Ruleset {
    param([hashtable]$Ruleset)
    $json = $Ruleset | ConvertTo-Json -Depth 10 -Compress
    $existentes = gh api "repos/$Repo/rulesets" | ConvertFrom-Json
    $id = ($existentes | Where-Object { $_.name -eq $Ruleset.name } | Select-Object -First 1).id
    if ($id) {
        Invoke-Gh @('api', '-X', 'PUT', "repos/$Repo/rulesets/$id", '--input', '-') $json
        Write-Host "   ✔ ruleset '$($Ruleset.name)' atualizado"
    } else {
        Invoke-Gh @('api', '-X', 'POST', "repos/$Repo/rulesets", '--input', '-') $json
        Write-Host "   ✔ ruleset '$($Ruleset.name)' criado"
    }
}

$bypassAdmin = @(@{ actor_id = 5; actor_type = 'RepositoryRole'; bypass_mode = 'always' })
Write-Host "➤ Repositório: $Repo   check obrigatório: $CheckCI" -ForegroundColor Cyan

Write-Host '① Ruleset da branch padrão'
Set-Ruleset @{
    name = 'proteger-main'; target = 'branch'; enforcement = 'active'
    conditions = @{ ref_name = @{ include = @('~DEFAULT_BRANCH'); exclude = @() } }
    bypass_actors = $bypassAdmin
    rules = @(
        @{ type = 'deletion' }, @{ type = 'non_fast_forward' }, @{ type = 'required_linear_history' },
        @{ type = 'pull_request'; parameters = @{
            required_approving_review_count = 1; dismiss_stale_reviews_on_push = $true
            require_code_owner_review = $true; require_last_push_approval = $false
            required_review_thread_resolution = $true } },
        @{ type = 'required_status_checks'; parameters = @{
            strict_required_status_checks_policy = $true
            required_status_checks = @(@{ context = $CheckCI }) } }
    )
}

Write-Host '② Ruleset das tags de versão'
Set-Ruleset @{
    name = 'proteger-tags'; target = 'tag'; enforcement = 'active'
    conditions = @{ ref_name = @{ include = @('refs/tags/v*'); exclude = @() } }
    bypass_actors = $bypassAdmin
    rules = @(@{ type = 'deletion' }, @{ type = 'update' }, @{ type = 'non_fast_forward' })
}

Write-Host '③ Dependabot: alertas e correções automáticas'
Invoke-Gh @('api', '-X', 'PUT', "repos/$Repo/vulnerability-alerts"); Write-Host '   ✔ alertas ligados'
Invoke-Gh @('api', '-X', 'PUT', "repos/$Repo/automated-security-fixes"); Write-Host '   ✔ correções ligadas'

Write-Host '④ Secret scanning + push protection'
$seguranca = @{ security_and_analysis = @{
    secret_scanning = @{ status = 'enabled' }
    secret_scanning_push_protection = @{ status = 'enabled' } } } | ConvertTo-Json -Depth 5 -Compress
Invoke-Gh @('api', '-X', 'PATCH', "repos/$Repo", '--input', '-') $seguranca; Write-Host '   ✔ ligados'

Write-Host '⑤ Relato privado de vulnerabilidade'
Invoke-Gh @('api', '-X', 'PUT', "repos/$Repo/private-vulnerability-reporting"); Write-Host '   ✔ ligado'

Write-Host '⑥ Actions: exigir ações fixadas por SHA'
Invoke-Gh @('api', '-X', 'PUT', "repos/$Repo/actions/permissions", '-F', 'enabled=true', '-f', 'allowed_actions=all', '-F', 'sha_pinning_required=true')
Write-Host '   ✔ política aplicada'

Write-Host ''
Write-Host "✅ Pronto! Confira em https://github.com/$Repo/settings/rules" -ForegroundColor Green
Write-Host "   Rode DEPOIS que o check '$CheckCI' tiver aparecido ao menos uma vez num PR."
