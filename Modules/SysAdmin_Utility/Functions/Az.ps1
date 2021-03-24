<#
Scripts around AzureMFA(MultiFactor Authentication)
#Enable-AzureMFA - Force MFA on all HRG users
#Get-AzureMFAcsv - Check to see who has MFA 'forced' and 'waiting'
#>

#51 Connect to Az Module
function Connect-AzureModule {
    Import-Module -Name Az
    Connect-AzAccount -Tenant 6cb1f02e-ded5-4987-a92a-420f11a0debb
}

#52 Force MFA on all HRG users
function Enable-AzureMFA {
Connect-MsolService
[int] $MaxResults = 2000
[bool] $isLicensed = $true

    #Going out and finding all of the licensed users
    $AllUsers = Get-MsolUser -MaxResults $MaxResults | Where-Object {$_.IsLicensed -eq $isLicensed} | select UserPrincipalName,
            #Adding a column for finding if the users have MFA forced on them
        @{Name = 'MFAForced'; Expression={if ($_.StrongAuthenticationRequirements) {Write-Output $true} else {Write-Output $false}}}

    #Create a new array with the users who need to be forced
    $FilteredUsers = $AllUsers.Where({$_.MFAForced -match 'FALSE'})

    #Here are the one off exclusions for MFA
    $FilteredUsers2 = $FilteredUsers |
        Where {$_.UserPrincipalName -ne "unifiedmessaging@hrgpros.onmicrosoft.com"} |
        Where {$_.UserPrincipalName -ne "spmarketplace@hrgpros.onmicrosoft.com"} |
        Where {$_.UserPrincipalName -ne "sharepointjobapplications@hrgpros.onmicrosoft.com"}

    #Create another array with just the usernames that need to be updated
    $users = $FilteredUsers2 | foreach { $_.UserPrincipalName }

#Below is a simple output to make sure the right users are being updated
#Write-Output $users

#Code provided by Microsoft to enable MFA
    foreach ($user in $users)
    {
        $st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
        $st.RelyingParty = "*"
        $st.State = "Enabled"
        $sta = @($st)
        Set-MsolUser -UserPrincipalName $user -StrongAuthenticationRequirements $sta
    }
}
    
#53 Check to see who has MFA 'forced' and 'waiting'
function Get-AzureMFAcsv {
Connect-MsolService

[int] $MaxResults = 2000
[bool] $isLicensed = $true

    $AdminUsers = Get-MsolRole | foreach {Get-MsolRoleMember -RoleObjectId $_.ObjectID} | Where-Object {$_.EmailAddress -ne $null} | Select EmailAddress -Unique | Sort-Object EmailAddress
    $AllUsers = Get-MsolUser -MaxResults $MaxResults | Where-Object {$_.IsLicensed -eq $isLicensed} | select DisplayName, UserPrincipalName, `
        @{Name = 'isAdmin'; Expression = {if ($AdminUsers -match $_.UserPrincipalName) {Write-Output $true} else {Write-Output $false}}}, `
        @{Name = 'MFAForced'; Expression={if ($_.StrongAuthenticationRequirements) {Write-Output $true} else {Write-Output $false}}},
        @{Name = 'MFAWaiting'; Expression={if ($_.StrongAuthenticationMethods -like "*") {Write-Output $true} else {Write-Output $false}}}

        $workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\AzureMFA.csv'
        Write-Output $AllUsers | Sort-Object MFAForced, MFAWaiting, isAdmin | export-csv -Path $workOutput
}


function Get-AzureInventoryReport {
#Provide the subscription Id where the VMs reside
$subscriptionId = "6cb1f02e-ded5-4987-a92a-420f11a0debb"

#Provide the name of the csv file to be exported
$reportName = "myReport.csv"

Select-AzSubscription 6cb1f02e-ded5-4987-a92a-420f11a0debb
$report = @()
$vms = Get-AzVM
$publicIps = Get-AzPublicIpAddress 
$nics = Get-AzNetworkInterface | ?{ $_.VirtualMachine -NE $null} 
foreach ($nic in $nics) { 
    $info = "" | Select VmName, ResourceGroupName, Region, VmSize, VirturalNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress 
    $vm = $vms | ? -Property Id -eq $nic.VirtualMachine.id 
    foreach($publicIp in $publicIps) { 
        if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
            $info.PublicIPAddress = $publicIp.ipaddress
            } 
        } 
        $info.OsType = $vm.StorageProfile.OsDisk.OsType 
        $info.VMName = $vm.Name 
        $info.ResourceGroupName = $vm.ResourceGroupName 
        $info.Region = $vm.Location 
        $info.VmSize = $vm.HardwareProfile.VmSize
        $info.VirturalNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3] 
        $info.Subnet = $nic.IpConfigurations.subnet.Id.Split("/")[-1] 
        $info.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress 
        $report+=$info 
    } 
$report | ft VmName, ResourceGroupName, Region, VmSize, VirturalNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress 
$report | Export-CSV "myreport.csv"
}

