
Write-Host "If not done, refer to ReadMe to download and install"
Write-Host "the Active Directory and SCCM modules. These are"
Write-Host "required modules for the use of this script."


#GUI colors here
Install-Module -Name "PSWriteColor"
Import-Module PSWriteColor
Write-Host "PSwriteColor complete."


#copy vmware.hv.helper to 
#C:\Program Files (x86)\WindowsPowerShell\Modules\ and 
#C:\Program Files\WindowsPowerShell\Modules
Import-Module -Name VMware.Hv.Helper
Write-Host "VMware.Hv.Helper complete."


#install powercli module
Find-Module -Name VMware.PowerCLI
Install-Module -Name VMware.PowerCLI -Scope CurrentUser
Get-Command -Module *VMWare*
Write-Host "PowerCLI complete."

Write-Host -prompt "Press Enter to exit."
<#
*active directory module - download appropriate file from link and install
https://www.microsoft.com/en-us/download/details.aspx?id=45520

*sccm module download here
https://www.microsoft.com/en-us/download/details.aspx?id=45520

#>