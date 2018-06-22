#param must be the first statement in your script
Param(
  [string]$ip,
  [string]$location,
  [string]$driver = "Xerox Global Print Driver PCL6",
  [string]$driverPath = "C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf"
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
    $res = $false;
    Get-Printer | foreach {
        if (($_.Name -eq $loc) -and ($_.PortName -eq $port)) { 
            write-host "...Found printer [$loc] on port [$port]."
            $res = $true;
        } else {
            write-host "...Did not find printer [$loc] on port [$port]."
            }
        }
    return $res;
}

function installPrinter($ip, $loc, $driver, $driverPath) {
    $port = "IP_" + $ip;
    write-host "Installing printer [$loc] at ip [$ip].";
    rundll32 printui.dll,PrintUIEntry /dl /n "$loc - $driver" /q
    cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r $port -h $ip -o raw -n 9100
    rundll32 printui.dll,PrintUIEntry /if /b "$loc - $driver" /f $driverPath /r $port /m $driver /Z
}

clear

#set vars
$pushRoot = "c:\push\"
$driverUrl = "https://s3.amazonaws.com/aait/Xerox.zip";
$downloadPath = "$pushRoot\xerox.zip";
$extractPath = "C:\Push\";
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
if (isPrinterInstalled $ip $location) {
    Write-Output "...Printer already installed [$printerLocation].  Doing nothing."
} else {
    installPrinter $ip $location $driver $driverPath;
    Write-Output "...Time taken for printer install [$printerLocation]: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}