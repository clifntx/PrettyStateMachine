# Main powershell script to run automation
param(
    [int]$logLevel = -1
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
function changeScriptingPolicy($pol="restricted") {
    log "Calling changeScriptingPolicy(`n>>> pol=$pol`n>>> )" "darkgray"
    try {            
        #Set-ExecutionPolicy $pol
        if ($pol -eq "unrestricted") {  
            Set-ExecutionPolicy unrestricted
        } else {
            Set-ExecutionPolicy restricted
            }
        $epol = Get-ExecutionPolicy
        log "...set execution policy to [$epol]"      
    } catch [UnauthorizedAccessException] {
        #log ">> Caught Error: UnauthorizedAccessException" "yellow"
        log "...running in an unelevated session.  Rerun script as admin." "red"
    } catch {
        log ">> Uncaught Error: $($Error[0].Exception.getType().FullName)" "red"
        log ">> ... $($Error[0].Exception)" "red"
        }
}
function checkForSecureBoot {
    log "Calling keysAreCorrect(`n>>> no args`n>>> )" "darkgray"    
    log "...checking for secure boot"
    try { 
        if(Get-SecureBootPolicy) {
            log "...secure boot enabled." "gray"
            return $true; 
        } else {
            log "...secure boot not enabled." "red"            
            return $false
            }
    } catch { 
        log "...secure boot not enabled." "red"                    
        return $false; }
    }
function checkBitLockerStatus {
    log "Calling checkBitLockerStatus(`n>>> no args`n>>> )" "darkgray"    
        $statuses = Get-BitLockerVolume
        foreach ($s in $statuses) {
            switch($s.VolumeStatus) {
                "FullyDecrypted" {$c = "red"; $res = $false; }
                "FullyEncrypted" {$c = "green"; $res = $true; }
                }
            log "Volume [$($_.MountPoint)] encryption status: [$($_.ProtectionStatus)] $($_.VolumeStatus)" $c
            }
        return $res
    }
function setBitLockerStatus ($newStatus) {
    switch($newStatus) {
        $true {Enable-Bitlocker}
        $false {Disable-Bitlocker}
        default {throw (">>ERROR: Please enter a valid boolean value.  To turn on encryption: setBitLockerStatus `$true")}
        }
    if (checkBitLockerStatus -eq $newStatus) {
        log "...sucessfully updated BitLocker status to [$newStatus]." "gray"
    } else {
        log "...failed to update BitLocker status to [$newStatus]." "red"
        }
    }
function activateWindows ($key=""){
    log "Calling activateWindows(`n>>> key=$key`n>>> )" "darkgray"        
    $KMSservice = Get-WMIObject -query "select * from SoftwareLicensingService"
    if($key.Length -lt 1) {
        $key = $KMSservice.OA3xOriginalProductKey
        log "...reset key from board: `"$key`""
        }
    try {
        $ref = $KMSservice.InstallProductKey($key)
        $ref = $KMSservice.RefreshLicenseStatus()
    } catch [System.Management.Automation.RuntimeException] {
        #log ">> Caught Error: System.Management.Automation.RuntimeException" "yellow"
        log "...no key found (key: `"$key`").  Cannot activate Windows." "red"
    } catch {
        log ">> Uncaught Error: $($Error[0].Exception.getType().FullName)" "red"
        log ">> ... $($Error[0].Exception)" "red"
        }
    }
function copyUniDirToPushDir($uniPushPath, $pushPath) {
# copy the push folder from the NAS 
    log "Calling keysAreCorrect(`n>>> uniPushPath=$uniPushPath`n>>> pushPath=$pushPath`n>>> )" "darkgray"            
    log "Copying universal push folder..." "white"
    dir $uniPushPath | foreach { 
        copyFolderFromUniPush $uniPushPath $pushPath $_
        }
    $specialChecks = @("$pushPath\install_these")
    foreach ($dirToCheck in $specialChecks) {    
        if (checkThatFolderIsCopied $dirToCheck) {
            og "...found [$folderPath]" "green";        } else {
            log "...did not find dir [$dirToCheck] in [$pushPath]. Retrying." "yellow"; 
            copy-item $dirToCheck $pushPath -recurse -force; 
            }  
        }
    } 

function copyFolderFromUniPush($uniPushPath, $pushPath, $folderPath) {
    log "Calling copyFolderFromUniPush(`n>>> uniPushPath=$uniPushPath`n>>> pushPath=$pushPath`n>>> folderPath=$folderPath>>> )" "darkgray"
    log "...copying [$uniPushPath\$folderPath] to [$pushPath]" "gray";     
    copy-item "$uniPushPath\$folderPath" $pushPath -recurse -force;
    }
    
function checkThatFolderIsCopied($pushPath, $folderPath) {
    log "Calling checkThatFolderIsCopied(`n>>> pushPath=$pushPath`n>>> folderPath=$folderPath`n>>> )" "darkgray"
    $folderPath = "$pushPath\$folderPath"
    log "...checking for [$folderPath]" "gray"; 
    $res = $true
    if (test-path $folderPath) {
        log "...found [$folderPath]" "green";
        dir $folderPath | foreach {
            if (test-path "$folderPath\$_") {
                log "......file exists [$_]" "green"
            } else {
                log "......file not found[$_]" "red"
                $res = $false
                }
            }
    } else {
        $res = $false
        }
    return $res
    }

