#
.\InstallSoftwareRemotely.ps1 -AppPath '\\hrgatad\SCCM\Applications\VMWareHorizonViewAgent - 7.9\VMware-Horizon-Agent-x86_64-7.9.0-13938590.exe' -AppArgs '/S /V"/qn VDM_VC_MANAGED_AGENT=1"' -CSV 'C:\Users\tkonsonlas\psScripts\TestScripts\Machines.csv' -Retries 2 -AppName 'VMware Horizon View Agent' -AppVersion '7.9.0-13938590' -WMIQuery 'select * from Win32_Processor where DeviceID="CPU0" and AddressWidth="64"' -EnablePSRemoting -Credential

$VMID = "HRGVM0320-173"
Get-WmiObject -Class Win32_Product -ComputerName $VMID | Where Vendor -eq 'VMware, Inc.' | select Name, Version

psexec \\hrgvm0518-13 -u hrg\tkonsonlas -h cmd

winrm quickconfig

$VMID = "HRGVM1120-7"
Invoke-Command -ComputerName $VMID -ScriptBlock {
    $MyApp = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -Match "Horizon Agent"}
    $MyApp.Uninstall()
}

.\InstallSoftwareRemotely.ps1 -AppPath '\\hrgatad\SCCM\Applications\VMWareHorizonViewAgent - 7.9\VMware-Horizon-Agent-x86_64-7.9.0-13938590.exe' -AppArgs '/S /V"/qn VDM_VC_MANAGED_AGENT=1"' -CSV 'C:\Users\tkonsonlas\psScripts\TestScripts\Machines.csv' -Retries 2 -AppName 'VMware Horizon View Agent' -AppVersion '7.9.0-13938590' -WMIQuery 'select * from Win32_Processor where DeviceID="CPU0" and AddressWidth="64"' -EnablePSRemoting -Credential

Update tools 'update-tools -vm HRGVM0318-12'