# clientSetup.ps1
# Should accompolish the following:
# 0. Import config from csv
# 1. move push nd user
# 2. install printers
# 3. join to domain
# 4. install special software
# 5. QA the above

param(
    $configPath= "DEFAULT", #$(throw "No config provided.  Please include the path to a config csv."),
    $pushPath = "C:\Push\",
    $logLevel = -1
    )

function log ($str, $fc="white"){
# fc can be any of these [Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White]
    $fc = $fc.ToLower()
    switch ($fc) {
        "red"      {$priority = 5}
        "yellow"   {$priority = 4}
        "green"    {$priority = 2} 
        "white"    {$priority = 1}
        "gray"     {$priority = 0; $str = "  "+$str;}
        "darkgray" {$priority = -1}
        }
    if ($priority -ge $logLevel) {
        write-host $str -ForegroundColor $fc
        }
    }

function download($driverUrl, $downloadPath) {
    log " Calling download(`n>>> -driverUrl $driverUrl`n>>> -downloadPath $downloadPath`n>>> )" "darkgray"
    try {
        $n = 0
        while(!((Test-Path $downloadPath) -or ($n -gt 10))) {
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($driverUrl, $downloadPath)
            log "...($n) downloading [$driverUrl]" "gray"
            timeout /t ($n*3)
            $n += 1
        }
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
    return (Test-Path $downloadPath)
}

function buildConfig($configPath) {
    log "Calling buildConfig(`n>>> -configPath `"$configPath`"`n>>> )" "darkgray"
    log "...importing csv [$configPath]" "gray"
    $csv = Import-Csv $configPath
    log ">> Imported csv..." "darkgray"
    log $csv "darkgray"
    log "...building config." "gray"
    $config = @{}
    $config['pathToSetupFolder'] = $csv[0].pathToSetupFolder
    $config['pathToPrinterConfig'] = $csv[0].pathToPrinterConfig
    $config['domain'] = $csv[0].domain
    $config['install_these'] = @()
    foreach ($r in $csv) {
        $config.install_these += $r.install_these
        }
    log "...built config with length [$($config.Length)] and keys[$($config.Keys)]" "gray"
    return $config
    }

function TEST_buildConfig($customerId, $configRepoPath, $configPath) {
    log "Calling buildConfig(`n>>> -customerId `"$customerId`n>>> -configRepoPath `"$configRepoPath`"`n>>> -configPath `"$configPath`"`n>>>`n>>> )" "darkgray"
    # check to see if configRepoPath is a url or unc path
    if($configRepoPath.contains("http")){
        #if repo is url, download and unzip
        $repoIsUrl = $true
        if(download $configRepoPath $configPath) {
            $csv = import-csv $configPath
            Remove-Item -Path $configPath
        } else {
            log ">>ERROR: Could not download config from `"$configUrl`"" "red"
            $customerId = "001"
        }
    } else {
        #if repo is unc, path to csv is configRepoPath
        $repoIsUrl = $false
        $csv = $configRepoPath
    }
   
    if($customerId.Length -ne 3){
        $customerId = promptForCustomerId ($csv)
        log "User inputted customer id: $customerId; Len: $($customerId.Length)" "gray"
    } else {
        log "Script provided customer id: $customerId; Len: $($customerId.Length)" "gray"
    }

    if($customerId -eq "001") {
        $config = @{
            "install_these"=$Null;
            "customerId"=$Null;
            "pathToSetupFolder"=$Null;
            "pathToPrinterConfig"=$Null;
            "Domain"=$Null;
        }
        log "...no config provided.  Returning blank config." "white"
    } else {
        $lod = @()
        foreach ($r in $csv) {
            log ">check($($r.customerId) -eq $customerId)" "darkgray"
            if ($r.customerId -eq $customerId) {
                log "...located customerId.  $($r.customerId)" "gray"
                $keys = $r.PSObject.Properties.Name
                $c = @{}
                $keys | foreach {
                $c[$_] = $r[0].($_)
                }
                $lod += $c
            }
        }
        log "...located $($lod.Length) config record(s)." "gray"
        $config = $lod[0]               
        
        log "...returning config." "darkgray"
        log ">{" "darkgray"
        foreach ($k in $keys) {
            log ">   `$config[$k] = $($config[$k])" "darkgray"
        }
        log ">}" "darkgray"
    }

    return $config
}

