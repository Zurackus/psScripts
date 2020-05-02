$machine = "172.29.164.78"
$port = 3389

while ((Test-NetConnection $machine -Port $port).TcpTestSucceeded -eq $False) {
  Write-Host "Waiting..."
  Start-Sleep -s 30
}

Write-Host "Port is up"