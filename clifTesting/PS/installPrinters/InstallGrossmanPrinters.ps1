#param must be the first statement in your script
param(
    [array]$printers,
    [int]$logLevel = 2,
    [string]$pushRoot = "c:\push\",
    [array]$DRIVER_URL_MAP = @(
        @{"driver"="TOSHIBA Universal Printer 2"; "path"="C:\Push\Toshiba\64bit\eSf6u.inf"; "url" = "https://s3.amazonaws.com/aait/Toshiba_64bit.zip"},
        @{"driver"="Xerox Global Print Driver PCL6"; "path"="C:\Push\Toshiba\64bit\eSf6u.inf"; "url" = "https://s3.amazonaws.com/aait/Xerox.zip"},
        @{"driver"="KX DRIVER for Universal Printing"; "path"="C:\Push\Kyocera\KXPrintDriverv7.3.1207\64bit\oemsetup.inf"; "url" = "https://s3.amazonaws.com/aait/KXPrintDriverv7.3.1207.zip"},
        @{"driver"="HP Universal Printing PCL 6"; "path"="C:\Push\HP\HPUniversalPCL6\hpcu215u.inf"; "url" = "https://s3.amazonaws.com/aait/HP.zip"},
        @{"driver"="PCL6 V4 Driver for Universal Print"; "path"="C:\push\Savin\SavinUniversal\disk1\r4600.inf"; "url" = "https://s3.amazonaws.com/aait/Savin.zip"},
        @{"driver"=""; "path"=""; "url" = ""}
        )
    )

$printers = @(
    @{"location"="Upstairs Copier"; "driverName"="PCL6 V4 Driver for Universal Print"; "ip"="10.0.0.99"; "color"="Color"},
    @{"location"="Upstairs Copier"; "driverName"="PCL6 V4 Driver for Universal Print"; "ip"="10.0.0.99"; "color"="BW"},
    @{"location"="Downstairs Copier"; "driverName"="PCL6 V4 Driver for Universal Print"; "ip"="10.0.0.25"; "color"="Color"},
    @{"location"="Downstairs Copier"; "driverName"="PCL6 V4 Driver for Universal Print"; "ip"="10.0.0.25"; "color"="BW"},
    @{"location"="HP Laserjet 4350"; "driverName"="HP Universal Printing PCL 6"; "ip"="10.0.0.19"; "color"="Color"},
    @{"location"="TESTTOSH"; "driverName"="TOSHIBA Universal Printer 2"; "ip"="10.10.10.10"; "color"="Color"}
    )

function log ($str, $fc="white"){
# fc can be any of these [Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White]
    $fc = $fc.ToLower()
    switch ($fc) {
        "red"      {$priority = 5}
        "yellow"   {$priority = 4}
        "green"    {$priority = 2} 
        "white"    {$priority = 1}
        "gray"     {$priority = 0}
        "darkgray" {$priority = -1}
        }
    if ($priority -ge $logLevel) {
        write-host $str -ForegroundColor $fc
        }
    }

function getDriverInfo($driverName, $driverUrlMap) {
    log "Calling getDriverInfo(`n>>> -driverName $driverName`n>>> -driverUrlMap $driverUrlMap`n>>> )" "darkgray"
    $driver = @{}
    log "...Evaluating [$($driverName)]" "Gray"
    foreach ($d in $driverUrlMap) {
        if ($d.driver -eq $driverName) {
            $driver = $d
            }
        }
    if (($driver.driver).length -gt 0) { 
            log "...Located [$driverName == $($driver.driver)] in driverUrlMap." "Gray"
            return $driver
        } else {
            log "...Failed to locate [$driverName] in driverUrlMap." "Red"
            return $false
            }
}

function downloadZip($driverUrl, $downloadPath) {
    log " Calling downloadZip(`n>>> -driverUrl $driverUrl`n>>> -downloadPath $downloadPath`n>>> )" "darkgray"
    $wc = New-Object System.Net.WebClient
    try {
        $wc.DownloadFile($driverUrl, $downloadPath)
    } catch [System.Management.Automation.MethodInvocationException] {
        log ">> CAUGHT ERROR: <MethodInvocationException> Cannot access url [$driverUrl] ..." "Yellow"
        log ">> CAUGHT ERROR: $PSItem" "Yellow"
        return $false
    } catch {
        log "E!"
        log ">> UNCAUGHT ERROR: $PSItem" "red"
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
        return $false
        }
    return $true
}

function Unzip ($downloadPath, $extractPath) {
    log "Calling Unzip(`n>>> -downloadPath $downloadPath`n>>> -extractPath $extractPath`n>>> )" "darkgray"
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem;
        [System.IO.Compression.ZipFile]::ExtractToDirectory($downloadPath, $extractPath);
    } catch [System.Management.Automation.MethodInvocationException] {
        log ">> CAUGHT ERROR: <MethodInvocationException> Cannot locate path [$downloadPath] ..." "Yellow"
        log ">> CAUGHT ERROR: $PSItem" "Yellow"
        return $false
    } catch {
        log "E!"
        log ">> UNCAUGHT ERROR: $PSItem" "red"
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
        return $false
        }
    return $true
}

