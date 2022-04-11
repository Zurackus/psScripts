#To require a module for a script to run you can add the below line
#Requires -Modules Az

#Modules
    Az
    AzureAD
    ExchangeOnlineManagement
    MSOnline
    ADFSToolbox

#--General Commands--#
    #Check current sessions Modules
        Get-Module
    #Remove Module from current session
        Remove-Module -Name <module-name>
    #Add Module to current session
        Import-Module -Name <module-name>
    #Set the Execution Policy of the machine
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    #Install Module
        Install-Module -Name Az
    #Only works for modules installed via 'install-module'
        Update-Module -Name Az
    #Remote Terminal
        Enter-Pssession -computername Server64
    #Run a script remotely
        Invoke-Command -filepath c:\scripts\test.ps1 -computerName Server64

#--PSScriptroots--#
    $exportsPath = Join-Path $PSScriptRoot 'Notes.txt'
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


#--Basic Networking - Powershell Equivalents--#
    Cmd         ->  Powershell
    Ipconfig    ->  get-netipconfiguration
    Ipconfig /all-> get-netipaddress
    Ping        ->  test-netconnection
    Nslookup    ->  resolve-dnsname

    Enter-PSSession -HostName "pi-"