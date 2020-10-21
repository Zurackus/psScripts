#Check Security
get-acl "\\vhrgihpe\data\CBO_Clients" | fl

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