<#
    .NOTES
        Tested with Powershell 7.2
        Use the Az module connect to the client/subscription the Sentinel resource is located to run this script
            Import-Module -Name Az
                (Must connect to the subscription that Sentinel is located on)
            Connect-AzAccount -Tenant '00000aaa-00aa-0000-aa00-aaa00000aaaa' -Subscription '0000aaa0-aa00-00aa-aaaa-000aaa000aa0'
            Disconnect-AzAccount
        Currently drops the output CSV in the directory the script is ran from
    .ERRORS

    .SYNOPSIS
        This command will generate a CSV file containing the information about all the Azure Sentinel
        Analytic rules templates.
    .DESCRIPTION
        This command will generate a CSV file containing the information about all the Azure Sentinel
        Analytic rules templates.(Place an X in the first column of the CSV file for any template
        that should be used to create a rule and then call New-RulesFromTemplateCSV.ps1 to generate
        the rules.
    .PARAMETER WorkSpaceName
        Enter the Log Analytics workspace name, this is a required parameter
    .PARAMETER ResourceGroupName
        Enter the Resource Group name, this is a required parameter
    .PARAMETER FileName
        Enter the file name to use.  Defaults to "ruletemplates"  ".csv" will be appended to all filenames
    .NOTES
        AUTHOR: Gary Bushey
        LASTEDIT: 16 Jan 2020
        https://github.com/garybushey/AzSentinelAnalyticsRules
        EDITOR: Tyler Konsonlas
        LASTEDIT: 2022 Feb 22
    .EXAMPLE
        Export-AzSentinelAnalyticsRuleTemplates -WorkspaceName "workspacename" -ResourceGroupName "rgname"
        In this example you will get the file named "Sentinel_RuleTemplates.csv" generated containing all the rule templates
    .EXAMPLE
        Export-AzSentinelAnalyticsRuleTemplates -WorkspaceName "workspacename" -ResourceGroupName "rgname" -fileName "Sentinel_RuleTemplates"
        In this example you will get the file named "Sentinel_RuleTemplates.csv" generated containing all the rule templates
#>

Function Export-AzSentinelAnalyticsRuleTemplates {
    param (
        #flip to true, comment out default 
        [Parameter(Mandatory = $false)]  [string]$WorkSpaceName = "3PSIEM",
        #flip to true, comment out default
        [Parameter(Mandatory = $false)]  [string]$ResourceGroupName = "danh2",
        [Parameter(Mandatory = $false)] [string]$FileName = "Sentinel_RuleTemplates2.0.csv" #default
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
    $url = "https://management.azure.com/subscriptions/$($subscriptionId)/resourceGroups/$($resourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($workspaceName)/providers/Microsoft.SecurityInsights/alertruletemplates?api-version=2021-10-01"
    #Calling a JSON file with the 'Invoke-RestMethod' so that Powershell can work with the data
    $results = (Invoke-RestMethod -Method "Get" -Uri $url -Headers $authHeader ).value

    foreach ($result in $results) {
        ###--Description--###
        #Escape the description field so it does not cause any issues with the CSV file
        $description = $result.properties.Description
        #Replace any double quotes.  Commas are already taken care of
        $description = $description -replace '"', '""'

        ###--Tactics--###
        #Generate the list of tactics.  Using the pipe as the 
        #delimiter since it does not appear in any data connector name
        $tactics = ""
        foreach ($tactic in $result.properties.tactics) { 
            $tactics += $tactic + ","
        }
        #If we have an entry, remove the last pipe character
        if ("" -ne $tactics) {
            $tactics = $tactics.Substring(0, $tactics.length - 1)
        }

        ###--Frequency--###
        #Translate the query frequency and period text into something a bit more readable.  
        #Handles simple translations only.
        $frequencyText = ConvertISO8601ToText -queryFrequency $result.properties.queryFrequency  -type "Frequency"
        $queryText = ConvertISO8601ToText -queryFrequency $result.properties.queryPeriod -type "Query"

        ###--Threshold--###
        #Translate the threshold values into some more readable.
        $ruleThresholdText = RuleThresholdText -triggerOperator $result.properties.triggerOperator -triggerThreshold $result.properties.triggerThreshold


        ###--Entities--###
        #Clear the entity list
        $entitylist = ""
        $entities = $result.properties.entityMappings
        if ($entities.length -gt 0) {
            #Grab the Type, Identifier, and Column name, if there are Entities
            foreach($entity in $entities) {
                $entitylist += $entity.entityType + ":"
                $entitylist += $entity.fieldMappings.identifier + ","
                $entitylist += $entity.fieldMappings.columnname + "|"
            }
        }
        #If we have an entry, remove the last pipe character
        if ($entitylist.length -gt 3) {
            $entitylist = $entitylist.Substring(0, $entitylist.length - 1)
        }

        ###--DataConnectors & LogTables--###
        #Clear the entity list
        $DataConnectorList = ""
        $LogTableList = ""
        $DataConnectors = $result.properties.requiredDataConnectors
        if ($DataConnectors.length -gt 0) {
            #Grab the Type, Identifier, and Column name, if there are Entities
            foreach($DataConnector in $DataConnectors) {
                $DataConnectorList += $DataConnector.connectorId + ","
                    foreach ($LogTable in $DataConnector.dataTypes) { 
                        $LogTableList += $LogTable + ","
                    }
            }
        }
        #If we have an entry, remove the last pipe character
        if ($DataConnectorList.length -gt 3) {
            $DataConnectorList = $DataConnectorList.Substring(0, $DataConnectorList.length - 1)
        }
        #If we have an entry, remove the last pipe character
        if ("" -ne $LogTableList) {
            $LogTableList = $LogTableList.Substring(0, $LogTableList.length - 1)
        }

        #Create and output the line of information.
        $severity = $result.properties.severity
		$displayName = $result.properties.displayName
        $displayName = $displayName -replace '\(Preview\) ',''#Remove the (Preview) so the displayname is more standardized
		$twName = "_TW_" + $displayName
        $kind = $result.kind
		$name = $result.Name
        $version = $result.properties.version
        $status = $result.properties.status
        $query = $result.properties.query

		[pscustomobject]@{ 
            'Selected' = "";
            'TWName' = $twName;
            'ID' = $name;
            'Version' = $version;
            'MSSeverity' = $severity;
            'DisplayName' = $displayName;
            'Kind' = $kind;
            'Description' = $description;
            'Tactics' = $tactics;
            'Entities' = $entitylist;
            'DataConnectors' = $DataConnectorList;
            'LogTables' = $LogTableList
            'RuleFrequency' = $frequencyText;
            'RulePeriod' = $queryText;
            'RuleThreshold' = $ruleThresholdText;
            'Status' = $status; #Easy way to see which templates are already installed
            'KQL' = $query
        } | Export-Csv $filename -Append -NoTypeInformation
    }
}

function ConvertISO8601ToText($queryFrequency, $type) {
    $returnText = ""
    if ($null -ne $queryFrequency) {
        #Don't need the first character since it will always be a "P"
        $tmp = $queryFrequency.Substring(1, $queryFrequency.length - 1)
        #Check the first character now.  If it is a "T" remove it
        if ($tmp.SubString(0, 1) -eq "T") {
            $tmp = $tmp.Substring(1, $tmp.length - 1)
        }
        #Get the last character to determine if we are dealing with minutes, hours, or days, and then strip it out
        $timeDesignation = $tmp.Substring($tmp.length - 1)
        $timeLength = $tmp.Substring(0, $tmp.length - 1)

        $returnText = "Every " + $timeLength
        if ($type -eq "Query") {
            $returnText = "Last " + $timeLength
        }
        switch ($timeDesignation) {
            "M" {
                $returnText += " minute"
                if ([int]$timeLength -gt 1) { $returnText += "s" }
            }
            "H" {
                $returnText += " hour" 
                if ([int]$timeLength -gt 1) { $returnText += "s" }
            }
            "D" {
                $returnText += " day" 
                if ([int]$timeLength -gt 1) { $returnText += "s" }
            }
            Default { }
        }
    }
    return $returnText
}


Function RuleThresholdText($triggerOperator, $triggerThreshold) {
    $returnText = ""
    if ($null -ne $triggerOperator) {
        $returnText = "Trigger alert if query returns "
        switch ($triggerOperator) {
            "GreaterThan" {
                $returnText += "more than"
            }
            "FewerThan" {
                $returnText += "less than" 
            }
            "EqualTo" {
                $returnText += "exactly" 
            }
            "NotEqualTo" {
                $returnText += "different than" 
            }
            Default { }
        }
        $returnText += " " + $triggerThreshold + " results"
    }
    return $returnText
}

#Comment out if you want to just use the Az_Utility Module to call this function
Export-AzSentinelAnalyticsRuleTemplates