$users = Import-Csv -Path C:\Scripts\adtest.csv            
            
foreach ($user in $users) {            
 Get-ADUser -Identity $user.SamAccountName -Properties * |            
 select SamAccountName, Division, Office, City             
}


# Import AD Module             
Import-Module ActiveDirectory            
            
# Import CSV into variable $userscsv            
#$userscsv = import-csv D:\areile\Desktop\adtest.csv            
$users = Import-Csv -Path C:\Scripts\adtest.csv            
# Loop through CSV and update users if the exist in CVS file            
            
foreach ($user in $users) {            
#Search in specified OU and Update existing attributes            
 Get-ADUser -Filter "SamAccountName -eq '$($user.samaccountname)'" -Properties * -SearchBase "cn=Users,DC=manticore,DC=org" |            
  Set-ADUser -City $($user.City) -Office $($user.Office) -Division $($user.Division)            
}


# Import AD Module             
Import-Module ActiveDirectory            
            
# Import CSV into variable $userscsv            
#$userscsv = import-csv D:\areile\Desktop\adtest.csv            
$users = Import-Csv -Path C:\Scripts\adtest.csv            
# Loop through CSV and update users if the exist in CVS file            
            
foreach ($user in $users) {            
#Search in specified OU and Update existing attributes            
 Get-ADUser -Filter "SamAccountName -eq '$($user.samaccountname)'" -Properties * -SearchBase "cn=Users,DC=manticore,DC=org" |            
  Set-ADUser -Replace @{l = "$($user.City)"; physicalDeliveryOfficeName = "$($user.Office)"; division = "$($user.Division)"}            
}


# Import AD Module             
Import-Module ActiveDirectory 

$users = Import-Csv -Path C:\Scripts\adtest.csv                        
# Loop through CSV and update users if the exist in CVS file                        
                        
foreach ($user in $users) {                        
#Search in specified OU and Update existing attributes                        
 Get-ADUser -Filter "SamAccountName -eq '$($user.samaccountname)'" -Properties * -SearchBase "cn=Users,DC=manticore,DC=org" |                        
  Set-ADUser -Clear l, physicalDeliveryOfficeName, division                        
}

get-aduser -filter "(enabled -eq 'true') -AND (company -eq 'Healthcare Resource Group')" -properties title, mail, department |
 ? {$_.DistinguishedName -notlike "*,OU=Non_Employee,*"} |
 select Department, Mail, Name, SamAccountName, Title |
 export-csv "\\hrgfile\DATA\DataControl\Clients\Test Client\TCNScoreCard\AD_Request.csv"