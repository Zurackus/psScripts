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

#Get all API connectors
Write-Host 'Looking up API Connectors'
$resourceName = ''
$resources = Get-AzResource -ResourceGroupName $resourcegroupName -ResourceType Microsoft.Web/connections
$resources | ForEach-Object {
    
    #Build URL
    $resourceName = $_.Name
    $resourceIdLower = $_.id.ToLower()
    Write-Host 'Found API Connector:'$resourceName
    #Reference below for the API
    #Couldn't find reference to uri, ran below command to view data available
    #Can also run the following command to see a live example: az rest --method get --uri <URL>
    $resourceUrl = $resourceGroupPath + '/providers/Microsoft.Web/connections/' + $resourceName + '?api-version=2016-06-01'
    
    #Get Resource JSON
    $resourceJson = az rest --method get --uri $resourceUrl
    #Base calls to the JSON information
    $resourceJsonText = $resourceJson | ConvertFrom-Json
    $resourceProperties = $resourceJsonText.properties
    #AuthenticatedUser is preferred, but if it's empty, grab displayName
    if ($resourceProperties.authenticatedUser.name -like '*@*'){
        $AuthenticatedUser = $resourceProperties.authenticatedUser.name}
    else {
        $AuthenticatedUser = $resourceProperties.displayName}

    #Extracting all of the desired information per API Connector
    $azureConnector = New-Object -TypeName psobject
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'IsUsed' -Value 'FALSE'
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Id' -Value $resourceJsonText.id
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Name' -Value $resourceJsonText.name
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Connector' -Value $resourceProperties.api.displayName
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'State' -Value $resourceProperties.overallStatus
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'ChangedTime' -Value $resourceProperties.changedTime
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'CreatedTime' -Value $resourceProperties.createdTime
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'AuthenticatedUser' -Value $AuthenticatedUser
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Playbook' -Value ''
    #Loading the variables into the dictionary with the 'id' as the key value
    $connectorDictionary.Add($resourceIdLower, $azureConnector)
}


#Check logic apps to find orphaned connectors
Write-Host ''
Write-Host ''
Write-Host ''
Write-Host 'Looking up Logic Apps'
$resources = Get-AzResource -ResourceGroupName $resourcegroupName -ResourceType Microsoft.Logic/workflows
$resources | ForEach-Object {

    #Build URL
    $logicAppName = $_.Name
    #Reference below for the API
    #https://learn.microsoft.com/en-us/rest/api/logic/workflows/get?view=rest-logic-2016-06-01&tabs=HTTP
    #Can also run the following command to see a live example: az rest --method get --uri <URL>
    $logicAppUrl = $resourceGroupPath + '/providers/Microsoft.Logic/workflows/' + $logicAppName + '?api-version=2018-07-01-preview'

    #Get Logic App Content
    $logicAppJson = az rest --method get --uri $logicAppUrl
    #Base calls to the JSON information
    $logicAppJsonText = $logicAppJson | ConvertFrom-Json
    $logicAppParameters = $logicAppJsonText.properties.parameters
    #Searching under 'properties' for field containing exactly '$connections' not a variable
    $logicAppConnections = $logicAppParameters.psobject.properties.Where({$_.name -eq '$connections'}).value
    $logicAppConnectionValue = $logicAppConnections.value

    #Iterate through the connectors
    $logicAppConnectionValue.psobject.properties | ForEach-Object{

        $connection = $_.Value
        #Verify the value isn't empty
        if($connection -ne $null)
        {
            Write-Host 'Logic App: ' $logicAppName ' uses connector: name='$connection.connectionName
            #Grabbing the connectorid in lowercase for comparison
            $connectorIdLower = $connection.connectionId.ToLower()
            #Check if connector is in the connector dictionary
            if($connectorDictionary.ContainsKey($connectorIdLower))
            {
                #Mark connector as being used
                $matchingConnector = $connectorDictionary[$connectorIdLower]
                $matchingConnector.IsUsed = 'TRUE'
                #Build the list of related Playbooks for the API Connector
                $matchingConnector.Playbook += "$logicAppName,"
                #Update the appropriate line from the dictionary
                $connectorDictionary[$connectorIdLower] = $matchingConnector
                #Write-Host 'Marking connector as used: '$connection.connectionName
            }
        }
   }
}

#Optional section where an action can be pushed based on one or more of the extracted fields
Write-Host ''
Write-Host ''
Write-Host ''
Write-Host 'Orphaned API Connectors'
$connectorDictionary.Values | ForEach-Object{
    $azureConnector = $_
    #Can use this to take action based on a field
    Write-Host $azureConnector.Name ' : ' $azureConnector.IsUsed
    if($azureConnector.IsUsed -eq 'FALSE')
    {   #Leaving as a proof of concept to verify the selected field is returning as desired
        #Recommend running at least once before pushing changes, like deletions
        Write-Host $azureConnector.Name ' : is an orphan'
        
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
$csvFilePath = Join-Path -Path $pwd -ChildPath "OrphanedConnectors.csv"
$connectorDictionary.Values | Export-Csv -Path $csvFilePath