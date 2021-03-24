#Get-MsolUser -UserPrincipalName tkonsonlas@hrgpros.com
#Get-MsolAccountSku
#Set-MsolUserLicense -UserPrincipalName 

$users = Import-Csv -Path "C:\Users\tkonsonlas\Documents\users3.csv"       
            
foreach ($user in $users) {            
 Set-MsolUserLicense -UserPrincipalName "$($user.samaccountname)" -RemoveLicenses "hrgpros:ENTERPRISEPACK"
}