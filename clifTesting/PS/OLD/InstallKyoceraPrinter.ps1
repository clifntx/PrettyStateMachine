#param must be the first statement in your script
Param(
  [string]$ip,
  [string]$location,
  [string]$driver = "KX DRIVER for Universal Printing"
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

function installPrinter($ip, $loc, $driver) {
    $port = "IP_" + $ip;
    write-host "Installing printer [$loc] at ip [$ip].";
    rundll32 printui.dll,PrintUIEntry /dl /n "$loc - $driver" /q
    cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r $port -h $ip -o raw -n 9100
    rundll32 printui.dll,PrintUIEntry /if /b "$loc - $driver" /f $driverPath /r $port /m $driver /Z
}

clear

#set vars
$pushRoot = "c:\push\"
$driverUrl = "https://s3.amazonaws.com/aait/KXPrintDriverv7.3.1207.zip";
$downloadPath = "$pushRoot\toshiba.zip";
$extractPath = "C:\Push\";
$driverPath = "C:\Push\Kyocera\KXPrintDriverv7.3.1207\64bit\oemsetup.inf";
$start_time = Get-Date;

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