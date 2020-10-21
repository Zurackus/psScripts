# Delete all Files in R:\SCANNED older than 30 day(s)
function remove-oldfiles {
$Path = "\\hrgfile\Remote\SCANNED"
$Daysback = "-1"
 
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $DatetoDelete }
}
