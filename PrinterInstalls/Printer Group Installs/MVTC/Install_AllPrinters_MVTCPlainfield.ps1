function downloadZip($driverUrl, $downloadPath) {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($driverUrl, $downloadPath)
}

function Unzip($zipPath, $extractPath) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem;
    #param([string]$zipPath, [string]$extractPath);
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractPath);
}

function isPrinterInstalled($ip, $loc) {
    $port = "IP_$ip";
    #write-host "...Checking for [$loc] on port [$port]:";
    $res = $false;
    Get-Printer | foreach {
        if (($_.Name -like "$loc*") -and ($_.PortName -like $port)) { 
            $res = $true;
            }
        }
    if ($res) {
        write-host "......Found printer [$loc] on port [$port]."
    } else {
        write-host "...Did not find printer [$loc] on port [$port].";
    }
    return $res;
}

function installToshibaPrinter($ip, $loc) {
    $port = "IP_$ip";

    Get-Printer | foreach {
        $name = $_.Name;
        if ($_.PortName -like $port) {
            write-host "...removing port conflict [$name] [" $_PortName "]";
            rundll32 printui.dll,PrintUIEntry /dl /n $name /q;
            }
        if ($name -like "$loc*") {
            write-host "...removing name conflict [$name] [" $_PortName "]";
            rundll32 printui.dll,PrintUIEntry /dl /n $name /q
            }
        }

    write-host "Installing printer [$loc] on port [$port].";
    cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r $port -h $ip -o raw -n 9100
    rundll32 printui.dll,PrintUIEntry /if /b "$loc - TOSHIBA Universal Printer 2" /f C:\Push\Toshiba\64bit\eSf6u.inf /r $port /m "TOSHIBA Universal Printer 2" /Z
}

clear

#set vars
$pushRoot = "c:\push\"
$driverUrl = "https://s3.amazonaws.com/aait/Toshiba_64bit.zip"
$downloadPath = "$pushRoot\toshiba.zip"
$extractPath = "C:\Push\"
$driverPath = "C:\Push\Toshiba\64bit\eSf6u.inf"
$start_time = Get-Date

#install driver
if (Test-Path $driverPath) {
    Write-Host "Path [$driverPath] already exists.  Doing nothing.";
} else {
    Write-Host "Path [$driverPath] does not exist.  Downloading and installing...";    
    downloadZip $driverUrl $downloadPath;
    Write-Output "...Time taken for download: $((Get-Date).Subtract($start_time).Seconds) second(s)";
    Unzip $downloadPath $extractPath;
    Write-Output "...Time taken for extraction: $((Get-Date).Subtract($start_time).Seconds) second(s)";
}

#install printers
$printers = @(
    @{"loc" = "Plainfield Admissions"; "ip" = "10.10.20.25"; },
    @{"loc" = "Plainfield Clinical"; "ip" = "10.10.20.27"; },
    @{"loc" = "Plainfield Residential"; "ip" = "10.10.20.26"; }
    );

$printers | foreach {
    $l = $_.loc;
    $i = $_.ip;
    #$installed = isPrinterInstalled $i $l;
    write-host "Installing $l on port [IP_$i]:";
    if (isPrinterInstalled $i $l) {
        Write-Output "...Doing nothing.";
    } else {
        installToshibaPrinter $i $l;
        Write-Output "...time taken for printer install [$l]: $((Get-Date).Subtract($start_time).Seconds) second(s)";
        }
    }