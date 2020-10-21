Connect-MsolService

[int] $MaxResults = 2000
[bool] $isLicensed = $true

    $AdminUsers = Get-MsolRole | foreach {Get-MsolRoleMember -RoleObjectId $_.ObjectID} | Where-Object {$_.EmailAddress -ne $null} | Select EmailAddress -Unique | Sort-Object EmailAddress
    $AllUsers = Get-MsolUser -MaxResults $MaxResults | Where-Object {$_.IsLicensed -eq $isLicensed} | select DisplayName, UserPrincipalName, `
        @{Name = 'isAdmin'; Expression = {if ($AdminUsers -match $_.UserPrincipalName) {Write-Output $true} else {Write-Output $false}}}, `
        @{Name = 'MFAForced'; Expression={if ($_.StrongAuthenticationRequirements) {Write-Output $true} else {Write-Output $false}}},
        @{Name = 'MFAWaiting'; Expression={if ($_.StrongAuthenticationMethods -like "*") {Write-Output $true} else {Write-Output $false}}}

        Write-Output $AllUsers | Sort-Object MFAForced, MFAWaiting, isAdmin | export-csv "C:\Users\tkonsonlas\documents\AzureMFA.csv"