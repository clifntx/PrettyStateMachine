# clientSetup.ps1
# Should accompolish the following:
# 0. Import config from csv
# 1. move push nd user
# 2. install printers
# 3. join to domain
# 4. install special software
# 5. QA the above

param(
    [string]$customerId= "",
    $configPath= "DEFAULT", #$(throw "No config provided.  Please include the path to a config csv."),
    $pushPath = "C:\Push\",
    $logLevel = 1
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

function buildPrinterLod($customerId, $configUrl, $configPath, $public="1") {
    log "Calling convertCsvToLod(`n>>> -customerId `"$customerId`n>>> -configUrl `"$configUrl`"`n>>> -configPath `"$configPath`"`n>>> -public `"$public`"`n>>> )" "darkgray"
    if(download $configUrl $configPath) {
            $pmap = @{
                "public"     = "Public";
                "location"   = "location";
                "driverName" = "driver";
                "ip"         = "ip";
                "driverPath" = "driverPath";
                "color"      = "BW or Color"
            }
            $csv = import-csv $configPath
            $temp = $csv | where {$_.GroupId -eq $customerId -and $_.Public -eq $public}

            $lod = @()
            foreach ($r in $csv) {
                if (($r.GroupId -eq $customerId) -and ($r.Public -eq $public)) {
                    $lod += $r
                }
            }
            log "...located $($lod.Length) printer record(s)." "gray"

            $printerLod = @()
            foreach ($d in $lod){
                    $p = @{}
                    $pmap.keys | foreach {
                        $p[$_] = $d.($pmap[$_])
                    }
                    $printerLod += $p
                    log "      + adding printer [$($printerLod.Length)] to lod: $p" "darkgray"
            }
    } else {
        log ">>ERROR: Could not download printer config from `"$url`"" "red"
    }
    Remove-Item -Path $configPath
    log "...returning lod with $($printerLod.Length) printer(s)." "gray"

    return $printerLod
}

function validateCustomerId ($id, $idList) {
    log "Calling validateCustomerId(`n>>> `$id=`"$id`"`n>>> )" "darkgray"
    #switch ($id) {
    #    ($id.Length -ne 3) {$res=$false}
    #    ($id.getType().Name -ne "String") {$res=$false}
    #    default {$res = $true}
    #}
    $res = $idList.contains($id)

    log "...validateCustomerId() returning $res for `$id:$id" "gray"
    return $res
}
function promptForCustomerId($idList) {
    log "Calling promptForCustomerId(`n>>> no args`n>>> )" "darkgray"    
    $n = 0
    $id = ""
    $msg = "Please enter a valid customer id number..."
    $idList | foreach {
        log "$($_.customerId) : $($_.customerAbbreviation) : $($_.account)" "white"
    }
    while ($true) {
        log "...id not validated. id=$id" "gray"
        log $msg "White"
        $id = ([string](Read-Host -Prompt "Customer Id")).trim()
        $n += 1
        if(validateCustomerId $id $idList.customerId) {
            log "...received valid user input.  Returning id: $id" "gray"
            break
        }
        if ($n -gt 3){
            $id = "001"
            log "...failed to receive valid user input.  Returning id: $id" "gray"
            break
        }
    }
    return $id
}

function buildConfig($customerId, $configUrl, $configPath) {
    log "Calling buildConfig(`n>>> -customerId `"$customerId`n>>> -configUrl `"$configUrl`"`n>>> -configPath `"$configPath`"`n>>>`n>>> )" "darkgray"
    if(download $configUrl $configPath) {
        $csv = import-csv $configPath
        Remove-Item -Path $configPath
    } else {
        log ">>ERROR: Could not download config from `"$configUrl`"" "red"
        $customerId = "001"
    }
    
    if($customerId.Length -lt 3){
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

    if($pathToSetupFolder.Length -lt 5){
        log ">> ERROR: `$pathToSetupFolder too short.  `$pathToSetupFolder=`"$pathToSetupFolder`"" "red"
    }   
    if($pathToSetupFolder[-1] -ne "\"){
       $pathToSetupFolder = "$pathToSetupFolder\"
    }
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
    log "...no really, copy the public desktop folder: [$($pathToSetupFolder + "Users\Public\Desktop\*")] > [C:\Users\Public\Desktop]" "gray"
    copy-item ($pathToSetupFolder + "Users\Public\Desktop\*") ("C:\Users\Public\Desktop") -Recurse -Force

    # verify that move was successful
    foreach ($dir in $dirs) {
        if (!(test-path "$pathToSetupDir\$dir")) {
            $res = $false
            }
        }

    return $res    
    } 

