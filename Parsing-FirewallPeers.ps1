#Parsing-FirewallPeers
    #With this you will need to put in brackets the information that you want with a * after the variable name
    #The curly brackets will also be needed around the variable
    #Pulled with 'Show vpn-sessiondb l2l', transfered to 'VPNsUp.xlsx'
$template=@'
Connection   : {ip*:199.91.236.20}
Index        : 63686                  IP Addr      : 199.91.236.20
Protocol     : IKEv1 IPsecOverNatT
Encryption   : IKEv1: (1)AES256  IPsecOverNatT: (1)AES256
Hashing      : IKEv1: (1)SHA1  IPsecOverNatT: (1)SHA1
Bytes Tx     : 257532170              Bytes Rx     : 153046045
Login Time   : 03:57:56 PDT Fri Apr 24 2020
Duration     : 7h:24m:57s
'@

#explode file with template
$listexploded=Get-Content -Path "C:\ScriptSource\peercheck.txt" | ConvertFrom-String -TemplateContent $template

#export csv 
$listexploded | Export-Csv -Path "C:\ScriptOutput\peerOut.csv" -NoTypeInformation