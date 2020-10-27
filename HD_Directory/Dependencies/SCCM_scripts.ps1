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

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope User -ParticipateInCEIP:$false | out-null

#connect to vcenter server
Connect-VIServer -Server vCenter1.corp.hrg | out-null
write-host "`n"

Write-Host "        SCCM Task Menu      " -foregroundcolor Yellow -BackgroundColor DarkGreen
write-host "`n"
write-host "`n"

function Get-SCCMMainMenu {
    write-host "`n"
    Write-Host "    Active Directory Task Menu" -foregroundcolor Yellow -BackgroundColor DarkGreen
    write-host "`n"
    Write-Color "1.  ", "Device affiliations by username" -Color Yellow, Green
    Write-Color "2.  ", "Remote Control" -Color Yellow, Green
    Write-Color "3.  ", "N/A" -Color Yellow, Green
    Write-Color "4.  ", "N/A" -Color Yellow, Green
    Write-Color "5.  ", "N/A" -Color Yellow, Green
    Write-Color "6.  ", "N/A" -Color Yellow, Green

    write-host "`n"
}

Get-SCCMMainMenu

while (($var = Read-Host -Prompt "Enter Number for Selection or Q to return to Main Menu") -ne 'Q')
    {

switch ($var) {
    1 {
        $mainUserName = Read-Host "Enter username for device affiliations"
        write-host "`n"
        Set-Location hrg:
        $machines = Get-CMUserDeviceAffinity -Username "hrg\$mainUserName" | Select-Object ResourceName
        $machines
        Set-Location C:\Users\sstraughen
        write-host "`n"
        Get-SCCMMainMenu    }
    2 { 
        Write-Color "   Use ", "$mainMachine", " for remote connection? " -Color Green, Red, Green -NoNewLine
        $ans = Read-Host "Yes(1) or No(2)   "
        if ($ans -eq 1) {
            start-process "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\i386\CmRcViewer.exe" -ArgumentList "$mainMachine"
        } Else {
            $mainMachine2 = Read-Host " Please enter machine to remote into."
            start-process "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\i386\CmRcViewer.exe" -ArgumentList "$mainMachine2"
        }

        write-host "`n"
        Get-SCCMMainMenu    }
    3 {
       
        write-host "`n"
        Get-SCCMMainMenu    }
    4 {
        
        write-host "`n"
        Get-SCCMMainMenu    }
    5 {
        
        write-host "`n"
        Get-SCCMMainMenu    }

}

}

