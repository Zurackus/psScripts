$spreadsheet = Import-Csv -Path "C:\Users\tkonsonlas\Documents\ExportList.csv"       
           
foreach ($item in $spreadsheet) {            
 
    $Computer = $item.Name

########## Install Software On PC ##########

    Write-Host "Copying over the folder to $Computer"

    New-Item -ItemType directory -Path "\\$Computer\c$\deleteme\MSMonitorAgent" -Force
    Start-Sleep -Seconds 2

    Copy-Item -Path "\\hrgatad\SCCM\Applications\MSMonitorAgent\*" -Destination "\\$Computer\c$\deleteme\MSMonitorAgent" -Recurse
    Start-Sleep -Seconds 2

    Write-Host "Installing Microsoft Monitor Agent on $Computer"

    Invoke-Command -ComputerName $Computer -ScriptBlock {Start-Process -FilePath "C:\deleteme\MSMonitorAgent\Setup.exe" -ArgumentList "/qn NOAPM=1 ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_AZURE_CLOUD_TYPE=0 OPINSIGHTS_WORKSPACE_ID=`"2fc39ce4-5915-4914-a5d8-92c81a682bb5`" OPINSIGHTS_WORKSPACE_KEY=`"mJFB03Zm9LYZ6PA4VVuIuTtDzZzyebG1HyrxdLjhXhhnvwqrRa+54uGp0865jb/DmiQ0zHRYVRM5i1lL2UyHEw==`" AcceptEndUserLicenseAgreement=1" -Wait} 
########## Remove temporary files and folder on each PC ##########

    Write-Host "Removing Temporary files on $Computer"
    $RemovalPath = "\\$Computer\c$\deleteme"
    Get-ChildItem  -Path $RemovalPath -Recurse  | Remove-Item -Force -Recurse
    Remove-Item $RemovalPath -Force -Recurse

    Write-Host "Completed install for $Computer"
}