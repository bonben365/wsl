New-Item -Path "${env:LOCALAPPDATA}\Packages\centstr9" -ItemType Directory -Force
Set-Location "${env:LOCALAPPDATA}\Packages\centstr9"
Invoke-Item -Path "${env:LOCALAPPDATA}\Packages\centstr9"

Write-Host 'Downloading CentOS Stream 9 from GitHub...'

$url = 'https://github.com/mishamosher/CentOS-WSL/releases/latest'
$request = [System.Net.WebRequest]::Create($url)
$response = $request.GetResponse()
$tagUrl = $response.ResponseUri.OriginalString

###Create the download link
$downloadUrl = $tagUrl.Replace('tag', 'download') + '/' + "CentOS9-stream.zip"
$filePath = "${env:LOCALAPPDATA}\Packages\centstr9\CentOS9-stream.zip"
(New-Object Net.WebClient).DownloadFile($downloadUrl, $filePath)

#Extraxt downloaded file to a .tar file
Expand-Archive .\CentOS9-stream.zip
Move-Item .\CentOS9-stream\rootfs.tar.gz rootfs.tar

#Cleanup
Remove-Item CentOS9-stream.zip
Remove-Item .\CentOS9-stream\ -Recurse
