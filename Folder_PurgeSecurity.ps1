$acl = Get-Acl "C:\Users\tkonsonlas\Documents\PS_Scripts"
$usersid = New-Object System.Security.Principal.Ntaccount ("hrg\jediaz")
$acl.PurgeAccessRules($usersid)
$acl | Set-Acl "C:\Users\tkonsonlas\Documents\PS_Scripts"