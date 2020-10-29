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

function Test-NetConPrimaryHIM {
  $ip2check = Read-Host "IP to check"
  $count = 2
  $HIMaddress = "10.40.4."
  $HIMaccess = $False
  $success = $False
  do {
      $iphost = $HIMaddress +$count
      if(Test-Connection $iphost -Quiet)
      {
        $success = $true
        $PCname = Resolve-DnsName $iphost | select NameHost
        Write-host "$PCname"
        $HIMAccess = Invoke-Command -ComputerName $PCname.
        {
          Test-Connection $HIMaccess -Quiet
        }
      }
      else { $count++ }
  } until ($count -eq 254 -or $success)
  
  Write-host  "Result is: $HIMaccess"
}


<#

Try{
  $Array      = @()
  $Servers    = Get-Content "c:\users\$env:username\desktop\servers.txt"
  $PortNumber = '80'
  $Array = Invoke-Command -cn $Servers {param($PortNumber)

              $Destinations = "10.40.2.29","10.40.3.58"  
                          
              $Object = New-Object PSCustomObject
              $Object | Add-Member -MemberType NoteProperty -Name "Servername" -Value $env:computername
              $Object | Add-Member -MemberType NoteProperty -Name "Port" -Value $PortNumber

              Foreach ($Item in $Destinations){
                  $Result = Test-NetConnection -Port $PortNumber -cn $Item -InformationLevel Quiet
                  $Object | Add-Member -Type NoteProperty -Name  "Destination" -Value $Item -Force
                  $Object | Add-Member -Type NoteProperty -Name  "Connection" -Value $Result -Force
                  $Object
              } 
                 
                     
  } -ArgumentList $PortNumber -ErrorAction stop | select * -ExcludeProperty runspaceid, pscomputername,PSShowComputerName
}
Catch [System.Exception]{
  Write-host "Error" -backgroundcolor red -foregroundcolor yellow
  $_.Exception.Message
}

$Array | Out-GridView -Title "Results" 
$Array | Export-Csv $env:userprofile\desktop\results.csv -Force -NoTypeInformation 
#>