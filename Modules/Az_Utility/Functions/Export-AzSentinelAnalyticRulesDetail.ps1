<#
    .NOTES
        Tested with Powershell 7.2
        Use the Az module connect to the client/subscription the Sentinel resource is located to run this script
            Import-Module -Name Az
                (Must connect to the subscription that Sentinel is located on)
            Connect-AzAccount -Tenant '00000aaa-00aa-0000-aa00-aaa00000aaaa' -Subscription '0000aaa0-aa00-00aa-aaaa-000aaa000aa0'
            Disconnect-AzAccount
        Currently drops the output CSV in the directory the script is ran from
    .Errors
    .SYNOPSIS
        This command will generate a CSV file containing the information about all the active Azure Sentinel Analytic rules.
    .DESCRIPTION
        This command will generate a CSV file containing the information about all the active Azure Sentinel Analytic rules.
        To work properly, as of 5/11/2022, the below KQL needs to be ran to aquire all of the active tables over the last year.
        Usage
        | summarize ['Table Size'] =sum(Quantity) by ['Table Name'] =DataType
        | order by ['Table Size'] desc
        Once the above query has been ran, export the data into a csv or whatever format you want. Pull out all of the table names,
        and load the variable $tables with them.
    .PARAMETER WorkSpaceName
        For the functions to work you will need to enter the Log Analytics workspace name, this is a required parameter
    .PARAMETER ResourceGroupName
        For the functions to work you will need to enter the Resource Group name, this is a required parameter
    .PARAMETER FileName
        Enter the file name to use.  Defaults to "Sentinel_AnalyticRulesDetail_Client.csv", but if you want to add a filename
        ".csv" will be appended to all filenames automatically if it isn't added in the name
    .NOTES
        AUTHOR: Tyler Konsonlas
        LASTEDIT: 2022 May 11
    .EXAMPLE
        Export-AzSentinelAnalyticRulesDetail -WorkspaceName "workspacename" -ResourceGroupName "rgname"
        In this example you will get the file named "Sentinel_AnalyticRulesDetail_Client.csv" generated containing all the rules
    .EXAMPLE
        Export-AzSentinelAnalyticRulesDetail -WorkspaceName "workspacename" -ResourceGroupName "rgname" -fileName "Sentinel_Rules"
        In this example you will get the file named "Sentinel_Rules.csv" generated containing all the Analytic rules
#>

