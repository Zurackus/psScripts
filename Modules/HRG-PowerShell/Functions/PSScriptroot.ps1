$exportsPath = Join-Path $PSScriptRoot 'Functions.csv'
$moduleRoot = Split-Path -Parent $PSScriptRoot
$workFolder = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath '\old'
$workOutput = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath '\WorkFiles\Import.csv'

Write-Output "`n1.`$exportsPath:[$exportsPath]"
Write-Output "2.`$PSScriptRoot:[$PSScriptRoot]"
Write-Output "3.Parent:[$(Split-Path -Parent $MyInvocation.MyCommand.Path)]"
Write-Output "4.Leaf:[$(Split-Path -Leaf $MyInvocation.MyCommand.Path)]"
Write-Output "5.Full path:[$($MyInvocation.MyCommand.Path)]"
Write-Output "6.Parent of `$PSScriptRoot:[$moduleRoot]"
Write-Output "7.Child of `$Scriptroots Parent :[$workFolder]"
Write-Output "8.Child/File of `$Scriptroots Parent :[$workOutput]"
Write-Output "9.Enviroment Variable, Appdata Local :[$env:LOCALAPPDATA]"
Write-Output "10.Enviroment Variable, Appdata Roaming :[$env:APPDATA]"
Write-Output "11.Enviroment Variable, Public :[$env:PUBLIC]"
Write-Output "12.Enviroment Variable, AppData\Local\Temp :[$env:TEMP]"

#$pshome -force

<#
$path = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles'
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}
$workOutput = Join-Path -Path $env:LOCALAPPDATA -ChildPath '\WorkFiles\ADenabled.csv'
get-aduser -filter "(enabled -eq 'true')" -properties title, company, department, officephone, canonicalname, whencreated, officephone, office, mail, lastlogontimestamp, employeeID | export-csv -path $workOutput
#>