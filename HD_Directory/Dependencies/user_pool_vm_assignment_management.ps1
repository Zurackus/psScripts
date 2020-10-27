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

#credentials will be required to log into this - set in another function? (not recommended)

write-host "`n"

Write-Host "        Vcenter Admin - user and machine pools/management      " -foregroundcolor Yellow -BackgroundColor DarkGreen
if (!$mainMachine) {
    write-host "`n"
    $mainMachine = Read-Host '      Enter Computer Name'
}

if (!$mainUserName) {
    write-host "`n"
    $mainUserName = Read-Host '     Enter Username'
}



#connect-hvserver vhrgcb-03.corp.hrg -user $UN -password $PW -domain 'hrg'



function Get-EntitlementMenu {
    write-host "`n"
    Write-Host "    Entitlements/VM assignments" -foregroundcolor Yellow -BackgroundColor DarkGreen
    write-host "`n"
    Write-Color "1.  ", "See current User Entitlements" -Color Yellow, Green
    Write-Color "2.  ", "Add/Remove Entitlements" -Color Yellow, Green
    Write-Color "3.  ", "User-Machine Assignment" -Color Yellow, Green
    Write-Color "4.  ", "Machine-Pool Assignment" -Color Yellow, Green
    Write-Color "5.  ", "Delete VM" -Color Yellow, Green
    Write-Color "6.  ", "Remove VM from VMware Horizon" -Color Yellow, Green
    Write-Color "7.  ", "Change VM Pool" -Color Yellow, Green
    Write-Color "8.  ", "Check VM Pool" -Color Yellow, Green
    write-host "`n"
    Write-Color "9.  ", "Set new machine" -Color Yellow, Green
    Write-Color "10. ", "Set new username" -Color Yellow, Green

    write-host "`n"
    Write-Color "       NOT ALL OPTIONS UTILIZE CURRENT SET MACHINE AND USERNAME    " -Color Red
    write-host "`n"
    write-host "`n"

}

Get-EntitlementMenu

