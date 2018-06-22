function log($str){
    $dir = ((($logPath.Split("\"))[0..($logPath.Split("\").Length-2)]) -join "\");
    if(!(test-path $dir)){ 
        mkdir $dir;
        }
    $str | Out-File $logPath -Append;
    }

function downloadFile ($driverUrl, $downloadPath, $start_time) {
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($driverUrl, $downloadPath)
    Write-Output "...Time taken for download: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}

clear

#set vars
$installerUrl = "https://s3.amazonaws.com/aait/Teams_windows_x64.exe"
$downloadPath = "c:\push\install_these\Teams_windows_x64.exe"

$start_time = Get-Date

#install driver
if (Test-Path $downloadPath) {
    Write-Host "Teams installer [$downloadPath] already exists.  Doing nothing.";
} else {
    Write-Host "Teams installer [$downloadPath] does not exist.  Downloading and installing...";    
    downloadFile $installerUrl $downloadPath $start_time;
}
#install Teams
& $downloadPath -s
Write-Output "...Time taken for Teams install: $((Get-Date).Subtract($start_time).Seconds) second(s)"