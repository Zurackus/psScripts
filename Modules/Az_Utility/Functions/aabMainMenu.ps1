

function Show-OptionMenu {
    write-host "`n"
    Write-Host "====================================TASK MENU====================================" -foregroundcolor Yellow -BackgroundColor DarkGreen
    write-host "`n"
    Write-Color "   1.  ", "Pull enabled users          ", "       2.  ", "Pull disabled users" -Color Yellow, Green, Yellow, Green
    Write-Color "   3.  ", "Passwords don't expire list ", "       4.  ", "No Loggin 60 days"-Color Yellow, Green, Yellow, Green
    Write-Color "   5.  ", "Unlock-ADUser               ", "       6.  ", ""-Color Yellow, Green, Yellow, Green
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
        '6' {
            Write-Host "    Running Get-ADMembers" -Color Green
            write-host "`n"
            Get-ADMembers
            Write-Color "   Completed" -Color Green
            }
        'q' {   return  }
        }
    }until ($input -eq 'q')
}