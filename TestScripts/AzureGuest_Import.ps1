#Connect to Teams PS Module

#Import CSV into variable $userscsv            
$users = Import-Csv -Path "C:\Users\tkonsonlas\Documents\IntriniumUsers.csv"

#Loop through CSV and update users if the exist in CVS file            
foreach ($user in $users) {            
  New-AzureADMSInvitation -InvitedUserDisplayName "$($user.name)" -InvitedUserEmailAddress "$($user.email)" -SendInvitationMessage $true -InviteRedirectUrl https://myapps.microsoft.com
}

foreach ($user in $users)
{
    $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
    $st.RelyingParty = "*"
    $st.State = "Enabled"
    $sta = @($st)
    Set-MsolUser -UserPrincipalName "$($user.email)" -StrongAuthenticationRequirements $sta
}