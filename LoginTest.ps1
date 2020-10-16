Clear-Host 
$Computer = (Read-Host -Prompt 'Enter a computername to get logon history.')
$MaxEvents = (Read-Host -Prompt 'Enter the number of event records to review.')

$getWinEventSplat = @{
    ComputerName = $Computer
    LogName = 'TerminalServices-RemoteConnectionManager'
    MaxEvents = $MaxEvents
    ErrorAction = 'SilentlyContinue'
}
Get-WinEvent  @getWinEventSplat |  
Where-Object {$PSItem.Message -match "Session log"} | 
Select-Object -Property TimeCreated, LogName, 
                        ProviderName, LevelDisplayName, 
                        ID, Message | 
Sort-Object -Property TimeCreated -Descending | 
Select-Object -First 1