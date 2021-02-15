<#
This is the where the SysAdmin Utility is first started and contains the following functions:

Start-SysAdminUtility
Get-AllMods
Set-ConsoleColor
Set-LoginCreds

#>

function Start-SysAdminUtility {
    #Get-AllMods
    Get-WorkFiles
    Set-ConsoleColor 'Black' 'Gray'
    Get-MainMenu
}

function Get-AllMods {
    # Modules we need
    $modulesArray = @(
        "Az",
        "MicrosoftTeams"
    )

    # Rather than looking through both arrays, just loop through the ones we care about
    foreach($mod in $modulesArray) {
        if(Get-Module -ListAvailable $mod) {
            # Module exists
            # Write-Host "Module '$mod' is already installed"
        } else {
            # Module does not exist, install it
            Write-Host "Open an Admin window and install:'$mod'"
            Install-Module $mod
        }
    }
}

function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
}

function Set-LoginCreds {
    $count = 0
    do {
        write-host "`n"
        $global:UN = Read-Host "Username"
        $global:PW = Read-Host "Password" -AsSecureString
        Write-Host "$Path"
        #    $global:UN = $UN
        #    $global:PW = $PW
        try {
            connect-hvserver vhrgcb-03.corp.hrg -user $global:UN -password $global:PW -domain 'hrg' 
            $success = $true
            write-host "`n"
            Write-Host "Login successful"
        }
        catch {
            write-host "Login failure, please try again."
        }
        $count++
    } until ($count -eq 2 -or $success)
    if (-not($success)) {
        Read-Host "Exit"
    }
}

function Set-CloudCreds {
    if ($null -eq $global:Credential) {
        write-host "Cloud Credentials are needed"
        $global:Credential = Get-Credential
    }else {
        write-host "Cloud Credentials set"
    }
}

function Get-WorkFiles {
    $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles'
    if(Test-Path -Path $workOutput) {
        Write-Host "WorkFiles folder already exists"
    }else {
        New-Item -Path $env:LOCALAPPDATA -Name "WorkFiles" -ItemType "directory"
        Write-Host "Workfiles Directory has been created"
        Write-Host "Located in %LOCALAPPDATA%\WorkFiles"
    }
}