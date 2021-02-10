function Get-VPN-ActiveTunnels {
    $dir = $PSScriptRoot + "\FirewallVPN_ActiveVPNs.py"
    #Calling a python script
    python $dir
}

function Get-VPN-TunnelGrous {
    $dir = $PSScriptRoot + "\FirewallVPN_TunnelGroups.py"
    #Calling a python script
    python $dir
}