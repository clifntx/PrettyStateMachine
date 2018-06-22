#param must be the first statement in your script

$DRIVER_URL_MAP = @(
        @{"driver"="TOSHIBA Universal Printer 2"; "path"="C:\Push\Toshiba\64bit\eSf6u.inf"; "url" = "https://s3.amazonaws.com/aait/Toshiba_64bit.zip"},
        @{"driver"="Xerox Global Print Driver PCL6"; "path"="C:\Push\Toshiba\64bit\eSf6u.inf"; "url" = "https://s3.amazonaws.com/aait/Xerox.zip"},
        @{"driver"="KX DRIVER for Universal Printing"; "path"="C:\Push\Kyocera\KXPrintDriverv7.3.1207\64bit\oemsetup.inf"; "url" = "https://s3.amazonaws.com/aait/KXPrintDriverv7.3.1207.zip"},
        @{"driver"="HP Universal Printing PCL 6"; "path"="C:\Push\HP\HPUniversalPCL6\hpbuio200l.inf"; "url" = "https://s3.amazonaws.com/aait/HP.zip"},
        @{"driver"="PCL6 V4 Driver for Universal Print"; "path"="C:\push\Savin\SavinUniversal\disk1\PrinterDrivers\r4600.inf"; "url" = "https://s3.amazonaws.com/aait/Savin.zip"},
        @{"driver"=""; "path"=""; "url" = ""}
        )


function downloadZip($driverUrl, $downloadPath) {
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
    Get-Printer | foreach {
        if (($_.Name -eq $loc) -and ($_.PortName -eq $port)) { 
            write-host "...Found printer [$loc] on port [$port]."
            return $true;
        } else {
            write-host "...Did not find printer [$loc] on port [$port]."
            return $false;
            }
        }
}

function installPrinter($ip, $loc) {
    $port = "IP_" + $ip;
    write-host "Installing printer [$loc] at ip [$ip].";
    rundll32 printui.dll,PrintUIEntry /dl /n "$loc - $driver" /q
    cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r $port -h $ip -o raw -n 9100
    rundll32 printui.dll,PrintUIEntry /if /b "$loc - $driver" /f C:\Push\Toshiba\64bit\eSf6u.inf /r $port /m $driver /Z
}

function downloadAndInstallPrinter($start_time, $driverPath, $driverUrl, $downloadPath, $extractPath, $printerIp, $printerLocation) {
    #install driver
    if (Test-Path $driverPath) {
        Write-Host "Path [$driverPath] already exists.  Doing nothing.";
    } else {
        Write-Host "Path [$driverPath] does not exist.  Downloading and installing...";    
        downloadZip $driverUrl $downloadPath;
        Write-Output "...Time taken for download: $((Get-Date).Subtract($start_time).Seconds) second(s)"
        Unzip $downloadPath $extractPath;
        Write-Output "...Time taken for extraction: $((Get-Date).Subtract($start_time).Seconds) second(s)"
    }
    #install printer
    if (isPrinterInstalled $printerIp $printerLocation) {
        Write-Output "...Printer already installed [$printerLocation].  Doing nothing."
    } else {
        installPrinter $printerIp $printerLocation;
        Write-Output "...Time taken for printer install [$printerLocation]: $((Get-Date).Subtract($start_time).Seconds) second(s)"
    }
}

function getDriverInfo($driverName, $DRIVER_URL_MAP) {
    
    $driver = @{}
    foreach ($d in $DRIVER_URL_MAP) {
        if ($d.driver -eq $driverName) {
            $driver = $d
            }
        }
    return $driver
}

function main($start_time, $pushRoot, $printers) {

    foreach ($p in $printers) {
        $downloadPath = "$pushRoot\printerTemp.zip"
        $extractPath = $pushRoot
        $driver = getDriverInfo($driverName)
        downloadAndInstallPrinter $start_time $driver.url $downloadPath $extractPath $p.location $driver.path, $p.ip
        }
    }

#set vars
$start_time = Get-Date
$pushRoot = "c:\push\"
$printers = @(
    @{"location"=""; "driverName"="PCL6 V4 Driver for Universal Print"; "ip"=""},
    @{"location"=""; "driverName"="PCL6 V4 Driver for Universal Print"; "ip"=""},
    @{"location"=""; "driverName"="HP Universal Printing PCL 6"; "ip"=""},
    @{"location"=""; "driverName"="TOSHIBA Universal Printer 2"; "ip"=""},
    )

clear
main $start_time $pushRoot $printers