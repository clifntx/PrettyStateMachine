param(
    [string]$configCsv = "",
    $logLevel = -1
    )

function log ($str, $fc="white"){
# fc can be any of these [Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White]
    $fc = $fc.ToLower()
    switch ($fc) {
        "red"      {$priority = 5}
        "yellow"   {$priority = 4}
        "green"    {$priority = 2} 
        "white"    {$priority = 1}
        "gray"     {$priority = 0; $str = "  ..."+$str;}
        "darkgray" {$priority = -1; $str = "  >> "+$str;}
        default {$priority = 1; $fc = "white"}
        }
    if ($priority -ge $logLevel) {
        write-host $str -ForegroundColor $fc
    }
}
function sum($list){
    $sum = 0
    $list | foreach {
        $sum += $_   
    }
    return $sum
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
function buildConfig($configUrl){
    log "Calling buildConfig(`n>>> `$configUrl=$configUrl`n>>> )" "darkgray"  

    $downloadPath = "c:\push\wksMaintenanceConfig.zip"
    $csvPath = "c:\push\wksMaintenanceConfig.csv"
    $lod = @{}
    
    #download and extract csv from url
    #download $configUrl $extractPath
    #extract $extractPath $csvPath
    #convert csv to config lod
    #$csv = Import-Csv $configCsv

    return $lod
}
function getStorageSize($drive=$null){
    log "Calling getStorageSize(`n>>> `$drive=$drive`n>>> )" "darkgray"  
    $data = get-wmiobject win32_LogicalDisk -Filter "DriveType = 3" | 
        Select DeviceID, FreeSpace, Size
    $data | foreach {
        Add-Member -InputObject $_ -NotePropertyName "UsedSpace" -NotePropertyValue ($_.Size - $_.FreeSpace)
    }
    if ($drive -eq $null) {
        $sum = sum $data.Size
        return $sum/1Gb
    }else{
        $data | foreach {
            if($_.DeviceID -contains ($drive + ":")){
                return $_.Size/1Gb
            }
        }
    }
}
function deleteFile($path){
    log " Calling deleteFile (`n>>> `$path=$path`n>>> )" "darkgray" 
    try{
        remove-item -Path $path -Recurse -Force -EA STOP
    }catch [System.IO.IOException]{
        log ">>WARNING: $($ERROR[4].Exception.Message)" "Yellow"
        log ">>   Could not delete [$($error[5].TargetObject)]." "darkgray"

        return $false
    } catch [System.Management.Automation.RuntimeException] {
        log ">> Warning: $($error[0].exception.message)..." "Yellow"
        log "Could not delete [$($error[5].TargetObject)]." "darkgray"
        return $false
    } catch {
        log "E!"
        log ">> UNCAUGHT ERROR: $PSItem" "red"
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
        return $false
    }
}
function deleteDirContents ($dir){
    log " Calling deleteDirContents(`n>>> `$dir=$dir`n>>> )" "darkgray"  

    if(checkToSeeIfDirIsEmpty $dir){
        log "dir [$dir] is already empty.  Skipping" "gray"
        $res = $true

    }else{
        try {
            #del contents of $dir
            log "deleting contents of [$dir]." "gray"
            $files = (dir $dir -Recurse -File | select FullName).FullName 
        
            if($files.Length -lt 1){
                log "dir [$dir] is empty.  Skipping." "gray"
                $res = $true
            }else{
                $files | foreach {
                    deleteFile $_
                }
                log "(dir $dir).Length == $((dir $dir).Length)" "darkgray"
                log "(dir $ndirName).Length == $((dir $ndirName).Length)" "darkgray"
            }
        
 
            #verify dir is now empty
            $res = checkToSeeIfDirIsEmpty $dir  

        } catch [System.Management.Automation.RuntimeException] {
            log ">> CAUGHT ERROR: $($error[0].exception)..." "Yellow"
            log ">> Could not delete [$($error[5].TargetObject)]." "Yellow"
            return $false
        } catch {
            log "E!"
            log ">> UNCAUGHT ERROR: $PSItem" "red"
            log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
            return $false
        }
    }
    return $res
}
function moveAndDeleteDirContents ($dir){
    log " Calling moveAndDeleteDirContents(`n>>> `$dir=$dir`n>>> )" "darkgray"  
    
    #rename C:\Windows\SoftwareDistribution\Download to OLD
    #log "...renaming [$dir] to [$ndirName]." "gray"
    #$t = Rename-Item -Path $dir -NewName $ndirName
    #create a new temp dir
    $ndirName = $dir + "_OLD"
    $n = 1
    while (test-path $ndirName){
        $ndirName = $ndirName + "_$n"
        $n+=1
    }
    log "...creating a new temp dir [$ndirName]." "gray"
    $t = New-Item -Path $ndirName -ItemType Directory
    log "$t" "darkgray"

    try {
        #move contents of $dir to $ndirName
        log "...moving contents of [$dir] to [$ndirName]." "gray"
        Move-Item -Path $dir\* -Destination $ndirName -Force -EA SilentlyContinue
        log "(dir $dir).Length == $((dir $dir).Length)" "darkgray"
        log "(dir $ndirName).Length == $((dir $ndirName).Length)" "darkgray"
    
        #delete contents of ndirName    
        log "deleting dir [$ndirName]." "gray"
        $t = Remove-Item $ndirName -Force -Recurse
        log "$t" "darkgray"
 
        #verify dir is now empty
        $res = checkToSeeIfDirIsEmpty $dir
        return $res  

    } catch [System.Management.Automation.RuntimeException] {
        log ">> CAUGHT ERROR: $($ERROR[0].exception)..." "Yellow"
        log ">> Could not delete [$($ERROR[0].TargetObject)]." "Yellow"
        return $false
    } catch {
        log "E!"
        log ">> UNCAUGHT ERROR: $PSItem" "red"
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
        return $false
    }
}

function checkToSeeIfDirIsEmpty ($pathToDir){
    log "Calling checkToSeeIfDirIsEmpty(`n>>> `$pathToDir=$pathToDir`n>>> )" "darkgray"  
    log "verifiying that dir [$pathToDir] is empty." "gray"
    log "dir ($pathToDir).Length -lt 1" "darkgray"
    try { 
        if (Test-path $pathToDir){  
            $res = (((dir $pathToDir -ErrorAction Stop).Length) -lt 1) 
        }else{
            log "Dir [$pathToDir] does not exist.  Skipping." "gray"
            $res = $true
        }

        $remainingFiles = (dir $pathToDir -ErrorAction Stop).Length

        if ($res){
            log "Successfully deleted all contents of [$pathToDir]." "green"
        }elseif ($remainingFiles -lt 10){
            log "Successfully deleted almost all contents of [$pathToDir].  $remainingFiles remaining." "green"
        }else{
            log "Failed to delete contents of [$pathToDir].  $remainingFiles remaining" "red"        
        }
        return $res   
    } catch [System.Management.Automation.ItemNotFoundException] {
        log ">> WARNING: $($ERROR[0].Exception.Message)" "Yellow"
        return $true
    } catch {
        log "E!"
        log ">> UNCAUGHT ERROR: $PSItem" "red"
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
        return $false
    }
}

function deleteTempFiles (){
    log "Calling deleteTempFiles(`n>>> no args`n>>> )" "darkgray"
    $tdirs = @(
        "c:\temp",
        “C:\Windows\Temp",
        “C:\Windows\Prefetch",
        “C:\Documents and Settings\Local Settings\temp”
        )
    #delete the files from $tdirs recursively
    $res = @()
    $tdirs | foreach {
        $r = deleteDirContents $_
        $res += @{
            "dir"=$_;
            "res"=$r;
        }
    }
    return !($res.res).contains($false)
}
function checkTempDirs (){
    log "Calling checkTempDirs(`n>>> no args`n>>> )" "darkgray"
    $tdirs = @(
        "c:\temp",
        “C:\Windows\Temp",
        “C:\Windows\Prefetch",
        “C:\Documents and Settings\Local Settings\temp”
        )
    #check to see if  the files from $tdirs recursively
    $res = @()
    $tdirs | foreach {
        $r = checkToSeeIfDirIsEmpty $_
        $res += @{
            "dir"=$_;
            "res"=$r;
        }
    }
    return !($res.res).contains($false)
}

function deleteUserTempFiles(){
    log "Calling deleteUserTempFiles(`n>>> no args`n>>> )" "darkgray"
    try{
        foreach ($u in (get-item c:\users\*).Name) {
            log "checking temp files for [$u]." "gray"
            $tds = (Get-ChildItem ("C:\Users\" +$u+ "\AppData\Local\Temp\") -Recurse -ErrorAction SilentlyContinue | 
                ?{ $_.PSIsContainer } |
                select FullName).FullName
            $tds += "C:\Users\" +$u+ "\AppData\Local\Temp\"
            if ($tds.Length -gt 0){
                $tds | foreach {
                    log "deleting contents of [$_]." "gray"
                    try{
                        Remove-Item $_ -Recurse -Force -ErrorAction Continue
                    } catch {
                        log "E!"
                        log ">> UNCAUGHT ERROR: $PSItem" "red"
                        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
                    }
                }
            }else{
                log "no files to delete for [$u]" "gray"
            }
        }
        $res = $true
    } catch [System.UnauthorizedAccessException] {
        log ">> Skipping [$($ERROR[0].TargetObject)]. $($ERROR[0].Exception)" "yellow"
        return $false
    } catch {
        log "E!"
        log ">> UNCAUGHT ERROR: $PSItem" "red"
        log ">> UNCAUGHT ERROR: $($Error[0].Exception.GetType().fullname)" "red"
        return $false
        }
    return $res
}
function deleteOldUpdateFiles(){
    log "Calling deleteOldUpdateFiles(`n>>> no args`n>>> )" "darkgray"
    $ufDir = "C:\Windows\SoftwareDistribution"
    log "pre function (dir $ufDir).Length == $((dir $ufDir).Length)" "darkgray"
    #Stop Windows Update Service (wauaserv)
    $wus = "wuauserv"
    $n = 0
    while(((get-service $wus).Status -ne "Stopped") -and ($n -lt 5)){
        Stop-Service $wus
        $n+=1
        timeout /t 5
        if($n -gt 5){
            log "...timed out while waiting for svc to close." "red"
            return $false
            break
        }
    }
    log "Service State [$((get-service $wus).DisplayName)]: [$((get-service $wus).Status)]" "darkgray"
    #delete update dir and replace with a blank dir
    $res = deleteDirContents $ufDir
    #Start Windows Update Service (wauaserv)
    Start-Service $wus
    log "Service State [$((get-service $wus).DisplayName)]: [$((get-service $wus).Status)]" "darkgray"
    log "post function (dir $ufDir).Length == $((dir $ufDir).Length)" "darkgray"
    return $res    
}
function emptyRecyclingBin(){
    log "Calling emptyRecyclingBin(`n>>> no args`n>>> )" "darkgray"
    #doesn't work on psv2, works in v5
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}
function flushDNS() {
    log "Calling flushDNS(`n>>> no args`n>>> )" "darkgray"
    Clear-DnsClientCache
}
function runDiskCleanup(){
    log "Calling runDiskCleanup(`n>>> no args`n>>> )" "darkgray"
    $t = cleanmgr /verylowdisk
    $n = 0
    While($true) {
        timeout /t 10
        if(checkTempDirs){
            log "...completed disk cleanup." "gray"            
        }
        if($n -gt 5){
            log "WARNING: Timed out while waiting for Dick Cleanup." "Yellow"
            break
        }
        $n += 1
    }
}
function runDiskCheck(){
    log "Calling runDiskCheck(`n>>> no args`n>>> )" "darkgray"
    $t = CHKDSK /B /X
}
function defragDisk($disk){
    log "Calling defragDisk(`n>>> `$disk=$disk`n>>> )" "darkgray"
    pass
}
function main(){
    #buildConfig
    $pre = getStorageSize
    
    deleteTempFiles
    #deleteUserTempFiles
    deleteOldUpdateFiles
    emptyRecyclingBin
    flushDNS
    runDiskCleanup
    checkTempDirs
    $post = getStorageSize
    log "Removed $($pre-$post) Gb of files." "green"

    #runDiskCheck #schedules a diskcheck for the next reboot
    #Restart-Computer    
}

#may want to upgrade PS first.
clear
main
