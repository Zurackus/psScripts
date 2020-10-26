function Get-PowerMainMenu {
    write-host "`n"
    write-host "========= Power Options Task Menu =========" -foregroundcolor Yellow -BackgroundColor DarkGreen
    write-host "`n"
    Write-Color "1.  ", "Machine details/power status/uptime" -Color Yellow, Green
    Write-Color "2.  ", "Power on Machine" -Color Yellow, Green
    Write-Color "3.  ", "Restart Machine" -Color Yellow, Green
    Write-Color "4.  ", "Shut Down machine" -Color Yellow, Green
    Write-Color "5.  ", "Set new machine" -Color Yellow, Green
    write-host "`n"
}

function Show-PowerMainMenu {
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
    Write-Color "`n   Logged in Username:     ", "$UN" -Color White, Green
    Write-Color "   PW                      ", "$PW" -Color White, Green
    Write-Color "`n   Session Username:       ", "$mainUserName" -Color White, Red
    Write-Color "   Session Machine:        ", "$mainMachine" -Color White, Red
    write-host "`n"
    
    Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope User -ParticipateInCEIP:$false | out-null
    
    #connect to vcenter server
    Connect-VIServer -Server vCenter1.corp.hrg | out-null
    
    if (!$mainMachine) {
        $mainMachine = Read-Host "`nEnter Computer Name"
    }
    
    Write-Color "`nMachine is ", "$mainMachine" -Color White, Red
    
    Get-VM $mainMachine | Select-Object Name, @{N="FolderName";E={ $_.Folder.Name}}, NumCpu, MemoryGB, @{N="CPUUSage";E={ $_.ExtensionData.Summary.QuickStats.OverallCpuUsage}}, @{N="MemoryUsage";E={$_.ExtensionData.Summary.QuickStats.GuestMemoryUsage}}, ProvisionedSpaceGB, UsedSpaceGB, PowerState, VMHost, @{N="Datastore";E={$_.ExtensionData.Config.DatastoreUrl.Name}}, @{N="Network";E={$_.Guest.Nics[0]}}, @{N="IPAddress";E={$_.Guest.IPAddress[0]}}, @{N="DNSName";E={$_.ExtensionData.Guest.Hostname}}
    $pwrState = (Get-VM -Name $mainMachine).ExtensionData.guest.guestState
    $mainMachine + " power state is " + $pwrState
    
    $os = gwmi Win32_OperatingSystem -computerName $mainMachine
    $boottime = $OS.converttodatetime($OS.LastBootUpTime)
    $uptime = New-TimeSpan (get-date $boottime)
    
    $uptime_days = [int]$uptime.days
    $uptime_hours = [int]$uptime.hours
    $uptime_minutes = [int]$uptime.minutes
    
    write-host "`n"
    
    $mainMachine +" uptime is " + $uptime_days + " Days, " + $uptime_hours + " Hours, " + $uptime_minutes + " Minutes"
    
    do{
        Get-PowerMainMenu
        $select = Read-Host "Enter Number for Selection or Q to quit"
        switch ($select) {
        '1' {
            write-host "`n"
            Write-Color "Machine is ", "$mainMachine" -Color White, Red
            write-host "`n"
            Get-VM $mainMachine | Select-Object Name, @{N="FolderName";E={ $_.Folder.Name}}, NumCpu, MemoryGB, @{N="CPUUSage";E={ $_.ExtensionData.Summary.QuickStats.OverallCpuUsage}}, @{N="MemoryUsage";E={$_.ExtensionData.Summary.QuickStats.GuestMemoryUsage}}, ProvisionedSpaceGB, UsedSpaceGB, PowerState, VMHost, @{N="Datastore";E={$_.ExtensionData.Config.DatastoreUrl.Name}}, @{N="Network";E={$_.Guest.Nics[0]}}, @{N="IPAddress";E={$_.Guest.IPAddress[0]}}, @{N="DNSName";E={$_.ExtensionData.Guest.Hostname}}
            $pwrState = (Get-VM -Name $mainMachine).ExtensionData.guest.guestState
            $mainMachine + " power state is " + $pwrState
            write-host "`n"

            $os = gwmi Win32_OperatingSystem -computerName $mainMachine
            $boottime = $OS.converttodatetime($OS.LastBootUpTime)
            $uptime = New-TimeSpan (get-date $boottime)
        
            $uptime_days = [int]$uptime.days
            $uptime_hours = [int]$uptime.hours
            $uptime_minutes = [int]$uptime.minutes

            $mainMachine +" uptime is " + $uptime_days + " Days, " + $uptime_hours + " Hours, " + $uptime_minutes + " Minutes"

            Write-Host "`nTask Complete`n"
            }
        '2' {
            Write-Color "`nMachine is ", "$mainMachine" -Color White, Red
            Start-VM -vm $mainMachine
            Write-Host "Startup in progress`n"
            }
        '3' {
            write-host "`n"
            Write-Color "Machine is ", "$mainMachine" -Color White, Red
            Invoke-command $mainMachine {Restart-Computer -Force }
            #Restart-Computer -ComputerName $mainMachine -Force
            Write-Host "Restart in progress"
            write-host "`n"
            }
        '4' {
            write-host "`n"
            Write-Color "Machine is ", "$mainMachine" -Color White, Red
            Stop-VM -vm $mainMachine -Confirm:$false
            Write-Host "Shutdown in progress"
            write-host "`n"
            }
        '5' {
            write-host "`n"
            Write-Color "Current Machine is ", "$mainMachine" -Color White, Red
            write-host "`n"
            $mainMachine = Read-Host "Enter new machine name"
            write-host "`n"
            Write-Color "New Machine is ", "$mainMachine" -Color White, Red
            write-host "`n"
            }
        }       
    }until ($select -eq 'q')
}