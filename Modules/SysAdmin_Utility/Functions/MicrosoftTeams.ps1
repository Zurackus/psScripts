#Command to Connect to Microsoft Teams
function Connect2Teams {
    Import-Module MicrosoftTeams
    $sfbSession = New-CsOnlineSession
    Import-PSSession $sfbSession -AllowClobber
}

<#
Pull all users assigned Teams Phone numbers
Get-CsOnlineUser | Where-Object  { $_.LineURI -notlike $null } | select UserPrincipalName, LineURI | export-csv -path TeamsPeople.csv
#>

<#
Set resource account Phone number
Set-CsOnlineVoiceApplicationInstance -Identity HRG-CBOLine@hrgpros.onmicrosoft.com -TelephoneNumber +18332176620
#>

<#
Set user phone number
Set-CsOnlineVoiceUser -Identity <UserAccount> -TelephoneNumber <Number> -LocationID SpokaneValley_HQ
#>