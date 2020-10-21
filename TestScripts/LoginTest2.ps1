$TargetReportFile = "C:\Users\tkonsonlas\Documents\LoggedOnReport.csv"
$ThisString="Target, Status, Username, Logon Time"
Add-Content "$TargetReportFile" $ThisString
$AllTargetsCSV = Import-CSV "C:\Users\tkonsonlas\Documents\TargetPCs.csv"
$TotTargets = $AllTargetsCSV.Count
$n = 0
foreach ($ItemName in $AllTargetsCSV)
{
$TargetNameNow = $ItemName.TargetName
$RC = Get-WinEvent -Computer $TargetNameNow -FilterHashtable @{ Logname = ‘Security’; ID = 4672 } -MaxEvents 1 | Select @{ N = ‘User’; E = { $_.Properties[1].Value } }, TimeCreated
$ValueA = $TargetNameNow
$ValueB = $RC.User
$ValueC = $RC.TimeCreated
$STRNow = $ValueA + ",Ok," + $ValueB + "," + ‘"‘ + $ValueC + ‘"‘
Add-Content $TargetReportFile $STRNow
}
Write-Host "Script was finished executing successfully!"