function installPrinters($customerId) {
    log "Calling installPrinters(`n>>> customerId=$customerId`n>>> )" "darkgray"
    log "...opening a window for installing printers" "gray"
    $call = "-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1 -customerId $customerId -logLevel $logLevel"
    log "Calling {Start-Process PowerShell.exe -ArgumentList `"$call`" -Verb RunAs}" "white"
    & {Start-Process PowerShell.exe -ArgumentList $call -Verb RunAs}
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
        $command = "$downloadPath /paasive /norestart;"
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
    
    log "TODO:" "yellow"
    log "#Enablabe BitLocker" "yellow"
    log "Enable-BitLocker" "yellow"
    log "#Save bitlocker keys to NAS;" "yellow"
    log "`$keys = (get-bitlockervolume).KeyProtector" "yellow"
    log "#Save bitlocker keys to ITGlue" "yellow"
    }

function clientQA($config, $scriptPath) {
    log "Calling clientQA(`n>>> config=$config`n>>> scriptPath=$scriptPath`n>>> )" "darkgray"
    log "...opening a window for QA" "gray"
    $fileName = "$scriptPath\QAStandardSetup.ps1"
    $logLevel = $script:logLevel
    log "fileName=$fileName"
    $call = "-ExecutionPolicy Bypass -File $fileName -customerId $($c.customerId) -logLevel 1"
    log "Calling {Start-Process PowerShell.exe -ArgumentList '$call' -Verb RunAs}" "yellow"
    & {Start-Process PowerShell.exe -ArgumentList $call -Verb RunAs}
    #& {Start-Process PowerShell.exe -ArgumentList "-ExecutionPolicy Bypass -File $fileName -logLevel 1" -Verb RunAs}
   }

function main ($customerId, $configUrl, $configPath, $pushPath, $scriptPath) {
    log "Calling main(`n>>> customerId=$customerId`n>>> configUrl=$configUrl`n>>> configPath=$configPath`n>>> pushPath=$pushPath`n>>> scriptPath=$scriptPath`n>>> )" "darkgray"
    # -1. Run main script
    #runMainScript
    # 0. Import config from csv
    #$c = buildConfig $configPath 
    $c = buildConfig $customerId $configUrl $configPath
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
    installPrinters $c.customerId
    # 7. QA the above
    timeout /t 30
    clientQA $c $scriptPath
    }

clear
# CONSTANTS
$CONFIG_SETUPCLIENT_URL = "https://s3.amazonaws.com/aait/config_setupClient.csv"
$CONFIG_SETUPCLIENT_PATH = "c:\push\config_setupClient.csv"
$PUSH_PATH = "C:\Push";
$SCRIPT_PATH = "\\192.168.1.24\technet\Scripts\wksSetups"
$UNIPUSH_PATH = "\\192.168.1.24\technet\Setup_Workstations\UniversalPushFolder\Push";

main $customerId $CONFIG_SETUPCLIENT_URL $CONFIG_SETUPCLIENT_PATH $pushPath $SCRIPT_PATH
#$c = buildConfig $configPath
#clientQA $c $SCRIPT_PATH

# TODO: Modify config to pull all configs from a single spreadsheet.  
#    Will require a method like...
#  function getConfig ($pathToConfigCsv) {
#    $csv = import-csv config.csv; 
#    $config = $csv.CustomerId | $customerId;
#    return $config
#    }

pause