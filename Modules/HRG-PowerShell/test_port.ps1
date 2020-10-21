#Loop a single port test
$machine = "10.42.10.58"
$port = 3389

while ((Test-NetConnection $machine -Port $port).TcpTestSucceeded -eq $False) {
  Write-Host "Waiting..."
  Start-Sleep -s 30
}

Write-Host "Port is up"

#Test Multiple ports once
$machine = 10.42.10.58
$port_arr = @(443, 3389, 9100)

foreach ($port in $port_arr) {
    Test-NetConnection $machine -port $port -InformationLevel Quiet
}