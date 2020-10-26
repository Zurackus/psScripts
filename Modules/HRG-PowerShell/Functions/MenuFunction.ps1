#MainMenu Function
<#
Module's required to run this script
Install-Module -Name PSWriteColor
Install-Module -Name Vmware.powercli
Install-Module -Name MicrosoftTeams
Install-Module -Name AzureAD
Install-Module -Name MSOnline
Drop the VMware.hv.helper into the x64 module folder
#>

#Set the Main user to work with
function Set-MainUserName {
    $global:mainUserName = Read-Host "Enter username (function)"
}
#Set the Main Machine to work with
function Set-MainMachine {
    $global:mainMachine = Read-Host "Enter machine (function)"
}

function Set-UserAndPass {
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
            connect-hvserver vhrgcb-03.corp.hrg -user $UN -password $PW -domain 'hrg' 
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
    
}

#Menu Presented to the user
function Show-Options {
    #Clear-Host
    Write-Host "`n================ Main Menu ================" -foregroundcolor Yellow -BackgroundColor DarkGreen
    Write-Color " 1:", " View Current set variables." -Color Yellow, Green
    Write-Color " 2:", " Clear Machine and Username" -Color Yellow, Green
    Write-Color " 3:", " Username search/set" -Color Yellow, Green
    Write-Color "x 4:", " Machine search/set" -Color Yellow, Green
    Write-Color "`nx 5:", " SCCM Scripts" -Color Yellow, Green
    Write-Color " 6:", " Power Options" -Color Yellow, Green
    Write-Color "x 7:", " Network Options" -Color Yellow, Green
    Write-Color "x 8:", " Active Directory Tasks" -Color Yellow, Green
    Write-Color "x 9:", " Delete 2.0 Helix Folder" -Color Yellow, Green
    Write-Color "x10:", "VM File Migration" -Color Yellow, Green
    Write-Color "x11:", "Move VM to OPCVirtualMach OU" -Color Yellow, Green
    Write-Color "x12:", "New - VM - Replace E1000E NIC with VMXNET 3 NIC" -Color Yellow, Green
    Write-Color "x13:", "Extend VM Disk Volume" -Color Yellow, Green
    Write-Color "x14:", "Entitlements/VM assignments" -Color Yellow, Green
    #Write-Color "15:", "" -Color Yellow, Green
    Write-Host "Q: Press 'Q' to quit."
}

function Show-MainMenu {

import-module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
Import-Module VMware.Hv.Helper
Set-UserAndPass

    do{
        #The options are shown
        Show-Options
        $input = Read-Host "what do you want to do?"
        switch ($input){#Functions that will be used based on the users selection
        '1' {   
            Write-Host "    Current set variables" -foregroundcolor Yellow -BackgroundColor DarkGreen
            write-host "`n"
    
            Write-Color "   Current set Username is ", "$global:mainUserName" -Color Green, Red
            write-host "`n"
    
            Write-Color "   Current set Machine is ", "$global:mainMachine" -Color Green, Red
            }
        '2' {
            $global:mainMachine = $null
            $global:mainUserName = $null
        
            write-host "`n"
            Write-Host "    Set username and machine have been cleared."
            write-host "`n"
            }
        '3' {
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
                    }
                    else {
                    Write-Color "Username is ", "$global:mainUserName" -Color Green, Red
                    }
                }
                else {
                Write-Host "    No global username set"
                }
            }
        '6' {
            Show-PowerMainMenu -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName
            }
        'q' {   return  }
        }
    }
    until ($input -eq 'q')
}