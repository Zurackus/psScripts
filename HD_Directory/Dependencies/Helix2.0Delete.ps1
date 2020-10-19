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


Write-Host "        VM HELIX 2.0 Folder Delete      " -foregroundcolor Yellow -BackgroundColor DarkGreen
write-host "`n"
Start-Sleep -s 3

Write-Color "    Deleting 2.0 Folder....." -Color Green

$directoryPath = "\\$mainMachine\c$\Users\$mainUserName\AppData\Local\Apps\2.0"
Get-Childitem $directoryPath -Recurse | Remove-Item -Force

Start-Sleep -s 5
write-host "`n"
Write-Color "    Helix 2.0 Folder deleted." -Color Green
write-host "`n"
write-host "`n"

Read-Host -Prompt "     Press Enter to return to Main Menu"