function installSoftware ($uniPushPath, $pushPath) {
    log "Calling installSoftware(`n>>> uniPushPath=$uniPushPath`n>>> pushPath=$pushPath`n>>> )" "darkgray"
    log "Installing needed applications." "white"

    $installerDir = "install_these"
    # Verify that exes have been copied
    if(!(checkThatFolderIsCopied $pushPath $installerDir)) {
        copyFolderFromUniPush $uniPushPath $pushPath $installerDir
        }

    # Checks for Lenovo and installs System Update if Lenovo
    $x = Get-WmiObject Win32_BaseBoard | Select-Object Manufacturer
    if($x.Manufacturer -eq "LENOVO"){ 
        log "...identified this as a Lenovo device.  Installing System Update." "gray"
        $command = "$pushPath\$installerDir\systemupdate.exe /verysilent /norestart;"
        log "...running $_ installer [{ $command }]." "gray"
        $scriptBlock = [Scriptblock]::Create($command)
        $call = Invoke-Command -ScriptBlock $scriptBlock
        log "      > $call" "darkgray" 
        }
    # Installs Ninite
    @("ninite.exe", "niniteVLC.exe") | foreach {
        $command = "$pushPath\$installerDir\$_;"
        log "...running $_ installer [{ $command }]." "gray"
        $scriptBlock = [Scriptblock]::Create($command)
        $call = Invoke-Command -ScriptBlock $scriptBlock
        log "      > script call: $call" "darkgray"
        }    
    }

function updateComputerName {
    log "Calling updateComputerName(`n>>> no args`n>>> )" "darkgray"
    # get the serial number and change the computer name
    $serialNumber = (Get-WmiObject win32_bios).SerialNumber
    try {
        Rename-Computer -NewName "WS-$serialNumber" -ErrorAction Stop
    } catch [InvalidOperationException] {
        #log ">> Caught Error: InvalidOperationException" "yellow"
        log "...Computer name is already correct." "yellow"
    } catch {
        log ">> Uncaught Error: $($Error[0].Exception.getType().FullName)" "red"
        log ">> ... $($Error[0].Exception)" "red"
        }
}

function removeDefaultApps($scriptPath) {
    log "Calling installPrinters(`n>>> scriptPath=$scriptPath`n>>> )" "darkgray"
    log "...opening a window for removeDefaultApps" "gray"      
    $command = "-ExecutionPolicy Bypass -File $scriptPath\removeDefaultApps.ps1"
    log ">> Calling & {Start-Process PowerShell.exe -ArgumentList $command -Verb RunAs}" "darkgray"
    & {Start-Process PowerShell.exe -ArgumentList $command -Verb RunAs}
    log "      > script call: $call" "darkgray"           
    }

function installPrinters($pathToPrinterConfig) {
    log "Calling installPrinters(`n>>> pathToPrinterConfig=$pathToPrinterConfig`n>>> )" "darkgray"
    log "...opening a window for installing printers" "gray"

    log "Calling {Start-Process PowerShell.exe -ArgumentList "-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1 -printerCsv $pathToPrinterConfig -logLevel $logLevel" -Verb RunAs}" "yellow"
    & {Start-Process PowerShell.exe -ArgumentList "-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1 -printerCsv $pathToPrinterConfig -logLevel $logLevel" -Verb RunAs}
    
    #PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1 -printerCsv \\192.168.1.24\technet\Setup_Workstations\Setup_MPA_Workstation\push\printerDrivers\config_Printers_MPA.csv' -Verb RunAs}"
    }

#function removeDefaultApps {
# try removing windows apps
#    log "Calling removeDefaultApps(`n>>> no args`n>>> )" "darkgray"
#    try {
#        $dump = Get-AppxPackage -AllUsers | where-object {$_.name -notlike "*Microsoft.WindowsStore*"} | where-object {$_.name -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.name -notlike "*Microsoft.WindowsSoundRecorder*"} | where-object {$_.name -notlike "*Microsoft.ZuneMusic*"} | Remove-AppxPackage 
#        $dump = Get-AppxProvisionedPackage -online | where-object {$_.packagename -notlike "*Microsoft.WindowsStore*"} | where-object {$_.packagename -notlike "*Microsoft.WindowsCalculator*"} | where-object {$_.name -notlike "*Microsoft.WindowsSoundRecorder*"} | where-object {$_.name -notlike "*Microsoft.ZuneMusic*"} | Remove-AppxProvisionedPackage -online -ErrorAction Ignore
#    } catch [UnauthorizedAccessException] {
#        #log ">> Caught Error: UnauthorizedAccessException" "yellow"
#        log "...running in an unelevated session.  Rerun script as admin." "red"
#    } catch {
#        log ">> Uncaught Error: $($Error[0].Exception.getType().FullName)" "red"
#        log ">> ... $($Error[0].Exception)" "red"
#        }
#    }

