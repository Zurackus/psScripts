#Network Tests
#Test-NetConLoop - loop a TCP test for a specific IP
#Test-NetConMulti - quickly test regularly used ports

#Function to loop a TCP test for a specific IP 
function Test-NetConLoop {
#IP and port to test
$machine = Read-Host "IP to test"
Write-Host -Object "`nRDP - 3389, https - 443, http - 80, Printer - 9100`n" 
$port = Read-Host "Port to test"
Write-Host -Object "Press ctrl+c to quit"

  while ((Test-NetConnection $machine -Port $port).TcpTestSucceeded -eq $False) {
    Write-Host "Waiting..."
    Start-Sleep -s 30
  }

#Notification the port is up
Write-Host "Port is up"
}

#Function to quickly test regularly used ports
function Test-NetConMulti {
#Test Multiple ports once
$machine = Read-Host "IP to test"
Write-Host -Object "`nOrder of checks:`nhttps - 443, http - 80, RDP - 3389, Printer - 9100`n"
$port_arr = @(443, 80, 3389, 9100)

  foreach ($port in $port_arr) {
      Test-NetConnection $machine -port $port -InformationLevel Quiet
  }
}