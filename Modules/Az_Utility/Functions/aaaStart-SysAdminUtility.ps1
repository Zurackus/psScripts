<#
This is the where the AzUtility is first started and contains the following functions:

Start-AzUtility
Get-AllMods
Set-ConsoleColor
Get-WorkFiles

#>

function Start-AzUtility {
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

    #Rather than looking through both arrays, just loop through the ones we care about
    foreach($mod in $modulesArray) {
        if(Get-Module -ListAvailable $mod) {
            # Module exists
            Write-Host "Module '$mod' is already installed"
        } else {
            #Module does not exist, install it
            Write-Host "Open an Admin window and install:'$mod'"
            Install-Module -Name $mod
        }
    }
}

function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
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