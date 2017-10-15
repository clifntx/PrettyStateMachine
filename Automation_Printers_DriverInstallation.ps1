filter timestamp {"$(Get-Date -UFormat "[ %b%d%Y %H:%M:%S ]"): $_"}

##Requires -RunAsAdministrator
#elevate session
function elevate {
    # Get the ID and security principal of the current user account
    $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
    # Get the security principal for the Administrator role
    $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
    # Check to see if we are currently running "as Administrator"
    if ($myWindowsPrincipal.IsInRole($adminRole))
                           {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
    else
                                                                           {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
   }
 }

function clearDriverStore($dlod) {
    #https://docs.microsoft.com/en-us/windows-hardware/drivers/devtest/pnputil-command-syntax
    foreach ($d in $dlod) {
        pnputil.exe /d 
    }
}

function log($s) {    
    Write-Host ("$s" | timestamp)
    Add-Content .\$log ("$s`n" | timestamp)
}

#initializes logging
function startLogging ($ti) {
    if(!(Test-Path $log)) { New-Item -Name $logp -Type file }
    Write-Host "[ START ] $ti"
    Add-Content .\$log "[ START ]"
    log("Starting log")
}

#closes logging
function endLogging ($timeElapsed) {
    Write-Host "[ END ] Total time elapsed: $timeElapsed ms"
    Add-Content .\$log "[ END ] Total time elapsed: $timeElapsed ms"
}

function isadmin {
 # Returns true/false
   ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
 }

#get list of all driver folders present and compare it to list of paths from csv.
#returns an array of hashes
function getDriverList($pathToCsv, $pathToDriverDir) {
    $driversLod = @()

    $driverDirs = Get-ChildItem $pathToDriverDir
    log("  Located " +$driverDirs.Length+ " driver folders")

    $csv = Import-Csv $pathToCsv
    log("  Imported csv with " +$csv.Length+ " rows")
    foreach ($r in $csv) {
        $driver = $r.driver
        $path = $pathToDriverDir+($r.path).trim()
        if(test-path $path){
            $p = @{"driver" = $driver; "path" = $path}
            try {
                $driversLod = $driversLod + $p
                #log("Added $driver to `$driversLod.")
            } catch {
                log(">> Could not add $driver")
            }
        } else {
            log(">> Could not find $path on local machine.")
        }
        
    }
    log("  Added " +$driversLod.Length+ " drivers to lod")
    #$driversLod | foreach {
    #    Write-Host $_.driver
    #}

    return $driversLod  
}

#get driver certificates from dir and import them into trusted dir
function importPrintDriverCertificates($pathToPrintDriverCertificates) {
    $certificates = Get-ChildItem -Path ($pathToPrintDriverCertificates) -Filter *.cer -Recurse
    foreach ($cert in $certificates) {
        log("  Located " +$certificates.Length+ " certificates.")
        $c = Import-Certificate -FilePath $cert.FullName -CertStoreLocation Cert:\LocalMachine\TrustedPublisher\Certificates
        log("  Imported certificate: '$($c.Subject)'")
    }
}

#add driver to driverstore (and add cert to trusted if necessary)
function addDriversToDriverStore($driverLod) {
    $added = 0
    foreach ($d in $driverLod) {
        $infpath = $d.path
        $pathToPrintDriverCertificates = $infpath.Substring(0, $infpath.LastIndexOf("\")) + "\*.cer"
        if(test-path $infpath) {
            if(test-path $pathToPrintDriverCertificates) {
                importPrintDriverCertificates($pathToPrintDriverCertificates)
            }
            try {
                pnputil.exe -i -a $infpath
                $add ++
                log("    Successfully added " +$d.driver+ " to DriverStore.")
            } catch {
                log(">> FAILED:  Could not add driver " +$d.driver+ " to DriverStore.")
            } 
        } else {
                log(">> FAILED:  Could not locate inf file at " +$infpath)
        }
    }
    log("  Added $added drivers to DriverStore")
    return $added
}

#install printer drivers that are already in DriverStore.
#install certificates that are present
function installPrinterDrivers($driverLod) {
    $installed = 0
    foreach ($d in $driverLod){
        try {
            Add-PrinterDriver $d.driver
            $installed ++
            log("    Successfully installed " +$d.driver+ ".")
        } catch {
            log(">> FAILED:  Could not install driver: " +$d.driver+ ".")
        }
    }
    log("  Installed $installed drivers.")
    return $installed
}

# test: assert that $driversLod.name are all installed
function testForPrinterDriversInstalled($dlod){
    $res = "PASS"
    $installedDrivers = Get-PrinterDriver
    foreach($n in $dlod.name){
        if($installedDrivers.name.contains($n)) {
            log("  Successfully installed $n")
        } else {
            log(">> FAIL: $n is not installed.")
            $res = "FAIL"
        }
    }
    return $res
}

#.....................................................
#: Constants
#.....................................................
$push = "C:\Push\"
$pathToDriverDir = "$push`PrinterDrivers\"
$pathToCsv = "$printDir`printerdrivers.csv"

#.....................................................
#: Execution steps
#.....................................................
$sw = [Diagnostics.Stopwatch]::StartNew()
#initialize logging
$timeInitial = Get-Date -UFormat "%b%d%Y_%H`h%M`m%S`s"
$log = "print_driver_log.txt"
startLogging ($timeInitial)
    
#elevate

#if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

#make driver lod
$driverLod = getDriverList $pathToCsv $pathToDriverDir
#add driver to driverstore (and add cert to trusted if necessary)
addDriversToDriverStore($driverLod)
#install printer drivers that are already in DriverStore
installPrinterDrivers($driverLod)
# test: assert that $driversLod.name are all installed
$test = testForPrinterDriversInstalled($driverLod)
log("Tested successful install: $test")
log("  Install complete")
$timeFinal = Get-Date -UFormat "%b%d%Y_%H`h%M`m%S`s"
$sw.Stop()
endLogging($sw.ElapsedMilliseconds)



#Write-Host -NoNewLine "Press any key to continue..."
#$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")