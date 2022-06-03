$tables = @('SecurityEvent','CommonSecurityLog','InsightsMetrics','Event','Sysmon')#,'Operation')

$query = "Operation Sysmon | where EventID == 1 and (process_parent_command_line contains SecurityEvent"

$logSource = ""
        if($query -ne ""){
            #Iterate through the tables, and search the query for which table is used
            foreach($table in $tables) {
                if($table -eq ('Event' -or 'Operation' -or 'Update' -or 'Perf')) {
                    $pattern2 = '|\s+' + [regex]::Escape($table) + '[\s|\n]+'
                    $pattern = '^\s*' + [regex]::Escape($table) + '[\s|\n]+'
                    
                    if($query -match $pattern) {
                        $logSource += $table + "|"
                    }
                }
                elseif($query.Contains($table)) {
                    #Add any tables that were found within the Query
                    $logSource += $table + "|"
                }
                else{
                }
            }
        }


$logSource
#$pattern
$pattern2
$query -match $pattern
