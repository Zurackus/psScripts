#Gets information for the spreadsheet
$timeformat='MM-dd-yyyy hh:mm:ss tt'
$time = (Get-Date).ToString($timeformat)

#Specifies filename, and directory
#Replace "C:\Users\tkonsonlas\Documents" with desired location
$directory = "C:\Users\tkonsonlas\Documents"
$filedate = 'MM-dd-yyyy'
#Replace 'PooledData' with appropriate name for data
$filename = 'PooledData' + ' ' + $(Get-Date).ToString($filedate)
$file = "$filename.csv"

#$testingArray = 64, "hello", 3.2154, "stuff"

#
$formula= {
get-adgroupmember -identity "AnyConnect"

}

#Testing the for loop
#for(($i=0); $i -le $testingArray.Count; ($i++))
#{
#    $testingArray[$i]
#}

#Checks if CSV has already been created for the day
if (Test-path "$directory\$file") {
    import-csv -Path "$directory\$file" > null
    $formula | Export-Csv -Append -Path "$directory\$file"
}

else {
    $formula | Export-Csv -Path "$directory\$file"
}