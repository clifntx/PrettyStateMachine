. .\logger.ps1

#.....................................................
#: Constants
#.....................................................
$log = "print_driver_log.txt"
$pathToInf = ""
$nameOfDriver = ""
$printerIP = ""
$basePushPath = "C:\Push\"
$printDir = "Printers\"
$baseUrl = "https://s3.amazonaws.com/aait/"
$driverCsv = "printerdrivers.csv"
#.....................................................
#: Execution steps
#.....................................................


#initialize logging
sw$ = startLogging

#get printer information (printer location, driver, infpath)

function download-bigfile($inurl, $outpath) {
	Write-Host "inurl: $inurl"
	Write-Host "outpath: $outpath"
	$WebClient = New-Object System.Net.WebClient
	Write-Host "established web client: $WebClient"
	$WebClient.DownloadFile($inurl,$outpath)
	"Downloaded large file from $inurl to $outpath" | timestamp >> $log
}

function getPrinterCsv {
    $pdir = ($basePushPath + $printDir)
    if (!(Test-Path $pdir)) {
        New-Item -Path $pdir -ItemType directory
    }
    download-bigfile ($baseUrl + $driverCsv) ($pdir + $driverCsv)
    $csv = Import-Csv ($pdir + $driverCsv)
    return $csv
}

function downloadDriver($driverName) {
    try {
        $csv = getPrinterCsv

        download-bigfile($baseUrl + $driverUrl)
        log("    >> Successfully downloaded " +$driverName+ " .")
    } catch {
        log("    >> FAIL: Failed to download " +$driverName+ " .")
    }
    return (Test-Path $infPath)
}

function addToDriverStore($infPath){
    #check infpath
    if(!(Test-Path $infPath)) {
        downloadDriver($driverName)
    }
    #add driver to store
    try {
        $pnpOutput = pnputil.exe -i -a $infpath | Select-String "Published Name"
        log("    Successfully added " +$pnpOutput+ " to DriverStore.")
        return $true
    } catch {
        log(">> FAILED:  Could not add driver " +$pnpOutput+ " to DriverStore.")
        return $false
    } 
}

function installDriver($nameOfDriver) {
    try {
        if (!((Get-PrinterDriver).Name.contains($nameOfDriver))) {
            addToDriverStore($pathToInf) # how to check driver store?
            Add-PrinterDriver -Name $nameOfDriver
            log("    Successfully installed " +$nameOfDriver+ " driver.")
        }
        log("    " +$nameOfDriver+ " driver already installed.")
    } catch {
        log("    >> FAIL: Failed to install " +$nameOfDriver+ " driver.")
    }
    return ((Get-PrinterDriver).Name.contains($nameOfDriver))
}





    #   Check for infpath:
    #     infpath present:
    #       continue
    #     infpath not present:
    #       download and extract driver
    #       check again
    #     add driver to driver store  
    # driver installed:
    #   continue   
    #install printer

#

#add driver to driverstore (and add cert to trusted if necessary)
addDriversToDriverStore($driverLod)
#install printer drivers that are already in DriverStore
installPrinterDrivers($driverLod)
# test: assert that $driversLod.name are all installed


test($driverLod)

log("  Install complete")
endLogging($sw)
