#Restart VM's that have been on for over X days
#Require -Modules VMware.PowerCLI

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope User -ParticipateInCEIP:$false | out-null

#connect to vcenter server
Connect-VIServer -Server vCenter1.corp.hrg

$now = Get-Date

#import vm list into array from csv
$VMlist = import-csv "\\hrgatad\I\Helpdesk\Restart\VM_Test_List2.csv"
$VMlist

#update txt file with log that script started
$VMImportComplete = "`nVM Restart Test list import complete - $now"
$VMImportComplete | Out-File "\\hrgatad\I\Helpdesk\Restart\VM_Test_Report.txt" -append

#convert object list to string format
$VMlistString = $VMlist | foreach {"$($_.LIST)"}
$VMlistString

#count total number of vms to restart
$VMct = $VMlistString.Count
$VMCount = "Total machines to be restarted: $VMct"
$VMCount | Out-File "\\hrgatad\I\Helpdesk\Restart\VM_Test_Report.txt" -append
$VMct

#Restart each VM in the Xdays array
ForEach ($VM in $VMlistString)
    {
        Invoke-command $VM {Restart-Computer -Force }
        #pausing for 60 seconds so that the server isn't overwhelmed
        start-sleep -Seconds 6
    }

#180 second delay after last restart
Start-Sleep -s 18

#export list of vms with new powerstate
get-vm $VMlistString | Select-Object Name,Powerstate | 
Export-Csv -Path "\\hrgatad\I\Helpdesk\Restart\VMRestartList1.csv"

#update txt file with log that script completed.
$now = Get-Date
$jobComplete = "First restart phase complete - $now"
$jobComplete | Out-File "\\hrgatad\I\Helpdesk\Restart\VM_Test_Report.txt" -append

Read-Host -Prompt "Press Enter to exit"