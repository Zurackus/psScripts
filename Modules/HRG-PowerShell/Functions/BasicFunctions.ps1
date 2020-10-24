#Master list of all Basic PowerShell functions


#Pull all users who are currently enabled
function get-ADenabled {
    get-aduser -filter "(enabled -eq 'true')" -properties title, company, department,officephone, canonicalname, whencreated, officephone,office,mail,lastlogontimestamp,employeeID | export-csv ".\ADenabled.csv" 
}

#Pull all users who are currently disabled
function get-ADdisabled {
    get-aduser -filter "(enabled -eq 'false')" -properties title, company, department,officephone, canonicalname, whencreated, officephone,office,mail,lastlogontimestamp | export-csv ".\ADdisabled.csv"
}

#Pull all users who have a password that does not expire
function get-ADPasswordNeverExpires {
    get-aduser -Filter {(Enabled -eq $TRUE) -and (PasswordNeverExpires -eq $TRUE)} -ResultPageSize 2000 -Properties Name, SamAccountName, LastLogonDate, passwordlastset, distinguishedname | where-object {$_.distinguishedname -notlike "*disabled*" -and $_.distinguishedname -notlike "*roleaccounts*"} | export-csv ".\PassNeverExpiresAccounts.CSV"
}

<#
# ---csv---
#SamAccountName
#user1
#user2
#user3
import-csv "C:\Users\tkonsonlas\OneDrive - Healthcare Resource Group, Inc\Documents\AD.csv" | ForEach-Object {Set-ADUser -Identity $_.SamAccountName -PasswordNeverExpires:$FALSE}
#>

#Pull all users who have not logged in for the last 60 days
function get-ADnologgin60days {
    $60Days = (get-date).adddays(-60)
    Get-ADUser -Filter {(Enabled -eq $TRUE) -and (PasswordNeverExpires -eq $TRUE)} -Properties Name,SamAccountName,LastLogonDate,DistinguishedName | Where {($_.LastLogonDate -le $60Days) -and ( $_.distinguishedname -notlike "*roleaccounts*") -and ( $_.distinguishedname -notlike "*sccm*")} | Sort | Select Name,SamAccountName,LastLogonDate,DistinguishedName | Export-Csv ".\PassNeverExpiresAccounts-Over60days.CSV" -NoTypeInformation
}

<#
#Remotely get a running Process
Invoke-Command  -ComputerName HRGW0521-5 -ScriptBlock{Get-Process -Name "*msi*"}
#Remotely stop a process
Invoke-Command  -ComputerName HRGW0521-5 -ScriptBlock{Stop-Process -Name "*msi*"}
#>
