#Scripts around AzureMFA(MultiFactor Authentication)
#Enable-AzureMFA - Force MFA on all HRG users
#Get-AzureMFAcsv - Check to see who has MFA 'forced' and 'waiting'
#Requires -Modules AzureAD

#Force MFA on all HRG users
function Enable-AzureMFA {
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
}

#Check to see who has MFA 'forced' and 'waiting'
function Get-AzureMFAcsv {
Connect-MsolService

[int] $MaxResults = 2000
[bool] $isLicensed = $true

    $AdminUsers = Get-MsolRole | foreach {Get-MsolRoleMember -RoleObjectId $_.ObjectID} | Where-Object {$_.EmailAddress -ne $null} | Select EmailAddress -Unique | Sort-Object EmailAddress
    $AllUsers = Get-MsolUser -MaxResults $MaxResults | Where-Object {$_.IsLicensed -eq $isLicensed} | select DisplayName, UserPrincipalName, `
        @{Name = 'isAdmin'; Expression = {if ($AdminUsers -match $_.UserPrincipalName) {Write-Output $true} else {Write-Output $false}}}, `
        @{Name = 'MFAForced'; Expression={if ($_.StrongAuthenticationRequirements) {Write-Output $true} else {Write-Output $false}}},
        @{Name = 'MFAWaiting'; Expression={if ($_.StrongAuthenticationMethods -like "*") {Write-Output $true} else {Write-Output $false}}}

        Write-Output $AllUsers | Sort-Object MFAForced, MFAWaiting, isAdmin | export-csv ".\AzureMFA.csv"
}