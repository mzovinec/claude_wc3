# RTS Claude Code Sounds - Windows Installer
# Copies scripts to ~/.claude/ and configures hooks in settings.json

$ErrorActionPreference = "Stop"
$ScriptDir = $PSScriptRoot
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"

Write-Host "=== RTS Claude Code Sounds (Windows) ===" -ForegroundColor Yellow
Write-Host ""

# Copy all sounds
$SoundsDestDir = Join-Path $ClaudeDir "rtssounds"
Write-Host "Copying sound files to $SoundsDestDir ..."
if (Test-Path $SoundsDestDir) { Remove-Item $SoundsDestDir -Recurse -Force }
$SoundsSourceDir = Join-Path $ScriptDir "sounds"

# C&C Generals folder-to-hook mappings
$CncAcceptFolders   = @("Move", "Build", "Repair", "ClearMine", "Crush")
$CncAskFolders      = @("Select")
$CncCompleteFolders = @("BuildComplete")

foreach ($gameDir in Get-ChildItem $SoundsSourceDir -Directory) {
    foreach ($raceDir in Get-ChildItem $gameDir.FullName -Directory) {
        if ($gameDir.Name -eq "wc3") {
            # WC3: copy accept/ask/complete directly
            foreach ($type in @("accept", "ask", "complete")) {
                $src = Join-Path $raceDir.FullName $type
                $dst = Join-Path $SoundsDestDir "$($raceDir.Name)\$type"
                if (Test-Path $src) {
                    New-Item -ItemType Directory -Path $dst -Force | Out-Null
                    Copy-Item "$src\*" $dst -Force
                }
            }
        } elseif ($gameDir.Name -eq "cnc") {
            # C&C Generals: map Select->ask, Move/Build/etc->accept, BuildComplete->complete
            foreach ($subDir in Get-ChildItem $raceDir.FullName -Directory) {
                $hookType = $null
                if ($CncAcceptFolders -contains $subDir.Name) { $hookType = "accept" }
                elseif ($CncAskFolders -contains $subDir.Name) { $hookType = "ask" }
                elseif ($CncCompleteFolders -contains $subDir.Name) { $hookType = "complete" }
                if ($hookType) {
                    $dst = Join-Path $SoundsDestDir "$($raceDir.Name)\$hookType"
                    New-Item -ItemType Directory -Path $dst -Force | Out-Null
                    Copy-Item "$($subDir.FullName)\*" $dst -Force
                }
            }
        }
    }
}

# Copy scripts
Write-Host "Copying hook scripts to $ClaudeDir ..."
foreach ($script in @("rts_accept_win.ps1", "rts_ask_win.ps1", "rts_complete_win.ps1", "rts_play_win.ps1")) {
    Copy-Item -Path (Join-Path $ScriptDir "scripts\$script") -Destination (Join-Path $ClaudeDir $script) -Force
}

# Copy config (only if not already present, so user edits are preserved)
$ConfigDest = Join-Path $ClaudeDir "rts_config.json"
if (-not (Test-Path $ConfigDest)) {
    Copy-Item -Path (Join-Path $ScriptDir "rts_config.json") -Destination $ConfigDest -Force
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
                    command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$($ClaudeDir -replace '\\', '\\')\rts_accept_win.ps1`""
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
                    command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$($ClaudeDir -replace '\\', '\\')\rts_ask_win.ps1`""
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
                    command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$($ClaudeDir -replace '\\', '\\')\rts_ask_win.ps1`""
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
                    command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$($ClaudeDir -replace '\\', '\\')\rts_complete_win.ps1`""
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
