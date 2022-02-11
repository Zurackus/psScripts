#Grabbing all of the functions
  $exportsPath = Join-Path $PSScriptRoot './Functions'

  if($exportsPath) {
    Get-ChildItem -Path $exportsPath -Recurse -Include '*.ps1' -File | ForEach-Object { . $_.FullName }
  }