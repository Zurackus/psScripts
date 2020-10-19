Param (
    [Parameter(Position=1)]
    [string]$UN,
    [Parameter(Position=2)]
    [string]$PW,
    [Parameter(Position=3)]
    [string]$mainMachine,
    [Parameter(Position=4)]
    [string]$mainUserName
        
)
write-host "`n"
Write-Color "   Logged in Username:     ", "$UN" -Color White, Green
Write-Color "   PW                      ", "$PW" -Color White, Green
write-host "`n"
Write-Color "   Session Username:       ", "$mainUserName" -Color White, Red
Write-Color "   Session Machine:        ", "$mainMachine" -Color White, Red
write-host "`n"

write-host "`n"
Write-Host "        VM MIGRATION SCRIPT - username, old vm, and new vm required to run      " -foregroundcolor Yellow -BackgroundColor DarkGreen
write-host "`n"
write-host "`n"


Write-Host "Username is $mainUserName."
write-host "`n"
Write-Host "Old machine is $mainMachine."
write-host "`n"

#input VM that user is migrating TO
$newVM = Read-Host 'Enter new VM'
write-host "`n"

#variable to copy all desired folders from user's profile
$remoteFolderCopy = "\\$mainMachine\c$\Users\$mainUserName\Contacts", 
    "\\$mainMachine\c$\Users\$mainUserName\Desktop",
    "\\$mainMachine\c$\Users\$mainUserName\Documents",
    "\\$mainMachine\c$\Users\$mainUserName\Downloads",
    "\\$mainMachine\c$\Users\$mainUserName\Favorites",
    "\\$mainMachine\c$\Users\$mainUserName\Links"

#variable to paste desired folders to new VM
$remoteFolderPaste = "\\$newVM\c$\Users\$mainUserName\"

#variable to copy chrome favorites 
$chromeFolderCopy = "\\$mainMachine\c$\Users\$mainUserName\AppData\Local\Google\Chrome\User Data\Default"

#variable to paste chrome favorites
$chromeFolderPaste = "\\$newVM\c$\Users\$mainUserName\AppData\Local\Google\Chrome\User Data\"

#variable for testing that chrome favorites were moved
$chromeFavorites = "\\$newVM\c$\Users\$mainUserName\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"

#test paths to each area
#Write-Host "$mainMachine Contacts, Desktop, Documents, Downloads, Favorites, and Links folders exist:"
#Test-Path -Path $remoteFolderCopy

if (Test-Path -Path $remoteFolderCopy){
    "$mainMachine Contacts, Desktop, Documents, Downloads, Favorites, and Links folders exist."
    write-host "`n"
} Else {"$mainMachine Contacts, Desktop, Documents, Downloads, Favorites, and Links folders do not exist."
write-host "`n"
}

#Write-Host "$newVM Username/Profile folders exist:"
#Test-Path -Path $remoteFolderPaste

if (Test-Path -Path $remoteFolderPaste){
    "$newVM Username/Profile folders exist."
    write-host "`n"
} Else {"$newVM Username/Profile folders do not exist."
write-host "`n"
}

#Write-Host "$mainMachine Chrome Default folder exists:"
#Test-Path -Path $chromeFolderCopy

if (Test-Path -Path $chromeFolderCopy){
    "$mainMachine Chrome Default folders exist:."
    write-host "`n"
} Else {"$mainMachine Chrome Default folders does not exist."
write-host "`n"
}

#Write-Host "$newVM Chrome Default folder exists:"
#Test-Path -Path $chromeFolderPaste

if (Test-Path -Path $chromeFolderPaste){
    "$newVM Chrome Default folder exists."
    write-host "`n"
} Else {"$newVM Chrome Default folder does not exist."
write-host "`n"
}

if (Test-Path -Path $remoteFolderCopy){
    
    #copy and paste commands
    Copy-Item -Path $remoteFolderCopy -Destination $remoteFolderPaste -Force -Recurse

    } Else { "User profile does not exist on old VM."
    write-host "`n"
}


# correct network path error  not found use true and true statements, warn that one of the machines is wrong



#output message that script has completed running
Write-Host "My Music, My Pictures, and My Videos are junction point folders for backwards compatibility to certain Windows XP applications. Warnings can be safely ignored."
write-host "`n"

Add-Type -AssemblyName System.Windows.Forms
$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
$balmsg.BalloonTipText = "My Music, My Pictures, and My Videos warnings can be safely ignored."
$balmsg.BalloonTipTitle = "Attention $Env:USERNAME"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(20000)

#Copy and paste old chrome bookmarks to new vm, IF it exists.
if(Test-Path -Path $chromeFolderCopy){
    Copy-Item -Path $chromeFolderCopy -Destination $chromeFolderPaste -Force -Recurse
    } Else {
        "There is no chrome profile on old VM to copy."
        write-host "`n"
    }


#verify chrome bookmarks pasted correctly and exist
if (Test-Path -Path $chromeFavorites){
    "$newVM Chrome Bookmarks file transferred successfully"
    write-host "`n"
} Else {"$newVM Chrome Bookmarks file transfer was unsuccessful"
write-host "`n"
}

#output message that script has completed running
Add-Type -AssemblyName System.Windows.Forms
$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
$balmsg.BalloonTipText = "All files transferred successfully."
$balmsg.BalloonTipTitle = "Attention $Env:USERNAME"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(20000)

write-host "`n"
write-host "`n"
Read-Host -Prompt "Press Enter to return to Main Menu"