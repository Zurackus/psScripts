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

write-host "`n"

Write-Host "        Script to remove primary E1000E network adapter and replace with VMXNET 3 network adapter.      " -foregroundcolor Yellow -BackgroundColor DarkGreen
write-host "`n"
write-host "`n"

$Exists = get-vm -name $mainMachine -ErrorAction SilentlyContinue  
If ($Exists){  
     Write-Color "   VM exists." -Color Green
}  
Else {  
     Write-Color "   VM not found." -Color Green
     Exit  
}  

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
get-networkadapter -vm $mainMachine | where {$_.Name -eq "Network adapter 1"} | remove-networkadapter
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
Read-Host -Prompt "Press Enter to return to Main Menu"



