#Scripts around Microsoft Teams
#Connect2Teams - Command to Connect to Microsoft Teams
#
#Skype for Business
#https://docs.microsoft.com/en-us/powershell/module/skype/?view=skype-ps
#Microsoft Teams
#https://docs.microsoft.com/en-us/powershell/teams/?view=teams-ps
#Require module MicrosftTeams

#Command to Connect to Microsoft Teams
function Connect2Teams {
    Import-Module MicrosoftTeams
    $sfbSession = New-CsOnlineSession
    Import-PSSession $sfbSession
}

<#
Pull all users assigned Teams Phone numbers
Get-CsOnlineUser | Where-Object  { $_.LineURI -notlike $null } | select UserPrincipalName, LineURI | export-csv -path TeamsPeople.csv
#>

<#
Set resource account Phone number
Set-CsOnlineVoiceApplicationInstance -Identity HRG-CBOLine@hrgpros.onmicrosoft.com -TelephoneNumber +18332176620
#>