function disableDefaultsSettings($scriptPath) {
    log "Calling disableDefaultsSettings(`n>>> scriptPath=$scriptPath`n>>> )" "darkgray"
    log "...opening a window for disableDefaultsSettings" "gray"      
    $command = "-ExecutionPolicy Bypass -File $scriptPath\disableDefaultsSettings.ps1"
    log ">> Calling & {Start-Process PowerShell.exe -Exec-ArgumentList $command -Verb RunAs}" "darkgray"
    & {Start-Process PowerShell.exe -ArgumentList $command -Verb RunAs}
    log "      > script call: $call" "darkgray" 
}

function stopUnwantedServices {
    log "Calling stopUnwantedServices(`n>>> no args`n>>> )" "darkgray"
    try {
        $dump = get-service Diagtrack,DmwApPushService,XblAuthManager,XblGameSave,XboxNetApiSvc,TrkWks,WMPNetworkSvc -ErrorAction Stop|
        stop-service -passthru -ErrorAction Stop | 
        set-service -startuptype disabled -ErrorAction Stop
    } catch [Microsoft.PowerShell.Commands.ServiceCommandException] {
        log ">> Caught Error: CouldNotStopService,Microsoft.PowerShell.Commands.StopServiceCommand" "yellow"
        log "...could not stop services." "yellow"
    } catch {
        log ">> Uncaught Error: $($Error[0].Exception.getType().FullName)" "red"
        log ">> ... $($Error[0].Exception)" "red"
        }
}

function installSystemUpdates {
    log "Calling installSytemUpdates(`n>>> no args`n>>> )" "darkgray"
    log "...running SytemUpdate to install all firmware." "gray"
    #$path = "'c:\Program Files (x86)\Lenovo\System Update\tvsu.exe'"
    $path = "`"C:\Program Files (x86)\Lenovo\System Update\tvsu.exe`""
    $args = "/CM `"-search ALL -action INSTALL -includerebootpackages 1,3,4 -noreboot -nolicense`""
    $command = "& $path $args"
    $scriptBlock = [Scriptblock]::Create($command)
    $call = Invoke-Command -ScriptBlock $scriptBlock
    log "      > $call" "darkgray"
        
    }

function setWinUpdateUXKeys ($scriptPath) {
    log "Calling setWinUpdateUXKeys(`n>>> no args`n>>> )" "darkgray"    
    log "...setting windows UX keys from [$scriptPath\SetWinUpdateUXKeys]" "gray"
    $command = "$scriptPath\SetWinUpdateUXKeys.ps1"
    log "...running { $command }." "gray"
    $scriptBlock = [Scriptblock]::Create($command)
    $call = Invoke-Command -ScriptBlock $scriptBlock
    }

function main ($uniPushPath, $pushPath, $scriptPath) {
    log "Calling main(`n>>> uniPushPath=$uniPushPath`n>>> pushPath=$pushPath`n>>> scriptPath=$scriptPath`n>>> )" "darkgray"
    #Enabling scripting
    changeScriptingPolicy "unrestricted"
    # remove default windows apps
    removeDefaultApps $scriptPath #DOESN"T WORK
    #disables many Win10 default settings
    disableDefaultsSettings $scriptPath
    # get the serial number and change the computer name
    updateComputerName
    # check to see if secure boot is enabled.
    $sb = checkForSecureBoot
    # activate windows from OEM if no key provided.
    activateWindows
    #copy files from universal push folder to c:\push
    copyUniDirToPushDir $uniPushPath $pushPath
    #Sets several reg keys effecting UX
    log "Setting windows UX keys from [$scriptPath\SetWinUpdateUXKeys]" "White"
    .$scriptPath\SetWinUpdateUXKeys -logLevel 2
    # Stopping and disabling diagnostics tracking services, Onedrive sync service, various Xbox services, Distributed Link Tracking, and Windows Media Player network sharinglog # Stopping and disabling diagnostics tracking services, Onedrive sync service, various Xbox services, Distributed Link Tracking, and Windows Media Player network sharing
    stopUnwantedServices
    #install several applications
    installSoftware $uniPushPath $pushPath
    #install all several applications
    installSystemUpdates
    #QA all changes
    log "Running QA script [$scriptPath\QAStandardSetup]" "White"
    #Disabling scripting
    #changeScriptingPolicy "restricted"
    }

clear
# CONSTANTS
$PUSH_PATH = "C:\Push";
$SCRIPT_PATH = "\\192.168.1.24\technet\Scripts\wksSetups"
$UNIPUSH_PATH = "\\192.168.1.24\technet\Setup_Workstations\UniversalPushFolder\Push";

#main $UNIPUSH_PATH $PUSH_PATH $SCRIPT_PATH

installSystemUpdates

log "Automation complete.  Reboot computer." "white"
#log "Automation complete.  Press any key to reboot." "white"
#timeout /t -1
#Restart-Computer 

#\\192.168.1.24\technet\Scripts\wksSetups\SetWinUpdateUXKeys.ps1