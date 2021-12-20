#91 Connect to Exchange Online
function Connect-ExchangeModule {
    Import-Module ExchangeOnlineManagement
    Connect-ExchangeOnline
}

#https://www.codetwo.com/admins-blog/prevent-users-from-changing-profile-photos-microsoft-365/
Get-OwaMailboxPolicy | FL name,SetPhotoEnabled
Set-OwaMailboxPolicy OwaMailboxPolicy-Default -SetPhotoEnabled $false

New-OwaMailboxPolicy "AllowChangingPhotos" | Set-OwaMailboxPolicy -SetPhotoEnabled $True

Set-CASMailbox -Identity brmitchell@hrgpros.com -OwaMailboxPolicy "AllowChangingPhotos"

DRobertson@hrgpros.com, jspraktes@hrgpros.com, brmitchell@hrgpros.com

$Perms = Get-ManagementRole -Cmdlet Set-UserPhoto
$Perms | foreach {Get-ManagementRoleAssignment -Role $_.Name -Delegating $false | Format-Table -Auto Role,RoleAssigneeType,RoleAssigneeName}

Add-RoleGroupMember "Organization Management" -Member drobertson@hrgpros.com

#email being blocked by odd rule
Get-TransportRule 7B066AB9-54FE-4699-B3A3-43E0C25259FA