#31
function Get-VPNActiveTunnels {
    $dir = $PSScriptRoot + "\FirewallVPN_ActiveVPNs.py"
    #Calling a python script
    python $dir
}

#32
function Get-VPNTunnelGroups {
    $dir = $PSScriptRoot + "\FirewallVPN_TunnelGroups.py"
    #Calling a python script
    python $dir
}