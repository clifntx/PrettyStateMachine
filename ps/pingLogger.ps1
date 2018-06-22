param(
    [string]$ip = $(throw "Please enter a valid ip arg.  ex. -ip `"NTSBERN17`"")
)

filter timestamp {"$(Get-Date -UFormat "[ %b%d%Y %H:%M:%S ]"): $_"}

$log = "c:\push\pinglog_$ip.txt";

#write text to log
function log($s) {    
    Write-Host ("$s" | timestamp)
    Add-Content $log ("$s`n" | timestamp)
    $script:out += "`n $s";
    }

function getPingStats($ip){
    $s = ping $ip;
    $pings = $s[2..5]
    $responseStats = $s[8].substring(13).split(",").trim()[0..2]
    $speedStats = $s[10].split(",").trim()[0..2]
    return @{
        "pings"=$pings; 
        "response"=$responseStats;
        "speed"=$speedStats
        }
}

function testIp($ip) {
    $s = getPingStats $ip
    $s.pings | foreach {
        if (($_ -contains "timed out") -or ($_ -contains "unavailable"))  {
            log $_;
        }
    }
    log ("<$ip> [$($s.response[2])], [$($s.speed)]")
     
}

$flag = $true;
while($flag) { testIp $ip; timeout /t 60 /nobreak; }