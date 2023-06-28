New-Item -Path "${env:LOCALAPPDATA}\Packages\centstr8" -ItemType Directory -Force | Out-Null
Set-Location "${env:LOCALAPPDATA}\Packages\centstr8"
Invoke-Item -Path "${env:LOCALAPPDATA}\Packages\centstr8"

Write-Host
Write-Host 'Downloading CentOS Stream 8 from GitHub...'

###Create the download link
$downloadUrl = https://github.com/mishamosher/CentOS-WSL/releases/download/8-stream-20220125/CentOS8-stream.zip
$filePath = "${env:LOCALAPPDATA}\Packages\centstr8\CentOS8-stream.zip"
(New-Object Net.WebClient).DownloadFile($downloadUrl, $filePath)

#Extraxt downloaded file to a .tar file
Expand-Archive .\CentOS8-stream.zip
Move-Item .\CentOS8-stream\rootfs.tar.gz rootfs.tar

#Cleanup
Remove-Item CentOS8-stream.zip
Remove-Item .\CentOS8-stream\ -Recurse
