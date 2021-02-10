<#
This is the where the SysAdmin Utility is first started and contains the following functions:

Start-SysAdminUtility
Set-ConsoleColor
Set-LoginCreds

#>
function Start-SysAdminUtility {
    Import-Module VMware.Hv.Helper
    import-module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
    Set-ConsoleColor 'Black' 'Gray'
    Set-LoginCreds
    Get-MainMenu
}

function Set-ConsoleColor ($bc, $fc) {
    $Host.UI.RawUI.BackgroundColor = $bc
    $Host.UI.RawUI.ForegroundColor = $fc
    Clear-Host
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
            write-host = "Login failure, please try again."

        }

        $count++
    } until ($count -eq 2 -or $success)

    if (-not($success)) {
        Read-Host "Exit"
    }
}

function Set-MainUserName {
    $global:mainUserName = Read-Host "Enter username (function)"

}

function Set-MainUserName2 ($UserTEST) {
    $global:mainUserName = $UserTEST

}

function Set-MainMachine ($VMTEST) {
    $global:mainMachine = $VMTEST

}
function Set-MainMachine2 {
    $global:mainMachine = Read-Host "Enter machine (function)"


}