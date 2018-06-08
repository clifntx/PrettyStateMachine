function log ($str, $fc="white"){
# fc can be any of these [Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White]
    $fc = $fc.ToLower()
    switch ($fc) {
        "red"      {$priority = 5}
        "yellow"   {$priority = 4}
        "green"    {$priority = 2} 
        "white"    {$priority = 1}
        "gray"     {$priority = 0; $str = "  "+$str;}
        "darkgray" {$priority = -1}
        }
    if ($priority -ge $logLevel) {
        write-host $str -ForegroundColor $fc
        }
    }
function removeDefaultApps {
# try removing windows apps
    log "Calling removeDefaultApps(`n>>> no args`n>>> )" -foreground "darkgray"
    try {
        $dump = Get-AppxPackage -AllUsers | where-object {$_.name -notlike "*Microsoft.WindowsStore*"} | where-object {$_.name -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.name -notlike "*Microsoft.WindowsSoundRecorder*"} | where-object {$_.name -notlike "*Microsoft.ZuneMusic*"} | Remove-AppxPackage 
        $dump = Get-AppxProvisionedPackage -online | where-object {$_.packagename -notlike "*Microsoft.WindowsStore*"} | where-object {$_.packagename -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.name -notlike "*Microsoft.WindowsSoundRecorder*"} | where-object {$_.name -notlike "*Microsoft.ZuneMusic*"} | Remove-AppxProvisionedPackage -online -ErrorAction Ignore
    } catch [UnauthorizedAccessException] {
        #log ">> Caught Error: UnauthorizedAccessException" "yellow"
        log "...running in an unelevated session.  Rerun script as admin." "red"
    } catch {
        log ">> Uncaught Error: $($Error[0].Exception.getType().FullName)" "red"
        log ">> ... $($Error[0].Exception)" "red"
        }
    log "...disableDefaultsSettings process complete." "green"
    }

removeDefaultApps
#pause
