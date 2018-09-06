param(
    $repoPath= "https://s3.amazonaws.com/aait/scripts/clientSetup.ps1", #$(throw "No config provided.  Please include the path to a config csv."),
    $pushPath = "C:\Push",
    $logLevel = 2
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
        }
    if ($priority -ge $logLevel) {
        write-host $str -ForegroundColor $fc
        }
    }

function download($driverUrl, $downloadPath) {
    log " Calling download(`n>>> -driverUrl $driverUrl`n>>> -downloadPath $downloadPath`n>>> )" "darkgray"
    try {
        if (test-path $downloadPath) { remove-item $downloadPath -Force }
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
function makeFolder($path){
    if(Test-Path $path){
        log "Folder already exists [$path]" "gray"
    }else{
        $t = mkdir $path
        log "Created folder [$path]" "gray"
    }
    return (test-path $path)
}
function runScript($path, $margs = @()){
    log "Calling runScript(`n>>> `$path `"$path`"`n>>> `$margs=$margs`n>>> )" "darkgray"   
    log "calling: $path $margs" "Gray"
    Invoke-Expression "& `"$path`" $margs"
}
function main ($customerId, $repoPath, $path){
    log "Calling main(`n>>> -customerId `"$customerId`"`n>>> -repoPath `"$repoPath`"`n>>> -path `"$path`"`n>>>`n>>> )" "darkgray"
    if($repoPath.contains("http")){
        $repoIsUrl = $true
        if(download $repoPath $path) {
            log "Downloaded script." "gray"
        } else {
            log ">>ERROR: Could not download script from `"$repoPath`"" "red"
            $customerId = "001"
        }
    } else {
        $repoIsUrl = $false
        log "Pulled script." "gray"
    }
    $lod = @()
    $csv = @(@{"name"="01";"num"=1};@{"name"="02";"num"=2};@{"name"="03";"num"=3};@{"name"="04";"num"=4})
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
    makeFolder $path.Substring(0,$path.LastIndexOf("\"))
    $margs = ("-logLevel", "$script:logLevel")
    runScript $path @("-logLevel", "$script:logLevel")
    #timeout /t 20
    Remove-Item -Path $path
    New-Item -Path $path
}
$path = "$pushPath\temp3.ps1"
clear
main 001 $repoPath $path