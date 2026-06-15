# Docker Desktop diagnostics script
# Run as Administrator

$OutDir = "$PSScriptRoot\diagnostics"
if (-Not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

Write-Host "Collecting Docker and WSL diagnostics to $OutDir"

$files = @{
    'docker_version' = 'docker_version.txt'
    'docker_info' = 'docker_info.txt'
    'docker_contexts' = 'docker_contexts.txt'
    'docker_desktop_logs' = 'docker_desktop_logs.txt'
    'wsl_list' = 'wsl_list.txt'
    'wsl_status' = 'wsl_status.txt'
}

# Run commands and capture output
try {
    docker version *>&1 | Out-File (Join-Path $OutDir $files.docker_version) -Encoding UTF8
} catch { $_ | Out-File (Join-Path $OutDir $files.docker_version) -Encoding UTF8 }

try {
    docker info *>&1 | Out-File (Join-Path $OutDir $files.docker_info) -Encoding UTF8
} catch { $_ | Out-File (Join-Path $OutDir $files.docker_info) -Encoding UTF8 }

try {
    docker context ls *>&1 | Out-File (Join-Path $OutDir $files.docker_contexts) -Encoding UTF8
} catch { $_ | Out-File (Join-Path $OutDir $files.docker_contexts) -Encoding UTF8 }

try {
    wsl -l -v *>&1 | Out-File (Join-Path $OutDir $files.wsl_list) -Encoding UTF8
} catch { $_ | Out-File (Join-Path $OutDir $files.wsl_list) -Encoding UTF8 }

try {
    wsl --status *>&1 | Out-File (Join-Path $OutDir $files.wsl_status) -Encoding UTF8
} catch { $_ | Out-File (Join-Path $OutDir $files.wsl_status) -Encoding UTF8 }

# Collect Docker Desktop logs if available
$logPaths = @(
    "$env:APPDATA\Docker\log.txt",
    "$env:LOCALAPPDATA\Docker\log.txt"
)
foreach ($lp in $logPaths) {
    if (Test-Path $lp) {
        Get-Content $lp -ErrorAction SilentlyContinue | Out-File (Join-Path $OutDir $files.docker_desktop_logs) -Encoding UTF8 -Append
    }
}

Write-Host "Diagnostics collected in: $OutDir"
Write-Host "You can paste the contents of the files here or zip the folder and upload the archive."