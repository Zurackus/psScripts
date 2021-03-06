#Gets information for the spreadsheet
$username = $env:USERNAME
$computername = $env:COMPUTERNAME
$ipv4 = Test-Connection -ComputerName (hostname) -Count 1 | foreach { $_.ipv4address } 
$ipv6 = Test-Connection -ComputerName (hostname) -Count 1 | foreach { $_.ipv6address } 
$computermodel = get-wmiobject win32_computersystem | foreach { $_.model } 
$serial = get-wmiobject win32_bios | foreach { $_.serialnumber } 
$timeformat='MM-dd-yyyy hh:mm:ss tt'
$time = (Get-Date).ToString($timeformat)
$action = 'Logon'

#Specifies filename, and directory
#Replace "\\Server\Directory" with desired location
$directory = "\\Server\Directory"
$filedate = 'MM-dd-yyyy'
$filename = 'CompInfo' + ' ' + $(Get-Date).ToString($filedate)
$file = "$filename.csv"

#Creates custom table and sorts the information
$table=  New-Object -TypeName PSObject -Property @{
            'Date/Time' = $time
            'Username' = $username
            'ComputerName'= $computername
            'IPv4 Address' = $ipv4
            'IPv6 Address' = $ipv6
            'Model' = $computermodel
            'Serial' = $serial
            'Notes/Action' = $action
} | Select date/time, username, computername, 'IPv4 Address', 'IPv6 Address', model, serial, notes/action 

#Checks if CSV has already been created for the day
if (Test-path "$directory\$file") {
    import-csv -Path "$directory\$file" > null
    $table | Export-Csv -NoTypeInformation -Append -Path "$directory\$file"
}

else {
    $table | Export-Csv -NotypeInformation -Path "$directory\$file"
}