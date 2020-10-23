#Scripts around Microsoft Teams
#Connect2Teams - Command to Connect to Microsoft Teams
#
#Skype for Business
#https://docs.microsoft.com/en-us/powershell/module/skype/?view=skype-ps
#Microsoft Teams
#https://docs.microsoft.com/en-us/powershell/teams/?view=teams-ps
#Requires -Modules MicrosftTeams

#Command to Connect to Microsoft Teams
function Connect2Teams {
    Import-Module MicrosoftTeams
    $sfbSession = New-CsOnlineSession
    Import-PSSession $sfbSession
}
