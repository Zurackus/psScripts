#RunAsAdmin
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

#------------------------------------------------------------------------------------------------------------------------------------#
#ActiveDirectory

function InstallAD {
Set-ItemProperty "REGISTRY::HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" UseWUserver -value 0
Get-Service wuauserv | Restart-Service
Get-WindowsCapability -Online -Name RSAT.ActiveDirectory*  | Add-WindowsCapability -Online
Set-ItemProperty "REGISTRY::HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" UseWUserver -value 1
}

Get-WindowsCapability -online | Where-Object { $_.Name -like "rsat.ActiveDirectory*" -and $_.State -eq "NotPresent"} | InstallAD

#------------------------------------------------------------------------------------------------------------------------------------#
#AzureAD

function InstallAzureAD {
Install-PackageProvider -name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false
Install-Module -name "AzureAD" -Confirm:$false
Import-Module -name "AzureAD"
}

$AzureAD = Get-Module -Name AzureAD
if (($AzureAD) -eq $null){InstallAzureAD}

#------------------------------------------------------------------------------------------------------------------------------------#
#ExchangeOnlineManagement

if ((get-module PowerShellGet) -eq $null){
Install-Module powershellget -Force -Confirm:$false
Update-Module powershellget -Confirm:$false
}

$ExchangeOnlineManagement = Get-Module -Name ExchangeOnlineManagement
if (($ExchangeOnlineManagement) -eq $null){
Install-module -Name ExchangeOnlineManagement -Confirm:$false
Update-Module -Name ExchangeOnlineManagement -Confirm:$false
}

#------------------------------------------------------------------------------------------------------------------------------------#
#MSOnline

$MSOnline = Get-Module -Name MSOnline
if (($MSOnline) -eq $null){Install-Module -Name MSOnline -Confirm:$false}

