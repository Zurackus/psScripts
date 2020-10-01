$machine = "10.20.20.215"
$port = 8080

while ((Test-NetConnection $machine -Port $port).TcpTestSucceeded -eq $False) {
  Write-Host "Waiting..."
  Start-Sleep -s 30
}

Write-Host "Port is up"


Import-Module SkypeOnlineConnector
$sfbSession = New-CsOnlineSession
Import-PSSession $sfbSession
