param(
    [string]$customerId = "",
    [int]$logLevel = 1,
    [string]$configRepoPath = "https://s3.amazonaws.com/aait/config_setupClient.csv",
    [string]$PUSH_PATH = "C:\Push",
    [string]$SCRIPT_PATH = "\\192.168.1.24\technet\Setup_Workstations",
    [string]$UNIPUSH_PATH = "\\192.168.1.24\technet\Setup_Workstations\UniversalPushFolder\Push"
    
    )

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

function logLod($lod){
    log " Calling logLod(`n>>> -lod $lod`n>>> )" "darkgray"
    $tlod = @(
        @{"name"="Name1";"data"="data1"},
        @{"name"="Name2";"data"="data2"},
        @{"name"="Name3";"data"="data3"}
    )
    log "writing lod with length $($lod.length)" "gray"
    $n = 0
    foreach ($d in $lod) {
        log "  [$n]:{" "gray"
        $d.keys | foreach {
            log "    k[$_]: `"$($d[$_])`"" "gray"
        }
        log "  }" "gray"
        $n += 1
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

function buildConfig($customerId, $configRepoPath, $configPath) {
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

function old_buildConfig($customerId) {
    log "Calling buildConfig(`n>>> -configPath `"$configPath`"`n>>> )" "darkgray"
    
    if($customerId.Length -lt 3){
        $customerId = promptForCustomerId
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
        try {
            $csv = Import-Csv $configPath -ErrorAction Stop
            $keys = $csv[0].PSObject.Properties.Name
        } catch [System.Management.Automation.RuntimeException] {
            log ">>CAUGHT ERROR: [System.Management.Automation.RuntimeException]" "yellow"
            if (([String]$e.Exception).contains("null-valued expression")) {
                log "...provided csv is null." "yellow"
            } elseif (([String]$e.Exception).contains("index into a null array")) {
                log "...first row of provided csv is empty." "yellow"
            } else {
                log ">> $($Error[0].Exception)" "yellow"
            }
        } catch {
            log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "Red"
            log ">> $error[0]" "red"
        }
        log ">> Imported csv..." "darkgray"
        log $csv "darkgray"
        log "...building config." "gray"
    
        $config = @{}
        foreach ($k in $keys) {
            $config[$k] = $csv.($k)
        }

        #TODO: Provided a way to decode a list from a single csv field.  ec ["app1","app2"]
        log "...built config with length [$($config.Length)] and keys[$($config.Keys)]" "white"
    }
    
    return $config
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

function checkDomain ($domainShoudBe) {
    log "Calling checkDomain `n>>> `$domainShoudBe=$domainShoudBe`n>>> )" "darkgray"
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

    log "...discovered $res, should be $domainShoudBe" "gray"
    #[0]: bool : Does discovered domain match provided domain?
    #[1]: bool : Discovered Domain
    #[2]: bool : ShouldBe Domain
    return (($res -eq $domainShoudBe),$res,$domainShoudBe)
    }
function qaDomain ($domainShoudBe) {
    log "Calling qaDomain `n>>> no args`n>>> )" "darkgray"
    $d = checkDomain $domainShoudBe
    if($d[2].Length -lt 1) {
        log "!! [ ] Joined to correct Domain" "white"
        log "!!       Discoverd Domain: [$($d[1])]" "yellow"
    } elseif($d[0]) {
        log "!! [X] Joined to correct Domain" "green"
        #log "!!       Discovered Domain: [$($d[1])]" "yellow"
    } else {
        log "!! [ ] Joined to correct Domain" "red"       
        log "!!       Discoverd Domain: [$($d[1])] (should be $domainShoudBe)" "red" 
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
    $setupFlag = $true
    $libsFlag = $true
    #get OneDrive folder
    $uds = @()
    foreach ($u in dir c:\users | where {$_.Name -ne "AllAccess" -and $_.Name -ne "Public"}) {
       $uds+= $u
    }
    if ($uds.Length -eq 1){
        $odd = (dir $uds[0].FullName).FullName | where {$_ -match 'OneDrive -'}
    } elseif ($uds.Length -lt 1){
        log "...`>> ERROR<checkThatSystemFoldersAreMovedToOneDrive()>: No users found on this computer." "red"
        log "...`$uds=$uds" "red"
    } else {
        log "!!   `WARNING<checkThatSystemFoldersAreMovedToOneDrive()>: " "yellow"
        log "!!     ...Multiple users found [$($uds.Length)].  QA may be unreliable." "yellow"        
        log ">`$uds=$([system.String]::Join(", ", $uds))" "darkgray"
    }
    $sfs = @("Desktop", "Documents", "Pictures")
    foreach ($sf in $sfs) {
        $dir = "$odd\$sf"
        if (test-path $dir) {
            log "!!      ...located $dir" "gray"
        } else {
            log "!!      ...could not locate $dir" "red"            
            $libsFlag = $false
        }
    }
    # [0]: bool : Is OneDrive set up?
    # [1]: bool : Are library folders in OneDrive?
    return @{"odSetup"=$setupFlag; "odLibsPresent"=$libsFlag}
}
function qaOneDrive {
    $res = checkThatSystemFoldersAreMovedToOneDrive
    if ($res["odSetup"]) {
        log "!! [X] OneDrive installed" "green"
    } else {
        log "!! [ ] OneDrive installed" "red"
    }
    #check if library folders are present in OneDrive
    if ($res["odLibsPresent"]) {
        log "!! [X] Desktop, Documents, and Pictures are mapped to OneDrive folders" "green"
    } else {
        log "!! [ ] Desktop, Documents, and Pictures are mapped to OneDrive folders" "red"        
    }
    #check if libraries have been mapped to OneDrive
    log "!! [ ] Local libraries are mapped to OneDrive" "white"
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
        if ([bool]($apps.Name -like "Adobe Acrobat Reader*") -or [bool]($apps64.DisplayName -like $a)) {
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
    $shouldBeInstalled32 = @(
        "Adobe Acrobat Reader DC",
        "Office 16 Click-to-Run Licensing Component"
        "Windows Agent"
        )
    $shouldBeInstalled64 = @(
        "Microsoft Office 365 ProPlus - en-us",
        "Google Chrome",
        "Mozilla Firefox *"
        )
    $shouldBeInstalled = $shouldBeInstalled32 + $shouldBeInstalled64


    $res = checkInstalledPrograms $shouldBeInstalled
    if ($res.res) {
        log "!! [X] Needed software installed." "green"
    } else {
        log "!! [ ] Needed software installed." "red"        
    }
    foreach ($a in $res.present) {
        log "!!         $a" "gray"
    }
    foreach ($a in $res.missing) {
        log "!!         $a" "red"
    }

    if(Test-Path "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"){
        log "!! [X] Lenovo System Update is installed." "Green"
    } else {
        log "!! [ ] Lenovo System Update is installed." "red"
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

function downloadPrinterConfig ($configUrl, $configPath) {
    log "Calling downloadPrinterConfig(`n>>> configUrl `"$configUrl`n>>> configPath `"$configPath`"`n>>> )" "darkgray"
    try {
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($configUrl, $configPath)
    } catch [System.Management.Automation.MethodInvocationException] {
        log ">> CAUGHT ERROR: <MethodInvocationException> Cannot access url [$configUrl] ..." "Yellow"
        log ">> CAUGHT ERROR: $PSItem" "Yellow"
        return $false
    } catch {
        log "E!"
        log ">> UNCAUGHT ERROR: $PSItem" "red"
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
        return $false
        }
    return (test-path $configPath)
}

function buildPrinterLod($customerId, $configUrl, $configPath, $public="1") {
    log "Calling convertCsvToLod(`n>>> -customerId `"$customerId`n>>> -configUrl `"$configUrl`"`n>>> -configPath `"$configPath`"`n>>> -public `"$public`"`n>>> )" "darkgray"
    if(downloadPrinterConfig $configUrl $configPath) {
            $pmap = @{
                "public"     = "Public";
                "location"   = "location";
                "driverName" = "driver";
                "ip"         = "ip";
                "driverPath" = "driverPath";
                "color"      = "BW or Color"
            }
            $csv = import-csv $configPath
            #$temp = $csv | where {$_.GroupId -eq $customerId -and $_.Public -eq $public}
            
            $lod = @()
            foreach ($r in $csv) {
                if (($r.GroupId -eq $customerId) -and ($r.Public -eq $public)) {
                    $rkeys = $r | Get-Member -MemberType NoteProperty | select -ExpandProperty Name    
                    $nr = $r
                    $rkeys | foreach {
                        $nr.$_ = ($r.$_).trim()
                    }
                    #$nr | Add-Member -NotePropertyName name -NotePropertyValue "$($r.location.trim()) - $($r.driverName.trim())"
                    $lod += $nr
                    log "  + adding @{$nr}" "darkgray"
                } else {
                    #log "  - ($($r.GroupId) -eq $customerId) -and ($($r.Public) -eq $public)=$(($r.GroupId -eq $customerId) -and ($r.Public -eq $public))" "darkgray"
                }
            }
            log "...located and cleaned $($lod.Length) printer record(s)." "gray"
            $printerLod = @()
            log "Building printer Lod: [" "gray"
            foreach ($d in $lod){
                    $p = @{}
                    $pstr = ""
                    $pmap.keys | foreach {
                        $p[$_] = $d.($pmap[$_])
                        $pstr += "`"$_`"=`"$($p.$_)`"; "
                    }
                    log "    + @{$pstr}"     "darkgray"
                    $printerLod += $p
            }
            log "]" "gray"
            log "...added [$($printerLod.Length)] printers to printerLod:" "gray"
    } else {
        log ">>ERROR: Could not download printer config from `"$configUrl`"" "red"
    }
    Remove-Item -Path $configPath
    log "...returning lod with $($printerLod.Length) printer(s)." "gray"

    return $printerLod
}

function checkPrinters ($customerId) {
    log "Calling checkPrinters `n>>> `$customerId=$customerId`n>>> )" "darkgray"
    log "...checking printers." "gray"
    $PRINTER_CONFIG_URL = "https://s3.amazonaws.com/aait/config_Printers.csv"
    $PRINTER_CONFIG_PATH = "c:\push\config_Printer.csv"
    #$printerInstallScriptPath = "\\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1"
    $plod = buildPrinterLod $customerId $PRINTER_CONFIG_URL $PRINTER_CONFIG_PATH

    logLod $plod

    log "...checking for $($plod.length) printers." "gray"
    $printers = Get-Printer
    log "...discovered $($plod.length) printers." "gray"

    $res = @()
    foreach ($p in $plod) {
        $printerName = "$($p.location) - $($p.driverName)"
        $printersShouldBe += $printerName
        if (($printers.Name) -contains $printerName) {
            log "!!     + $printerName is installed." "gray"
        } else {
            log "!!     - $printerName is not installed." "red"
            $res += $false
        }
    }

    return (-not $res.contains($false))
}
function qaPrinters ($customerId) {
    log "Calling qaPrinters `n>>> no args`n>>> )" "darkgray"
    

    if($customerId.Length -lt 1) {
        log "!! [ ] Installed printers:" "white"
        foreach ($p in (get-printer).Name) {
            log  "!!       $p" "yellow"
        }
    } else {
        $res = checkPrinters $customerId
        if ($res) {
            log "!! [X] Correct printers installed." "green"
        } else {
            log "!! [ ] Correct printers installed." "red"
            foreach ($p in (get-printer).Name) {
                log  "!!       $p" "yellow"
            }
        }
    }
}

function OLD_qaPrinters ($customerId) {
    log "Calling qaPrinters `n>>> no args`n>>> )" "darkgray"
    
    if($customerId.Length -lt 1) {
        log "!! [ ] Installed printers:" "white"
        foreach ($p in (get-printer).Name) {
            log  "!!       $p" "yellow"
        }
    } else {
        
        log "...opening a window for printer qa" "gray"
        $call = "-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1 -customerId $customerId -logLevel $logLevel -qa 1"
        log "Calling {Start-Process PowerShell.exe -ArgumentList `"$call`" -Verb RunAs}" "white"
        & {Start-Process PowerShell.exe -ArgumentList $call -Verb RunAs}

    }
}

function checkWifi ($shouldBeWifiSSIDs){
    $ssids = @()
    $shouldBeWifiSSIDs = $shouldBeWifiSSIDs.split(",").trim()
    log "`$shouldBeWifiSSIDs = [$shouldBeWifiSSIDs]" "gray"
    $text = netsh wlan show profiles
    $wifi = $text[9..($text.Length-2)]
    $wifi | foreach {
        $ssid = $(-join $_[27..$_.Length])
        if(-not ([string]::IsNullOrEmpty($ssid))) {
            $ssids += $ssid
        }
    }
    log "...discovered `$ssids: $([system.String]::Join(", ", $ssids))" "gray"
    $flag = $true
    foreach ($ssid in $shouldBeWifiSSIDs) {
        if ($ssids.contains($ssid)) {
            #log "...located `"$ssid`" in `$ssids" "gray"
        } else {
            #log "...failed to locate `"$ssid`" in `$ssids" "red"
            $flag = $false            
        }
    }
    return ($flag, $ssids)
}
function qaWifi ($shouldBeWifiSSIDs){
    log "Calling qaWifi `n>>> no args`n>>> )" "darkgray"
    $res = checkWifi $shouldBeWifiSSIDs

    if ($res[0]){
        log "!! [X] Connected to correct wifi ssid" "green"
    } else {
        log "!! [ ] Connected to correct wifi ssid" "red"
        log "       ..SSIDs should be: [$([system.String]::Join(", ", $shouldBeWifiSSIDs))]" "yellow"
        $res[1] | foreach {
            log "!!       $_" "yellow"
        }
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

function main ($customerId, $configRepoPath, $configPath) {
    log "Calling main(`n>>> -customerId `"$customerId`"`n>>> -configUrl `"$configUrl`"`n>>> -configPath `"$configPath`"`n>>>`n>>> )" "darkgray"
    
    $c = buildConfig $customerId $configRepoPath $configPath

    log "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" "green"
    log "!!" "green"
    log "!! Running QA for [$(hostname)]" "green"
    log "!!" "green"
    #log "[ ] Secure boot enabled"
    qaSecureBoot
    #log "[ ] BitLocker Enabled"
    qaBitLockerStatus
    #log "!! Joined to Azure domain"
    qaDomain $c.Domain
    #log "[ ] Machine name is correct"
    qaComputerName
    #log "!! [ ] Windows is activated"
    qaWindowsActivationStatus
    #log "!! [ ] 8GB of RAM is installed"
    qaRam
    #log "!! [ ] OneDrive set up"
    #log "!! [ ] Desktop, Documents, and Pictures are mapped to OneDrive folders"
    #log "!! [ ] OneDrive sync complete"
    qaOneDrive
    #log "!! [ ] Chrome, Firefox, and Nable agent are installed"
    qaInstalledPrograms
    #log "!! [ ] AV is installed (Webroot or Security Manager)"
    qaAV
    log "!! [ ] Office shortcuts are on desktop or in start menu"
    # log "!! [ ] Outlook is configured for user"
    #qaOutlook
    #log "[ ] Correct printers installed. No superfluous printers installed."
    qaPrinters $c.customerId
    #log "!! [ ] Connected to correct wifi ssid"
    qaWifi $c.wifi
    log "!! [ ] Correct push folder(s) is transferred and current"
    log "!! [ ] Sharepoint site(s) set up correctly"
    log "!! [ ] Office is connected to correct account"
    log "!! [ ] COMPLETE QA SCRIPT!!!" "red"
    log "!!" "green"
    log "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" "green"
    log ""
    log "TODOs: " "yellow"
    log "[ ] QA correct push folder moved" "yellow"
    log "[ ] QA correct Users folder moved" "yellow"
    log "[ ] QA correct printers moved" "yellow"
    log "[ ] QA library locations correct" "yellow"
    log "[ ] Printers self healing" "yellow"

}

#clear

# CONSTANTS
$PUSH_PATH = "C:\Push";
$CONFIG_SETUPCLIENT_PATH = "c:\push\config_setupClient.csv"
$SCRIPT_PATH = "\\192.168.1.24\technet\Scripts\wksSetups"
$UNIPUSH_PATH = "\\192.168.1.24\technet\Setup_Workstations\UniversalPushFolder\Push";
$DEFAULT_CONFIG_PATH = "\\192.168.1.24\technet\Scripts\setupConfigs\config_setupClient__DEFAULT.csv"

main $customerId $configRepoPath $CONFIG_SETUPCLIENT_PATH
#checkPrinters $customerId

pause
