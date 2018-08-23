param(
    [string]$source = $(throw "Please enter a valid source arg.  ex. -source `"c:\data\stufftobackup`""),
    [string]$destination = $(throw "Please enter a valid source arg.  ex. -destination `"\\nas\data\backupfolder`"")

)

filter timestamp {"$(Get-Date -UFormat "[ %b%d%Y %H:%M:%S ]"): $_"}

$log = "c:\push\backupMediaDrive\log_backupMediaDrive.txt";
$changelogfile = "c:\push\backupMediaDrive\changelog\log_robocopyBackup_$(Get-Date -UFormat "%b%d%Y_%H%M").txt";

#write text to log
function log($s) {    
    Write-Host ("$s" | timestamp)
    Add-Content $log ("$s`n" | timestamp)
    }
function lognotts($s) {    
    Write-Host ("$s")
    Add-Content $log ("$s`n")
    }

#$source = "\\STOREEASY1450\MediaShare"
#$destination = "\\192.168.1.140\Backups\storeeasy1450\MediaDriveBackup"

lognotts "=========================================================================="
log "Logging to status to [$log]."
log "Logging change record to [$changelogfile]."
log "Started robocopy from [$source] to [$destination]"
$res = robocopy $source $destination /E /XO /TEE /NFL /r:3 /w:1 /log+:$changelogfile
log "Robocopy results:"
lognotts "      ---------------------------------"
$res[($res.Length-7)..($res.Length-2)] | foreach {
    lognotts "     | $_"
}
lognotts "       ---------------------------------"
log "Completed robocopy"


