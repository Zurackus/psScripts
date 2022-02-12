#31
function Get-VPNActiveTunnels {
    $dir = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "\Python\FirewallVPN_ActiveVPNs.py"
    #Calling a python script
    python $dir
}

#32
function Get-VPNTunnelGroups {
    $dir = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath "\Python\FirewallVPN_TunnelGroups.py"
    #Calling a python script
    python $dir
}