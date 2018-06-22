function checkKeys() {
    $cid = (get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Eaglesoft\ -Name ClientID).ClientID
    $cidIsCorrect = $cid -eq "710200744"
    $lnum = (get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Eaglesoft\" -Name LicenseNumber).LicenseNumber
    $lnumIsCorrect = $lnum -eq "710200744-011160-018257-026784-00188063"
    $res = $true
    $msg = "ClientID correct: $cidIsCorrect; LicenseNumber correct: $lnumIsCorrect; `n"
    if(!($cidIsCorrect)) { 
        $msg += " ...wrong cid: $cid `n" 
        $res = $false
        }
    if(!($lnumIsCorrect)) { 
        $msg += " ...wrong license num: $lnum `n" 
        $res = $false
        }
    write-host $msg
    $script:msg += "$msg `n"
    return $res
    }

function checkForEaglesoftRunning {
    $e = Get-Process -Name "Eaglesoft" -ErrorAction SilentlyContinue
    if ($e) {
        $script:msg += "Eaglesoft is running. `n"
        $res = $true
    } else {
        $res = $false
        $script:msg += "Eaglesoft is not running. `n"
        }
    return $res
}

function updateKeys() {
    while(checkForEaglesoftRunning) {
        Stop-Process -InputObject $e
        timeout /t 1
        }
    $msg = "Eaglesoft stopped.  Updating keys... `n"
    if (checkForEaglesoftRunning) {
        $msg += "ERROR: Eaglesoft is still running. Aborting.`n"
    } else {
        # update keys
        Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Eaglesoft\" -Name ClientID -Value 710200744
        Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Eaglesoft\" -Name LicenseNumber -Value 710200744-011160-018257-026784-00188063
        $msg += "...keys updated. `n"
        }
    write-host $msg
    $script:msg += "$msg `n"
    }

$msg = ""
if(checkKeys) {
    $msg += "Keys are correct.  Doing nothing. `n"
} else {
    updateKeys
    if(checkKeys){
        start-process "C:\Eaglesoft\Shared Files\Eaglesoft.exe"
        checkForEaglesoftRunning
        }
    }
write-host $msg