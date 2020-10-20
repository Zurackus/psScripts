<#
Module's required to run this script
Install-Module -Name PSWriteColor
Install-Module -Name Vmware.powercli
Drop the VMware.hv.helper into the x64 module folder

#>

#import sccm module
import-module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
#import the vmware horizon view helper
Import-Module VMware.Hv.Helper

write-host "`n"
write-host "`n"
Write-Host "        HELPDESK TASK TREE        " -foregroundcolor Yellow -BackgroundColor DarkGreen

function Get-MainMenu {
    write-host "`n"
    Write-Host "    TASK MENU" -foregroundcolor Yellow -BackgroundColor DarkGreen
    write-host "`n"
    Write-Color "1.  ", "View Current set variables" -Color Yellow, Green
    Write-Color "2.  ", "Clear Machine and Username" -Color Yellow, Green
    Write-Color "3.  ", "Username search/set" -Color Yellow, Green
    Write-Color "4.  ", "Machine search/set" -Color Yellow, Green
    write-host "`n"
    Write-Color "5.  ", "SCCM Scripts" -Color Yellow, Green
    Write-Color "6.  ", "Power Options" -Color Yellow, Green
    Write-Color "7.  ", "Network Options" -Color Yellow, Green
    Write-Color "8.  ", "Active Directory Tasks" -Color Yellow, Green
    Write-Color "9.  ", "Delete 2.0 Helix Folder" -Color Yellow, Green
    Write-Color "10. ", "VM File Migration" -Color Yellow, Green
    Write-Color "11. ", "Move VM to OPCVirtualMach OU" -Color Yellow, Green
    Write-Color "12. ", "New - VM - Replace E1000E NIC with VMXNET 3 NIC" -Color Yellow, Green
    Write-Color "13. ", "Extend VM Disk Volume" -Color Yellow, Green
    Write-Color "14. ", "Entitlements/VM assignments" -Color Yellow, Green

    write-host "`n"
}

function Set-MainUserName {
    $global:mainUserName = Read-Host "Enter username (function)"

}

function Set-MainMachine {
    $global:mainMachine = Read-Host "Enter machine (function)"


}
$count = 0

do {

    write-host "`n"
    $UN = Read-Host "Username"
    $PW = Read-Host "Password" -AsSecureString
    Write-Host "$Path"
    $global:UN = $UN
    $global:PW = $PW
    write-host "`n"

    try{
       
        connect-hvserver vhrgcb-03.corp.hrg -user tkonsonlas -password Training365! -domain 'hrg'
        #connect-hvserver vhrgcb-03.corp.hrg -user $UN -password $PW -domain 'hrg' 
        $success = $true
        write-host "`n"
        Write-Host "Login successful"

    }
    catch {
        write-host = "Login failure, please try again."

    }

    $count++
} until ($count -eq 3 -or $success)

if(-not($success)) {
    Read-Host "Exits"
}

Get-MainMenu

