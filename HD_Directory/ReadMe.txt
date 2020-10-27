Readme

1. Download and install the following two modules. These are required for any use of this script.

*active directory module - download appropriate file from link and install
https://www.microsoft.com/en-us/download/details.aspx?id=45520

*sccm module download here
https://www.microsoft.com/en-us/download/details.aspx?id=45520

*install necessary modules with Install_Script.ps1
	>Right-click "Run with Powershell" to use.

*Parent_Script.ps1 is the default folder for HD-Directory use
	>Right-click "Run with Powershell" to use.

*Admin credentials are required to run/use this directory. Failed credentials within 
	the scope of this tool will still lock out your Active Directory account.

*Option #14 utilizes your Vcenter login - This login does time out and 
	will need occasional refresh with Option #15

*Option #15 (Vcenter Login) will log you in to your horizon 7 Admin account. 
	This utilizes your current session credentials to refresh your login.
	You will not need to re-enter your credentials.

*Multiple instances of this tool can be open at once and run separately.


*NECESSARY MODULES:	


*GUI colors here
Install-Module -Name "PSWriteColor"
Import-Module PSWriteColor

*copy vmware.hv.helper to 
C:\Program Files (x86)\WindowsPowerShell\Modules\ and 
C:\Program Files\WindowsPowerShell\Modules
Import-Module -Name VMware.Hv.Helper

*install powercli module
Find-Module -Name VMware.PowerCLI
Install-Module -Name VMware.PowerCLI -Scope CurrentUser
Get-Command -Module *VMWare*

*active directory module - download appropriate file from link and install
https://www.microsoft.com/en-us/download/details.aspx?id=45520

*sccm module download here
https://www.microsoft.com/en-us/download/details.aspx?id=45520