while (($var = Read-Host -Prompt "Enter Number for Selection or Q to return to Main Menu") -ne 'Q')
    {

switch ($var) {
    1 {
        write-host "`n"
        Write-Host "GET CURRENT DESKTOP POOL ENTITLEMENTS FOR ENTERED USERNAME *MUST MATCH"
        write-host "`n"
        $entitledids = (get-hventitlement -user "corp.hrg\$mainUserName").localdata
        foreach ($entityid in ($entitledids.desktops)) {get-hvinternalname $entityid}
        write-host "`n"
        Get-EntitlementMenu
        }
    2 {
        write-host "`n"
        Write-Host "ADD OR REMOVE USER ENTITLEMENTS *POOL AND USERNAME MUST MATCH PRECISELY"
        write-host "`n"
        $selection = Read-Host "Enter 1 to add pool entitlement, 2 to remove pool entitlement"
        write-host "`n"
        get-hvpoolsummary | Out-Gridview
        write-host "`n"
        $desktopPool = Read-Host "Enter pool to add/remove"
        write-host "`n"

        if ($selection -eq '1') {
        New-HVEntitlement  -User "corp.hrg\$mainUserName" -ResourceName "$desktopPool"
        $entitledids = (get-hventitlement -user "corp.hrg\$mainUserName").localdata
        
        $esc = [char]27 
        "$esc[4m"
        Write-Host "Current User: $mainUserName"
        Write-Host "Current Entitlements"
        $esc = [char]27 
        "$esc[0m"

        foreach ($entityid in ($entitledids.desktops)) {get-hvinternalname $entityid}
        write-host "`n"
    }
        elseif ($selection -eq '2') {
        Remove-HVEntitlement -User "corp.hrg\$mainUserName" -ResourceName "$desktopPool"
        $entitledids = (get-hventitlement -user "corp.hrg\$mainUserName").localdata
        Write-Host "Current User: $mainUserName"
        
        $esc = [char]27 
        "$esc[4m"
        Write-Host "Current Entitlements"
        $esc = [char]27 
        "$esc[0m"

        foreach ($entityid in ($entitledids.desktops)) {get-hvinternalname $entityid}
        }
        else {       
            write-host "`n"
            }
            write-host "`n"
            Get-EntitlementMenu
            }
    3 {
        write-host "`n"
        Write-Host "ASSIGN MACHINE TO SPECIFIC USER"
        write-host "`n"
        $mainUserName1 = Read-Host "Enter username for device assignment"
        write-host "`n"
        $mainMachine1 = Read-Host "Enter machine to assign to user"
        write-host "`n"
        Set-HVMachine -MachineName "$mainMachine1" -User "corp.hrg\$mainUserName1"
        write-host "`n"
        Write-Host "           User-Machine Assignment Complete"

        $curDate = Get-Date -UFormat "%m.%d.%y"
        $NotesTemp = (Get-VM $mainMachine1 | Select-Object -ExpandProperty Notes)
        $dept = Get-ADUser $U -Properties MemberOf,Department
        $department = $dept.department
        $userMachineUpdate = "$mainUserName1 - $department"
        Set-VM $mainMachine1 -Notes "$($userMachineUpdate)`n$($NotesTemp)" -Confirm:$false

        # ALTER CODE IN THIS SECTION TO BE MORE USER FRIENDLY AND HAVE BETTER FLOW

        Get-EntitlementMenu

        }
    4 {
        write-host "`n"
        Write-Host "            ADD VM TO DESKTOP POOL"
        write-host "`n"
        Write-Host "            Available Pools"
        write-host "`n"
        $mainMachine2 = Read-Host "Enter vm to add to vmware Admin"
        write-host "`n"
        Start-Sleep -s 3
        get-hvpoolsummary | Out-Gridview
        Start-Sleep -s 3
        $desktopPool = Read-Host "Enter desired pool for vm"

        write-host "`n"
        write-host "Assigning pool..."
        write-host "`n"        

        Add-HVDesktop -Poolname "$desktopPool" -machines "$mainMachine2"

        write-host "`n"
        Start-Sleep -s 3
        Write-Host "Updating VM Notes..."
        Start-Sleep -s 3

        $NotesTemp = (Get-VM $mainMachine2 | Select-Object -ExpandProperty Notes)
        $desktopPool = (get-hvmachine -machinename "$mainMachine2").base.desktopname
        $userMachineUpdate = "Assigned VM Pool - $desktopPool"
        Set-VM $mainMachine2 -Notes "$($userMachineUpdate)`n$($NotesTemp)" -Confirm:$false


        write-host "`n"
        Write-Host "           Machine-Pool Assignment Complete"
        write-host "`n"
        Write-Host $desktopPool
        Get-EntitlementMenu

    }
    5 {
        write-host "`n"
        Write-Host "            Delete machine from vmware horizon and hard disk"
        write-host "`n"
        $mainMachine3 = Read-Host "Enter vm to delete"
        remove-machine -machinenames "$mainMachine3"
        write-host "`n"
        Write-Host "           Machine Deletion Complete"
        write-host "`n"
        Get-EntitlementMenu
    }
    6 {
        write-host "`n"
        Write-Host "            Remove machine from VMware Horizon - this does not delete the vm from the disk"
        write-host "`n"
        $mainMachine4 = Read-Host "Enter vm to remove"
        remove-hvmachine -machinenames "$mainMachine4" -deletefromdisk:$false
        Get-EntitlementMenu
    }
    7 {
        write-host "`n"
        Write-Host "            Change VM's assigned desktop pool"
        write-host "`n"
        $mainMachine5 = Read-Host "Enter VM"
        $desktopPool = Read-Host "Enter new desktop pool"
        write-host "`n"
        Write-Host "Please wait..."
        remove-hvmachine -machinenames "$mainMachine5" -deletefromdisk:$false

        Start-Sleep -s 10
        Add-HVDesktop -Poolname "$desktopPool" -machines "$mainMachine5"

        Start-Sleep -s 10
        (get-hvmachine -machinename "$mainMachine5").base.desktopname

        $NotesTemp = (Get-VM $mainMachine5 | Select-Object -ExpandProperty Notes)
        $userMachineUpdate = "$Desktop Pool - $desktopPool"
        Set-VM $mainMachine5 -Notes "$($userMachineUpdate)`n$($NotesTemp)" -Confirm:$false

        write-host "`n"
        Write-Host "           Re-assignment complete"
        write-host "`n"
        Get-EntitlementMenu
        }
    8 {
        write-host "`n"
        Write-Host "            Check VM Pool assignment"
        write-host "`n"
        $pool = (get-hvmachine -machinename "$mainMachine").base.desktopname
        Write-Host "$mainMachine assigned pool is $pool"
        write-host "`n"
        Get-EntitlementMenu
        }
    9 {
        write-host "`n"
        Write-Color "Current Machine is ", "$mainMachine" -Color White, Red
        write-host "`n"
        $mainMachine = Read-Host "Enter new machine name"
        write-host "`n"
        Write-Color "New Machine is ", "$mainMachine" -Color White, Red
        write-host "`n"
        Get-EntitlementMenu
    
    }
    10 {
        write-host "`n"
        Write-Color "Current Username is ", "$mainUserName" -Color White, Red
        write-host "`n"
        $mainMachine = Read-Host "Enter new username"
        write-host "`n"
        Write-Color "New Machine is ", "$mainUserName" -Color White, Red
        write-host "`n"
        Get-EntitlementMenu
    
        }
}
    }




<#   GET CURRENT DESKTOP POOL ENTITLEMENTS FOR ENTERED USERNAME *MUST MATCH 
$username = Read-Host "Enter username"
$entitledids = (get-hventitlement -user "corp.hrg\$username").localdata
foreach ($entityid in ($entitledids.desktops)) {get-hvinternalname $entityid}
#>


<#ADD OR REMOVE USER ENTITLEMENTS *POOL AND USERNAME MUST MATCH PRECISELY
New-HVEntitlement  -User 'corp.hrg\sstraughen' -ResourceName 'ceres'
Remove-HVEntitlement -User 'corp.hrg\sstraughen' -ResourceName 'ceres'
#>

<#ASSIGN MACHINE TO SPECIFIC USER
Set-HVMachine -MachineName hrgvm0120-6 -User "corp.hrg\sstraughen"
#>


<#ADD DESKTOP TO POOL
#script will fail if pool name does not exist or if machine is already member of another desktop pool
add-hvdesktop -poolname 'jupiter' -machines hrgvm1020-9
#>

<#remove machine from vmware horizon admin 
#this does not delete the machine from the hard disk
#will unassign pool
#multiple machines can be removed at once by separating them with a comma
remove-hvmachine -machinenames 'hrgvm1020-9' -deletefromdisk:$false
#>

<#remove/delete machine from vmware horizon
#multiple machines can be removed at once by separating them with a comma
remove-machine -machinenames 'hrgvm1020-9'
#>

<# show all available pools 
get-hvpoolsummary
#>

<#script to get assigned pool of vm
(get-hvmachine -machinename hrgvm0120-6).base | Select-Object desktopname
#>

