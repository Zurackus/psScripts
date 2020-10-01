$App = Get-WmiObject -ComputerName HRGW0521-5 -Class Win32_Product | Where-Object{$_.Name -eq "Google Chrome"}
$App.Uninstall()

$App = Get-WmiObject -ComputerName HRGW0521-5 -Class Win32_Product | Where-Object{$_.Name -eq "Google Update Helper"}
$App.Uninstall()

Google Update Helper

$MyApp = Get-WmiObject -ComputerName HRGW0521-5 -Class Win32_Product -Filter "name='msiexec'"
$MyApp.terminate()


Invoke-Command  -ComputerName HRGW0521-5 -ScriptBlock{$P Get-Process -Name "msiexec"}
Invoke-Command  -ComputerName HRGW0521-5 -ScriptBlock{Stop-Process -Name msiexec}

Get-Process -ComputerName HRGW0521-5 -Name "msiexec"