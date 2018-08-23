param(
    [string]$msiUrl = $(throw 'No msiUrl provided.  Please include a valid url to a msi file.  ex. -msiUrl "https://s3.amazonaws.com/aait/installers/AllAccessSystemTrayDotNet.msi"'),
    [string]$appName = $(throw 'No appName provided.  Please include a valid appName.  ex. -appName "AllAccess System Tray Icon"'),
    $pushPath = "C:\Push",
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
        default {$priority = 1; $fc = "white"}
        }
    if ($priority -ge $logLevel) {
        write-host $str -ForegroundColor $fc
    }
}
function download($msiUrl, $downloadPath) {
    log " Calling download(`n>>> -msiUrl $msiUrl`n>>> -downloadPath $downloadPath`n>>> )" "darkgray"
    try {
        $n = 0
        #if path exists, delete it.
        if(Test-Path $downloadPath){
            remove-item $downloadPath
            timeout /t 3
        }
        #download file
        while(!((Test-Path $downloadPath) -or ($n -gt 10))) {
            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($msiUrl, $downloadPath)
            log "...($n) downloading [$msiUrl]" "gray"
            timeout /t ($n*3)
            $n += 1
        }
    } catch [System.Management.Automation.MethodInvocationException] {
        log ">> CAUGHT ERROR: <MethodInvocationException> Cannot access url [$msiUrl] ..." "Yellow"
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
function install($appName, $pathToMsi) {
    log "Calling installAgent(`n>>>`$appName=$appName`n>>>`$pathToMsi=$pathToMsi`n>>> )" "darkgray"
    $command = "$pathToMsi"
    $params = "/qn", "/norestart" #/passive
    log "...running [{ $command $params }]." "gray"
    & $command $params
    $n = 0
    while($n -lt 6){
        if(checkForInstalled $appName){
            log "Confirmed that $appName is installed." "gray"
            return $true
        }
        $n += 1
        log "($n) waiting for install..." "gray"
        timeout /t 5
    }
    log "Failed to confirm that $appName is installed." "red"    
    return $false
}
function uninstall($appName, $pathToMsi) {
    log "Calling uninstallAgent(`n>>>`$appName=$appName`n>>>`$pathToMsi=$pathToMsi`n>>> )" "darkgray"
    log "...uninstalling [$($appName)]" "gray"
    (Get-WmiObject -Class Win32_Product -filter "Name='$appName'").Uninstall()
    log "...uninstalled [$($appName)]" "gray"
    $n = 0
    while($n -lt 6){
        if(!(checkForInstalled $appName)){
            log "Confirmed that $appName is not installed." "gray"
            return $true
        }
        $n += 1
        log "($n) waiting for uninstall..." "gray"
        timeout /t 5
    }
    log "Failed to confirm that $appName is not installed." "red"    
    return $false
}
function checkForInstalled($appName){
    log "Calling checkForInstalled(`n>>>`$appName=$appName`n>>> )" "darkgray"
    $apps = Get-WmiObject -Class Win32_Product 
    $apps64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    $res = ($apps.Name.contains($appName) -or $apps64.DisplayName.contains($appName))
    return $res
}
function main ($appName, $msiUrl, $pathToMsi) {
    #download installer
    if (download $msiUrl $pathToMsi){
        log "Msi successfully downloaded" "white"

        #check for app and uninstall if installed
        if(checkForInstalled $appName){
            if(uninstall $appName $pathToMsi){
                log "Application [$appName] successfully uninstalled.  Re-Installing..." "white"
                #reinstall app
                if(install $appName $pathToMsi){
                    log "Application [$appName] successfully installed" "white"
                } else {
                    log "Failed to install application [$appName]" "red"
                }
            }else{
                log "Failed to uninstall application [$appName]." "red"
            }
        } else {
            log "Application [$appName] not installed.  Installing..." "white"
            #install app
            if(install $appName $pathToMsi){
                log "Application [$appName] successfully installed" "white"
            } else {
                log "Failed to install application [$appName]" "red"
            }

        }
    } else {
        log "Failed to download msi" "red"
    }
}

#$msiUrl = "https://s3.amazonaws.com/aait/installers/AllAccessSystemTrayDotNet.msi"
#$appName = "AllAccess System Tray Icon"

$pathToMsi = "$pushPath\$appName.msi"
main $appName $msiUrl $pathToMsi

