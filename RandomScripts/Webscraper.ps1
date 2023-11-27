# List of table names
$tableNames = "securityevent"#, "event", "commonsecuritylog" # Add more table names as needed

foreach ($tableName in $tableNames) {
    # Construct the URL
    $url = "https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/$tableName"
    #Write-Output $url
    # Get the content of the page
    $response = Invoke-WebRequest -Uri $url
    #Write-Output $response
    #Invoke-WebRequest -Uri "https://learn.microsoft.com/en-us/azure/azure-monitor/reference/tables/securityevent"
    $definition = $response.AllElements | Where {$_.TagName -eq "p"}
    Write-Output $definition
    # Extract the definition from the HTML
    #$definition = ($response.ParsedHtml.getElementsByTagName('p') | Where $_.
    #$definition = $response.ParsedHtml.getElementsByTagName('p') | Select-Object -First 1 -ExpandProperty innerText
    #$html = [xml]$response.Content
    #[xml] is a cast to convert code to xml
    #$definition = $html.getElementsByTagName('p')
    # Output the results in the specified format
    #Write-Output "`"$tableName`",`"$definition`""#>
}