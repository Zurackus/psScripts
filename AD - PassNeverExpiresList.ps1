#Get list of User accounts that have password never expires enabled

#All except disabled accounts/roles
$search1 = Search-ADAccount -PasswordNeverExpires -UsersOnly -ResultPageSize 2000 -resultSetSize $null | Select-Object Name, SamAccountName, DistinguishedName | where-object {$_.distinguishedname -notlike "*disabled*" -and $_.distinguishedname -notlike "*roleaccounts*"} | Export-CSV “.\PassNeverExpiresAccounts.CSV” -NoTypeInformation
$search1
#^remake with get-aduser
Get-ADUser -Filter {(Enabled -eq $TRUE) -and (PasswordNeverExpires -eq $TRUE)} -ResultPageSize 2000 -Properties Name, SamAccountName, LastLogonDate, passwordlastset, distinguishedname | where-object {$_.distinguishedname -notlike "*disabled*" -and $_.distinguishedname -notlike "*roleaccounts*"}

#Only accounts in clientportalnonemployee (tab2)
$search2 = Search-ADAccount -PasswordNeverExpires -UsersOnly -ResultPageSize 2000 -resultSetSize $null | Select-Object Name, SamAccountName, DistinguishedName | where-object {$_.distinguishedname -like "*ClientPortalNonEmployee*" -and $_.distinguishedname -notlike "*disabled*" -and $_.distinguishedname -notlike "*roleaccounts*"} | Export-CSV “C:\Scripts\PassNeverExpiresAccounts-OnlyClientPortal.CSV” -NoTypeInformation
$search2

#Only accounts not logged in last 60days (tab3) including disabled ou
$60Days = (get-date).adddays(-60)
Get-ADUser -Filter {(Enabled -eq $TRUE) -and (PasswordNeverExpires -eq $TRUE)} -Properties Name,SamAccountName,LastLogonDate,DistinguishedName | Where {($_.LastLogonDate -le $60Days) <#-and ($_.LastLogonDate -ne $NULL)#> <#-and ($_.distinguishedname -notlike "*disabled*") #> -and ( $_.distinguishedname -notlike "*roleaccounts*") -and ( $_.distinguishedname -notlike "*sccm*")} | Sort | Select Name,SamAccountName,LastLogonDate,DistinguishedName | Export-Csv "C:\Scripts\PassNeverExpiresAccounts-Over60days.CSV" -NoTypeInformation

#Disabled OU accounts with login over 60days?



####Testing####
#get-aduser -Identity jediaz -Properties *