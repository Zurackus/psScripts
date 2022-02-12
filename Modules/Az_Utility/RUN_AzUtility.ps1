<#
This is here simply to trigger the first 'Start-AzUtility' by right clicking this file and 'Run with Powershell'

If desired, the folder 'Az_Utility' can be dropped into the PowerShell 'Module' folder.
    Once in the Module folder you can open a PowerShell window and should be able to run the command:
    "Start-AzUtility"

All of the commands are being tested on PowerShell 7
#>
$PSM1 = Join-Path $PSScriptRoot 'ImportFunctions.psm1'
Import-Module -Name $PSM1

Start-AzUtility