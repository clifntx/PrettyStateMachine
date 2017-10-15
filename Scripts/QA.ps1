
function getComputerName { return $env:COMPUTERNAME; }
function getSerialNumber { return (get-ciminstance win32_bios).SerialNumber; }
function getInstalledRam {  return [MATH]::Round(((Get-WmiObject -class win32_computersystem).TotalPhysicalMemory)/1GB,0) }
function getDomain {  return (Get-WmiObject -class win32_computersystem).Domain }

function checkInstalled($an){
    $present = (Get-WmiObject -Class Win32_Product).Name.Contains($an);
    return $present;
}
function checkMemberInGroup($mem, $group){
    #log("Checking for $mem in $group");
    $b=$false;$cn=getComputerName;
    foreach($m in (Get-LocalGroupMember $group).Name){
        if($mem -eq ($m.substring($cn.Length+1))){$b = $true;} 
    }
    return $b;
}
function checkMachineName($n){
    if($n -eq (getComputerName)){
        return $true;
    }else{
        log("    >> ERROR: Change computername to $n.");
        return $false;
    }
}
function checkActivationStatus {
    $b = $false;
    try {
       # $wpa = Get-WmiObject SoftwareLicensingProduct -Property LicenseStatus -ErrorAction Stop
        $wpa = Get-WmiObject SoftwareLicensingProduct -ErrorAction SilentlyContinue
    } catch {
        $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
        $wpa = $null    
    }
    $lic = New-Object psobject -Property @{Name = [string]::Empty;Status = [string]::Empty;}
    $out = @();
    if ($wpa) {
        foreach($item in $wpa) {
            $lic.Name = $item.Name;
            #write-host "Name: [ "+ $item.Name " ]; Status: [" $item.LicenseStatus "]";
            switch ($item.LicenseStatus){
                0 {$lic.Status = "Unlicensed"}
                1 {$lic.Status = "Licensed"; break outer}
                2 {$lic.Status = "Out-Of-Box Grace Period"; break outer}
                3 {$lic.Status = "Out-Of-Tolerance Grace Period"; break outer}
                4 {$lic.Status = "Non-Genuine Grace Period"; break outer}
                5 {$lic.Status = "Notification"; break outer}
                6 {$lic.Status = "Extended Grace"; break outer}
                default {$lic.Status = "Unknown value"}
            }
            $out += $lic;
            if(($lic.Name).Contains("Windows")){
                if($lic.Status -eq 1){
                    $b = $true;
                }else{
                    log("    >> ERROR: "+ $lic.Name +" is not licensed.");
                    return $false;
                }
            }
        }
    } #else {$out.Status = $status.Message}
    write-host "reached the end"
    return $b;
}
function checkInstalledRam($n){
    if((getInstalledRam) -ge $n){
        return $true;
    }else{
        log("    >> ERROR: Add "+($n-(getInstalledRam))+" RAM.");
        return $false;
    }
}
function checkUniPush($pushPath){
    $b = $true;
    $files = @("", `
        "PrinterDrivers", `
        "NDDC", `
        "Scripts", `
        "install_these\Ninite.exe", `
        "install_these\systemupdate5-07-0027.exe"`
    );
    $printerDrivers = @( `
        "Canon\Driver\CNLB0UA64.inf", `
        "HP\UniversalDriver_PCL6\hpbuio200l.inf", `
        "KonicaMinolta\bizhub4750\Win_x64\KOBK1J__.inf", `
        "KonicaMinolta\C3110\bizhubC3110_Win10_PCL_PS_XPS_FAX_v1.2.1.0\Win_x64\KOBK4J__.inf", `
        "KonicaMinolta\BizhubC3850fs_MFP_Win_x64\KOBJ_J__.inf", `
        "Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf", `
        "Kyocera\KyoClassicUniversalPCL6_v1.56\OEMsetup.inf", `
        "Toshiba\64bit\eSf6u.inf", `
        "Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver\x2UNIVX.inf" `
    );
    $shouldBePresent = @(
        @{"base" = ($pushPath +"");"check" = $files;"msg" = "Could not find"},
        @{"base" = ($pushPath +"PrinterDrivers\");"check" = $printerDrivers;"msg" = "Printer Driver inf not found"}
    );
    foreach($c in $shouldBePresent){
        foreach($p in $c.check){
            if (!(Test-Path ($c.base + $p))){ 
                $b = $false; 
                log("    >> ERROR: "+ $c.msg +" [ "+ $c.base + $p +" ]");
            }
        }
    }
    return $b;
}
function checkPS {
    $v = $PSVersionTable.PSVersion.Major;
    if($v -lt 4){
        log("    >> ERROR: Update Powershell to at least version 4.  Current version "+ $v);
        return false;
    } 
    return $true;
}
function checkNet {
    $b = $true;
    $p = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\";
    if(test-path ($p +"\v4")){
        $r = (Get-ChildItem ($p +"\v4"))[0] | Get-ItemPropertyValue -Name Release;
        $v = (Get-ChildItem ($p +"\v4"))[0] | Get-ItemPropertyValue -Name Version
        #write-host ".Net r: $r ; v: $v";
        if($r | % {$_ -lt 394802}){log("    >> ERROR: Upgrade .Net to >= 4.6.2.  Current version "+ $v);$b = $false;}
    }else{
        if(test-path $p){
            ((Get-ChildItem $p).Name) | foreach { $_.substring($_.lastindexof("\")+1) }|foreach{
                $v = 0.0;
                if($_.contains("v")){  
                    $nv = [convert]::ToDouble($_.substring(1));
                    $v = [Math]::Max($v,$nv);
                }
            }
            log("    >> ERROR: Upgrade .Net to >= 4.6.2.  Current version: "+ $v);
        }else{log("    >> ERROR: .Net not installed.  Install .Net >= 4.6.2"+ $v);}
        $b = false;
    }
    return $b;
}
function checkApps(){
    
    $b = $true;
    $shouldBeInstalled = @("7zFM.exe","ccleaner.exe","chrome.exe","firefox.exe","PowerShell.exe");
    $officeApps = @("excel.exe","outlook.exe","powerpnt.exe","winword.exe");
    $shouldBeinstalled | foreach {
        $p = 'hklm:\software\Microsoft\Windows\CurrentVersion\App Paths\'+ $_;
        if(test-path $p){      
            $n = (Get-Item (Get-ItemProperty $p).'(Default)').name;
            $v = (Get-Item (Get-ItemProperty $p).'(Default)').versioninfo.ProductVersion;
        }else{
        $b = $false;
            log("    >> ERROR: "+ $_ +" is not installed.");
        }
    }
    return $b;
}
function checker($s, $c){
    if($c){ 
        log("[ PASS ] $s`: $c"); 
    }else{ 
        log("[ FAIL ] $s`: $c");
    }
    return $c;
}
function findex($f){
    switch ($f.f){
                "checkPS" {$res = checkPS} 
                "checkNet" {$res = checkNet} 
                "checkMemberInGroup" {$res = checkMemberInGroup $f.args[0] $f.args[1]} 
                "checkMachineName" {$res = checkMachineName $f.args[0]} 
                "checkActivationStatus" {$res = checkActivationStatus} 
                "checkInstalledRam" {$res = checkInstalledRam $f.args[0]} 
                "checkUniPush" {$res = checkUniPush $f.args[0]} 
                "checkApps" {$res = checkApps} 
                default {$res = $false;}
    }
    return $res;
}
function checkStandardSetup($params) {
    $res = @();$RAM = 8;    
    $checks = @(`
        @{"msg"="Checking for PS v 4.0 or better";"f"="checkPS";"args"=@()},`
        @{"msg"="Checking for .Net 4.6.2 or better";"f"="checkNet";"args"=@()},`
        @{"msg"="Checking for {0} local admin account" -f $params.admin;"f"="checkMemberInGroup";"args"=@($params.admin, "Administrators")},`
        @{"msg"="Checking for correct computer name";"f"="checkMachineName";"args"=@(("WS-{0}" -f $params.sn))},`
        #@{"msg"="Checking for Windows activation";"f"="checkActivationStatus";"args"=@()},`
        @{"msg"="Checking for {0} Gb RAM or better" -f $params.RAM;"f"="checkInstalledRam";"args"=@($params.RAM)},`
        @{"msg"="Checking for universal push folder {0}" -f $params.pushPath;"f"="checkUniPush";"args"=@($params.pushPath)},`
        @{"msg"="Checking for required applications";"f"="checkApps";"args"=@()}`
    );
    write-host "Starting checks..."   
    foreach($c in $checks){
        try{
            $res += (checker $c.msg (findex($c)));
        }catch{
            log("    >> ERROR: Error with function {0}.  args: {1}" -f @($c.f,$c.args));
        }
    }
    if($res.contains($false)){ $b=$false;}else{ $b=$true;}
    write-host "...Completed checks.  Pass: $b";
    return $b;
}

#.....................................................
#: Constants
#.....................................................
$pushPath = "C:\Users\dbadmin\Google Drive\LocalSync\Documents\AAIT\WIn10DesktopDeployment\"; 
$log = $pushPath + "logs\log_qa.txt";
#.....................................................
#: Execution steps
#.....................................................

Set-Location -Path $pushPath;
. .\Scripts\logger.ps1;
. .\Scripts\WinGUI.ps1;
$sw = startLogging $pushPath "log_qa.txt";
$pass = checkStandardSetup @{"ram"=8;"pushPath"=$pushPath; "sn"=getSerialNumber; "admin"="AllAccess"};
$out = endLogging $sw
#timeout /t -1
$outtitle = "QA Results:"; 
$res = okBox $outtitle $out;

# [] Nable remote control is working

# Client Specific
# [] Joined to Azure domain
# [] Correct push folder(s) is transferred and current
# [] Correct printers installed
# [] No superfluous printers installed
# [] Connected to correct wifi ssid 
# [] AV is installed (Webroot or Security Manager)

#User setup
# [] Office shortcuts are on desktop or in start menu
# [] Outlook is configured for user
# [] Office is activated
# [] Office is connected to correct account
# [] Sharepoint site(s) set up correctly
# [] OneDrive set up
# [] Desktop, Documents, and Pictures are mapped to OneDrive folders
# [] OneDrive sync complete
# [] SharePoint sync complete

