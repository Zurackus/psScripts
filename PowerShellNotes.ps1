#Powershell scripting Notes
#Extentions
    #Python
    #PowerShell
    #GitLens
    #Settings Sync
    #Prettier

'''Powershell Equivalent***
Cmd -> Powershell
Ipconfig -> get-netipconfiguration
Ipconfig /all -> get-netipaddress
Ping -> test-netconnection
Nslookup - resolve-dnsname

'''

''' Modules
AzureAD
ExchangeOnlineManagement
MSOnline
ADFSToolbox


'''
#Calling a python Script
python 

#Spacing ctrl + ] to add an indent for selected code
#Spacing ctrl + [ to remove an indent for selected code

#Simple Commands
    #Remote to PC
enter-pssession -computername 10.40.1.171

    #Parent of $PSScriptRoot
$Rootpath = Split-Path(Split-Path $PSScriptRoot)
