function Show-OptionMenu {
    write-host "`n"
    Write-Host "====================================TASK MENU====================================" -foregroundcolor Yellow -BackgroundColor DarkGreen
    write-host "`n"
    Write-Color "   1.  ", "Pull enabled users          ", "       2.  ", "Pull disabled users" -Color Yellow, Green, Yellow, Green
    Write-Color "   3.  ", "Passwords don't expire list ", "       4.  ", "No Loggin 60 days"-Color Yellow, Green, Yellow, Green
    Write-Color "   5.  ", "Unlock-ADUser               ", "       6.  ", ""-Color Yellow, Green, Yellow, Green
    write-host "`n"
    Write-Color "   21. ", "Looped port test            ", "       22. ", "Test multiple ports for 1 ip" -Color Yellow, Green, Yellow, Green
    Write-Color "   23. ", "PsSession                   ", "       24. ", "" -Color Yellow, Green, Yellow, Green
    write-host "`n"
    Write-Color "   31. ", "Get-VPNActiveTunnels        ", "       32. ", "Get-VPNTunnelGroups" -Color Yellow, Green, Yellow, Green
    write-host "`n"
    Write-Color "   51. ", "Connect to Az               ", "       52. ", "Enable-AzureMFA" -Color Yellow, Green, Yellow, Green
    Write-Color "   53. ", "Get-AzureMFAcsv             ", "       54. ", "" -Color Yellow, Green, Yellow, Green
    write-host "`n"
    Write-Color "   71. ", "Connect to Teams            ", "       72. ", "Get Assigned Teams Numbers" -Color Yellow, Green, Yellow, Green
    write-host "`n"
    Write-Color "   91. ", "Connect to ExchangeOnline   ", "       92. ", "" -Color Yellow, Green, Yellow, Green
    write-host "`n"
}

function Get-MainMenu {
    do{
        #The options are shown
        Show-OptionMenu
        $input = Read-Host "`nEnter the number of your desired action('q' to quit)"
        switch ($input){#Functions that will be used based on the users selection
        '1' {   
            Write-Host "    Pulling the enabled users from AD" -Color Green
            write-host "`n"
            Get-ADenabled
            Write-Color "   Completed" -Color Green
            }
        '2' {
            Write-Host "    Pulling the disabled users from AD" -Color Green
            write-host "`n"
            Get-ADdisabled
            Write-Color "   Completed" -Color Green
            }
        '3' {
            Write-Host "    Pulling the users with never expiring passwords from AD" -Color Green
            write-host "`n"
            Get-PasswordNeverExpires
            Write-Color "   Completed" -Color Green
            }
        '4' {
            Write-Host "    Pulling the users with never expiring passwords from AD" -Color Green
            write-host "`n"
            Get-NoLogIn60Days
            Write-Color "   Completed" -Color Green
            }
        '5' {
            Write-Host "    Running Unlock-ADUser" -Color Green
            write-host "`n"
            Unlock-ADUser
            Write-Color "   Completed" -Color Green
            }
        'x' {
            #Show-PowerMainMenu -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName
            }
        '21'{   
            Write-Host "    Running Test-NetworkLoop" -Color Green
            write-host "`n"
            Test-NetworkLoop
            Write-Color "   Completed" -Color Green
            }
        '22' {
            Write-Host "    Running Test-NetworkMulti" -Color Green
            write-host "`n"
            Test-NetworkMulti
            Write-Color "   Completed" -Color Green
            }
        '31'{
            Write-Host "    Pulling currently active tunnels in OPC2" -Color Green
            write-host "`n"
            Get-VPNActiveTunnels
            Write-Color "   Completed" -Color Green
            }
        '32'{
            Write-Host "    Pulling a list of all Tunnel groups in OPC2" -Color Green
            write-host "`n"
            Get-VPNTunnelGroups
            Write-Color "   Completed" -Color Green
            }
        '51'{
            Write-Host "    Running Connect-AzureModule" -Color Green
            write-host "`n"
            Connect-AzureModule
            Write-Color "   Completed" -Color Green
            }
        '52'{
            Write-Host "    Running Enable-AzureMFA" -Color Green
            write-host "`n"
            Enable-AzureMFA
            Write-Color "   Completed" -Color Green
            }
        '53'{   
            Write-Host "    Running Get-AzureMFAcsv" -Color Green
            write-host "`n"
            Get-AzureMFAcsv
            Write-Color "   Completed" -Color Green
            }
        '71'{
            Write-Host "    Running Connect-TeamsModule" -Color Green
            write-host "`n"
            Connect-TeamsModule
            Write-Color "   Completed" -Color Green
            }
        '72'{
            Write-Host "    Running Get-AssignedTeamsNum" -Color Green
            write-host "`n"
            Get-AssignedTeamsNum
            Write-Color "   Completed" -Color Green
            }
        '91'{
            Write-Host "    Running Connect-ExchangeModule" -Color Green
            write-host "`n"
            Connect-ExchangeModule
            Write-Color "   Completed" -Color Green
            }
        'x' {
            Write-Host "    Getting Command for unlocking AD Account" -Color Green
            write-host "`n"
            Unlock-ADUser
            Write-Color "   Completed" -Color Green
            }
        'q' {   return  }
        }
    }until ($input -eq 'q')
}