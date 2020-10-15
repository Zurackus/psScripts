$machine = 10.42.10.58
$port_arr = @(443, 3389, 9100)

foreach ($port in $port_arr) {
    Test-NetConnection $machine -port $port -InformationLevel Quiet
}