param(
    [string]$serviceName = $(throw ">> ERROR: Please include a service name argument.  ex. -serviceName 'ADVANTAGE'"),
    [string]$action = $(throw ">> ERROR: Please include an action argument ['start', 'stop'].  ex. -serviceName 'start'"),
    [string]$suppressStart = "1500",
    [string]$suppressStop = "20:00",
    [string]$logPath = "c:\push\log_backup.txt",
    [int]$timesToAttempt = 5,
    [int]$logLevel = 1
    )

# setServiceStatus.ps1 -serviceName "AdobeARMservice" -action "start" -suppressStart "15:00" -suppressStop "20:00" -logLevel -1
# setServiceStatus.ps1 -serviceName "Advantage" -action "start" -suppressStart "23:00" -suppressStop "5:00" -logLevel -1
# setServiceStatus.ps1 -serviceName "PracticeWatch" -action "start" -suppressStart "23:00" -suppressStop "5:00" -logLevel -1

filter timestamp {"$(Get-Date -UFormat "[ %b%d%Y %H:%M:%S ]"): $_"}
$LOG = ""

function log ($str, $fc="white"){
# fc can be any of these [Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White]
    $fc = $fc.ToLower()
    switch ($fc) {
        "red"      {$priority = 5; $str = ($str  | timestamp)}
        "yellow"   {$priority = 4; $str = ($str  | timestamp)}
        "green"    {$priority = 2; $str = ($str  | timestamp)} 
        "white"    {$priority = 1; $str = (".."+$str | timestamp);}
        "gray"     {$priority = 0; $str = ("...."+$str | timestamp);}
        "darkgray" {$priority = -1;}
        default {$fc = "white";$priority = 1;}
        }
    if ($priority -ge $logLevel) {
        $script:LOG += '$str `n '
        write-host $str -ForegroundColor $fc
        Add-Content $logPath "$str `n"
        }
    }

function isServiceRunning($serviceName) {
    log "> Calling isServiceRunning(`n>>> serviceName=$serviceName`n>>> )" "darkgray"
    $status = (Get-Service -Name $serviceName).Status
    switch($status) {
        "Running" {$res = $true; log "Service [$serviceName] Running." "gray"}
        "Stopped" {$res = $false; log "Service [$serviceName] stopped." "gray"}
        default {$res = $false; log "received invalid input."}
        }
    return $res
    }

function startService($serviceName, $timesToAttempt) {
    log "> Calling startService(`n>>> serviceName=$serviceName`n>>> timesToAttempt=$timesToAttempt`n>>> )" "darkgray"
    $i = 0
    while($i -lt $timesToAttempt) {
        if(isServiceRunning $serviceName) {
            log "successfully started [$serviceName]." "gray"
            return $true
        } else {
            try {
                start-service -Name $serviceName -ErrorAction Stop
            } catch [Microsoft.PowerShell.Commands.ServiceCommandException] {
                log "script requires elevation.  Please re-run as administrator." "yellow"
            } catch {
                log ">> UNCAUGHT ERROR: $PSItem" "red"
                log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
                }
            }
        $i += 1
        }
    log "...failed to start [$serviceName]." "red"
    return $false
    }

function stopService($serviceName, $timesToAttempt) {
    log "> Calling stopService(`n>>> serviceName=$serviceName`n>>> timesToAttempt=$timesToAttempt`n>>> )" "darkgray"
    $i=0
    while($i -lt $timesToAttempt) {
        if(isServiceRunning $serviceName) {
            try {
                stop-service -Name $serviceName -ErrorAction Stop
            } catch [Microsoft.PowerShell.Commands.ServiceCommandException] {
                log "script requires elevation.  Please re-run as administrator." "yellow"
            } catch {
                log ">> UNCAUGHT ERROR: $PSItem" "red"
                log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
                }
        } else {
            log "...successfully stopped [$serviceName]." "gray"
            return $true
            }
        $i += 1
        }
    log "...failed to stop [$serviceName]." "red"
    return $false
    }

function isNowOUtsideOfSuppressWindow($suppressStart, $suppressStop) {
    log "> Calling isNowIsOUtsideOfSuppressWindow(`n>>> suppressStart=$suppressStart`n>>> suppressStop=$suppressStop`n>>> )" "darkgray"
    $now = @(get-date)
    log "suppress window is [$suppressStart to $suppressStop]" "gray"
    log "checking if $now falls outside of suppress window." "gray"
    if (($now -lt $suppressStart) -or ($now -gt $suppressStop)) {
        log "time [$now] is -lt [$suppressStart] and -gt [$suppressStop].  Returning true." "gray"
        $res = $true
    } else {
        log "time [$now] is not -lt [$suppressStart] and -gt [$suppressStop].  Returning False." "gray"
        $res = $false
        }
    log "isNowOUtsideOfSuppressWindow($suppressStart, $suppressStop) returning $res." "gray"
    return $res    
    }

function validateStartandStop($str) {
    log "> Calling validateStartandStop(`n>>> str=$str`n>>> )" "darkgray"
    $nstr = ""
    if ($str.Length -gt 5) {
        throw ">> ERROR $str is not a valid time"
        return $false
        }
    if (!($str.Contains(":"))) { 
        $nstr = "$($str.Substring(0,2)):$($str.Substring(2,2))"
    } else {
        $nstr = $str
        }
    log "returning nstr [$nstr]" "gray"
    return $nstr
    }

function main($action, $serviceName, $suppressStart, $suppressStop, $timesToAttempt) {
    log "Attempting to [$action] service [$serviceName]." "white"

    switch($action) {
        "start" {}
        "stop"  {}
        }
    
    log "validating suppressStart..." "gray"        
    $suppressStart = validateStartandStop($suppressStart)
    log "validating suppressStop..." "gray"        
    $suppressStop = validateStartandStop($suppressStop)

    if($suppressStart -and 
        $suppressStop -and 
        (isNowOUtsideOfSuppressWindow $suppressStart $suppressStop)) {
        log "Now is outside of suppression window.  Continuing." "white"        
            switch($action.ToLower()) {
                "start" { 
                    if(!(isServiceRunning $serviceName)) {
                        $res = startService $serviceName $timesToAttempt 
                        if((isServiceRunning $serviceName) -eq "Running") {
                            $res = $true
                            }
                    } else {
                        log "Service [$serviceName] is already started." "white"
                        $res = $true
                        

                        }
                    }
                "stop"  {
                    if(isServiceRunning $serviceName) { 
                        $res = stopService $serviceName $timesToAttempt 
                        if((isServiceRunning $serviceName) -eq "Stopped") {
                            $res = $true
                            }
                    } else {
                        log "Service [$serviceName] is already stopped." "white"
                        $res = $true
                        }
                    }
                default { 
                    throw ">> ERROR: Invalid action [$($action.ToLower())]" 
                    }
                }
    } else {
        log "time [$(@(get-date))] is within time window [$suppressStart - $suppressStop].  Aborting." "white"
        $res = $false
        }
    
    if($res) {$c="green"} else {$c="red"}
    log "Is [$serviceName] running: $(isServiceRunning $serviceName)" "white"
    log "Successfully enacted [$action] on [$serviceName]?: $res" $c
    }

    main $action $serviceName $suppressStart $suppressStop $timesToAttempt