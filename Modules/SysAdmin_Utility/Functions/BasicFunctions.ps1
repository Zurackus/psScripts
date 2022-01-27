<#
Here are Basic functions

Get-ADenabled
Get-ADdisabled
Get-PasswordNeverExpires
Get-NoLogIn60Days
Unlock-ADUser
Get-ADMembers
Test-NetworkLoop - Loop TCP test a specific port for a specific IP
Test-NetworkMulti - TCP test multiple ports for a single IP
Remove-SelfpayDB
Remove-OldFiles
FolderSecurity - NOT A FUNCTION(to-do)
Get-MembersOfGroups - NOT A FUNCTION(to-do)

#>

#1 Pull all users who are currently enabled
function Get-ADenabled {
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\ADenabled.csv'
    get-aduser -filter "(enabled -eq 'true')" -properties title, company, department, officephone, canonicalname, whencreated, officephone, office, mail, lastlogontimestamp, employeeID | export-csv -path $workOutput
}
#get-aduser -filter "(enabled -eq 'true') -AND (company -eq 'Healthcare Resource Group')" -properties title, mail, department | ? {$_.DistinguishedName -notlike "*,OU=Non_Employee,*"} | select Department, Mail, Name, SamAccountName, Title | export-csv "\\vhrgihpe\DATA\DataControl\Clients\Test Client\TCNScoreCard\AD_Request.csv"

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
<# ---csv---
#SamAccountName
#user1
#user2
#user3
import-csv "C:\Users\tkonsonlas\OneDrive - Healthcare Resource Group, Inc\Documents\AD.csv" | ForEach-Object {Set-ADUser -Identity $_.SamAccountName -PasswordNeverExpires:$FALSE}
#>

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

function Remove-SelfpayDB {
Enter-PSSession -ComputerName vhrgihpe

Get-SmbOpenFile | Where-Object {$_.Path -like "Q:\EMPLOYEE\SPAYDataBase\Supervisor Interface*"} | Close-SmbOpenFile -Force
Start-Sleep -Seconds 10

Remove-Item -Path "Q:\EMPLOYEE\SPAYDataBase\Supervisor Interface.accdb"
Remove-Item -Path "Q:\EMPLOYEE\SPAYDataBase\Supervisor Interface.laccdb"
Start-Sleep -Seconds 1

Copy-Item "Q:\EMPLOYEE\SPAYDataBase\back up-dont't touch please\Supervisor Interface-Current.accdb" "Q:\EMPLOYEE\SPAYDataBase\Supervisor Interface-Current.accdb"
Start-Sleep -Milliseconds 500
Rename-Item "Q:\EMPLOYEE\SPAYDataBase\Supervisor Interface-Current.accdb" "Supervisor Interface-testing.accdb"
Start-Sleep -Milliseconds 500

Exit-PSSession
}

#Delete all Files in R:\SCANNED older than 30 day(s)
function Remove-OldFiles {
  $Path = "\\hrgfile\Remote\SCANNED"
  $Daysback = "-1"
   
  $CurrentDate = Get-Date
  $DatetoDelete = $CurrentDate.AddDays($Daysback)
  Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $DatetoDelete }
}

#NOT A FUNCTION - bits and pieces that need to be organized into a full function
function FolderSecurity {

    Write-Host -Object 'Full path needed like:
    `n\\hrgatad\I\helpdesk
    `nC:\users\%username%\desktop'
    $FolderPath = Read-Host "Full network path"
        
    #Check Security
    get-acl $FolderPath | fl
    
    # Add Security
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


#NOT A FUNCTION - bits and pieces that need to be organized into a full function
function Get-MembersOfGroups {

    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\GoupmemberShip.csv'
    $GroupList = "DCAnalyst", "DCManager"
    foreach ($Group in $GroupList)
    { 
        Get-ADGroupMember $Group | Export-csv -Path $workOutput -Append
    }
}

#NOT A FUNCTION - Set specific AD field for a group of users 
function set-ADParameter {
  $users = Import-Csv -Path C:\Users\tkonsonlas\Documents\Selfpay-users.csv            
  # Loop through CSV and update users if the exist in CVS file                      
  foreach ($user in $users) {            
  #Search in specified OU and Update existing attributes            
    Set-ADUser -Identity $user.SamAccountName -Department "Selfpay"
  }
  
}
