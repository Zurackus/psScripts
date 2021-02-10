<#
Here are Basic functions

#>

#Pull all users who are currently enabled
function Get-ADenabled {
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\ADenabled.csv'
    get-aduser -filter "(enabled -eq 'true')" -properties title, company, department, officephone, canonicalname, whencreated, officephone, office, mail, lastlogontimestamp, employeeID | export-csv -path $workOutput
}

#Pull all users who are currently disabled
function Get-ADdisabled {
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\ADdisabled.csv'
    get-aduser -filter "(enabled -eq 'false')" -properties title, company, department, officephone, canonicalname, whencreated, officephone, office, mail, lastlogontimestamp | export-csv -path $workOutput
}

#Pull all users who have a password that does not expire
function Get-ADPasswordNeverExpires {
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\PassNeverExpiresAccounts.csv'
    get-aduser -Filter { (Enabled -eq $TRUE) -and (PasswordNeverExpires -eq $TRUE) } -ResultPageSize 2000 -Properties Name, SamAccountName, LastLogonDate, passwordlastset, distinguishedname | where-object { $_.distinguishedname -notlike "*disabled*" -and $_.distinguishedname -notlike "*roleaccounts*" } | export-csv -path $workOutput
}

#Pull all users who have not logged in for the last 60 days
function Get-ADnologgin60days {
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\PassNeverExpiresAccounts.csv'
    $60Days = (get-date).adddays(-60)
    Get-ADUser -Filter { (Enabled -eq $TRUE) -and (PasswordNeverExpires -eq $TRUE) } -Properties Name, SamAccountName, LastLogonDate, DistinguishedName | Where { ($_.LastLogonDate -le $60Days) -and ( $_.distinguishedname -notlike "*roleaccounts*") -and ( $_.distinguishedname -notlike "*sccm*") } | Sort | Select Name, SamAccountName, LastLogonDate, DistinguishedName | Export-Csv -path $workOutput
}

#Unlock specified username
function Unlock-ADUser {
    $mainUserName = Read-Host 'Enter username'
    get-aduser $mainUserName -properties PasswordExpired, PasswordLastSet, PasswordNeverExpires, LockedOut
    Unlock-ADAccount -Identity $mainUserName
    }