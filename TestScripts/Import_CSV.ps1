# Import AD Module             
Import-Module ActiveDirectory            
            
# Import CSV into variable $userscsv            
#$userscsv = import-csv D:\areile\Desktop\adtest.csv            
$users = Import-Csv -Path C:\users\tkonsonlas\desktop\test.csv            
# Loop through CSV and update users if the exist in CVS file            
            
foreach ($user in $users) {            
#Search in specified OU and Update existing attributes            
 Get-ADUser -Filter "SamAccountName -eq '$($user.samaccountname)'" -Properties * -SearchBase "OU=HRG_USERS,DC=corp,DC=hrg" |            
  Set-ADUser -Title $($user.Title) -Department $($user.Department)            
}