function isPrinterInstalled($name, $ip, $driver) {
    log "Calling isPrinterInstalled(`n>>> -name $name`n>>> -ip $ip`n>>> -driver $driver`n>>> )" "darkgray"
    $port = "IP_" + $ip;
    Get-Printer | foreach {
        if (($_.Name -eq $name) -and ($_.PortName -eq $port) -and ($_.DriverName -eq $driver)) { 
            $res = $true;
        } else {
            $res = $false;
            }
        }
    if ($res) {
        log "...Found printer [$name -and $port -and $driver]." "White"
    } else {
        log "...Did not find printer [$name -and $port -and $driver]." "Gray"
    }
    return $res
}

function waitForPrinterInstallToComplete($printerName) {
    log "Calling waitForPrinterInstallToComplete(`n>>> -printerName $printerName`n>>> )" "darkgray"
    $count = 0
    $chances = 12
    log "...Waiting for install of [$printerName]" "Gray"
    Do {
        try{
            log "..." "Gray"
            if (((get-printer $printerName -ErrorAction Stop).Name).Length -gt 0) {
                log "...[$printerName] successfully installed."
                return $true
            }
        } catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] {
            log "...Printer not found.  Continuing to wait..." "gray"
        } catch {
            log ">> UNCAUGHT ERROR: $PSItem" "red"
            log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
        } finally {
            Start-Sleep -Seconds 5
            $count += 1
            }
        } While ($count -lt $chances) {
            log "...Timed out after $($count*$chances) seconds.  Failed to install [$printerName]." "Red"
        }
    return $false
    }

function installPrinter($name, $loc, $ip, $driver, $driverPath) {
    log "Calling installPrinter(`n>>> -name $name`n>>> -loc $loc`n>>> -ip $ip`n>>> -driver $driver`n>>> -driverPath $driverPath`n>>> )" "darkgray"
    
    $port = "IP_" + $ip    
    log "...Creating port [$port] at ip [$ip]." "Gray"
    cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r $port -h $ip -o raw -n 9100

    try {
        log "...Installing printer [$name] with driver [$driver]" "gray"
        log "...from inf file [$driverPath]." "gray"
        rundll32 printui.dll,PrintUIEntry /if /b $name /f $driverPath /r $port /m $driver /Z
    } catch [System.Management.Automation.MethodInvocationException] {
        log ">> CAUGHT ERROR: Could not install [$driver] from: [$driverPath]" "red"
    } catch {
        log ">> UNCAUGHT ERROR: $PSItem" "red"
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
    }
    return $true
    }

function waitForPrinterRemovalToComplete($printerName) {
    log "Calling waitForPrinterRemovalToComplete(`n>>> -printerName $printerName`n>>> )" "darkgray"
    $count = 0
    $chances = 12
    log "...Waiting for removal of [$printerName]" "Gray"
    While ($count -lt $chances) {
        try{
            ((get-printer $printerName -ErrorAction Stop).Name).Length -gt 0

            log "..." "Gray"
            if ((((get-printer $printerName -ErrorAction Stop).Name).Length -gt 0)) {
                log "...Printer still exists.  Continuing to wait..." "gray"    
            } else {
                log "...[$printerName] successfully removed."
                return $true
            }
            Start-Sleep -Seconds 5
        } catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] {
            log "...Printer not found.  Continuing..." "gray"
            return $true
        } catch {
            log ">> UNCAUGHT ERROR: $PSItem" "red"
            log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
        } finally {
            $count += 1
            }
        }
    log "...Timed out after $($count*$chances) seconds.  Failed to remove [$printerName]." "Red"
    return $false
    }

function removePrinter($name) {
    log "Calling removePrinter(`n>>> -name `"$name`"`n>>> )" "darkgray"
    try {
        log "...removing printer [$name]" "gray"
        if ($name.Length -gt 0) {
            rundll32 printui.dll,PrintUIEntry /dl /n $name /q
            remove-printer -Name "$name*" -ErrorAction Stop
        } else {
            log ">> ERROR: `$name arg is blank.  [$name]" "red"
            return $false
        }
    } catch [Microsoft.PowerShell.Cmdletization.Cim.CimJobException] {
        log "...no printer matching name [$name*].  Continuing..." "gray"
        return $true
    } catch {
        log ">> UNCAUGHT ERROR: $PSItem" "red"
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
    }
    if(waitForPrinterRemovalToComplete $name) {
        return $true
    } else {
        return $false
        }
    }

