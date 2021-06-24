#Connect to Teams PS Module
Import-Module MicrosoftTeams
$sfbSession = New-CsOnlineSession
Import-PSSession $sfbSession -AllowClobber

#Import CSV into variable $userscsv            
$users = Import-Csv -Path "C:\Users\tkonsonlas\Healthcare Resource Group, Inc\Information Systems - General\Helpdesk_GeneralDocs\PortedUserNumbers.csv"            

#Loop through CSV and update users if the exist in CVS file            
foreach ($user in $users) {            
  Set-CsOnlineVoiceUser -Identity "$($user.User)" -TelephoneNumber "$($user.Number)" -LocationID 01bc4c52-f79f-495f-8424-a7390642945d
}