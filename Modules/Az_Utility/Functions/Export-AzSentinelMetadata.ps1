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
        [Parameter(Mandatory = $false)]  [string]$WorkSpaceName = "CISOLogAnalyticsWorkspace",
        #flip to true, comment out default
        [Parameter(Mandatory = $false)]  [string]$ResourceGroupName = "cisosentinelloganalytics_rg",
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

    $url = "https://management.azure.com/subscriptions/$($subscriptionId)/resourceGroups/$($resourceGroupName)/providers/Microsoft.OperationalInsights/workspaces/$($workspaceName)/providers/Microsoft.SecurityInsights/alertRules?api-version=2019-01-01-preview"
    $results = (Invoke-RestMethod -Method "Get" -Uri $url -Headers $authHeader ).value

    foreach ($result in $results) {
        #Create and output the line of information.
		$tableName = $result.name

		[pscustomobject]@{ 
            'TableName' = $tableName;
        } | Export-Csv $filename -Append -NoTypeInformation
    }
}

#Comment out if you want to just use the Az_Utility Module to call this function
Export-AzSentinelAnalyticsRules

<#  ---Original parsing code---
foreach ($table in $results) {
    $output = $table.name + ","
    $output >> $filename
    foreach ($column in $table.columns | Sort-Object -Property name) {
        #Column names starting with an underscore do not show up in the Logs
        #listing so I am skipping them here as well.
        if (!$column.name.StartsWith("_")) {
            #The two commas in the beginning are to indent the column information to match the header
            $output = ",," + $column.name + "," + $column.description + "," + $column.type
            $output >> $filename
        }
    }
}#>

<# ---Potential loop if the columns are needed---
$requiredDataConnectors = ""
foreach ($dc in $result.properties.requiredDataConnectors) {
    $requiredDataConnectors += $dc.connectorId + "|" 
}#>