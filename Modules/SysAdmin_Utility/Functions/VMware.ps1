#Restart VM's that have been on for over X days
#Requires -Modules VMware.PowerCLI
$stat = 'sys.osuptime.latest'
$now = Get-Date

#Grab all machines powered 'on' and begin with 'HRGVM'
$AllVMs = Get-VM | where{$_.PowerState -eq 'PoweredOn' -and $_.Name -like 'HRGVM*'}

#Collect the uptime of all of the machines
$AllVMuptime = Get-Stat -Entity $AllVMs -Stat $stat -Realtime -MaxSamples 1 |
Select @{N='VM';E={$_.Entity.Name}},
    #Column 'LastOSBoot' down to the second
    @{N='LastOSBoot';E={$now.AddSeconds(- $_.Value)}},
    #Column 'UptimeDays' round down to the nearest day
    @{N='UptimeDays';E={[math]::Floor($_.Value/(24*60*60))}}

#Filter the previous array down to just the VM's greater than X days
$VMupXdays = $AllVMuptime |
    Where {$_.UptimeDays -gt 1<#Number of days since last reboot#>} |
    Export-Csv -Path "\\hrgatad\I\Helpdesk\VMRestartList.csv"

#Restart each VM in the Xdays array
ForEach ($VM in $VMupXdays)
{
    get-vm $VM | Restart-VMGuest
    #pausing for 60 seconds so that the server isn't overwhelmed
    start-sleep -Seconds 60
}

#Pause for 20 minutes before trying to run through the machines again
Start-Sleep -Seconds 1200

#After all of the initial restarts have been completed another pass
#of the machines will be done to try powering up machines still 'off'
ForEach ($VM in $VMupXdays)
{
    if($VM.PowerState -eq "PoweredOff"){
        Start-VM $VM
        Start-Sleep -Seconds 60
    }
}
