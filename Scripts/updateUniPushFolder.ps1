
$url = "https://s3.amazonaws.com/aait/common_drivers.zip"
$destpath = "c:\push\tempZip.zip"
$lanpath = "D:\PrinterDrivers\common_drivers.zip"
$log = "c:\push\update_log.txt"

filter timestamp {"$(Get-Date -Format G): $_"}

function download-smallfile($inurl, $outpath) {
	Invoke-WebRequest -Uri $inurl -OutFile $outpath
	"Downloaded small file from $inurl to $outpath" | timestamp >> $log
}

function download-bigfile($inurl, $outpath) {
	Write-Host "inurl: $inurl"
	Write-Host "outpath: $outpath"
	$WebClient = New-Object System.Net.WebClient
	Write-Host "established web client: $WebClient"
	$WebClient.DownloadFile($inurl,$outpath)
	"Downloaded large file from $inurl to $outpath" | timestamp >> $log
}

if (!(Test-Path "c:\push\Toshiba\")) {
	if(Test-Path $lanpath) { 
		Copy-Item -Source $lanpath -Destination $destpath;
		"Copied file from $lanpath to $destpath"| timestamp >> $log
	} else { 
		download-bigfile $url $destpath
	} 
}