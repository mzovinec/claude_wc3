# WC3 Worker Accept Command Sound (Windows)
# Randomly picks a game (weighted), then a race within it, and plays an "accept" voice line
# Saves the chosen race so ask/complete hooks use the same race

$SoundsDir = Join-Path $PSScriptRoot "wc3sounds"
$RaceFile = Join-Path $env:TEMP "wc3_current_race.txt"
$ConfigFile = Join-Path $PSScriptRoot "wc3_config.json"

# Two-level weighted selection: game first, then race
$config = Get-Content $ConfigFile -Raw | ConvertFrom-Json

# Pick a game (skip games with weight 0)
$gameTotal = 0
foreach ($g in $config.games.PSObject.Properties) {
    if ($g.Value.weight -gt 0) { $gameTotal += $g.Value.weight }
}
if ($gameTotal -eq 0) { exit }

$roll = Get-Random -Minimum 1 -Maximum ($gameTotal + 1)
$cumulative = 0
$game = $null
foreach ($g in $config.games.PSObject.Properties) {
    if ($g.Value.weight -le 0) { continue }
    $cumulative += $g.Value.weight
    if ($roll -le $cumulative) { $game = $g.Value; break }
}

# Pick a race within the chosen game
$raceTotal = 0
foreach ($r in $game.races.PSObject.Properties) { $raceTotal += $r.Value }
if ($raceTotal -eq 0) { exit }

$roll = Get-Random -Minimum 1 -Maximum ($raceTotal + 1)
$cumulative = 0
$Race = ($game.races.PSObject.Properties | Select-Object -First 1).Name
foreach ($r in $game.races.PSObject.Properties) {
    $cumulative += $r.Value
    if ($roll -le $cumulative) { $Race = $r.Name; break }
}

$Race | Out-File -FilePath $RaceFile -NoNewline -Encoding UTF8

# Play a random accept sound from that race
$Dir = Join-Path $SoundsDir "$Race\accept"
$Files = Get-ChildItem -Path "$Dir\*" -Include *.wav, *.mp3 -File -ErrorAction SilentlyContinue
if ($Files.Count -gt 0) {
    $Sound = ($Files | Get-Random).FullName
    & (Join-Path $PSScriptRoot "wc3_play_win.ps1") $Sound
}
