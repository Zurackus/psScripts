Param (
    [Parameter(Position=0)]
    [string]$UN,
    [Parameter(Position=1)]
    [string]$PW,
    [Parameter(Position=2)]
    [string]$mainMachine,
    [Parameter(Position=3)]
    [string]$mainUserName
        
)
write-host "`n"
Write-Color "   Logged in Username:     ", "$UN" -Color White, Green
Write-Color "   PW                      ", "$PW" -Color White, Green
write-host "`n"
Write-Color "   Session Username:       ", "$mainUserName" -Color White, Red
Write-Color "   Session Machine:        ", "$mainMachine" -Color White, Red
write-host "`n"

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope User -ParticipateInCEIP:$false | out-null

#connect to vcenter server
Connect-VIServer -Server vCenter1.corp.hrg | out-null

function Get-ADMainMenu {
    write-host "`n"
    Write-Host "    Active Directory Task Menu" -foregroundcolor Yellow -BackgroundColor DarkGreen
    write-host "`n"
    Write-Color "1.  ", "Username Summary" -Color Yellow, Green
    Write-Color "2.  ", "Unlock Account" -Color Yellow, Green
    Write-Color "3.  ", "Disable Account" -Color Yellow, Green
    Write-Color "4.  ", "Enable Account" -Color Yellow, Green
    Write-Color "5.  ", "Reset Password" -Color Yellow, Green
    Write-Color "6.  ", "Set new username" -Color Yellow, Green

    write-host "`n"
}

write-host "`n"
Write-Host "        Active Directory - User Account Actions        " -foregroundcolor Yellow -BackgroundColor DarkGreen


if (!$mainUserName ) {
    write-host "`n"

    $mainUserName = Read-Host 'Enter username'
}
write-host "`n"
Write-Color "Username is ", "$mainUserName" -Color White, Red

get-aduser $mainUserName -properties PasswordExpired, PasswordLastSet, PasswordNeverExpires, LockedOut

Get-ADMainMenu

while (($var = Read-Host -Prompt "Enter Number for Selection or Q to return to Main Menu") -ne 'Q')
    {

switch ($var) {
    1 {
        write-host "`n"

        get-aduser $mainUserName -properties PasswordExpired, PasswordLastSet, PasswordNeverExpires, LockedOut
        write-host "`n"
        Get-ADMainMenu    }
    2 {
        Write-Host "Unlocking Account..."
        Unlock-ADAccount -Identity $mainUserName
        write-host "`n"
        Write-Host "Account unlocked."
        write-host "`n"
        Get-ADMainMenu    }
    3 {
        Write-Host "Disabling Account..."
        Disable-ADAccount -Identity $mainUserName
        write-host "`n"
        Write-Host "Account disabled."
        write-host "`n"
        Get-ADMainMenu
    }
    4 {
        Write-Host "Enabling Account..."
        Enable-ADAccount -Identity $mainUserName
        write-host "`n"
        Write-Host "Account Enabled." 
        write-host "`n"
        Get-ADMainMenu    }
    5 {
        write-host "`n"
        $newPW = Read-Host "Enter new password"
        write-host "`n"
        $newPW2 = Read-Host "Re-enter password"
        write-host "`n"
        if ($newPW -eq $newPW2) {
            Set-ADAccountPassword -Identity $mainUserName -NewPassword (ConvertTo-SecureString -AsPlainText $newPW -Force)
            Write-Host "Password reset successful."
        } Else {
            Write-Host "Passwords do not match. Please try again."
        }
        write-host "`n"
        Get-ADMainMenu
    }
    5 {
        write-host "`n"
        get-aduser $mainUserName -properties PasswordExpired, PasswordLastSet, PasswordNeverExpires, lastlogontimestamp
        write-host "`n"
        Get-ADMainMenu    }
    6 {
        write-host "`n"
        Write-Color "Current Username is ", "$mainUserName" -Color White, Red
        write-host "`n"
        $checkUserName = Read-Host "Enter new username"
        write-host "`n"
        $adSearch = Get-ADUser -Filter {SamAccountName -eq $checkUserName} | Select-Object SamAccountName

        if(!$adSearch) {
            Write-Color "    Username does not exist in Active Directory. Please try again." -Color Red
        } else {
            $mainUserName = $checkUserName
            Write-Color "   New username is ", "$mainUserName" -Color White, Red
        }

        Get-ADMainMenu
        }

}

}

