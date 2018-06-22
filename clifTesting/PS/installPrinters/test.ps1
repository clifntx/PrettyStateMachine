
# CONSTANTS
$PUSH_PATH = "C:\Push";
$SCRIPT_PATH = "\\192.168.1.24\technet\Setup_Workstations\scripts"
$UNIPUSH_PATH = "\\192.168.1.24\technet\Setup_Workstations\UniversalPushFolder\Push";

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

function installSoftware ($installerDir="$PUSH_PATH\install_these") {
    log "Calling installSoftware(`n>>> installerDir=$installerDir`n>>> )" "darkgray"
    log "Installing needed applications." "white"
    
    # Checks for Lenovo and installs System Update if Lenovo
    $x = Get-WmiObject Win32_BaseBoard | Select-Object Manufacturer
    if($x.Manufacturer -eq "LENOVO"){ 
        log "...identified this as a Lenovo device.  Installing System Update." "gray"
        $command = {'$installerDir\systemupdate.exe /verysilent /norestart;'}
        $call = Invoke-Command -ScriptBlock $command
        log "      > $call" "darkgray" 
        }
    # Installs Ninite
    #log "Running Ninite installer." "White"
    #Invoke-Command -ScriptBlock { "$installerDir\ninite.exe;" }
    # Installs NiniteVLC
    #log "Running Ninite VLS installer." "White"
    #Invoke-Command -ScriptBlock { c:\push\niniteVLC.exe; }

    @("ninite.exe", "niniteVLC.exe") | foreach {
        log "...running $_ installer." "gray"
        $command = {"$installerDir\$_;"}
        #$call = Invoke-Command -ScriptBlock $command
        #log "      > $call" "darkgray"
        }
    }

installSoftware