Function Export-AzSentinelAnalyticRulesDetail { 
    param (
        #flip to true, comment out default 
        [Parameter(Mandatory = $false)]  [string]$WorkSpaceName = "CISOLogAnalyticsWorkspace",#"3PSIEM",
        #flip to true, comment out default
        [Parameter(Mandatory = $false)]  [string]$ResourceGroupName = "cisosentinelloganalytics_rg",#"danh2",
        [Parameter(Mandatory = $false)] 
        [string]$FileName = "Sentinel_AnalyticRulesDetail_Client.csv" #default
    )
    #Verify the Filename ends with .csv, add if needed
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

    #Loading the API url, found at the below link, with the required variables of the environment
    #https://docs.microsoft.com/en-us/rest/api/azure/
    $url = "https://management.azure.com/subscriptions/$($subscriptionId)/resourceGroups/$($resourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($workspaceName)/providers/Microsoft.SecurityInsights/alertRules?api-version=2021-10-01"
    #Calling a JSON file with the 'Invoke-RestMethod' so that Powershell can work with the data
    $results = (Invoke-RestMethod -Method "Get" -Uri $url -Headers $authHeader ).value

    #Create the list variable for all of the tables from the KQL mentioned in top 'Notes'
    $tables = @('SecurityEvent','CommonSecurityLog','InsightsMetrics','Event','DeviceEvents',
    'AADNonInteractiveUserSignInLogs','DeviceProcessEvents','DeviceRegistryEvents','BehaviorAnalytics',
    'W3CIISLog','DeviceNetworkEvents','DnsEvents','DeviceFileEvents','AWSCloudTrail','Heartbeat',
    'DeviceImageLoadEvents','Syslog','DeviceFileCertificateInfo','Perf','OfficeActivity','SigninLogs',
    'DeviceNetworkInfo','AuditLogs','DeviceLogonEvents','ThreatIntelligenceIndicator','DeviceInfo',
    'EmailEvents','CloudAppEvents','AADProvisioningLogs','DnsInventory','EmailUrlInfo','EmailAttachmentInfo',
    'UserPeerAnalytics','AADServicePrincipalSignInLogs','SalesforceServiceCloud_CL','ComputerGroup',
    'Operation','AzureActivity','Update','SailPointIdentityIQ_CL','OfficeAudit_CL','Dynamics365Activity',
    'IdentityInfo','SecurityRecommendation','SecurityAlert','SecurityIncident','Anomalies','MDEAudit_CL',
    'SecurityBaseline','TeamsAuditLogs_CL','SecurityNestedRecommendation','IntuneOperationalLogs',
    'InformationProtectionLogs_CL','Watchlist','IntuneAuditLogs','ProtectionStatus','UserAccessAnalytics',
    'AADManagedIdentitySignInLogs','IdentityIQ_CL','EmailPostDeliveryEvents','AzureMetrics','AzureDiagnostics',
    'UpdateSummary','SecurityBaselineSummary','IncidentFileActions_CL','IncidentProcessActions_CL','Sysmon')

    #Begin to cycle through all of the Active rules from the environment
    foreach ($result in $results) {
        #Escape the description field so it does not cause any issues with the CSV file
        $description = $result.properties.Description
        #Replace any double quotes.  Commas are already taken care of
        $description = $description -replace '"', '""'

        #Create and output the information(all of these were found first using Postman)
		$displayName = $result.properties.displayName
        $alertID = $result.name
        $enabledrule = $result.properties.enabled
		$severity = $result.properties.severity
        $kind = $result.kind
        $description = $result.properties.description
        $query = $result.properties.query
        $entities = $result.properties.entityMappings
        
        #Make sure the log source is empty
        $logSource = ""

        #Check if the query is empty
        if($query.length -gt 3){
            #Iterate through the tables, and search the query for which table is used
            foreach($table in $tables) {
                #Tables that are short and could be used as part of other words/variables
                if($table -eq 'Operation' -or
                    $table -eq 'Update' -or
                    $table -eq 'Perf'
                    ) {
                    #Clear Pattern
                    $pattern = ""
                    #Create Regex Pattern(Start line with 0+ spaces, word, single space or newline)
                                                            #Or with the pipe '|'
                        #Second variation(1+ space or new line, word, space or new line)
                    $pattern = '^\s*' + [regex]::Escape($table) + '[\s|\n]+|\s+' + [regex]::Escape($table) + '[\s|\n]+'
                    #Must use 'cmatch' if you want a case sensitive search
                    if($query -cmatch $pattern) {
                        $logSource += $table + "|"
                    }
                
                }
                #Separate IF statement for Event, due to it being *****ing everywhere
                elseif($table -eq 'Event') {
                    $pattern = ""
                    $pattern = '^\s*' + [regex]::Escape($table) + '[\s|\n]+|\s+' + [regex]::Escape($table) + '[\s|\n]+'
                    if($query -cmatch $pattern) {
                        #Added variable to something easier to search in the csv output(arbitrarily picked)
                        #You will need to still look at every Alert with Event, because people leave commented sections out
                        #with the word Event fairly regularly
                        $logSource += "Event-|"
                    }
                }
                #For all of the tables with longer more unique names that should not be part of other variables
                elseif($query.Contains($table)) {
                    #Add any tables that were found within the Query
                    $logSource += $table + "|"
                }
            }
        }

        #If we have an entry, remove the last pipe character
        if ($logSource.length -gt 3) {
            $logSource = $logSource.Substring(0, $logSource.length - 1)
        }

        #Clear the entity list
        $entitylist = ""

        #Check if there are any Entities for the Alert
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

        #Organize the csv output, and add the column headers
		[pscustomobject]@{ 
            'DisplayName' = $displayName;
            'AlertID' = $alertID;
            'Enabled' = $enabledrule;
            'Severity' = $severity;
            'Kind' = $kind;
            'Description' = $description;
            'LogSource' = $logSource;
            'Entities' = $entitylist;
            'Query' = $query
        } | Export-Csv $filename -Append -NoTypeInformation
    }  
}

#Comment out if you want to just use the Az_Utility Module to call this function
Export-AzSentinelAnalyticRulesDetail