function setPrinterColor($printerName, $color) {
    log "Calling setPrinterColor(`n>>> -printerName $printerName`n>>> -color $color`n>>> )" "darkgray"
    if ($color -eq "Color") {
        $b = $true
    } elseif ($color -eq "BW") {
        $b = $false
    } else {
        log "[ERROR: Invalid color input [$color] for printer $printerName]" "Red"
        }
    try {
        Set-PrintConfiguration -PrinterName $printerName -Color $b -ErrorAction Stop
        log "...Set `"$printerName`" to [$color]" "Gray"
    } catch [Microsoft.Management.Infrastructure.CimException] {
        log ">> CAUGHT ERROR: <CimException> Failed to configure printer color settings..." "Yellow"
        return $false
    } catch {
        log ">> UNCAUGHT ERROR: $PSItem" "red"
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
        return $false
        }
    return $true
    }

function downloadAndInstallPrinter($driverUrl, $downloadPath, $extractPath, $printerName, $printer, $driverPath) {
    log "Calling downloadAndInstallPrinter( `n>>> -driverUrl $driverUrl`n>>> -downloadPath $downloadPath`n>>> -extractPath $extractPath`n>>> -printerName $printerName`n>>> -printer $printer`n>>> -driverPath $driverPath`n>>> )" "darkgray"
    #install driver
    if (Test-Path $driverPath) {
        log "...Path [$driverPath] already exists.  Doing nothing." "gray"
    } else {
        log "...Path [$driverPath] does not exist.  Downloading and installing..." "gray"
        if (!(downloadZip $driverUrl $downloadPath)){
            log ">> FAIL: Could not download [$driverUrl]" "red"
            return $false
            }
        log "...Time taken for download: $((Get-Date).Subtract($start_time).Seconds) second(s)" "Gray"
        if(!(Unzip $downloadPath $extractPath)) {
            log ">> FAIL: Could not extract [$downloadPath]" "red"
            return $false
            }
        log "...Time taken for extraction: $((Get-Date).Subtract($start_time).Seconds) second(s)" "Gray"
        }
    #install printer
    if (isPrinterInstalled -name $printerName -ip $printer.ip -driver $printer.driverName) {
        log "...Printer already installed [$printer.location].  Doing nothing." "gray"
    } else {
        log "...Removing any duplicate printers of name [$printerName]" "gray"
        if (!(removePrinter($printerName))){
            log ">> WARNING: Could not remove duplicate printer [$printerName]" "yellow"
        }
        if (!(installPrinter $printerName $printer.location $printer.ip $printer.driverName $driverPath)){
            log ">> FAIL: Could not install printer [$printerName]" "red"
            return $false
            }
        waitForPrinterInstallToComplete $printerName
        log "...Setting printer [$printerName] color settings to [$($p.color)]" "Gray"
        if (!(setPrinterColor $printerName $p.color)) {
            log ">> FAIL: Could not configure printer color settings for [$printerName]." "red"
            return $false
            }
        }
    return $true
}

function main($pushRoot, $printers) {
    $start_time = Get-Date
    log "Calling main(`n>>> -start_time $start_time`n>>> -pushRoot $pushRoot`n>>> -printer $printers`n>>> )" "darkgray"
    log "Starting [$(Get-Date)]" "white"
    $printerInstalledTally = 0
    $n = 1
    $downloadPath = "$pushRoot\printerTemp.zip"
    $extractPath = $pushRoot
    foreach ($p in $printers) {
        $printerName = "$($p.location) ($($p.color)) - $($p.driverName)" 
        log "($n) Installing printer [$printerName]" "white"
        $driver = (getDriverInfo $($p.driverName) $DRIVER_URL_MAP)
        if ($driver) {
            $res = downloadAndInstallPrinter -driverUrl $driver.url -downloadPath $downloadPath -extractPath $extractPath -printerName $printerName -printer $p -driverPath $driver.path
        } else {          
            $res = $false
        }
        if($res){
            $rcolor = "white"
            $printerInstalledTally += 1
        } else {
            $rcolor = "Red"
            }
        log "...Is [ $($p.location) ($($p.color)) - $($p.driverName) ] installed?: $res" $rcolor
        log "...Time taken for printer install [$($printer.location)]: $((Get-Date).Subtract($start_time).Seconds) second(s)" "gray"
        $n +=1
        }
    log "Stopping [$(Get-Date)]" "white"
    log "---------------------------------------------------------" "Gray"
    log "|"
    log "|   Successfully installed $printerInstalledTally of $($printers.Length) printers" "Green"
    log "|"
    log "---------------------------------------------------------" "Gray"
    log ""
    $gp = get-printer
    log "[Total Installed Printers]:  [$($gp.Length)]" "Green"
    $n = 1
    $gp.Name | foreach {
        log "($n) $_" "Green"
        $n+=1
        }
    }

clear
main $pushRoot $printers
