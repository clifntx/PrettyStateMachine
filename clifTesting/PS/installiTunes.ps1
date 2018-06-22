function log ($str){
    write-host $str;
    }

function checkForPush($push){
    if(!(test-path $push)) {
        New-Item -Path $push -ItemType Directory
    }
    return (test-path $push)
}

function downloadZip($installerUrl, $downloadPath) {
    log "Downloading zip from [$installerUrl]..."
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($installerUrl, $downloadPath)
}

function unzip($downloadPath, $extractPath, $dirContainingInstallers) {
    log "Unzipping [$downloadPath]..."
    if (test-path $extractPath) {
        Remove-Item -Recurse -Force $dirContainingInstallers
        }
    Add-Type -AssemblyName System.IO.Compression.FileSystem;
    #param([string]$downloadPath, [string]$extractPath);
    [System.IO.Compression.ZipFile]::ExtractToDirectory($downloadPath, $extractPath);
    $res = isZipExtracted $dirContainingInstallers;
    return $res;

}


function isZipExtracted($dirContainingInstallers) {
    if(Test-Path($dirContainingInstallers)) {
        log "..zip extracted successfully to [$dirContainingInstallers].";
        return $true;
    } else {
        log "..zip not extracted successfully to [$dirContainingInstallers].";
        return $false;
    }
}

function installItunes($dirContainingInstallers) {
    Set-Location -Path $dirContainingInstallers;
    log "Changed pwd to $PWD"
    $apps = @(
        @{name = "Apple Application Support (32-bit)"; path = "AppleApplicationSupport.msi"; arg = "/i AppleApplicationSupport.msi ALLUSERS=1 /qn"}, 
        @{name = "Apple Application Support (64-bit)"; path = "AppleApplicationSupport64.msi"; arg = "/i AppleApplicationSupport64.msi ALLUSERS=1 /qn"},
        @{name = "Apple Mobile Device Support"; path = "AppleMobileDeviceSupport64.msi"; arg = "/i AppleMobileDeviceSupport64.msi ALLUSERS=1 /qn"}, 
#        @{name = "iTunes"; path="iTunes64.msi"; arg="/i iTunes64.msi /passive"}
        @{name = "iTunes"; path="iTunes64.msi"; arg="/i iTunes64.msi /qn"}
        )
    $apps | foreach {
        $trys = 0;
        $name = $_.name;
        $path = $_.path;
        log "..Installing [$name]...";
        $isInstalled = isInstalled $name;
        while( ($isInstalled -eq $false) -and ($trys -lt 5) ) {
            $pathValid = Test-Path $path;
            log "....Is path valid [ $path ]? $pathValid";
            Start-Process msiexec.exe -Wait -ArgumentList $_.arg;
            timeout /t 10
            $trys += 1;
            $isInstalled = isInstalled $name;
        }
    }
}

function isInstalled($appName) {
    $res = $false;
    $a = Get-WmiObject -Class Win32_Product
    $res = ($a.Name -like $appName).Length -gt 0
    if ($res) { 
        log "..$appName is installed.";
    } else {
        log "..$appName is not installed.";
        } 
    return $res;
}

function main ($installerUrl, $downloadPath, $extractPath, $dirContainingInstallers) {
    checkForPush $push;
    downloadZip $installerUrl $downloadPath;
    unzip $downloadPath $extractPath;
    installItunes $dirContainingInstallers;
}

$installerUrl = "https://s3.amazonaws.com/aait/iTunes64Setup.zip";
$push = "C:\Push";
$downloadPath = "$push\temp.zip";
$extractPath = "$push";
$dirContainingInstallers = "$extractPath\iTunes64Setup"

main $installerUrl $downloadPath $extractPath $dirContainingInstallers;

#$DataStamp = get-date -Format yyyyMMddTHHmmss
#$logFile = '{0}-{1}.log' -f $file.fullname,$DataStamp
#$MSIArguments = @(
#    "/i"
#    ('"{0}"' -f $file.fullname)
#    "/qn"
#    "/norestart"
#    "/L*v"
#    $logFile
#)
#Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow 