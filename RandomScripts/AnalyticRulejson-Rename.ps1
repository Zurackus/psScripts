#C:\Users\tyler.konsonlas\Downloads
# Set the path to the folder containing JSON files
$folderPath = "$env:USERPROFILE\Downloads"

# Get all JSON files in the specified folder
$jsonFiles = Get-ChildItem -Path $folderPath -Filter "*.json" -File

foreach ($jsonFile in $jsonFiles) {
    # Read the content of the JSON file
    $jsonContent = Get-Content -Raw -Path $jsonFile.FullName | ConvertFrom-Json

    # Extract the string from resources.properties.displayName
    $displayName = $jsonContent.resources.properties.displayName
    
    # Remove leading spaces
    $displayName = $displayName -replace '^[ _]+', ''
    # Replace space, = to :, and " to nothing
    #$displayName = $displayName -replace ' ', '' -replace '=', ':' -replace '"', ''
    
    # Close the JSON file
    $jsonContent | Out-Null

    # Form the new file name by adding '20230726_' to the front
    $newFileName = "20230920_$displayName.json"
    $newFilePath = Join-Path -Path $folderPath -ChildPath $newFileName

    # Rename the JSON file with the new file name
    Rename-Item -Path $jsonFile.FullName -NewName $newFilePath
}