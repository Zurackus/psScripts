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

function Get-NetworkMainMenu {

    write-host "`n"
    write-host "    Network Options Task Menu" -foregroundcolor Yellow -BackgroundColor DarkGreen
    write-host "`n"
    Write-Color "1.  ", "Ping" -Color Yellow, Green
    Write-Color "2.  ", "Trace Route" -Color Yellow, Green
    Write-Color "3.  ", "DNS Lookup" -Color Yellow, Green
    Write-Color "4.  ", "Change VLAN" -Color Yellow, Green
    Write-Color "5.  ", "Set new machine" -Color Yellow, Green
    Write-Color "6.  ", "Set new username" -Color Yellow, Green
    write-host "`n"
    
}

if (!$mainMachine) {
    write-host "`n"
    Write-Color "     Need computer name?" -Color Green
    write-host "`n"
    $CPUOption = Read-Host "      Yes(1) or No(2)?"
    if ($CPUOption -eq 1) {
        write-host "`n"
        $mainMachine = Read-Host "Enter Computer Name"
}
}

if (!$mainUsername) {
    write-host "`n"
    Write-Color "     Need Username?" -Color Green
    write-host "`n"
    $UserOption = Read-Host "      Yes(1) or No(2)?"
    if ($UserOption -eq 1) {
        write-host "`n"
        $mainUsername = Read-Host "Enter Userame"
}
}


write-host "`n"
Write-Color "Current machine is ", "$mainMachine" -Color White, Red
write-host "`n"
Write-Color "Current username is ", "$mainUsername" -Color White, Red

Get-NetworkMainMenu


while(($select = Read-Host "Enter Number for Selection or Q to return to Main Menu") -ne 'Q')
    {
        write-host "`n"

    switch ($select) {

    1 {
        Test-Connection $mainMachine 

        Get-NetworkMainMenu    }
    2 {
        Test-NetConnection $mainMachine 

        Get-NetworkMainMenu    }
    3 {
        $dns = Read-Host "Enter DNS address to search"
        Resolve-DNSName -Name $dns
        Get-NetworkMainMenu
    }
    4 {
        Get-NetworkAdapter -VM $mainMachine
        write-host "`n"
        Write-Host "Enter name of new desired VLAN (For Ex: DHCP or HIM VLAN 16) This is case sensitive."
        $networkName = Read-Host "="
        write-host "`n"
        $NIC = Get-NetworkAdapter -VM $mainMachine 
        write-host "`n"
        Set-NetworkAdapter -NetworkAdapter $NIC -NetworkName $networkName
        write-host "`n"
        Get-NetworkMainMenu    
    }
    5 {
        write-host "`n"
        Write-Color "Current Machine is ", "$mainMachine" -Color White, Red
        write-host "`n"
        $mainMachine = Read-Host "Enter new machine name"
        write-host "`n"
        Write-Color "New Machine is ", "$mainMachine" -Color White, Red
        write-host "`n"
        Get-PowerMainMenu
    }
    6 {
        write-host "`n"
        Write-Color "Current Username is ", "$mainUsername" -Color White, Red
        write-host "`n"
        $mainMachine = Read-Host "Enter new username"
        write-host "`n"
        Write-Color "New username is ", "$mainUsername" -Color White, Red
        write-host "`n"
        Get-PowerMainMenu
        }
    }
}
