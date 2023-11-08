#This will check for SAP API Connections and look at where they are pointing to
$subscriptioName = 'InformationSecurity PROD'
$resourceGroupName = 'cisosentinelloganalytics_rg'

#use the collection to build up objects for the table
$connectorDictionary = New-Object "System.Collections.Generic.Dictionary``2[System.String,System.Object]"

az account set --subscription $subscriptioname

#Get Subscription Info
$subscription = Get-AzSubscription -SubscriptionName $subscriptioName
$subscriptionId = $subscription.Id
Write-Host 'Subscription Id: ' $subscriptionId

#Get Resource Group Info
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName
$resourceGroupPath = $resourceGroup.ResourceId
Write-Host 'Resource Group Path: '  $resourceGroupPath


Write-Host 'Looking up API Connectors'
$resourceName = ''
$resources = Get-AzResource -ResourceGroupName $resourcegroupName -ResourceType Microsoft.Web/connections
$resources | ForEach-Object {

    $resourceName = $_.Name

    Write-Host 'Found connector: '$_.id
    $resourceIdLower = $_.id.ToLower()

    $azureConnector = New-Object -TypeName psobject
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'IsUsed' -Value 'FALSE'
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'Id' -Value $_.Id
    $azureConnector | Add-Member -MemberType NoteProperty -Name 'name' -Value $_.Name

    $connectorDictionary.Add($resourceIdLower, $azureConnector)
}


#Check logic apps to find orphaned connectors
Write-Host ''
Write-Host ''
Write-Host ''
Write-Host 'Looking up Logic Apps'
$resources = Get-AzResource -ResourceGroupName $resourcegroupName -ResourceType Microsoft.Logic/workflows
$resources | ForEach-Object {

    $resourceName = $_.Name
    $logicAppName = $resourceName
    $logicApp = Get-AzLogicApp -Name $logicAppName -ResourceGroupName $resourceGroupName
    $logicAppUrl = $resourceGroupPath + '/providers/Microsoft.Logic/workflows/' + $logicApp.Name + '?api-version=2018-07-01-preview'

    #Get Logic App Content
    $logicAppJson = az rest --method get --uri $logicAppUrl
    $logicAppJsonText = $logicAppJson | ConvertFrom-Json

    #Check Logic App Connectors
    $logicAppParameters = $logicAppJsonText.properties.parameters
    $logicAppConnections = $logicAppParameters.psobject.properties.Where({$_.name -eq '$connections'}).value
    $logicAppConnectionValue = $logicAppConnections.value
    $logicAppConnectionValues = $logicAppConnectionValue.psobject.properties.name

    #Iterate through the connectors
    $logicAppConnectionValue.psobject.properties | ForEach-Object{

        $objectName = $_
        $connection = $objectName.Value

        if($connection -ne $null)
        {
            Write-Host 'Logic App: ' $logicAppName ' uses connector: name='$connection.connectionName ', id=' $connection.connectionId

            #Check if connector is in the connector dictionary
            $connectorIdLower = $connection.connectionId.ToLower()

            if($connectorDictionary.ContainsKey($connectorIdLower))
            {
                #Mark connector as being used
                $matchingConnector = $connectorDictionary[$connectorIdLower]
                $matchingConnector.IsUsed = 'TRUE'
                $connectorDictionary[$connectorIdLower] = $matchingConnector
                Write-Host 'Marking connector as used: ' $connectorIdLower
            }
        }
   }
}

Write-Host ''
Write-Host ''
Write-Host ''
Write-Host 'Orphaned API Connectors'
$connectorDictionary.Values | ForEach-Object{
    $azureConnector = $_

    Write-Host $azureConnector.Id ' : ' $azureConnector.IsUsed
    if($azureConnector.IsUsed -eq 'FALSE')
    {
        Write-Host $azureConnector.Id ' : is an orphan'
        Remove-AzResource -ResourceId $azureConnector.Id -Force
        Write-Host $azureConnector.Id ' : has been deleted'
    }
}

$csvFilePath = Join-Path -Path $pwd -ChildPath "OrphanedConnectors.csv"
$connectorDictionary.Values | Export-Csv -Path $csvFilePath