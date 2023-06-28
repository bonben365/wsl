New-Item -Path "${env:LOCALAPPDATA}\Packages\centstr8" -ItemType Directory -Force | Out-Null
Set-Location "${env:LOCALAPPDATA}\Packages\centstr8"
Invoke-Item -Path "${env:LOCALAPPDATA}\Packages\centstr8"

Write-Host
Write-Host 'Downloading CentOS Stream 9 from GitHub...'

$url = 'https://github.com/mishamosher/CentOS-WSL/releases/latest'
$request = [System.Net.WebRequest]::Create($url)
$response = $request.GetResponse()
$tagUrl = $response.ResponseUri.OriginalString

###Create the download link
$downloadUrl = $tagUrl.Replace('tag', 'download') + '/' + "CentOS8-stream.zip"
$filePath = "${env:LOCALAPPDATA}\Packages\centstr8\CentOS8-stream.zip"
(New-Object Net.WebClient).DownloadFile($downloadUrl, $filePath)

#Extraxt downloaded file to a .tar file
Expand-Archive .\CentOS8-stream.zip
Move-Item .\CentOS8-stream\rootfs.tar.gz rootfs.tar

#Cleanup
Remove-Item CentOS8-stream.zip
Remove-Item .\CentOS8-stream\ -Recurse
