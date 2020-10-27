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

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope User -ParticipateInCEIP:$false | out-null

#connect to vcenter server
Connect-VIServer -Server vCenter1.corp.hrg | out-null

Write-Host "        Move New VM to the OPCVirtualMach OU in Active Directory      " -foregroundcolor Yellow -BackgroundColor DarkGreen
write-host "`n"
write-host "`n"


$Exists = get-vm -name $mainMachine -ErrorAction SilentlyContinue  
If ($Exists){  
    Write-Color "  VM existence verified."  -Color Green
    write-host "`n"
    Write-Host "Moving VM to OPCVirtualMach OU...."
    Get-ADComputer "CN=$mainMachine,OU=NewComputers,dc=corp,dc=hrg" | Move-ADObject -TargetPath "OU=OPCVirtualMach,dc=corp,dc=hrg"
    Write-Host "Verifying...."
    if (Get-ADComputer "CN=$mainMachine,OU=OPCVirtualMach,dc=corp,dc=hrg" -ErrorAction SilentlyContinue){
        write-host "`n"
        Write-Color "    $mainMachine has successfully been moved into OPCVirtualMach OU."

        $curDate = Get-Date -UFormat "%m.%d.%y"
        $NotesTemp = (Get-VM $mainMachine | Select-Object -ExpandProperty Notes)
        $AD_OU_change = "Moved to OPCVirtualMach OU - $curDate - $UN"
        Set-VM $mainMachine -Notes "$($AD_OU_change)`n$($NotesTemp)" -Confirm:$false

    } else {
        write-host "`n"
        Write-Color "    Transfer Failed." -Color Green
    }

}  
Else {  
    write-host "`n"
    Write-Color "    VM does not exist." -Color Green
}  


write-host "`n"
Read-Host -Prompt "Press Enter to return to Main Menu"
