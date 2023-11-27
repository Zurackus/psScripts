<%*
const categories = ["Action","BackBurner","Amtrak","AmtrakLink","Python", "PythonLink","Trustwave","TrustwaveLink", "PowerShell", "PowerShellLink","Research","ResearchLink","Sentinel","SentinelLink","KQL","KQLLink","Obsidian","ObsidianLink",]
let type = await tp.system.suggester(categories, categories, true, "Pick an inline catagory to print:",10)

final_name = type + "\:\:"
tR += final_name
%> 