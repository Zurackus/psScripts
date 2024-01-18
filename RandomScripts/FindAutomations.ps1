#This will check for SAP API Connections and look at where they are pointing to
$subscriptioName = 'InformationSecurity PROD'
$resourceGroupName = 'cisosentinelloganalytics_rg'
$workspace = 'CISOLogAnalyticsWorkspace'

#use the collection to build up objects for the table
$connectorDictionary = New-Object "System.Collections.Generic.Dictionary[System.String,System.Object]"

#Set Subscription for the script
az account set --subscription $subscriptioName

#Get Subscription Info
$subscription = Get-AzSubscription -SubscriptionName $subscriptioName
$subscriptionId = $subscription.Id
Write-Host 'Subscription Id: ' $subscriptionId

#Get Resource Group Info
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName
$resourceGroupPath = $resourceGroup.ResourceId
#Write-Host 'Resource Group Path: '  $resourceGroupPath

Write-Host ''
Write-Host ''
Write-Host ''
#Grabbing all of the logic apps within particular Resource Group
Write-Host 'Looking up Sentinel Automations'
$initialUrl = $resourceGroupPath + '/providers/Microsoft.OperationalInsights/workspaces/' + $workspace + '/providers/Microsoft.SecurityInsights/automationRules?api-version=2023-02-01'
$listJson = az rest --method get --uri $initialUrl
$resources = $listJson | ConvertFrom-Json
foreach ($item in $resources.value) {

    #Build URL
    $resourceName = $item.name
    $resourceId = $item.properties.displayName
    Write-Host 'Found Automation:'$resourceId
    #Reference below for the API
    #https://learn.microsoft.com/en-us/rest/api/securityinsights/automation-rules/get?view=rest-securityinsights-2023-11-01&tabs=HTTP
    #Can also run the following command to see a live example: az rest --method get --uri <URL>
    $resourceUrl = $resourceGroupPath + '/providers/Microsoft.OperationalInsights/workspaces/' + $workspace + '/providers/Microsoft.SecurityInsights/automationRules/' + $resourceName + '?api-version=2023-02-01'

    #Get Logic App Content
    $resourceJson = az rest --method get --uri $resourceUrl
    #Base calls to the JSON information
    $resourceJsonText = $resourceJson | ConvertFrom-Json
    $resourceProperties = $resourceJsonText.properties

    $actions = ""
    #Iterate through the actions
    $resourceProperties.actions | ForEach-Object{

        $action = $_.actionType
        #Not completely needed, but confirms the field isn't empty before appending
        if($action -ne $null)
        {
            $actions += "$action,"
        }
    }

    #Extracting all of the desired information per Logic App
    $azureConnector = New-Object -TypeName psobject
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Id' -Value $resourceJsonText.id
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'ToBeDeleted' -Value 'FALSE'
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Name' -Value $resourceJsonText.name
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Order' -Value $resourceProperties.order
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'IsEnabled' -Value $resourceProperties.triggeringLogic.isEnabled
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'TriggersOn' -Value $resourceProperties.triggeringLogic.triggersOn
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'TriggersWhen' -Value $resourceProperties.triggeringLogic.TriggersWhen
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'LastModified' -Value $resourceProperties.lastModifiedTimeUtc
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'CreatedTime' -Value $resourceProperties.createdTimeUtc
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Actions' -Value $actions

    #Loading the variables into the dictionary with the 'id' as the key value
    $connectorDictionary.Add($resourceName, $azureConnector)
}
<#
#Optional section where an action can be pushed based on one or more of the extracted fields
Write-Host ''
Write-Host ''
Write-Host ''
Write-Host 'Automation Output'
$connectorDictionary.Values | ForEach-Object{
    $azureConnector = $_
    #Can use this to take action based on a field
    Write-Host $azureConnector.Name
    if($azureConnector.State -eq 'Disabled' -and [DateTime]::Parse($azureConnector.ChangedTime) -lt [DateTime]::Parse('5/1/2023'))
    {   #Leaving as a proof of concept to verify the selected field is returning as desired
        #Recommend running at least once before pushing changes, like deletions
        Write-Host $azureConnector.Name ' : would be deleted'
        $azureConnector.ToBeDeleted = 'TRUE'
        
        ###Used below to export full JSON template of resource###
        #Replace value in $pwd\<value> with folder name of choice, $pwd grabs the full path of your working directory
        #$jsonPath = Join-Path -Path "$pwd\api-Playbooks" -ChildPath "$($azureConnector.Name).json"
        #az group export --resource-group $resourceGroupName --resource-ids $azureConnector.Id > $jsonPath
        
        ###Use the below to delete a resource###
        #Remove-AzResource -ResourceId $azureConnector.Id -Force
        #Write-Host $azureConnector.Name ' : has been deleted'
    }
}
#>
#Exporting all of the data in the working directory, $pwd grabs the full path of your working directory
$csvFilePath = Join-Path -Path $pwd -ChildPath "Automations.csv"
$connectorDictionary.Values | Export-Csv -Path $csvFilePath