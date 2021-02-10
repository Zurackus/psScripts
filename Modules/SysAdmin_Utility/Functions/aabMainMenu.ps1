function Show-OptionMenu {
    write-host "`n"
    Write-Host "====================================TASK MENU====================================" -foregroundcolor Yellow -BackgroundColor DarkGreen
    write-host "`n"
    Write-Color "   1.  ", "Pull enabled users          ", "       6.  ", "" -Color Yellow, Green, Yellow, Green
    Write-Color "   2.  ", "Pull disabled users         ", "       7.  ", ""-Color Yellow, Green, Yellow, Green
    Write-Color "   3.  ", "Passwords not expired       ", "       8.  ", ""-Color Yellow, Green, Yellow, Green
    Write-Color "   4.  ", "No Loggin 60 days           ", "       9.  ", ""-Color Yellow, Green, Yellow, Green
    Write-Color "   5.  ", "                            ", "       10. ", ""-Color Yellow, Green, Yellow, Green
    write-host "`n"
    Write-Color "   20. ", "                            ", "       26. ", "" -Color Yellow, Green, Yellow, Green
    write-host "`n"
}

function Get-MainMenu {
    do{
        #The options are shown
        Show-OptionMenu
        $input = Read-Host "what do you want to do?"
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
            Get-ADPasswordNeverExpires
            Write-Color "   Completed" -Color Green
            }
        '4' {
            Write-Host "    Pulling the users with never expiring passwords from AD" -Color Green
            write-host "`n"
            Get-ADnologgin60days
            Write-Color "   Completed" -Color Green
            }
        '6' {
            #Show-PowerMainMenu -UN $UN -PW $PW -mainMachine $global:mainMachine -mainUserName $global:mainUserName
            }
        'q' {   return  }
        }
    }until ($input -eq 'q')
}