function Remove-HRGAzureResource {
Write-Host -NoNewline -ForegroundColor Green "Please enter the VM name you would like to remove:"
$VMName = Read-Host
$vm = Get-AzVm -Name $VMName
if ($vm) {
$RGName=$vm.ResourceGroupName
Write-Host -ForegroundColor Cyan 'Resource Group Name is identified as-' $RGName
$diagSa = [regex]::match($vm.DiagnosticsProfile.bootDiagnostics.storageUri, '^http[s]?://(.+?)\.').groups[1].value
Write-Host -ForegroundColor Cyan 'Marking Disks for deletion...'
$tags = @{"VMName"=$VMName; "Delete Ready"="Yes"}
$osDiskName = $vm.StorageProfile.OSDisk.Name
$datadisks = $vm.StorageProfile.DataDisks
$ResourceID = (Get-Azdisk -Name $osDiskName).id
New-AzTag -ResourceId $ResourceID -Tag $tags | Out-Null
if ($vm.StorageProfile.DataDisks.Count -gt 0) {
    foreach ($datadisks in $vm.StorageProfile.DataDisks){
    $datadiskname=$datadisks.name
    $ResourceID = (Get-Azdisk -Name $datadiskname).id
    New-AzTag -ResourceId $ResourceID -Tag $tags | Out-Null
    }
}
if ($vm.Name.Length -gt 9){
    $i = 9
    }
    else
    {
    $i = $vm.Name.Length - 1
}
$azResourceParams = @{
 'ResourceName' = $VMName
 'ResourceType' = 'Microsoft.Compute/virtualMachines'
 'ResourceGroupName' = $RGName
}
$vmResource = Get-AzResource @azResourceParams
$vmId = $vmResource.Properties.VmId
$diagContainerName = ('bootdiagnostics-{0}-{1}' -f $vm.Name.ToLower().Substring(0, $i), $vmId)
$diagSaRg = (Get-AzStorageAccount | where { $_.StorageAccountName -eq $diagSa }).ResourceGroupName
$saParams = @{
  'ResourceGroupName' = $diagSaRg
  'Name' = $diagSa
}
Write-Host -ForegroundColor Cyan 'Removing Boot Diagnostic disk..'
if ($diagSa){
Get-AzStorageAccount @saParams | Get-AzStorageContainer | where {$_.Name-eq $diagContainerName} | Remove-AzStorageContainer -Force
}
else {
Write-Host -ForegroundColor Green "No Boot Diagnostics Disk found attached to the VM!"
}
Write-Host -ForegroundColor Cyan 'Removing Virtual Machine-' $VMName 'in Resource Group-'$RGName '...'
$null = $vm | Remove-AzVM -Force
Write-Host -ForegroundColor Cyan 'Removing Network Interface Cards, Public IP Address(s) used by the VM...'
foreach($nicUri in $vm.NetworkProfile.NetworkInterfaces.Id) {
   $nic = Get-AzNetworkInterface -ResourceGroupName $vm.ResourceGroupName -Name $nicUri.Split('/')[-1]
   Remove-AzNetworkInterface -Name $nic.Name -ResourceGroupName $vm.ResourceGroupName -Force
   foreach($ipConfig in $nic.IpConfigurations) {
     if($ipConfig.PublicIpAddress -ne $null){
     Remove-AzPublicIpAddress -ResourceGroupName $vm.ResourceGroupName -Name $ipConfig.PublicIpAddress.Id.Split('/')[-1] -Force
     }
    }
}
Write-Host -ForegroundColor Cyan 'Removing OS disk and Data Disk(s) used by the VM..'
Get-AzResource -tag $tags | where{$_.resourcegroupname -eq $RGName}| Remove-AzResource -force | Out-Null
Write-Host -ForegroundColor Green 'Azure Virtual Machine-' $VMName 'and all the resources associated with the VM were removed sucesfully...'
}
else{
Write-Host -ForegroundColor Red "The VM name entered doesn't exist in your connected Azure Tenant! Kindly check the name entered and restart the script with correct VM name..."
}
}


function FunctionName {
#This command uses MSOL to remove the licenses
Connect-MsolService   
#
$users = Import-Csv -Path "C:\Users\tkonsonlas\Documents\users2.csv"       
            
foreach ($user in $users) {            
 Set-MsolUserLicense -UserPrincipalName "$($user.samaccountname)" -RemoveLicenses "hrgpros:ENTERPRISEPACK"
}
<#
Grab the below ID's with 'Get-MsolAccountSku'
AccountSkuId                    ActiveUnits WarningUnits ConsumedUnits
------------                    ----------- ------------ -------------
hrgpros:VISIOCLIENT             10          0            8            
hrgpros:POWER_BI_PRO            2           0            2            
hrgpros:SPZA_IW                 10000       0            0            
hrgpros:ENTERPRISEPACK          510         0            406          
hrgpros:FLOW_FREE               10000       0            58           
hrgpros:MCOEV                   255         0            229          
hrgpros:MCOPSTN1                225         0            232          
hrgpros:Win10_VDA_E3            230         0            0            
hrgpros:PHONESYSTEM_VIRTUALUSER 10          0            4            
hrgpros:POWERAPPS_VIRAL         10000       0            1            
hrgpros:MEETING_ROOM            1           0            1            
hrgpros:POWER_BI_STANDARD       1000000     0            15           
hrgpros:MCOPSTNC                10000000    0            0            
hrgpros:TEAMS_EXPLORATORY       100         0            2            
hrgpros:EMS                     230         0            0            
hrgpros:MCOMEETADV              65          0            13           
hrgpros:SPE_E3                  280         0            134          
hrgpros:PROJECTPROFESSIONAL     5           0            3  
#>
}