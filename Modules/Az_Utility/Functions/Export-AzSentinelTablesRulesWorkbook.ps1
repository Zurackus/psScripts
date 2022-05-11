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

Function Export-AzSentinelAnalyticsRules {
    param (
        #flip to true, comment out default 
        [Parameter(Mandatory = $false)]  [string]$WorkSpaceName = "CISOLogAnalyticsWorkspace",#"3PSIEM",
        #flip to true, comment out default
        [Parameter(Mandatory = $false)]  [string]$ResourceGroupName = "cisosentinelloganalytics_rg",#"danh2",
        [Parameter(Mandatory = $false)] [string]$FileName = "Sentinel_CurrentRules_Client.csv" #default
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

    #Second API call for all of the Table Rules
    #Load the templates so that we can copy the information as needed
    $url = "https://management.azure.com/subscriptions/$($subscriptionId)/resourceGroups/$($resourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($workspaceName)/providers/Microsoft.SecurityInsights/alertRules?api-version=2021-10-01"
    #Calling a JSON file with the 'Invoke-RestMethod' so that Powershell can work with the data
    $results = (Invoke-RestMethod -Method "Get" -Uri $url -Headers $authHeader ).value

    #Create the list variable for all of the tables
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

    foreach ($result in $results) {
        #Escape the description field so it does not cause any issues with the CSV file
        $description = $result.properties.Description
        #Replace any double quotes.  Commas are already taken care of
        $description = $description -replace '"', '""'

        #Create and output the line of information.
		$displayName = $result.properties.displayName
        $alertID = $result.name
        $enabledrule = $result.properties.enabled
		$severity = $result.properties.severity
        $kind = $result.kind
        $description = $result.properties.description
        $query = $result.properties.query
        $entities = $result.properties.entityMappings
        
        #Make sure the log source is first empty
        $logSource = ""
        <# - Old table code
        #Verify the query is not empty
        if($query.length -gt 3){
            #Iterate through the tables, and search the query for which table is used
            foreach($table in $tables) {
                if($query.Contains($table)) {
                    #Add any tables that were found within the Query
                    $logSource += $table + "|"
                }
            }
        }#>
        #New table code
        if($query.length -gt 3){
            #Iterate through the tables, and search the query for which table is used
            foreach($table in $tables) {
                if($table -eq 'Event' -or 
                    $table -eq 'Operation' -or
                    $table -eq 'Update' -or
                    $table -eq 'Perf'
                    ) {
                    $pattern = ""
                    $pattern = '^\s*' + [regex]::Escape($table) + '[\s|\n]+|\s+' + [regex]::Escape($table) + '[\s|\n]+'
                    if($query -match $pattern) {
                        $logSource += $table + "|"
                    }
                }
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

        $entitylist = ""

        if ($entities.length -gt 0) {
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
Export-AzSentinelAnalyticsRules