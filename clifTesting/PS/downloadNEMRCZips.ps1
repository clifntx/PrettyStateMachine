#param must be the first statement in your script
Param(
  [string]$nemrcDir = "C:\OLD_NEMRC\", #the dir path of the NEMRC folder.
  [string]$urlRoot = "http://www.nemrc.com/winrele/", #the root url where zips are located.
  [string]$downloadDir = "C:\temp\", #the path you would like to download.
  [string]$extractDir = "C:\NEMRC\" #where you would like the zips extracted to, usually the new NEMRC folder.
)

function downloadZip($driverUrl, $downloadPath) {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($driverUrl, $downloadPath)
}

function Unzip($zipPath, $extractPath) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem;
    #param([string]$zipPath, [string]$extractPath);
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $extractPath);
}

function getFileNames($exeDir){
    $exes = @();
    (Get-ChildItem -Path $exeDir -Filter "*.exe").Name | foreach {
        $exes += $_ -replace "exe", "zip";
    }
    return $exes
}

clear
@($nemrcDir, $downloadDir, $extractDir) | foreach {
    if(!(Test-Path $_)) { 
        
        write-host "Creating dir [$_]";
        mkdir $_;
        }
    }
$files = getFileNames $nemrcDir;
write-host "Located [" $files.Length "] files."
write-host "Downloading and extracting files..."
$files | foreach {
    $url = $urlRoot + $_;
    write-host "..processing [$_].";
    try {
        downloadZip $url ($downloadDir + $_);
        Unzip ($downloadDir + $_) ($extractDir);
    } catch [System.Net.WebException] {
        write-host "<Error> Unable to download from [$url].";
    }
}
