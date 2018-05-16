param(
    [int]$logLevel = 1,
    [string]$PUSH_PATH = "C:\Push",
    [string]$SCRIPT_PATH = "\\192.168.1.24\technet\Setup_Workstations",
    [string]$UNIPUSH_PATH = "\\192.168.1.24\technet\Setup_Workstations\UniversalPushFolder\Push"
    )

# CONSTANTS
$PUSH_PATH = "C:\Push";
#$SCRIPT_PATH = "\\192.168.1.24\technet\Setup_Workstations\scripts"
$SCRIPT_PATH = "\\192.168.1.24\technet\Scripts\wksSetups"
$UNIPUSH_PATH = "\\192.168.1.24\technet\Setup_Workstations\UniversalPushFolder\Push";


function log ($str, $fc="white"){
# fc can be any of these [Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White]
    $fc = $fc.ToLower()
    switch ($fc) {
        "cyan"     {$priority = 6}
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

function checkForSecureBoot {
    log "Calling keysAreCorrect(`n>>> no args`n>>> )" "darkgray"    
    # log "Checking for secure boot"
    try { 
        if(Get-SecureBootPolicy) {
            log "...secure boot enabled." "gray"
            return $true; 
        } else {
            log "...secure boot not enabled." "red"            
            return $false
            }
    } catch [Microsoft.SecureBoot.Commands.StatusException] { 
        log "...secure boot not enabled." "gray"                    
        return $false;
    } catch {
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "Red"
        log ">> $error[0]" "red"  
        }
    }
function qaSecureBoot {
    log "Calling qaSecureBoot(`n>>> no args`n>>> )" "darkgray"  
    $sb = checkForSecureBoot
    if ($sb) { 
        log "!! [X] Secure Boot Enabled" "green"
    } else { 
        log "!! [ ] Secure Boot Enabled" "red"
        } 
    }

function checkBitLockerStatus {
    log "Calling checkBitLockerStatus(`n>>> no args`n>>> )" "darkgray"  
    #log "Checking BitLocker status."
    try {
        $statuses = Get-BitLockerVolume -ErrorAction Stop
        foreach ($s in $statuses) {
            log "...Volume [$s] status is [$($s.VolumeStatus)]" "gray"
            switch($s.VolumeStatus) {
                "FullyDecrypted" { $c = "red"; $res = $false; }
                "FullyEncrypted" { $c = "green"; $res = $true; }
                default: {
                    $c = "red"; 
                    $res = $false; 
                    log ">> ERROR: checkBitLockerStatus() received invalid `$s.VolumeStatus" "red"; 
                    }
                }
            }
        return @($res, $statuses)
    } catch [Microsoft.Management.Infrastructure.CimException] {
        throw $error[0]
    } catch {
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "Red"
        log ">> $error[0]" "red"  
        }
    }
function qaBitLockerStatus {
    log "Calling qaBitLockerStatus `n>>> no args`n>>> )" "darkgray"
    try {
        $bl = checkBitLockerStatus -ErrorAction Stop
        if ($bl[0]) { 
            log "!! [X] BitLocker Enabled" "green"
        } else { 
            log "!! [ ] BitLocker Enabled" "red"
            foreach ($s in $bl[1]) {
                log "!!       Volume [$($s.MountPoint)] encryption status: [$($s.ProtectionStatus)] $($s.VolumeStatus)" "red"
                }
            } 
    } catch [Microsoft.Management.Infrastructure.CimException] {
        log "!! [?] BitLocker Enabled.  ...cannot access BitLocker status.  Please rerun as admin" "yellow"
    } catch {
        log "!! [?] BitLocker Enabled." "yellow"
        log ">> UNCAUGHT ERROR: $error[0].Exception.GetType().fullname" "yellow"
        log ">> $error[0]" "yellow"
        }
    
    }

function checkComputerName {
    log "Calling checkComputerName `n>>> no args`n>>> )" "darkgray"
    # get the serial number and change the computer name
    $serialNumber = (Get-WmiObject win32_bios).SerialNumber
    $name = hostname
    return ("WS-$serialNumber" -eq $name)
}
function qaComputerName {
    log "Calling qaComputerName `n>>> no args`n>>> )" "darkgray"
    if (checkComputerName) { 
        log "!! [X] Computer name is 'WS-<serial number>': $(hostname)" "green"
    } else { 
        log "!! [ ] Computer name is 'WS-<serial number>': $(hostname)" "red"
        } 
    }

function checkWindowsActivationStatus {
    log "Calling checkWindowsActivationStatus `n>>> no args`n>>> )" "darkgray"
    $checks = @('Windows(R)', 'Office')
    
    $res = @()
    foreach ($c in $checks) {
        #build r
        $r = @()
        #build wpa
        try {
            $q = "SELECT Name,LicenseStatus FROM SoftwareLicensingProduct WHERE Name LIKE '$c%'"
            log "..constructed query: $q" "gray"  
            $wpa = Get-WmiObject -Query $q -ErrorAction Stop
            log "..acquired `$wpa for $c with length $($wpa.Length)" "gray"  
        } catch {
            $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
            $wpa = $null    
        }
        #loop through wpa to build l hashes
        if ($wpa) {
            foreach ($lic in $wpa) {
                #build l
                switch ($lic.LicenseStatus) {
                    0 {$msg = "$($lic.Name) is Unlicensed"}
                    1 {$msg = "$($lic.Name) is Licensed"}
                    2 {$msg = "$($lic.Name) is in status Out-Of-Box Grace Period"}
                    3 {$msg = "$($lic.Name) is in status Out-Of-Tolerance Grace Period"}
                    4 {$msg = "$($lic.Name) is in status Non-Genuine Grace Period"}
                    5 {$msg = "$($lic.Name) is in status Notification"}
                    6 {$msg = "$($lic.Name) is in status Extended Grace"}
                    default {$msg = "$($lic.Name)license returned an Unknown value"}
                }
                $l = @{
                    name = $lic.Name;
                    LicenseStatus=$lic.LicenseStatus;
                    activated=$lic.LicenseStatus -eq 1;
                    msg = $msg
                    }
                #add to l to r
                #log "....packaged `$l: $l" "gray"
                $r += $l
                #log "....added `$l to `$r" "gray" 
            }
        } else {
            $r = $null; log ">> ERROR: No wpa for $c!" "red"
        }       
    #add r to res
    log "..adding `$r of length $($r.Length) to `$res of length $($res.Length)" "gray"
    log "..`$r.activated [$($r.activated)]" "gray"
    log "..`$r.activated [$($r.activated.contains($true))]" "gray"
    $res += @{check=$c;res=$r;}
    log "..`$r added.  `$res length [$($res.Length)]" "gray"
    }
    log "returning `$res with length $($res.Length): $res" "gray"
    return $res
}
function qaWindowsActivationStatus() {
    log "Calling qaWindowsActivationStatus `n>>> no args`n>>> )" "darkgray"
    #log "!! [ ] Windows is activated" "white"
    $res = checkWindowsActivationStatus    
    foreach ($r in $res) {
        log "..processing $r" "gray"
        log "..keys $($r.keys)" "gray"
        log "..processing `"$($r.check)`"" "gray"
        log "..`$r.activated [$($r.activated)]" "gray"
        
        if($r.res.activated.contains($true)) {
            log "!! [X] $($r.check) is activated" "green"
        } else {
            log "!! [ ] $($r.check) is not activated" "red"
        }

        $r.res | where {$_.LicenseStatus -eq 1} | foreach {
       #     log "!!       [$($_.LicenseStatus)][$($_.activated)] $($_.msg)" "green"
        }
       # $r.res | where {$_.LicenseStatus -eq 0} | foreach {
       #     log "!!       [$($_.LicenseStatus)][$($_.activated)] $($_.msg)" "red"
       # }
    }
}

function checkRam ($minRam){
    log "Calling checkRam `n>>> minRam=$minRam`n>>> )" "darkgray"
    $InstalledRAM = Get-WmiObject -Class Win32_ComputerSystem
    $ram = [Math]::Round(($InstalledRAM.TotalPhysicalMemory/ 1GB),2)
    if ($ram -gt $minRam) {
        $res = $true
    } else {
        $res = $false
        }
    return @($res,$ram)
    }
function qaRam {
    log "Calling qaRam `n>>> no args`n>>> )" "darkgray"
    $minRam = 7.5
    $res = checkRam $minRam
    if ($res[0]) {
        log "!! [X] 8GB of RAM is installed" "green" 
    } else {
        log "!! [ ] 8GB of RAM is installed: $($res[1])" "red"         
        }
    }

function qaPrinters {
    log "Calling qaPrinters `n>>> no args`n>>> )" "darkgray"
    log "!! [ ] Installed printers:"
    foreach ($p in (get-printer).Name) {
        log  "!!       $p" "yellow"
        }
    }

function checkDomain {
    log "Calling checkDomain `n>>> no args`n>>> )" "darkgray"
    #(Get-WmiObject Win32_ComputerSystem)
    #    .UserName: AzureAD\ClifBoyd
    #    .Domain: WORKGROUP
    $cs = (Get-WmiObject Win32_ComputerSystem)
    if($cs.Domain -contains "WORKGROUP") {
        if ($cs.UserName -contains "AzureAD") {
            log "...found AzureAd user: $($cs.UserName)." "gray"
            $res = "AzureAd"               
        } else {
            log "...found local user: $($cs.UserName)." "gray"
            $res = "Local"
            }        
    } else {
        log "...found domain user: $($cs.UserName)" "gray"
        $res = $cs.Domain
        }
    $r = dsregcmd.exe /status
    if ($r[5].contains("AzureAdJoined") -and $r[5].contains("YES")) {
        log "...device is Azure joined." "gray"
        $res = "AzureAd"
    } else {
        log "...device is not Azure joined." "gray"
        }
    return $res
    }
function qaDomain {
    log "Calling qaDomain `n>>> no args`n>>> )" "darkgray"
    $d = checkDomain
    log "!! [ ] Check Domain:"
    log "!!       Domain: [$d]" "yellow"
    }

function qaWifi {
    log "Calling qaWifi `n>>> no args`n>>> )" "darkgray"
    log "!! [ ] Connected to correct wifi ssid"
    $text = netsh wlan show profiles
    $wifi = $text[9..$text.Length]
    $wifi | foreach {
        log "!!       $(-join $_[27..$_.Length])" "yellow"
        }
    }


function Set-KnownFolderPath {
    <#
    .SYNOPSIS
        Sets a known folder's path using SHSetKnownFolderPath.
    .PARAMETER Folder
        The known folder whose path to set.
    .PARAMETER Path
        The path.
    #>
    Param (
            [Parameter(Mandatory = $true)][ValidateSet('Desktop', 'Documents', 'Downloads', 'Music', 'Pictures')][string]$KnownFolder,
            [Parameter(Mandatory = $true)][string]$Path
    )

    # Define known folder GUIDs
    $KnownFolders = @{
        'Desktop' = 'B4BFCC3A-DB2C-424C-B029-7FE99A87C641';
        'Documents' = 'FDD39AD0-238F-46AF-ADB4-6C85480369C7';
        'Downloads' = '374DE290-123F-4565-9164-39C4925E467B';
        'Favorites' = '1777F761-68AD-4D8A-87BD-30B759FA33DD';
        'Music' = '4BD8D571-6D19-48D3-BE97-422220080E43';
        'Pictures' = '33E28130-4E1E-4676-835A-98395C3BC3BB';
    }

    # Define SHSetKnownFolderPath if it hasn't been defined already
    $Type = ([System.Management.Automation.PSTypeName]'KnownFolders').Type
    if (-not $Type) {
        $Signature = @'
[DllImport("shell32.dll")]
public extern static int SHSetKnownFolderPath(ref Guid folderId, uint flags, IntPtr token, [MarshalAs(UnmanagedType.LPWStr)] string path);
'@
        $Type = Add-Type -MemberDefinition $Signature -Name 'KnownFolders' -Namespace 'SHSetKnownFolderPath' -PassThru
    }

    # Validate the path
    if (Test-Path $Path -PathType Container) {
        # Call SHSetKnownFolderPath
        return $Type::SHSetKnownFolderPath([ref]$KnownFolders[$KnownFolder], 0, 0, $Path)
    } else {
        throw New-Object System.IO.DirectoryNotFoundException "Could not find part of the path $Path."
    }
}

function moveSystemFoldersToOneDrive{
    #get OneDrive folder
    $odd = (dir $env:USERPROFILE).Name | where {$_ -match 'OneDrive -'}
    $sfs = @("Desktop", "Documents", "Pictures")
    foreach ($sf in $sfs) {
        Set-KnownFolderPath -KnownFolder $sf -Path "$odd\$sf"
    }
}
function checkThatSystemFoldersAreMovedToOneDrive {
    log "Calling checkThatSystemFoldersAreMovedToOneDrive `n>>> no args`n>>> )" "darkgray"    
    $flag = $true
    $odd = (dir $env:USERPROFILE).Name | where {$_ -match 'OneDrive -'}
    $sfs = @("Desktop", "Documents", "Pictures")
    foreach ($sf in $sfs) {
        $dir = "$odd\$sf"
        if (test-path $dir) {
            log "...located $dir" "gray"
        } else {
            log "...could not locate $dir" "red"            
            $flag = $false
        }
    }
    return $flag
}

function qaOneDrive {
    #get OneDrive folder
    $odd = (dir $env:USERPROFILE).Name | where {$_ -match 'OneDrive -'}
    if ($odd.Length -gt 0) {
        log "!! [X] OneDrive set up" "green"
    } else {
        log "!! [ ] OneDrive set up" "red"
    }
    
    log "!! [ ] OneDrive sync complete"
    
    #check if libraries have been mapped to OneDrive
    if (checkThatSystemFoldersAreMovedToOneDrive) {
        log "!! [X] Desktop, Documents, and Pictures are mapped to OneDrive folders" "green"
    } else {
        log "!! [ ] Desktop, Documents, and Pictures are mapped to OneDrive folders" "red"        
    }
}

function checkInstalledPrograms ($shouldBeInstalled) {
    log "Calling checkInstalledPrograms `n>>> no args`n>>> )" "darkgray"
    $apps = Get-WmiObject -Class Win32_Product 
    $apps64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    $n = 0;
    $missing = @();
    $present = @();
    $res = $true;
    foreach ($a in $shouldBeInstalled) {
        if (($apps.Name).contains($a) -or ($apps64.DisplayName.contains($a))) {
            #log "!!       $a" "green"; 
            $present += $a;
        } else {
            #log "!!       $a" "red"; 
            $res = $false;
            $missing += $a;

            }            
        $n += 1 
    }
    return @{
        res = $res;
        present = $present;
        missing = $missing;
    }
    #Query installed 32-bit programs:
    #  Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize
    #Query installed 64-bit programs: 
    #  Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Format-Table –AutoSize
}
function qaInstalledPrograms {
    log "Calling qaInstalledPrograms `n>>> no args`n>>> )" "darkgray"
    $shouldBeInstalled = @(
        "Adobe Acrobat Reader DC",
        "Office 16 Click-to-Run Licensing Component"
        "Microsoft Office 365 ProPlus - en-us"
        "Windows Agent",
        "Google Chrome",
        "Mozilla Firefox 60.0 (x64 en-US)",
        "Lenovo System Update"
        )
    $res = checkInstalledPrograms $shouldBeInstalled
    if ($res.res) {
        log "!! [X] Chrome, Firefox, and AV are installed (Webroot or Security Manager)" "green"
    } else {
        log "!! [ ] Chrome, Firefox, and AV are installed (Webroot or Security Manager)" "red"        
    }
    foreach ($a in $res.present) {
        log "           $a" "green"
    }
    foreach ($a in $res.missing) {
        log "           $a" "red"
    }
}

function checkForSecurityDefender {
    log "Calling checkForSecurityDefender `n>>> no args`n>>> )" "darkgray"
    $app = "Security Manager AV Defender"
    $apps64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
        Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    $res = $apps64.DisplayName -contains $app;
    $install = $apps64 | where {($_.DisplayName) -contains $app};
    return @($res, $install)
}
function qaAV {
    log "Calling qaAV `n>>> no args`n>>> )" "darkgray"
    if (checkForSecurityDefender) {
        log "!! [X] AV is installed (Webroot or Security Manager)" "green"
    } else {
        log "!! [ ] AV is installed (Webroot or Security Manager)" "red"
    }
}

function checkOutlook {
    & 'C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE'
    }
function qaOutlook {
    log "!! [ ] Outlook is configured for user"
    checkOutlook
    }

###############
#
# Script here
#
###############

function main {

    log "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" "green"
    log "!!" "green"
    log "!! Running QA for [$(hostname)]" "green"
    log "!!" "green"
    #log "[ ] Secure boot enabled"
    qaSecureBoot
    #log "[ ] BitLocker Enabled"
    qaBitLockerStatus
    #log "!! Joined to Azure domain"
    qaDomain
    #log "[ ] Machine name is correct"
    qaComputerName
    #log "!! [ ] Windows is activated"
    qaWindowsActivationStatus
    #log "!! [ ] 8GB of RAM is installed"
    qaRam
    #log "[ ] Correct printers installed. No superfluous printers installed."
    qaPrinters
    #log "!! [ ] Connected to correct wifi ssid"
    qaWifi
    log "!! [ ] Correct push folder(s) is transferred and current"
    log "!! [ ] Sharepoint site(s) set up correctly"
    log "!! [ ] OneDrive set up"
    log "!! [ ] Desktop, Documents, and Pictures are mapped to OneDrive folders"
    log "!! [ ] OneDrive sync complete"
    qaOneDrive
    log "!! [ ] SharePoint sync complete"
    #log "!! [ ] Chrome, Firefox, and Nable agent are installed"
    qaInstalledPrograms
    #log "!! [ ] AV is installed (Webroot or Security Manager)"
    qaAV
    log "!! [ ] Office shortcuts are on desktop or in start menu"
    # log "!! [ ] Outlook is configured for user"
    #qaOutlook
    log "!! [ ] Office is connected to correct account"
    log "!! [ ] COMPLETE QA SCRIPT!!!" "red"
    log "!!" "green"
    log "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" "green"
}

main

pause
