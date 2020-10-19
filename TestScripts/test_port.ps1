$machine = "10.42.10.58"
$port = 3389

while ((Test-NetConnection $machine -Port $port).TcpTestSucceeded -eq $False) {
  Write-Host "Waiting..."
  Start-Sleep -s 30
}

Write-Host "Port is up"
