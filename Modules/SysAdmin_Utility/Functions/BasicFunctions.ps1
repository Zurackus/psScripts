<#
Here are Basic functions

#>

#1 Pull all users who are currently enabled
function Get-ADenabled {
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\ADenabled.csv'
    get-aduser -filter "(enabled -eq 'true')" -properties title, company, department, officephone, canonicalname, whencreated, officephone, office, mail, lastlogontimestamp, employeeID | export-csv -path $workOutput
}

#2 Pull all users who are currently disabled
function Get-ADdisabled {
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\ADdisabled.csv'
    get-aduser -filter "(enabled -eq 'false')" -properties title, company, department, officephone, canonicalname, whencreated, officephone, office, mail, lastlogontimestamp | export-csv -path $workOutput
}

#3 Pull all users who have a password that does not expire
function Get-PasswordNeverExpires {
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\PassNeverExpiresAccounts.csv'
    get-aduser -Filter { (Enabled -eq $TRUE) -and (PasswordNeverExpires -eq $TRUE) } -ResultPageSize 2000 -Properties Name, SamAccountName, LastLogonDate, passwordlastset, distinguishedname | where-object { $_.distinguishedname -notlike "*disabled*" -and $_.distinguishedname -notlike "*roleaccounts*" } | export-csv -path $workOutput
}

#4 Pull all users who have not logged in for the last 60 days
function Get-NoLogIn60Days {
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\NoLogIn60Days.csv'
    $60Days = (get-date).adddays(-60)
    Get-ADUser -Filter { (Enabled -eq $TRUE) -and (PasswordNeverExpires -eq $TRUE) } -Properties Name, SamAccountName, LastLogonDate, DistinguishedName | Where { ($_.LastLogonDate -le $60Days) -and ( $_.distinguishedname -notlike "*roleaccounts*") -and ( $_.distinguishedname -notlike "*sccm*") } | Sort | Select Name, SamAccountName, LastLogonDate, DistinguishedName | Export-Csv -path $workOutput
}

#5 Unlock specified username
function Unlock-ADUser {
    $mainUserName = Read-Host 'Enter username'
    get-aduser $mainUserName -properties PasswordExpired, PasswordLastSet, PasswordNeverExpires, LockedOut
    Unlock-ADAccount -Identity $mainUserName
}


#Get-MemberOf
function Get-ADMembers {
  $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\AD-GroupMembership.csv'
  get-aduser -filter "(enabled -eq 'true')" -properties memberof | select name, @{ l="GroupMembership"; e={$_.memberof  -join ";"  } } | export-csv -path $workOutput
}

<# Delete all Files in R:\SCANNED older than 30 day(s)
function remove-oldfiles {
    $Path = "\\hrgfile\Remote\SCANNED"
    $Daysback = "-1"
     
    $CurrentDate = Get-Date
    $DatetoDelete = $CurrentDate.AddDays($Daysback)
    Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $DatetoDelete }
}
#>

<#
function FolderSecurity {

    Write-Host -Object 'Full path needed like:
    `n\\hrgatad\I\helpdesk
    `nC:\users\%username%\desktop'
    $FolderPath = Read-Host "Full network path"
    
    Write-Host -Object 'Press '1' to '
    
    #Check Security
    get-acl $FolderPath | fl
    
    #Add Security
    # Replace the "FullControl" with the desired permission below
    # "FullControl", "Read", "Write", "ReadAndExecute", "Modify"
    $acl = Get-Acl "C:\Users\tkonsonlas\Documents\PS_Scripts"
    $AR = New-Object System.Security.AccessControl.FileSystemAccessRule("hrg\jediaz", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.SetAccessRule($AR)
    $acl | Set-Acl "C:\Users\tkonsonlas\Documents\PS_Scripts"
    
    #Purge Security
    $acl = Get-Acl "C:\Users\tkonsonlas\Documents\PS_Scripts"
    $usersid = New-Object System.Security.Principal.Ntaccount ("hrg\jediaz")
    $acl.PurgeAccessRules($usersid)
    $acl | Set-Acl "C:\Users\tkonsonlas\Documents\PS_Scripts"
}
#>


#21 Function to loop a TCP test for a specific IP 
function Test-NetworkLoop {
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
    
#22 Function to quickly test regularly used ports
function Test-NetworkMulti {
#Test Multiple ports at once
$machine = Read-Host "IP to test"
Write-Host -Object "`nOrder of checks:`nhttps - 443, http - 80, RDP - 3389, Printer - 9100`n"
$port_arr = @(443, 80, 3389, 9100)

  foreach ($port in $port_arr) {
    Test-NetConnection $machine -port $port -InformationLevel Quiet
  }
}

#23
function FunctionName {
  enter-pssession -computername $compName  
}

<#
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
#>    
    
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

<#
function Get-MembersOfGroups {
    param (
        OptionalParameters
    )
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\GoupmemberShip.csv'
    if (Test-Path -Path $workOutput) {
        
    }
    $GroupList = "DCAnalyst", "DCManager"
    foreach ($Group in $GroupList)
    { 
        Get-ADGroupMember $Group | Export-csv -Path $workOutput -Append
    }
}
#>

#Test from a specific port
Test-Connection -Source 10.40.4.140 -ComputerName 192.168.1.52
Test-Connection -Source 10.40.0.234 -ComputerName 192.168.1.53

function -SelfpayDB {
Enter-PSSession -ComputerName vhrgihpe

Get-SmbOpenFile | Where-Object {$_.Path -like "Q:\EMPLOYEE\SPAYDataBase\Supervisor Interface*"} | Close-SmbOpenFile -Force
Start-Sleep -Seconds 1

Remove-Item -Path "Q:\EMPLOYEE\SPAYDataBase\Supervisor Interface.accdb"
Remove-Item -Path "Q:\EMPLOYEE\SPAYDataBase\Supervisor Interface.laccdb"
Start-Sleep -Seconds 1

Copy-Item "Q:\EMPLOYEE\SPAYDataBase\back up-dont't touch please\Supervisor Interface-Current.accdb" "Q:\EMPLOYEE\SPAYDataBase\Supervisor Interface-Current.accdb"
Start-Sleep -Milliseconds 300
Rename-Item "Q:\EMPLOYEE\SPAYDataBase\Supervisor Interface-Current.accdb" "Supervisor Interface-testing.accdb"

Exit-PSSession
}