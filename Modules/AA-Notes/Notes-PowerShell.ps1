#To require a module for a script to run you can add the below line
#Will auto-load the module into the session if the module is installed, otherwise it will error out immediately
#Requires -Modules Az
#To require a specific version of PowerShell
#Requires -version 7
#To require running as Administrator
#Requires -RunAsAdministrator

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

    read-host "Enter a computer name"
    read-host "Enter a password" -assecurestring #Storing securly
        -get-credentials
    write-host "Here's my message" -forgroundcolor DarkCyan -backgroundcolor Yellow
    write-progress#ToolBuilding 4.3
    write-debug

Function Test-Net {
    [CmdletBinding()]#Will create an 'Advanced function' adding additional options:
                        #Debug,ErrorAction,WarningAction,InformationAction,ErrorVariable,WarningVariable
    param ( #New
        [Parameter(Mandatory = $true,helpmessage="Enter the name of the computer",#Here you can add the Mandatory option and the Helpmessage option
        ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]#Here is outlining how you can enable Pipeline option
		[Alias("servername","hostname")]#Alias will allow different ways to enter the same variable
        [ValidateCount(1,10)]#Limits the number of computers that can be listed
        [ValidateLength(1,15)]#Limits the number of characters that can be used for this variable
        [ValidatePattern("^LON[a-z]{2,3}\d{1.2}")]#Can use regex to limit the 'pattern' of the accepted variables
		[string[]]$computername,#[] within the string permits arrays
		
		[Parameter(Mandatory = $false,helpmessage="Enter the name of the port") #
        ] #helpmessage/mandatory
        [ValidateSet(135,80,22,445)]#ValidateSet allows us to hard-code a list of possible values
		[int[]]$port = 135#[] within the string permits arrays
    )

    BEGIN{}#Can be deleted if nothing is in here for the 'Pipeline option'
    PROCESS{#Required pieces of the actual function to be able to use the 'Pipeline option'
            #If using pipeline, you can pass a batch of variables to the function, and just the ones that can be processed will be processed
            #This will allow running the function against many variables all simultaneously 
        foreach($computer in $computername) {
            write-verbose "New testing $compter"#Here is how you add your own verbose chat you can add with -verbose being added when running the function
            $pingResult = test-netconnection -computerName $computer -InformationLevel Quiet
            if($pingResult){
                $result = $pingResult
            }else {
                write-verbose "Ping failed on $computer. Checking port $port..."#Another example of using the 'write-verbose'
                $portResult = test-netconnection -computerName $compter -InformationLevel Quiet -port $port
                $result = $portResult
            }
            $services = Get-service -computername $computer
            $properties = <#can add [ordered] here if you want to keep the hash table order. But that isn't recommended for larger hashtables#>
                        @{
                ComputerName = $compter
                Reachable = $result
                Services = $services
            }
            $return = New-Object -TypeName psobject -Property $properties
            Write-Output $return
        }
    }
    END{}#Can be deleted if nothing is in here for the 'Pipeline option'
}

enum ServerName {
    LonDC1
    LonDC2
    LonSVR1
}

[ServerName]::LonDC1

Function Register-Repo {
    [cmdletbinding(Supportsshouldprocess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$name,
        [Parameter(Mandatory=$true)]
        [string]$sourceLocation,
        [ValidateSet('Trusted','Untrusted')]
        [string]$installationPolicy = 'Trusted'
    )
    #Many site, including Github, now require TLS 1.2 or greater, so let's enable it:
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    if ($PSCmdlet.ShouldProcess("$name as a $installationPolicy repository")) {
        Register-PSRepostitory -Name $name -SourceLocation $sourceLocation -InstallationPolicy -$installationPolicy
    }
}

<#
Static Members from the .NET framework that can be accessed
[Math]::E
[Math]::PI
[Math]::Round(23.456,2)#round the number to a specific value

[System.Environment]::MachineName

[Security.Principal.WindowsBuiltInRole]::Administrator #<tab><tab> etc to cycle through options
[Security.Principal.WindowsBuiltInRole]:: | Get-Member -Static #List out all of the static members

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 #Enable tls1.2

#>

#Research get-memeber
#Research $error(Collects up to 256 errorsA)
#Research Powershell Profile
#Research DSC - Desired State Configuration
    get-command -module psdesiredstateconfiguration
    #Local Configuration Manager
#Research JEA - Just Enough Administration
    #9.2
