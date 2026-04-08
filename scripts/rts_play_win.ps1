# WC3 Sound Player (Windows)
# Plays a WAV or MP3 file. Used by the accept/ask/complete scripts.
param([string]$SoundFile)

if (-not (Test-Path $SoundFile)) { exit }

if ($SoundFile -match '\.wav$') {
    $player = New-Object System.Media.SoundPlayer $SoundFile
    $player.PlaySync()
} else {
    Add-Type @"
using System;
using System.Runtime.InteropServices;
public class WinMM {
    [DllImport("winmm.dll", CharSet = CharSet.Unicode)]
    public static extern int mciSendString(string command, System.Text.StringBuilder returnValue, int returnLength, IntPtr callback);
}
"@
    $sb = New-Object System.Text.StringBuilder 256
    [WinMM]::mciSendString("open `"$SoundFile`" type mpegvideo alias wc3sound", $sb, 256, [IntPtr]::Zero) | Out-Null
    [WinMM]::mciSendString("play wc3sound wait", $sb, 256, [IntPtr]::Zero) | Out-Null
    [WinMM]::mciSendString("close wc3sound", $sb, 256, [IntPtr]::Zero) | Out-Null
}