function runMainScript() {
    log "Calling runMainScript(`n>>> no args`n>>> )" "darkgray"
    ."\\192.168.1.24\technet\Setup_Workstations\main" -logLevel $logLevel
    }

function copyDir($pathToSetupFolder, $localPath) {
    log "Calling copyDir(`n>>> -pathToSetupFolder `"$pathToSetupFolder`"`n>>> -localPath `"$localPath`"`n>>> )" "darkgray"
    log "...copy $pathToSetupFolder folder to $localPath" "gray"
    try {
        copy-item $pathToSetupFolder $localPath -Recurse -Force -ErrorAction Stop
    } catch [System.UnauthorizedAccessException] {
        #log ">> Caught Error: UnauthorizedAccessException" "yellow"
        log "...running in an unelevated session.  Rerun script as admin." "red"
    } catch {
        log ">> Uncaught Error: $($Error[0].Exception.getType().FullName)" "red"
        log ">> ... $($Error[0].Exception)" "red"
        }
    }

function checkThatFolderIsCopied($remotePath, $localPath) {
    log "Calling checkThatFolderIsCopied(`n>>> remotePath=$remotePath`n>>> localPath=$localPath`n>>> )" "darkgray"
    log "...checking that [$pathToSetupFolder] has been copied to [$localPath]" "gray"; 
    $res = $true

    if (test-path $localPath) {
        log "...found [$localPath]" "green";
        dir $remotePath | foreach {
            if (test-path "$localPath\$_") {
                log "......file exists [$localPath\$_]" "green"
            } else {
                log "......file not found[$localPath\$_]" "red"
                $res = $false
                }
            }
    } else {
        log "...did not find [$localPath]" "red";
        
        $res = $false
        }
    return $res
    }

function moveClientDirs($pathToSetupFolder, $pushPath) {
    log "Calling moveClientDirs(`n>>> -pathToSetupFolder `"$pathToSetupFolder`"`n>>> -pushPath `"$pushPath`"`n>>> )" "darkgray"
    $res = $true
    $dirs = @("Push", "Users")

    # preprocessing
    #$path = $pushPath.ToLower().Substring(0,$pushPath.IndexOf("push"))
    $path = "C:\"
    if($pathToSetupFolder[0] -ne "\") {
        $pathToSetupFolder = "\\$pathToSetupFolder"
        }
    
    # copy push and user folder to computer
    foreach ($dir in $dirs) {
        $remotePath = "$pathToSetupFolder$dir"
        $localPath = "C:\$dir"

        if (checkThatFolderIsCopied $remotePath $localPath) {
        #TODO: Need a deeper test to see if dir is complete.
            log "...[$localPath] already exists.  Skipping." "gray"
        } else {
            $n = 0
            while(!(checkThatFolderIsCopied $remotePath $localPath) -and $n -le 5) {
                $n += 1
                log "...$n attempt to copy [$pathToSetupFolder\$dir] to [$path\$dir]" "gray"
                copyDir "$pathToSetupFolder\$dir" "$path"
                }
            }
        }
    

    # No really, move the Users folder
    log "...no really, copy the Users folder: [$($pathToSetupFolder+"Users")] > [$($path+"Users")]" "gray"
    copyDir $($pathToSetupFolder+"Users") $($path+"Users")
    
    # verify that move was successful
    foreach ($dir in $dirs) {
        if (!(test-path "$pathToSetupDir\$dir")) {
            $res = $false
            }
        }

    return $res    
    } 

function installPrinters($pathToPrinterConfig) {
    log "Calling installPrinters(`n>>> pathToPrinterConfig=$pathToPrinterConfig`n>>> )" "darkgray"
    log "...opening a window for installing printers" "gray"
    log "Calling {Start-Process PowerShell.exe -ArgumentList "-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1 -printerCsv $pathToPrinterConfig -logLevel $logLevel" -Verb RunAs}" "yellow"
    & {Start-Process PowerShell.exe -ArgumentList "-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1 -printerCsv $pathToPrinterConfig -logLevel $logLevel" -Verb RunAs}
    #PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1 -printerCsv \\192.168.1.24\technet\Setup_Workstations\Setup_MPA_Workstation\push\printerDrivers\config_Printers_MPA.csv' -Verb RunAs}"
    }

function joinToDomain($domain) {
    log "Calling joinToDomain(`n>>> domain=$domain`n>>> )" "darkgray"

    log "!! TODO: Write function to join to domain [$domain]" "red"
    }

