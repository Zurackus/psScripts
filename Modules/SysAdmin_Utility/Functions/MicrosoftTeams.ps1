#71 Command to Connect to Microsoft Teams
function Connect-TeamsModule {
    Import-Module MicrosoftTeams
    $sfbSession = New-CsOnlineSession
    Import-PSSession $sfbSession -AllowClobber
}


#72 Pull all users assigned Teams Phone numbers
function Get-AssignedTeamsNum {
$workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\TeamsPeople.csv'
Get-CsOnlineUser | Where-Object  { $_.LineURI -notlike $null } | select UserPrincipalName, LineURI | export-csv -path $workOutput
}

<#
Set resource account Phone number
Set-CsOnlineVoiceApplicationInstance -Identity HRG-CBOLine@hrgpros.onmicrosoft.com -TelephoneNumber +18332176620
#>

<#
Set user phone number
Set-CsOnlineVoiceUser -Identity <UserAccount> -TelephoneNumber <Number> -LocationID SpokaneValley_HQ
#>

<#
Get-Team -DisplayName 'Information Systems'
    GroupID/DisplayName/Visibility/Archived/MailNickName/Description

Get-TeamChannel -GroupId 6f0be2ec-69d0-43f9-8f01-9af4ce426733
#>