while (($var = Read-Host -Prompt "Enter Number for Selection or Q to quit") -ne 'Q')
    {

switch ($var) {

    1 {
        Write-Host "    Current set variables" -foregroundcolor Yellow -BackgroundColor DarkGreen
        write-host "`n"

        Write-Color "   Current set Username is ", "$global:mainUserName" -Color Green, Red
        write-host "`n"

        Write-Color "   Current set Machine is ", "$global:mainMachine" -Color Green, Red
        Get-MainMenu
        }

    2 {
        $global:mainMachine = $null
        $global:mainUserName = $null
    
        write-host "`n"
        Write-Host "    Set username and machine have been cleared."
        write-host "`n"
        Get-MainMenu
    
        }

    3 {
        write-host "`n"
        Write-Color "  Search and Set(1) or Set(2)      " -Color Green -NoNewLine
        $dec1 = Read-Host 

        if ($dec1 -eq 1) {

        write-host "`n"
        Write-Color "   Search for username:" -Color Green
        Write-Host "        Enter part of first name, last name, or username in search."
        Write-Host "        The query will return any matching category."

        write-host "`n"
        Write-Color "   For example:" -Color Green
        Write-Host "        A search for 'Joh' will return the Active Directory"
        Write-Host "        usernames of John Green and Dianna Johnson."

        write-host "`n"
        Write-Color "Enter desired search for username:     " -Color Green -NoNewLine
        $criteria = Read-host 
        $crit = "*" + $criteria + "*"
        $res = Get-ADUser -Filter {SamAccountName -like $crit -or GivenName -like $crit -or SurName -like $crit} | Select-Object SamAccountName
        $res
        }
        write-host "`n"
        Write-Color "    Would you like to assign username for this session?" -Color Green
        Write-Host "        This will allow username to be carried to all applicable scripts"
        Write-Host "        until this window is closed or until variables are cleared with option #12"

        write-host "`n"
        Write-Color "  Yes(1) or No(2)      " -Color Green -NoNewLine
        $dec = Read-Host 
        write-host "`n"

        if ($dec -eq 1) {
            Set-MainUserName
            write-host "`n"
            $unSearch = $Global:mainUserName

            $adSearch = Get-ADUser -Filter {SamAccountName -eq $unSearch} | Select-Object SamAccountName
            if(!$adSearch) {
                Write-Color "    Username does not exist in Active Directory. Please try again." -Color Red
            } else {
                Write-Color "Username is ", "$global:mainUserName" -Color Green, Red
            }
        }
        else {
            Write-Host "    No global username set"
        }

        Get-MainMenu
    }
    4 {
        write-host "`n"
        Write-Host "    MACHINE SEARCH/SELECT       " -foregroundcolor Yellow -BackgroundColor DarkGreen
        write-host "`n"

        Write-Color "   Search and Set(1) or Set(2)      " -Color Green -NoNewLine
        $dec4 = Read-Host 

        if ($dec4 -eq 1) {

            if($global:mainUserName) {

                write-host "`n"
                Write-Color "   Current set username is ", "$Global:mainUserName"-Color White, Red
                write-host "`n"
                Write-Color "    Would you like to search with this name? Yes(1) or No(2) " -Color Green -NoNewLine
                $dec3 = Read-Host
            }
                IF ($dec3 -eq 1) {
                    $username = $global:mainUserName
                }            
                else {
                    write-host "`n"

                    Write-Color "   Enter username for search: " -Color Green -NoNewLine
                    $username = Read-Host
    
                }
            

        write-host "`n"
        Set-Location hrg:
        $machines = Get-CMUserDeviceAffinity -Username "hrg\$username" | Select-Object ResourceName
        $machines
        Set-Location C:\Users\sstraughen
            
            }

        write-host "`n"
            Write-Color "    Would you like to assign a machine for this session?" -Color Green
            Write-Host "        This will allow the machine to be carried to all applicable scripts"
            Write-Host "        until this window is closed or until variables are cleared with option #12"
    
            write-host "`n"
            Write-Color "       Yes(1) or No(2) " -Color Green -NoNewLine
            $dec5 = Read-Host 
            write-host "`n"
    
            if ($dec5 -eq 1) {
                Set-MainMachine
            }
            else {
                Write-Host "    No global machine set."
            }
    
            write-host "`n"

        

        Write-Color "   Machine is ", "$global:mainMachine" -Color Green, Red
        Get-MainMenu

    }
    
    5 {
        $powerPath = $PSScriptRoot + "\Dependencies"
        .$powerPath\SCCM_scripts.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

#       .\Dependencies\SCCM_scripts.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

        Get-MainMenu
    }

    6 { 
        $powerPath = $PSScriptRoot + "\Dependencies"
        .$powerPath\VM_Power_Script.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName
#        .\Dependencies\VM_Power_Script.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

        Get-MainMenu
    }

    7 { 
        $powerPath = $PSScriptRoot + "\Dependencies"
        .$powerPath\Network_Options.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName
        Get-MainMenu
    }

    8 { 
        $powerPath = $PSScriptRoot + "\Dependencies"
        .$powerPath\AD_unlock_account.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName
#        .\Dependencies\AD_unlock_account.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

        Get-MainMenu
    }
    
    9 { 
        $powerPath = $PSScriptRoot + "\Dependencies"
        .$powerPath\Helix2.0Delete.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName
#       .\Dependencies\Helix2.0Delete.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

        Get-MainMenu
    }
    
    10 { 
        $powerPath = $PSScriptRoot + "\Dependencies"
        .$powerPath\vm_file_migration_script.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

#       .\Dependencies\vm_file_migration_script.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

        Get-MainMenu
    }
    
    11 { 
        $powerPath = $PSScriptRoot + "\Dependencies"
        .$powerPath\Move_VM_to_OPCVirtualMach_OU.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

#        .\Dependencies\Move_VM_to_OPCVirtualMach_OU.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

        Get-MainMenu
    }
    
    12 {
        $powerPath = $PSScriptRoot + "\Dependencies"
        .$powerPath\NewVM_Change_Network_Card.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

#        .\Dependencies\NewVM_Change_Network_Card.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

        Get-MainMenu
    }

    13 {
        $powerPath = $PSScriptRoot + "\Dependencies"
        .$powerPath\vm_extend_disk.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

 #       .\Dependencies\vm_extend_disk.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

        Get-MainMenu
    }

    14 {
        $powerPath = $PSScriptRoot + "\Dependencies"
        .$powerPath\user_pool_vm_assignment_management.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

#        .\Dependencies\user_pool_vm_assignment_management.ps1 -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName

        Get-MainMenu
    }

    Default {Write-Host "Unable to Proceed"}
}
    }





Read-Host -Prompt "Press Enter to exit"