function installClientSoftware($install_these) {
    log "Calling installClientSoftware(`n>>> install_these=$install_these`n>>> )" "darkgray"

    log "!! TODO: Write function to install list of software: $install_these" "red"
    }

function installNableAgent($customerId) {
    log "Calling installNableAgent(`n>>> customerId=$customerId`n>>> )" "darkgray"
    #download agent installer
    $serverAddress = "central.allaccess365.com"
    log "...serveraddress=$serverAddress" "gray"
    $driverUrl = "https://central.allaccess365.com/dms/FileDownload?customerID=$customerId&softwareID=101"
    $downloadPath = "C:\push\install_these\WindowsAgentSetup_$customerId.exe"
    #install agent
    #WindowsAgentSetup.exe /s /v" /qn CUSTOMERID=$customerId SERVERADDRESS=$serverAddress CUSTOMERSPECIFIC=1 SERVERPROTOCOL=HTTPS SERVERPORT=443 "
    #$args = "/s /v`" /qn CUSTOMERID=$customerId SERVERADDRESS=$serverAddress CUSTOMERSPECIFIC=1 SERVERPROTOCOL=HTTPS SERVERPORT=443`""
    if ($dl = download $driverUrl $downloadPath) {
        log "...agent installer downloaded.  Installing." "gray"
        $command = "'$downloadPath /s /v' /qn;"
        #$command = "'WindowsAgentSetup.exe /s /v' /qn CUSTOMERID=$customerId SERVERADDRESS=$serverAddress CUSTOMERSPECIFIC=1 SERVERPROTOCOL=HTTPS SERVERPORT=443;"
        log "...running [{ $command }]." "gray"
        $scriptBlock = [Scriptblock]::Create($command)
        $call = Invoke-Command -ScriptBlock $scriptBlock
        log "      > $call" "darkgray" 
    }
}

function turnOnBitlocker {
    log "Calling turnOnBitlocker(`n>>> no args`n>>> )" "darkgray"
    & {control /name Microsoft.BitLockerDriveEncryption}
    }

function clientQA($config, $scriptPath) {
    log "Calling clientQA(`n>>> config=$config`n>>> scriptPath=$scriptPath`n>>> )" "darkgray"
    log "...opening a window for QA" "gray"
    $fileName = "$scriptPath\QAStandardSetup.ps1"
    $logLevel = $script:logLevel
    log "fileName=$fileName"
    log "Calling {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File $fileName -logLevel 1' -Verb RunAs}" "yellow"
    & {Start-Process PowerShell.exe -ArgumentList "-ExecutionPolicy Bypass -File $fileName -logLevel $logLevel" -Verb RunAs}
    #PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1 -printerCsv \\192.168.1.24\technet\Setup_Workstations\Setup_MPA_Workstation\push\printerDrivers\config_Printers_MPA.csv' -Verb RunAs}"
    }

function main ($configPath, $pushPath, $scriptPath) {
    log "Calling main(`n>>> configPath=$configPath`n>>> )" "darkgray"
    # -1. Run main script
    #runMainScript
    # 0. Import config from csv
    $c = buildConfig $configPath 
    # 1. move push nd user
    moveClientDirs $c.pathToSetupFolder $pushPath
    # 2. Install Nable agent
    installNableAgent $c.customerId
    # 3. join to domain
    joinToDomain $c.domain
    # 4. install special software
    installClientSoftware $c.install_these
    # 5. Turn on Bitlocker (must be done after secure boot is enabled)
    turnOnBitlocker
    # 6. install printers
    installPrinters $c.pathToPrinterConfig
    # 7. QA the above
    clientQA $c $scriptPath
    }

clear
# CONSTANTS
$PUSH_PATH = "C:\Push";
$SCRIPT_PATH = "\\192.168.1.24\technet\Scripts\wksSetups"
$UNIPUSH_PATH = "\\192.168.1.24\technet\Setup_Workstations\UniversalPushFolder\Push";

#main $configPath $pushPath $SCRIPT_PATH
#$c = buildConfig $configPath
#clientQA $c $SCRIPT_PATH

installNableAgent "121"

# TODO: Modify config to pull all configs from a single spreadsheet.  
#    Will require a method like...
#  function getConfig ($pathToConfigCsv) {
#    $csv = import-csv config.csv; 
#    $config = $csv.CustomerId | $customerId;
#    return $config
#    }

pause