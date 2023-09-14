# Set the path to the folder containing JSON files
$folderPath = "$env:USERPROFILE\Downloads"
 
# Get all JSON files in the specified folder
$jsonFiles = Get-ChildItem -Path $folderPath -Filter "*.json" -File

foreach ($jsonFile in $jsonFiles) {
    try {
        # Read the JSON content from the file
        $jsonContent = Get-Content -Path $jsonFile.FullName -Raw | ConvertFrom-Json

        # Extract "properties.tactics" and remove whitespace
        $tactics = $jsonContent.resources.properties.tactics | ConvertTo-Json -Compress

        # Extract "properties.techniques" and remove whitespace
        $techniques = $jsonContent.resources.properties.techniques | ConvertTo-Json -Compress

        # Extract "properties.entityMappings" and format it as JSON on a new line
        $entityMappings = $jsonContent.resources.properties.entityMappings | ConvertTo-Json -Compress

        # Replace '@' symbols with an empty string and '=' with ':' and remove double quotes
        $entityMappings = $entityMappings -replace '@', '' -replace '=', ':' -replace '"', ''

        # Extract "properties.displayName" for the output file name
        $displayName = $jsonContent.resources.properties.displayName
        $outputFileName = "$displayName.txt"

        # Combine the extracted data and save it to a file with the extracted display name as the file name
        $outputFile = Join-Path -Path $folderPath -ChildPath $outputFileName
        "[$tactics]`n[$techniques]`n$entityMappings" | Out-File -FilePath $outputFile

        Write-Host "Extracted tactics and entityMappings from $($jsonFile.Name) and saved to $($outputFile)"
    } catch {
        Write-Host "Error processing $($jsonFile.Name): $_"
    }
}