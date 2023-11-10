#This will check for SAP API Connections and look at where they are pointing to
$subscriptioName = 'InformationSecurity PROD'
$resourceGroupName = 'cisosentinelloganalytics_rg'

#use the collection to build up objects for the table
$connectorDictionary = New-Object "System.Collections.Generic.Dictionary``2[System.String,System.Object]"

#Set Subscription for the script
az account set --subscription $subscriptioname

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
Write-Host 'Looking up Logic Apps'
$resources = Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Logic/workflows
$resources | ForEach-Object {

    #Build URL
    $resourceName = $_.Name
    $resourceIdLower = $resourceJsonText.id.ToLower()
    #Reference below for the API
    #https://learn.microsoft.com/en-us/rest/api/logic/workflows/get?view=rest-logic-2016-06-01&tabs=HTTP
    #Can also run the following command to see a live example: az rest --method get --uri <URL>
    $resourceUrl = $resourceGroupPath + '/providers/Microsoft.Logic/workflows/' + $resourceName + '?api-version=2018-07-01-preview'

    #Get Logic App Content
    $resourceJson = az rest --method get --uri $resourceUrl
    #Base calls to the JSON information
    $resourceJsonText = $resourceJson | ConvertFrom-Json
    $resourceProperties = $resourceJsonText.properties
    $resourceParameters = $resourceJsonText.properties.parameters
    #Searching under 'properties' for field containing exactly '$connections' not a variable
    $resourceConnections = $resourceParameters.psobject.properties.Where({$_.name -eq '$connections'}).value
    $resourceConnectionValue = $resourceConnections.value

    $connectors = ""
    #Iterate through the connectors
    $resourceConnectionValue.psobject.properties | ForEach-Object{

        $connection = $_.Value
        #Not completely needed, but confirms the field isn't empty before appending to $connectors
        if($connection -ne $null)
        {
            #Write-Host 'Logic App: ' $resourceName ' uses connector: name='$connection.connectionName
            $connectionName = $connection.connectionName
            $connectors += "$connectionName,"
        }
    }

    #Extracting all of the desired information per Logic App
    $azureConnector = New-Object -TypeName psobject
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Id' -Value $resourceJsonText.id
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Name' -Value $resourceJsonText.name
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'State' -Value $resourceProperties.state
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'ChangedTime' -Value $resourceProperties.changedTime
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'CreatedTime' -Value $resourceProperties.createdTime
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Connectors' -Value $connectors
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Triggers' -Value $resourceProperties.definition.triggers
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Actions' -Value $resourceProperties.definition.actions
    #Loading the variables into the dictionary with the 'id' as the key value
    $connectorDictionary.Add($resourceIdLower, $azureConnector)
}

#Optional section where an action can be pushed based on one or more of the extracted fields
Write-Host ''
Write-Host ''
Write-Host ''
Write-Host 'Disabled Playbooks'
$connectorDictionary.Values | ForEach-Object{
    $azureConnector = $_
    #Can use this to take action based on a field
    if($azureConnector.State -eq 'Disabled')
    {   #Leaving as a proof of concept to verify the selected field is returning as desired
        #Recommend running at least once before pushing changes, like deletions
        Write-Host $azureConnector.Name ' : is Disabled'
        
        ###Used below to export full JSON template of resource###
        #Replace value in $pwd\<value> with folder name of choice, $pwd grabs the full path of your working directory
        #$jsonPath = Join-Path -Path "$pwd\api-arm" -ChildPath "$($azureConnector.Name).json"
        #az group export --resource-group $resourceGroupName --resource-ids $azureConnector.Id > $jsonPath
        
        ###Use the below to delete a resource###
        #Remove-AzResource -ResourceId $azureConnector.Id -Force
        #Write-Host $azureConnector.Id ' : has been deleted'
    }
}

#Exporting all of the data in the working directory, $pwd grabs the full path of your working directory
$csvFilePath = Join-Path -Path $pwd -ChildPath "Playbooks.csv"
$connectorDictionary.Values | Export-Csv -Path $csvFilePath