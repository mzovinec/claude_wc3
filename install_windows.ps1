# Warcraft III Claude Code Sound Hook - Windows Installer
# Copies scripts to ~/.claude/ and configures hooks in settings.json

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"

Write-Host "=== Warcraft III Claude Code Sound Hook (Windows) ===" -ForegroundColor Yellow
Write-Host ""

# Copy all sounds
$SoundsDestDir = Join-Path $ClaudeDir "wc3sounds"
Write-Host "Copying sound files to $SoundsDestDir ..."
if (Test-Path $SoundsDestDir) { Remove-Item $SoundsDestDir -Recurse -Force }
$SoundsSourceDir = Join-Path $ScriptDir "sounds"
foreach ($raceDir in Get-ChildItem $SoundsSourceDir -Directory) {
    foreach ($type in @("accept", "ask", "complete")) {
        $src = Join-Path $raceDir.FullName $type
        $dst = Join-Path $SoundsDestDir "$($raceDir.Name)\$type"
        if (Test-Path $src) {
            New-Item -ItemType Directory -Path $dst -Force | Out-Null
            Copy-Item "$src\*" $dst -Force
        }
    }
}

# Copy scripts
Write-Host "Copying hook scripts to $ClaudeDir ..."
foreach ($script in @("wc3_accept_win.ps1", "wc3_ask_win.ps1", "wc3_complete_win.ps1", "wc3_play_win.ps1")) {
    Copy-Item -Path (Join-Path $ScriptDir "scripts\$script") -Destination (Join-Path $ClaudeDir $script) -Force
}

# Copy config (only if not already present, so user edits are preserved)
$ConfigDest = Join-Path $ClaudeDir "wc3_config.json"
if (-not (Test-Path $ConfigDest)) {
    Copy-Item -Path (Join-Path $ScriptDir "wc3_config.json") -Destination $ConfigDest -Force
    Write-Host "  Created default config at $ConfigDest"
} else {
    Write-Host "  Config already exists at $ConfigDest - keeping your settings" -ForegroundColor Cyan
}

# Update settings.json
$SettingsFile = Join-Path $ClaudeDir "settings.json"
Write-Host "Configuring hooks in $SettingsFile ..."

if (Test-Path $SettingsFile) {
    $settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json
} else {
    $settings = [PSCustomObject]@{}
}

$hooksConfig = @{
    UserPromptSubmit = @(
        @{
            hooks = @(
                @{
                    type = "command"
                    command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$($ClaudeDir -replace '\\', '\\')\wc3_accept_win.ps1`""
                    timeout = 10
                }
            )
        }
    )
    Notification = @(
        @{
            matcher = "permission_prompt"
            hooks = @(
                @{
                    type = "command"
                    command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$($ClaudeDir -replace '\\', '\\')\wc3_ask_win.ps1`""
                    timeout = 10
                }
            )
        }
    )
    PermissionRequest = @(
        @{
            hooks = @(
                @{
                    type = "command"
                    command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$($ClaudeDir -replace '\\', '\\')\wc3_ask_win.ps1`""
                    timeout = 10
                }
            )
        }
    )
    Stop = @(
        @{
            hooks = @(
                @{
                    type = "command"
                    command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$($ClaudeDir -replace '\\', '\\')\wc3_complete_win.ps1`""
                    timeout = 10
                }
            )
        }
    )
}

# Merge hooks into existing settings
if ($settings.PSObject.Properties.Name -contains "hooks") {
    Write-Host "  Merging with existing hooks..." -ForegroundColor Cyan
    foreach ($event in $hooksConfig.Keys) {
        $settings.hooks | Add-Member -NotePropertyName $event -NotePropertyValue $hooksConfig[$event] -Force
    }
} else {
    $settings | Add-Member -NotePropertyName "hooks" -NotePropertyValue ([PSCustomObject]$hooksConfig) -Force
}

$settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8
Write-Host ""
Write-Host "Done! Hooks installed." -ForegroundColor Green
Write-Host "Restart Claude Code to activate the sounds."
Write-Host ""
Write-Host "Lok'tar ogar! Ready to code." -ForegroundColor Red
