$machine = 172.30.253.159
$port_arr = @(443, 3389, 9100)

foreach ($port in $port_arr) {
    Test-NetConnection $machine -port $port -InformationLevel Quiet
}