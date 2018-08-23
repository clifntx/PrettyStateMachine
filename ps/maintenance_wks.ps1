param(
    [string]$configCsv = "",
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
function deleteDirContents ($dir){
    log " Calling deleteDirContents(`n>>> `$dir=$dir`n>>> )" "darkgray"
    $ndirName = $dir + "_OLD"
    #rename C:\Windows\SoftwareDistribution\Download to OLD
    log "...renaming [$dir] to [$ndirName]." "gray"
    Rename-Item -Path $dir -NewName $ndirName
    log ">> (dir $ndirName).Length == $((dir $dir).Length)" "darkgray"
    #create a new blank dir
    log "...creating a new dir [$dir]." "gray"
    New-Item -Path $dir -ItemType Directory
    log ">> (dir $dir).Length == $((dir $dir).Length)" "darkgray"
    #delete renamed dir    
    log "...deleting dir [$ndirName]." "gray"
    Remove-Item $ndirName -Force -Recurse
    #verify dir is now empty
    
    log "...verifiying that deleting dir is empty [dir ($dir).Length -lt 1]." "gray"
    $res = (((dir $dir).Length) -lt 1)
    if ($res){
        log "...Successfully deleted contents of [$dir]." "green"
    }else{
        log "...Failed to delete contents of [$dir]." "red"        
    }

    return $res  
}
function deleteTempFiles (){
    $tdirs = @(
        "c:\temp",
        "c:\windows\temp"
        ) #how to add %user%\appdata\temp for all users?

    #delete the files from $tdirs recursively
    $res = @()
    $tdirs | foreach {
        $r = deleteDirContents $_
        $res += @{
            "dir"=$_;
            "res"=$r;
        }
    }
    return $res
}
function deleteOldUpdateFiles(){
    log " Calling deleteOldUpdateFiles(`n>>> no args`n>>> )" "darkgray"
    $ufDir = "C:\Windows\SoftwareDistribution"
    log ">> pre function (dir $dir).Length == $((dir $dir).Length)" "darkgray"
    #Stop Windows Update Service (wauaserv)
    Stop-Service wuauserv
    #delete update dir and replace with a blank dir
    $res = deleteDirContents $ufDir
    #Start Windows Update Service (wauaserv)
    Start-Service wuauserv
    log ">> post function (dir $dir).Length == $((dir $dir).Length)" "darkgray"
    return $res    
}
function emptyRecyclingBin(){
    Clear-RecycleBin #doesn't work on psv2, works in v5
}
function flushDNS() {

}
function runDiskCleanup(){

}
funcion runDiskCheck(){

}
function defragDisk($disk){

}
function main(){
    buildConfig

    deleteTempFiles
    deleteOldUpdateFiles
    emptyRecyclingBin
    flushDNS
    runDiskCleanup
    runDiskCheck
    defragDisk
}

#may want to upgrade PS first.
main $configCsv
