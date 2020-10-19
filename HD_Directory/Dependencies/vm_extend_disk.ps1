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
Write-Host "        Add HDD space to computer via vSphere, and extend disk volume.      " -foregroundcolor Yellow -BackgroundColor DarkGreen
write-host "`n"
write-host "`n"

Write-Host ""
write-host "`n"


$hard_disk_number = 'Hard Disk 1'

$vm_info_disk = (Get-HardDisk -VM $mainMachine | Where-Object {$_.Name -eq $hard_disk_number}).CapacityGB 

Write-Host "$mainMachine $hard_disk_number is $vm_info_disk GB"
write-host "`n"

$space_to_increase = Read-Host 'Enter space in GB you wish to increase'
write-host "`n"

$DL = Read-Host 'Enter Drive Letter to expand (this is usually the C drive)'
write-host "`n"

write-host "Fetching information of $mainMachine"
write-host "`n"

$new_capacity = $vm_info_disk + $space_to_increase

Write-Host "New hard disk capacity will be $new_capacity GB"
write-host "`n"

Get-HardDisk -VM $mainMachine | Where-Object {$_.Name -eq $hard_disk_number} | Set-HardDisk -CapacityGB $new_capacity | out-null

$new_vm_info_disk = (Get-HardDisk -VM $mainMachine | Where-Object {$_.Name -eq $hard_disk_number}).CapacityGB

write-host "`n"

Write-Host "$mainMachine $hard_disk_number max capacity is now $new_vm_info_disk GB"
write-host "`n"

invoke-command $mainMachine -ScriptBlock {
    #variable specifying the drive you want to extend
    $DL = $using:DL

    #script to update the disk management module
    Update-HostStorageCache

    #script to get the partition sizes and then resize the volume
    $size = (Get-PartitionSupportedSize -DriveLetter $DL)
    Resize-Partition -DriveLetter $DL -Size $size.SizeMax
    
}

if($vm_info_disk -eq $new_vm_info_disk){
Write-Host "$mainMachine $hard_disk_number volume has not been extended to $new_vm_info_disk GB"
} else {
    Write-Host "$mainMachine $hard_disk_number volume has successfully been extended to $new_vm_info_disk GB"
}
write-host "`n"
write-host "`n"
Read-Host -Prompt "Press Enter to return to Main Menu"