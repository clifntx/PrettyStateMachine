param(
    [int]$logLevel = -1,
    [string]$desiredStatus = $true
    )

function log ($str, $fc="white"){
# fc can be any of these [Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White]
    $fc = $fc.ToLower()
    switch ($fc) {
        "red"      {$priority = 5}
        "yellow"   {$priority = 4}
        "green"    {$priority = 2} 
        "white"    {$priority = 1}
        "gray"     {$priority = 0; $str = "  " + $str;}
        "darkgray" {$priority = -1; $str = "> " +$str;}
        }
    if ($priority -ge $logLevel) {
        write-host $str -ForegroundColor $fc
        }
    }
function checkBitLockerStatus($desiredStatus) {
    log "Calling checkBitLockerStatus(`n>>> desiredStatus=$desiredStatus`n>>> )" "darkgray"  
        try {
            $statuses = Get-BitLockerVolume -ErrorAction Stop
            log "...Get-BitLockerVolume returned $($statuses.Length) results." "gray"
        } catch [System.Management.Automation.CommandNotFoundException] {
            log ">> CAUGHT ERROR: machine could not locate [Get-BitLockerVolume] cmdlet.  Attempting cmd backup function." "gray"
            log ">> $PSItem"
            $res = checkBitLockerStatusViaCMD $desiredStatus
        } catch [Microsoft.Management.Infrastructure.CimException] {
            log ">> CAUGHT ERROR: < $PSItem> Please re-run in an elevated session." "Yellow"
            return $false
        } catch {
            log ">> UNCAUGHT ERROR: $PSItem" "red"
            log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
            return $false
            }
        $enables = @()
        foreach ($s in $statuses) {
            log "...VolumeStatus for volume [$($s.MountPoint)]: $($s.VolumeStatus)" "gray"            
            switch($s.VolumeStatus) {
                "FullyDecrypted" {$c = "red"; $enabled = $false; }
                "FullyEncrypted" {$c = "green"; $enabled = $true; }
                }
            log "...Volume [$($s.MountPoint)] encryption status: [$($s.ProtectionStatus)] $($s.VolumeStatus)" $c
            log "  ...adding [$($desiredStatus -eq $enabled)] to `$enables" "darkgray"
            $enables += ($enabled)
            }
        log "  ...`$enables==$enables" "darkgray"
        log "  ...`$desiredStatus==$desiredStatus" "darkgray"
        log "  ...returning `$enables.contains(!`$desiredStatus)==[$(!$enables.contains(!$desiredStatus))]" "darkgray"
        return !$enables.contains(!$desiredStatus)
    }
function checkBitLockerStatusViaCMD($desiredStatus) {
    log "Calling checkBitLockerStatusViaCMD(`n>>> desiredStatus=$desiredStatus`n>>> )" "darkgray"  
    try {
        $status = manage-bde -status
        log "...`$status==$status" "darkgray"
        $needAdminAccessString = "ERROR: An attempt to access a required resource was denied."
        if(
            @($status|foreach{$_.contains($needAdminAccessString)}).contains($true)
            ) {
                throw "Needs admin rights.  Please re-run in an elevated session."
                $status = $null
        } elseif(
            @(($status)|foreach{$_.contains("Protection On")}).contains($true)
            ) {
                $enabled = $true
                log "...found [`"Protection On`"].  enabled=$enabled" 'gray'
        } elseif(
            @(($status)|foreach{$_.contains("Protection Off")}).contains($true)    
            ) {
                $enabled = $false
                log "...found [`"Protection Off`"].  enabled=$enabled" 'gray'
        } else {
            throw "Invalid output from manage-bde -status.  "
            }
        log "...checking ($desiredStatus -eq $enabled)." "gray"
        $res = ($desiredStatus -eq $enabled)
        if($res){$c ="green"}else{$c="red"}
        log "...checkBitLockerStatusViaCMD($desiredStatus) returning $res." $c
        return $res

    } catch [System.Management.Automation.RuntimeException] {
        log ">> CUSTOM ERROR: <checkBitLockerStatusViaCMD($desiredStatus)> $($Error[0].Exception.Message)" "Yellow"
        return $false
    } catch {
        log ">> UNCAUGHT ERROR: $PSItem" "red"
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
        return $false
        }
    }
function setBitLockerStatus ($newStatus) {
    switch($newStatus) {
        $true {Enable-Bitlocker -ErrorAction Stop}
        $false {Disable-Bitlocker -ErrorAction Stop}
        default {throw (">>ERROR: Please enter a valid boolean value.  To turn on encryption: setBitLockerStatus `$true")}
        }
    if (checkBitLockerStatus -eq $newStatus) {
        log "...sucessfully updated BitLocker status to [$newStatus]." "gray"
    } else {
        log "...failed to update BitLocker status to [$newStatus]." "red"
        }
    }

function main ($logLevel, $desiredStatus) {
    if($desiredStatus.contains("true")){ 
        $desiredStatus = $true
    } elseif ($desiredStatus.contains("false")){ 
        $desiredStatus = $false
    } else { 
        $desiredStatus = $desiredStatus
    }

    log "Checking if BitLocker status is [$desiredStatus]." "white"
    #$res = checkBitLockerStatus $desiredStatus
    $res = checkBitLockerStatusViaCMD $desiredStatus

    if($res){
        log "PASS: Bitlocker status [$res] -eq desiredStatus [$desiredStatus]" "green"
        return 1
    } else {
        log "FAIL: Bitlocker status [$res] does not equal desiredStatus [$desiredStatus]" "red"
        return 0
        }
    #log "BitLocker status [$res]." "white"
    #return $res
    }
    

clear
main $logLevel $desiredStatus