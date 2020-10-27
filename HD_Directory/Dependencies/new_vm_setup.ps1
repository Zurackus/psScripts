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
Write-Color "   Logged in Username:     ", "$global:UN" -Color White, Green
Write-Color "   PW                      ", "$global:PW" -Color White, Green
write-host "`n"
Write-Color "   Session Username:       ", "$mainUserName" -Color White, Red
Write-Color "   Session Machine:        ", "$mainMachine" -Color White, Red
write-host "`n"


#import the vmware horizon view helper
Import-Module VMware.Hv.Helper

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope User -ParticipateInCEIP:$false | out-null

#connect to vcenter server
Connect-VIServer -Server vCenter1.corp.hrg | out-null

#credentials will be required to log into this - set in another function? (not recommended)

write-host "`n"

Write-Host "        New VM Setup      " -foregroundcolor Yellow -BackgroundColor DarkGreen
if (!$mainMachine) {
    write-host "`n"
    $mainMachine = Read-Host '      Enter Computer Name for setup'

}

Write-Host "`n"
$networkCard = Read-Host "    Perform network card change? Yes(1) or No (2)   "
Write-Host "`n"

$moveVM = Read-Host "    Add machine to Virtual Machine OU ? Yes(1) or No (2)    "
Write-Host "`n"

$poolAssign = Read-Host "    Add vm to desktop pool? Yes(1) or No (2)    "
Write-Host "`n"

$userAssign = Read-Host "    Assign user to vm? Yes(1) or No (2)     "
Write-Host "`n"

if($poolAssign -eq 1){
    Write-Host "`n"
    $desktopPool = Read-Host "  Enter desired pool for vm"
    Write-Host "`n"
}

if($userAssign -eq 1){
    write-host "`n"
    $mainUserName1 = Read-Host "Enter username for device assignment"
}

if($networkCard -eq 1){
    
$Exists = get-vm -name $mainMachine -ErrorAction SilentlyContinue  
If ($Exists){  
     Write-Color "   VM exists." -Color Green

     #add to or new notes 1=add, 2=new

$curDate = Get-Date -UFormat "%m.%d.%y"
$TextToAppend2 = "*created $curDate - $UN"
Set-VM $mainMachine -Notes "$($TextToAppend2)`n$($NotesTemp)" -Confirm:$false


write-host "`n"
Write-Host "Shutting down $mainMachine"
Stop-VM -vm $mainMachine -Confirm:$false
Start-Sleep -s 13
$adapterType = "VMXNET3"

write-host "`n"
get-networkadapter -vm $mainMachine | where {$_.Name -eq "Network adapter 1"} | remove-networkadapter -Confirm:$false
write-host "`n"
Write-Color "   Network Adapter 1 has been removed." -Color Green

write-host "`n"
Write-Host "   Adding VMXNET 3 adapter..."
get-vm $mainMachine | new-networkadapter -networkname 'DHCP' -type $adapterType 
Write-Color "   Network Adapter of Type VMXNET 3 has been added." -Color Green
write-host "`n"

Write-host "Powering on $mainMachine"
Start-VM -vm $mainMachine

Start-Sleep -s 13

Get-VM  $mainMachine | get-networkadapter -Name "Network adapter 1" | Set-NetworkAdapter -Connected:$true -Confirm:$false
write-host "`n"
Write-Host "Network Adapter Connected."

$curDate = Get-Date -UFormat "%m.%d.%y"
$NotesTemp = (Get-VM $mainMachine | Select-Object -ExpandProperty Notes)
$NICchange = "NIC E1000E changed to VMXNET 3 - $curDate - $UN"
Set-VM $mainMachine -Notes "$($NICchange)`n$($NotesTemp)" -Confirm:$false

write-host "`n"


}  
Else {  
     Write-Color "   VM not found. No changes were made to NIC configuration." -Color Green
     
}  



}

if($moveVM -eq 1){
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
}

if($poolAssign -eq 1){

    write-host "`n"
    Start-Sleep -s 3
    get-hvpoolsummary | Out-Gridview
    Start-Sleep -s 3

    write-host "`n"
    write-host "Assigning pool..."
    write-host "`n"        

    Add-HVDesktop -Poolname "$desktopPool" -machines "$mainMachine"

    write-host "`n"
    Start-Sleep -s 3
    Write-Host "Updating VM Notes..."
    Start-Sleep -s 3

    $NotesTemp = (Get-VM $mainMachine | Select-Object -ExpandProperty Notes)
    $desktopPool = (get-hvmachine -machinename "$mainMachine").base.desktopname
    $userMachineUpdate = "Assigned VM Pool - $desktopPool"
    Set-VM $mainMachine -Notes "$($userMachineUpdate)`n$($NotesTemp)" -Confirm:$false

    write-host "`n"
    Write-Host "           $mainMachine Assignment to $desktopPool Complete"
    write-host "`n"
    
}


if($userAssign -eq 1){

    write-host "`n"
    Set-HVMachine -MachineName "$mainMachine" -User "corp.hrg\$mainUserName1"
    write-host "`n"
    Write-Host "           User-Machine Assignment Complete"

    $curDate = Get-Date -UFormat "%m.%d.%y"
    $NotesTemp = (Get-VM $mainMachine | Select-Object -ExpandProperty Notes)
    $dept = Get-ADUser $mainUserName -Properties MemberOf,Department
    $department = $dept.department
    $userMachineUpdate = "$mainUserName1 - $department"
    Set-VM $mainMachine -Notes "$($userMachineUpdate)`n$($NotesTemp)" -Confirm:$false

}

Write-Host "`n"
Write-Host "    VM Setup complete."
Write-Host "`n"

Read-Host -Prompt "Press Enter to exit to main menu"

