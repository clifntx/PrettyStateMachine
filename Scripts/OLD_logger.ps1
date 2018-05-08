filter timestamp {"$(Get-Date -UFormat "[ %b%d%Y %H:%M:%S ]"): $_"}

$pushPath = "c:\push\";
$log = "";
$sw = $null;
$out = ""

#write text to log
function log($s) {    
    Write-Host ("$s" | timestamp)
    Add-Content $log ("$s`n" | timestamp)
    $script:out += "`n $s";
}

#initializes logging in a log called $log
function startLogging($p, $l) {
    $sw = [Diagnostics.Stopwatch]::StartNew();
    $ti = Get-Date -UFormat "%b%d%Y_%H`h%M`m%S`s";
    $script:pushPath = $p;
    $script:log = $pushPath+"logs\"+$l;
    if(!(Test-Path $log)) { New-Item -Type file -force $log; }

    Write-Host "[ START ] $ti"
    Add-Content $log "[ START ] $ti"
    Write-Host ("Starting log" | timestamp)
    Add-Content $log ("Starting log`n" | timestamp)  
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
