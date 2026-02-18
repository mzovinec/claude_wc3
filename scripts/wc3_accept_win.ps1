# WC3 Worker Accept Command Sound (Windows)
# Randomly picks a race (weighted) and plays one of their "accept" voice lines
# Saves the chosen race so ask/complete hooks use the same race

$SoundsDir = Join-Path $PSScriptRoot "wc3sounds"
$RaceFile = Join-Path $env:TEMP "wc3_current_race.txt"
$ConfigFile = Join-Path $PSScriptRoot "wc3_config.json"

# Read race weights from config
$config = Get-Content $ConfigFile -Raw | ConvertFrom-Json
$total = 0
foreach ($prop in $config.races.PSObject.Properties) { $total += $prop.Value }
$Roll = Get-Random -Minimum 1 -Maximum ($total + 1)
$cumulative = 0
$Race = "orc"
foreach ($prop in $config.races.PSObject.Properties) {
    $cumulative += $prop.Value
    if ($Roll -le $cumulative) { $Race = $prop.Name; break }
}

$Race | Out-File -FilePath $RaceFile -NoNewline -Encoding UTF8

# Play a random accept sound from that race
$Dir = Join-Path $SoundsDir "$Race\accept"
$Files = Get-ChildItem -Path "$Dir\*" -Include *.wav, *.mp3 -File -ErrorAction SilentlyContinue
if ($Files.Count -gt 0) {
    $Sound = ($Files | Get-Random).FullName
    & (Join-Path $PSScriptRoot "wc3_play_win.ps1") $Sound
}
