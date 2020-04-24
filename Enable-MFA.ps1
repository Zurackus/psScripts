#Script to Force MFA
#Must connect to Microsoft Online Service
Connect-MsolService

[int] $MaxResults = 2000
[bool] $isLicensed = $true

    #Going out and finding all of the licensed users
    $AllUsers = Get-MsolUser -MaxResults $MaxResults | Where-Object {$_.IsLicensed -eq $isLicensed} | select UserPrincipalName,
            #Adding a column for finding if the users have MFA forced on them
        @{Name = 'MFAForced'; Expression={if ($_.StrongAuthenticationRequirements) {Write-Output $true} else {Write-Output $false}}}

    #Create a new array with the users who need to be forced
    $FilteredUsers = $AllUsers.Where({$_.MFAForced -match 'FALSE'})

    #Here are the one off exclusions for MFA
    $FilteredUsers2 = $FilteredUsers |
        Where {$_.UserPrincipalName -ne "unifiedmessaging@hrgpros.onmicrosoft.com"} |
        Where {$_.UserPrincipalName -ne "finvestigation@hrgpros.com"} |
        Where {$_.UserPrincipalName -ne "spmarketplace@hrgpros.onmicrosoft.com"} |
        Where {$_.UserPrincipalName -ne "sharepointjobapplications@hrgpros.onmicrosoft.com"}

    #Create another array with just the usernames that need to be updated
    $users = $FilteredUsers2 | foreach { $_.UserPrincipalName }

#Below is a simple output to make sure the right users are being updated
#Write-Output $users

#Code provided by Microsoft to enable MFA
foreach ($user in $users)
{
    $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
    $st.RelyingParty = "*"
    $st.State = "Enabled"
    $sta = @($st)
    Set-MsolUser -UserPrincipalName $user -StrongAuthenticationRequirements $sta
}