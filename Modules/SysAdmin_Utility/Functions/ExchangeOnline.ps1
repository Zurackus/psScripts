#91 Connect to Exchange Online
function Connect-ExchangeModule {
    Import-Module ExchangeOnlineManagement
    Connect-ExchangeOnline
}

#https://www.codetwo.com/admins-blog/prevent-users-from-changing-profile-photos-microsoft-365/
#Get the existing value of the photo setting
Get-OwaMailboxPolicy | FL name,SetPhotoEnabled
#Set the value of the photo setting for the 'Default' policy
Set-OwaMailboxPolicy OwaMailboxPolicy-Default -SetPhotoEnabled $false

#Create a new separate policy to be applied to a smaller group of users
New-OwaMailboxPolicy "AllowChangingPhotos" | Set-OwaMailboxPolicy -SetPhotoEnabled $True

#Apply an OWA policy to a user
Set-CASMailbox -Identity brmitchell@hrgpros.com -OwaMailboxPolicy "AllowChangingPhotos"

#Check for the management roles needed for a specific cmdlet, Specifically here 'Set-userphoto'
$Perms = Get-ManagementRole -Cmdlet Set-UserPhoto
$Perms | foreach {Get-ManagementRoleAssignment -Role $_.Name -Delegating $false | Format-Table -Auto Role,RoleAssigneeType,RoleAssigneeName}

#Add a person to a speficific Management group
Add-RoleGroupMember "Organization Management" -Member drobertson@hrgpros.com

#email being blocked by odd rule
Get-TransportRule 7B066AB9-54FE-4699-B3A3-43E0C25259FA