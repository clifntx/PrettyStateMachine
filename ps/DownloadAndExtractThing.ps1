#param must be the first statement in your script
Param(
  [string]$url = "https://s3.amazonaws.com/aait/Toshiba_64bit.zip",
  [string]$pushRoot = "c:\push",
  [string]$logPath = "c:\push\logs\download_log.txt"
)
function log($str){
    $dir = ((($logPath.Split("\"))[0..($logPath.Split("\").Length-2)]) -join "\");
    if(!(test-path $dir)){ 
        mkdir $dir;
        }
    $str | Out-File $logPath -Append;
    }
function downloadZip($url, $downloadPath) {
    if(!(test-path $pushRoot)) { mkdir $pushRoot; }
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($url, $downloadPath)
}

function Unzip ($zipPath, $extractPath) {
    if(!(test-path $pushRoot)) { mkdir $pushRoot; }
    Add-Type -AssemblyName System.IO.Compression.FileSystem;
    #param([string]$downloadPath, [string]$extractPath);
    [System.IO.Compression.ZipFile]::ExtractToDirectory($downloadPath, $extractPath);
}

function main($url, $pushRoot) {
    $start_time = Get-Date;
    #set vars
    $f = (($url.Split("/"))[-1]).split(".")[0];
    $downloadPath = "$pushRoot\$f.zip";
    $extractPath = "$pushRoot\$f\";

    log("Attempting to download from [$url] and extract to [$extractPath]:");
    downloadZip $url $downloadPath;
    Unzip $downloadPath $extractPath;
    if(test-path $extractPath) {
        log("..successfully downloaded and extracted file.");
    }else{
        log("..failed to download and extract file.");
    }
}

main $url $pushRoot;