#To require a module for a script to run you can add the below line
#'Requires -Modules AzureAD'

<# Modules
Az
AzureAD
ExchangeOnlineManagement
MSOnline
ADFSToolbox
#>

#PS-Repository, accept current settings
#Remove-Module <module-name>
#$env:PSModulePath

<# PSScriptroot #>
$exportsPath = Join-Path $PSScriptRoot 'Functions.csv'
$moduleRoot = Split-Path -Parent $PSScriptRoot
$workFolder = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath '\old'
$workOutput = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath '\WorkFiles\Import.csv'

Write-Output "`n1.`$exportsPath:[$exportsPath]"
Write-Output "2.`$PSScriptRoot:[$PSScriptRoot]"
Write-Output "3.Parent:[$(Split-Path -Parent $MyInvocation.MyCommand.Path)]"
Write-Output "4.Leaf:[$(Split-Path -Leaf $MyInvocation.MyCommand.Path)]"
Write-Output "5.Full path:[$($MyInvocation.MyCommand.Path)]"
Write-Output "6.Parent of `$PSScriptRoot:[$moduleRoot]"
Write-Output "7.Child of `$Scriptroots Parent :[$workFolder]"
Write-Output "8.Child/File of `$Scriptroots Parent :[$workOutput]"
Write-Output "9.Enviroment Variable, Appdata Local :[$env:LOCALAPPDATA]"
Write-Output "10.Enviroment Variable, Appdata Roaming :[$env:APPDATA]"
Write-Output "11.Enviroment Variable, Public :[$env:PUBLIC]"
Write-Output "12.Enviroment Variable, AppData\Local\Temp :[$env:TEMP]"

#$pshome -force

<# Basic Networking
Powershell Equivalent***
Cmd -> Powershell
Ipconfig -> get-netipconfiguration
Ipconfig /all -> get-netipaddress
Ping -> test-netconnection
Nslookup - resolve-dnsname
#>

#Remote Terminal
enter-pssession -computername Server64

#Run a script remotely
invoke-command -filepath c:\scripts\test.ps1 -computerName Server64