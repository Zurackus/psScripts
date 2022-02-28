<#
    .NOTES
        Use the Az module connect to the client/subscription the Sentinel resource is located to run this script
        Import-Module -Name Az
        Connect-AzAccount -Tenant '00000aaa-00aa-0000-aa00-aaa00000aaaa' -Subscription '0000aaa0-aa00-00aa-aaaa-000aaa000aa0'
    .SYNOPSIS
        This command will generate a CSV file containing the information about all the Azure Sentinel
        Connectors that are currently active.
    .DESCRIPTION
        This command will generate a CSV file containing the information about all the Azure Sentinel
        Connectors that are currently active.
    .PARAMETER WorkSpaceName
        Enter the Log Analytics workspace name, this is a required parameter
    .PARAMETER ResourceGroupName
        Enter the Resouce Group name, this is a required parameter
    .PARAMETER FileName
        Enter the file name to use. ".csv" will be appended to all filenames
    .NOTES
        AUTHOR: Tyler Konsonlas
        LASTEDIT: 2022 Feb 22
    .EXAMPLE
        Export-AzSentinelActiveConnectors -WorkspaceName "workspacename" -ResourceGroupName "rgname"
        In this example you will get the file named "ActiveConnectors.csv" generated containing all the connectors
    .EXAMPLE
        Export-AzSentinelActiveConnectors -WorkspaceName "workspacename" -ResourceGroupName "rgname" -fileName "test"
        In this example you will get the file named "test.csv" generated containing all the connectors
#>

Function Export-AzSentinelActiveConnectors {
    param (
        [Parameter(Mandatory = $true)]  [string]$WorkSpaceName,
        [Parameter(Mandatory = $true)]  [string]$ResourceGroupName,
        [Parameter(Mandatory = $false)] [string]$FileName = "ActiveConnectors.csv" #default
    )

    if (! $Filename.EndsWith(".csv")) { $FileName += ".csv"}
    
    #Setup the Authentication header needed for the REST calls
    $context = Get-AzContext
    $profiler = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    $profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($profiler)
    $token = $profileClient.AcquireAccessToken($context.Subscription.TenantId)
    $authHeader = @{
        'Content-Type'  = 'application/json' 
        'Authorization' = 'Bearer ' + $token.AccessToken 
    }
    
    $SubscriptionId = (Get-AzContext).Subscription.Id

    #Load the templates so that we can copy the information as needed
    #tk - URL from https://docs.microsoft.com/en-us/rest/api/securityinsights/preview/alert-rule-templates/get
    $url = "https://management.azure.com/subscriptions/$($subscriptionId)/resourceGroups/$($resourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($workspaceName)/providers/Microsoft.SecurityInsights/dataConnectors?api-version=2019-01-01-preview"
    #tk - Calling a JSON file with the 'Invoke-RestMethod' so that Powershell can work with the data
    $results = (Invoke-RestMethod -Method "Get" -Uri $url -Headers $authHeader ).value

    foreach ($result in $results) {
        #Escape the description field so it does not cause any issues with the CSV file
        $description = $result.properties.Description
        #Replace any double quotes.  Commas are already taken care of
        $description = $description -replace '"', '""'
        #replace '(Preview) '

        #Generate the list of data connectors.  Using the pipe as the 
        #delimiter since it does not appear in any data connector name
        $requiredDataConnectors = ""
        foreach ($dc in $result.properties.requiredDataConnectors) {
            $requiredDataConnectors += $dc.connectorId + "|" 
        }
        #If we have an entry, remove the last pipe character
        if ("" -ne $requiredDataConnectors) {
            $requiredDataConnectors = $requiredDataConnectors.Substring(0, $requiredDataConnectors.length - 1)
        }

        #Generate the list of tactics.  Using the pipe as the 
        #delimiter since it does not appear in any data connector name
        $tactics = ""
        foreach ($tactic in $result.properties.tactics) { 
            $tactics += $tactic + "|"
        }
        #If we have an entry, remove the last pipe character
        if ("" -ne $tactics) {
            $tactics = $tactics.Substring(0, $tactics.length - 1)
        }

        #Translate the query frequency and period text into something a bit more readable.  
        #Handles simple translations only.
        $frequencyText = ConvertISO8601ToText -queryFrequency $result.properties.queryFrequency  -type "Frequency"
        $queryText = ConvertISO8601ToText -queryFrequency $result.properties.queryPeriod -type "Query"
        $frequencyText2 = ConvertISO8601ToText -queryFrequency $result.properties.frequency -type "Frequency2"

        #Translate the threshold values into some more readable.
        $ruleThresholdText = RuleThresholdText -triggerOperator $result.properties.triggerOperator -triggerThreshold $result.properties.triggerThreshold

        #Create and output the line of information.
        $severity = $result.properties.severity
		$displayName = $result.properties.displayName
		$kind = $result.kind #Connector Name
		$name = $result.Name
        $version = $result.properties.anomalyDefinitionVersion
        $status = $result.properties.status

		[pscustomobject]@{ 
            'Selected' = " ";
            'Severity' = $severity;
            'DisplayName' = $displayName;
            'Kind' = $kind;
            'Name' = $name;
            'Description' = $description;
            'Tactics' = $tactics;
            'RequiredDataConnectors' = $requiredDataConnectors;
            'RuleFrequency' = $frequencyText;
            'RulePeriod' = $queryText;
            'RuleFrequency2' = $frequencyText2;
            'RuleThreshold' = $ruleThresholdText;
            'Version' = $version;
            'Status' = $status #Easy way to see which templates are already installed
        } | Export-Csv $filename -Append -NoTypeInformation
    }
}