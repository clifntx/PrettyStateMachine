#copy eyecare folder to test server
Param(
    [string]$source = "C:\Temp\Old\",
    [string]$dest = "C:\Temp\New\",
    [string]$userLogPath = "c:\users\Administrator\Desktop\",
    [string]$logPath = "c:\push\logs\backup_log.txt"

)
function log($str){
    $dir = ((($logPath.Split("\"))[0..($logPath.Split("\").Length-2)]) -join "\");
    if(!(test-path $dir)){ 
        mkdir $dir;
        }
    $str | Out-File $logPath -Append;
    }
     


function renameDestFolder($destPath){
    $destPath = $destPath.Trim("\");
    $destDir = $dest.trim("\").split("\")[-1];
    $renDir = "OLD_$destDir";
    $renPath = ($dest.trim("\").split("\")[0..($dest.trim("\").split("\").Length-2)] -join "\") + "\" + $renDir;

    if(test-path ($destPath)) {
        if(test-path $renPath) {
            log("..found renPath [$renPath], deleting.");
            del $renPath -Recurse;
            }
        log("..Renaming dest [$destPath] to [$renPath]...");
        ren $destPath $renPath;
    } else {
        log("..destination not found.  Creating [$destPath] and renaming to [$renPath]...");
        mkdir $destPath;
        ren $destPath $renPath;
        }
}
function copyFolder($source, $dest) {
    log("..Copying files...");
    $res = robocopy $source $dest /e /r:3 /w:10 /log:servermig.log;
    log("..Logging results to: $res");
}
function checkDest($source, $dest) {
    log("..Confirming that $source has replicated to $dest"); 
    $isVerified = $true;
    (Get-ChildItem $source -recurse).FullName | foreach { 
        $path = $_.toLower().Replace($source.toLower(), $dest.toLower()); 
        #log("..checking $path");
        $errs = @();
        if (!(test-path $path)) {
            $isVerified = $false;
            write-host "..FALSE [$path]";
            $errs += $path;
            }
        }
    $errs | foreach {
        log("..could not verify file [$_].")
        }
    $l = $errs.Length;
    write-host "Verified? $isVerified; [$l] errors.";
    return $isVerified;
}

function main($dest, $source, $terryLog) {
    #rename dest folder exists
    renameDestFolder($dest)
    #move folder
    copyFolder($source, $dest);
    #check for success
    if(checkDest $dest $source) {
        log("..Confirmed successful copy..");
        write-host $terryLog;
        logForUser $terryLog "Successfully backed up folder [$source] to [$dest].";
    } else {
        log("..Copy failed..");
        logForUser $terryLog "Failed to backup folder [$source] to [$dest].";
    }
    # complete
    log("Completed file backup script.");    
}

clear;

$scriptpath = $MyInvocation.MyCommand.Path;
$dir = Split-Path $scriptpath;
. $dir\logger.ps1;
$pushPath = "c:\push\";
$logName = "fileBackup_log.txt";
$sw = startLogging $pushPath $logName;

$destPath = "C:\Temp\Old\";
$sourcePath = "C:\Temp\New\";
$terryPath = "C:\Push\logs\";
$terryLog = ($terryPath + $logName);

main $destPath $sourcePath $terryLog;
#checkDest $destPath $sourcePath;

endLogging ($sw);