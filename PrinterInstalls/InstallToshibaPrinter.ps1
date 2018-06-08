#param must be the first statement in your script
Param(
  [string]$ip = $(throw ">> ERROR: Please enter a valid ip argument.  ex: -ip '10.10.5.6'"),
  [string]$location = $(throw ">> ERROR: Please include a location argument. ex -location 'Plymouth Nurse Office'"),
  [string]$driver = "TOSHIBA Universal Printer 2",
  [string]$logpath = "c:\push\logs\printer_log.txt"
)

-ip "90.90.90.90" -location = "Fitchburg Office"

function log($str){
    $dir = ((($logPath.Split("\"))[0..($logPath.Split("\").Length-2)]) -join "\");
    if(!(test-path $dir)){ 
        mkdir $dir;
        }
    $str | Out-File $logPath -Append;
    }

function downloadZip($driverUrl, $downloadPath) {
    if(!(test-path $pushRoot)) { mkdir $pushRoot; }
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($driverUrl, $downloadPath)
}

function Unzip {
    Add-Type -AssemblyName System.IO.Compression.FileSystem;
    #param([string]$downloadPath, [string]$extractPath);
    [System.IO.Compression.ZipFile]::ExtractToDirectory($downloadPath, $extractPath);
}

function isPrinterInstalled($ip, $loc) {
    $port = "IP_" + $ip;
    $res = $false;
    log("Checking for printer [$loc] on port [$port]:");
    Get-Printer | foreach {
        if (($_.Name -like "$loc*") -and ($_.PortName -like $port)) { 
            $res = $true;
            $match = "[" +$_.Name+ "][" +$_.PortName+ "]";
            #log("....MATCH!! [" +$_.Name+ "][" +$_.PortName+ "].");
        } else {
            #log("....does not match [" +$_.Name+ "][" +$_.PortName+ "].");
            }
        }
    if ($res) {
        log("..found printer: $match");
    } else {
        log("..did not find printer [$loc] on port [$port].");
    }
    return $res;
}

function installPrinter($ip, $loc, $driver) {
    $port = "IP_" + $ip;
    log("Installing printer [$loc] at ip [$ip].");
    rundll32 printui.dll,PrintUIEntry /dl /n "$loc - $driver" /q
    cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r $port -h $ip -o raw -n 9100
    rundll32 printui.dll,PrintUIEntry /if /b "$loc - $driver" /f $driverPath /r $port /m $driver /Z
    timeout /t 30;
    log("..checking for successful install.");
    if (isPrinterInstalled $ip $loc) {
        log("...printer successfully installed: $((Get-Date).Subtract($start_time).Seconds) second(s)");
    } else {
        log("...failed to install printer.  Run the following command:");
        log("===================================================================");
        log("rundll32 printui.dll,PrintUIEntry /if /b '$loc - $driver' /f $driverPath /r $port /m $driver /Z");
        log("===================================================================");
    }
}

function main($driverPath, $driverUrl, $downloadPath, $extractPath, $ip, $location) {
    $start_time = Get-Date;
    #install driver
    if (Test-Path $driverPath) {
        log("Path [$driverPath] already exists.  Doing nothing.");
    } else {
        log("Path [$driverPath] does not exist.  Downloading and installing...");
        downloadZip $driverUrl $downloadPath;
        log("Time taken for download: $((Get-Date).Subtract($start_time).Seconds) second(s)");
        Unzip $downloadPath $extractPath;
        log("Time taken for extraction: $((Get-Date).Subtract($start_time).Seconds) second(s)");
    }
    #install printer
    if (isPrinterInstalled $ip $location) {
        log("Printer already installed [$location][$ip].  Doing nothing.");
    } else {
        installPrinter $ip $location $driver;
        log("Time taken for printer install [$location][$ip]: $((Get-Date).Subtract($start_time).Seconds) second(s)");
    }
}

clear

#set vars
$pushRoot = "c:\push"
$driverUrl = "https://s3.amazonaws.com/aait/Toshiba_64bit.zip"
$downloadPath = "$pushRoot\toshiba.zip"
$extractPath = "$pushRoot\"
$driverPath = "$pushRoot\Toshiba\64bit\eSf6u.inf"

main $driverPath $driverUrl $downloadPath $extractPath $ip $location;
#write-host $driverPath $driverUrl $downloadPath $extractPath $ip $location;

