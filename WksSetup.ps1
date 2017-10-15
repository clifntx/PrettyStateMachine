
filter timestamp {"$(Get-Date -UFormat "[ %b%d%Y %H:%M:%S ]"): $_"}
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
function endLogging ($timeElapsed="?") {
    Write-Host "[ END ] Total time elapsed: $timeElapsed ms"
    Add-Content .\$log "[ END ] Total time elapsed: $timeElapsed ms"
}

#.....................................................
#: Constants
#.....................................................
$lanPushPath = "F:\push\"
$nasPath = "F:\nasFiles\"
$log = ".\wksSetup_log.txt"
$pushPath = "c:\Push\"
$clientMap = @{"becket.org" = "Setup_Becket_Workstation\"; "allaccessinfotech.com"="Setup_AAIT_Wks\" }
#.....................................................
#: Execution steps
#.....................................................

$sw = [Diagnostics.Stopwatch]::StartNew()
#initialize logging
$timeInitial = Get-Date -UFormat "%b%d%Y_%H`h%M`m%S`s"
startLogging ($timeInitial)

# setup admin account
function setupAllAccessAccount(){
# verify that Allaccess account exists and is an admin
# change AAIT user picture
}

# clear all currently installed apps and remove all tiles
function clearTheDeck(){
    # uninstall everything
    # clear all tiles
    $apps = Get-AppxPackage

    $apps.Name
    foreach($y in $apps){
        $name = $_.Name
        $pack = $_.PackageFullName
        Write-Host 
    }
}

# set computer to WS-SERIALNUMBER
function fixComputerName(){
    #get serial number
    #check computer name
    #change if wrong
}

# Turn off Microsoft consumer experience   
function turnOffMsConsumerExperience(){
    #-------
    #?There doesn’t appear to be an unattend.xml entry to turn this off, but given the Group Policy above, it’s easy enough to track down the associated registry key, located at “HKLM\Software\Policies\Microsoft\Windows\CloudContent,” value “DisableWindowsConsumerFeatures.”  Set that value to 1 and you won’t get the extra apps.
    #-------
    #?If your version of Windows 10 does not ship with the Group Policy Editor, you can Run regedit to open the Registry Editor, and navigate to the following key:
    #?HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent
    #?Double-click on DisableWindowsConsumerFeatures in the right pane and change the value of this DWORD to 1.
    #?If this DWORD does not exist, you will have to create it.
    #?This will disable Microsoft Consumer Experience on your Windows 10 computer.
    #-------
}

#Remove Game Links from Start Menu

# move unipushfolder to c:\push\
function setupPush(){
    #check path to push dir
    #move push dir to c:\push\
}

function setupClientFiles($clientMap){
    $path = $pathToSetupFiles + $clientMap[$domain]
    #check path to client dir
    #move clientPush to c:\push\
    #move clientUsers to c:\Users\
}

# install everything in c:\push\install_these\
function installThose(){
}

# run everthin in c:\push\run_these\
function runThose(){
}

# install system updates https://forums.lenovo.com/t5/Pre-Installed-Lenovo-Software/unattented-quot-system-update-quot-with-SCCM-Possible/td-p/47850
#------
#? systemupdate314-2008-5-15.exe -s -a /s /v" /qn
#------
#?cmd /c "C:\Program Files\Lenovo\System Update\Tvsu.exe"
#?cmd /c TASKKILL /F /IM tvsukernel.exe
#?REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Lenovo\System Update" /v "Languageoverride" /t REG_SZ /d "EN" /f
#?REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Lenovo\System Update\Preferences\UserSettings\General" /v "IgnoreLocalLicense" /t REG_SZ /d "YES" /f
#?REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Lenovo\System Update\Preferences\UserSettings\General" /v "DisplayLicenseNotice" /t REG_SZ /d "NO" /f
#?REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Lenovo\System Update\Preferences\UserSettings\General" /v "DisplayLicenseNoticeSU" /t REG_SZ /d "NO" /f
#?REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Lenovo\System Update\Preferences\UserSettings\General" /v "ExtrasTab" /t REG_SZ /d "NO" /f
#?REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Lenovo\System Update\Preferences\UserSettings\General" /v "RepositoryLocation1" /t REG_SZ /d "\\c-00008n002\updateretriever" /f
#?REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Lenovo\System Update\Preferences\UserSettings\General" /v "NotifyInterval" /t REG_SZ /d "36000" /f
#?REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Lenovo\System Update\Preferences\UserSettings\Scheduler" /v "SchedulerAbility" /t REG_SZ /d "YES" /f
#?REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Lenovo\System Update\Preferences\UserSettings\Scheduler" /v "SchedulerLock" /t REG_SZ /d "LOCK" /f
#?cmd /c "C:\Program Files\Lenovo\System Update\tvsu.exe" /CM -search A -action INSTALL -repository \\mylocation\updates. -includerebootpackages 1,3,4 -noreboot -noicon
#------


# run updater