filter timestamp {"$(Get-Date -UFormat "[ %b%d%Y %H:%M:%S ]"): $_"}

$pushPath = "c:\push\";
$log = "dummyLog.txt";
$sw = $null;
$out = ""

#write text to log
function log($s) {    
    Write-Host ("$s" | timestamp)
    Add-Content $log ("$s`n" | timestamp)
    $script:out += "`n $s";
}

function logForUser($logPath, $s){
    $dir = ($terryLog.trim("\").split("\")[0..($terryLog.trim("\").split("\").Length-2)] -join "\") + "\"
    if(!(test-path $dir)){ 
        mkdir $dir;
        }
    Add-Content $logPath ("$s`n" | timestamp);
    $script:out += "`n Logged to user log [$logPath]: $s";
    }

#initializes logging in a log called $log
function startLogging($pushPath, $logName) {
    $sw = [Diagnostics.Stopwatch]::StartNew();
    $ti = Get-Date -UFormat "%b%d%Y_%H`h%M`m%S`s";
    write-host "pushPath: $pushPath, logname: $logName";
    $log = "$pushPath\$logName";
    if(!(Test-Path $log)) { New-Item -Type file -force $log; }

    Write-Host "[ START ] $ti"
    Add-Content $log "[ START ] $ti"
    Write-Host ("Starting log" | timestamp)
    Add-Content $log ("Starting log`n" | timestamp)  

    $script:pushPath = $pushPath;
    $script:log = $log;
    return $sw
}

#closes logging
function endLogging ($sw) {
    $timeFinal = Get-Date -UFormat "%b%d%Y_%H`h%M`m%S`s"
    $sw.Stop()
    $timeElapsed = $sw.ElapsedMilliseconds
    Write-Host "[ END ] Total time elapsed: $timeElapsed ms"
    Add-Content  $log "[ END ] Total time elapsed: $timeElapsed ms"
    $script:out += "`n.......................................`n`nTotal time elapsed: $timeElapsed ms";
    return $script:out;
}