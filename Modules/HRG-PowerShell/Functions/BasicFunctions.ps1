#Master list of all Basic PowerShell functions

#Pull all users who are currently enabled
function get-ADenabled {
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\ADenabled.csv'
    get-aduser -filter "(enabled -eq 'true')" -properties title, company, department, officephone, canonicalname, whencreated, officephone, office, mail, lastlogontimestamp, employeeID | export-csv -path $workOutput
}

#Pull all users who are currently disabled
function get-ADdisabled {
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\ADdisabled.csv'
    get-aduser -filter "(enabled -eq 'false')" -properties title, company, department, officephone, canonicalname, whencreated, officephone, office, mail, lastlogontimestamp | export-csv -path $workOutput
}

#Pull all users who have a password that does not expire
function get-ADPasswordNeverExpires {
    get-aduser -Filter { (Enabled -eq $TRUE) -and (PasswordNeverExpires -eq $TRUE) } -ResultPageSize 2000 -Properties Name, SamAccountName, LastLogonDate, passwordlastset, distinguishedname | where-object { $_.distinguishedname -notlike "*disabled*" -and $_.distinguishedname -notlike "*roleaccounts*" } | export-csv ".\PassNeverExpiresAccounts.CSV"
}

#Pull all users who have not logged in for the last 60 days
function get-ADnologgin60days {
    $60Days = (get-date).adddays(-60)
    Get-ADUser -Filter { (Enabled -eq $TRUE) -and (PasswordNeverExpires -eq $TRUE) } -Properties Name, SamAccountName, LastLogonDate, DistinguishedName | Where { ($_.LastLogonDate -le $60Days) -and ( $_.distinguishedname -notlike "*roleaccounts*") -and ( $_.distinguishedname -notlike "*sccm*") } | Sort | Select Name, SamAccountName, LastLogonDate, DistinguishedName | Export-Csv ".\PassNeverExpiresAccounts-Over60days.CSV" -NoTypeInformation
}

function get-VPN-ActiveTunnels {
    #PSScript does not work with F8
    $dir = $PSScriptRoot + "\FirewallVPN_ActiveVPNs.py"
    #Calling a python script
    python $dir
}

function get-VPN-TunnelGrous {
    #PSScript does not work with F8
    $dir = $PSScriptRoot + "\FirewallVPN_TunnelGroups.py"
    #Calling a python script
    python $dir
}

function Unlock-ADUser {
$mainUserName = Read-Host 'Enter username'
get-aduser $mainUserName -properties PasswordExpired, PasswordLastSet, PasswordNeverExpires, LockedOut
Unlock-ADAccount -Identity $mainUserName
}

#Code to remotely reset a password even if the current password is expired
function Set-PasswordRemotely {
    [CmdletBinding(DefaultParameterSetName = 'Secure')]
    param(
        [Parameter(ParameterSetName = 'Secure', Mandatory)][string] $UserName,
        [Parameter(ParameterSetName = 'Secure', Mandatory)][securestring] $OldPassword,
        [Parameter(ParameterSetName = 'Secure', Mandatory)][securestring] $NewPassword,
        [Parameter(ParameterSetName = 'Secure')][alias('DC', 'Server', 'ComputerName')][string] $DomainController
    )
    Begin {
        $DllImport = @'
[DllImport("netapi32.dll", CharSet = CharSet.Unicode)]
public static extern bool NetUserChangePassword(string domain, string username, string oldpassword, string newpassword);
'@
        $NetApi32 = Add-Type -MemberDefinition $DllImport -Name 'NetApi32' -Namespace 'Win32' -PassThru

        if (-not $DomainController) {
            if ($env:computername -eq $env:userdomain) {
                # not joined to domain, lets prompt for DC
                $DomainController = Read-Host -Prompt 'Domain Controller DNS name or IP Address'
            } else {
                $Domain = $Env:USERDNSDOMAIN
                $Context = [System.DirectoryServices.ActiveDirectory.DirectoryContext]::new([System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain, $Domain)
                $DomainController = ([System.DirectoryServices.ActiveDirectory.DomainController]::FindOne($Context)).Name
            }
        }
    }
    Process {
        if ($DomainController -and $OldPassword -and $NewPassword -and $UserName) {
            $OldPasswordPlain = [System.Net.NetworkCredential]::new([string]::Empty, $OldPassword).Password
            $NewPasswordPlain = [System.Net.NetworkCredential]::new([string]::Empty, $NewPassword).Password

            $result = $NetApi32::NetUserChangePassword($DomainController, $UserName, $OldPasswordPlain, $NewPasswordPlain)
            if ($result) {
                Write-Host -Object "Set-PasswordRemotely - Password change for account $UserName failed on $DomainController. Please try again." -ForegroundColor Red
            } else {
                Write-Host -Object "Set-PasswordRemotely - Password change for account $UserName succeeded on $DomainController." -ForegroundColor Cyan
            }
        } else {
            Write-Warning "Set-PasswordRemotely - Password change for account failed. All parameters are required. "
        }
    }
}

#Edit domain, username, oldpassword, newpassword - Password can not be expired
#([adsi]'WinNT://domain/username,user').ChangePassword('oldpassword','newpassword')

<#
# ---csv---
#SamAccountName
#user1
#user2
#user3
import-csv "C:\Users\tkonsonlas\OneDrive - Healthcare Resource Group, Inc\Documents\AD.csv" | ForEach-Object {Set-ADUser -Identity $_.SamAccountName -PasswordNeverExpires:$FALSE}
# ---csv---
#SamAccountName OfficePhone
#user1          Phone1
#user2          Phone2
#user3          Phone3
import-csv "C:\Users\tkonsonlas\psScripts\PhoneNumberImport.csv" | ForEach-Object {Set-ADUser -Identity $_.SamAccountName -OfficePhone $_.OfficePhone}
#>

<#
#Remotely get a running Process
Invoke-Command  -ComputerName HRGW0521-5 -ScriptBlock{Get-Process -Name "*msi*"}
#Remotely stop a process
Invoke-Command  -ComputerName HRGW0521-5 -ScriptBlock{Stop-Process -Name "*msi*"}
#>

<#
Update Username with msol module
Connect-MsolService
Set-MsolUserPrincipalName -UserPrincipalName "cegger@hrgpros.com" -NewUserPrincipalName "chines@hrgpros.com"
#>

<#
Unlock SMB Share Access
Get-SmbShare -Special $false | ForEach-Object { Unblock-SmbShareAccess -Name $_.Name -AccountName ‘tkyes’ -Force }
#>