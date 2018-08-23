function log($s,$c){write-host $s -ForegroundColor $c}
function checkWriter($w){

}
$writers = @{
    "System Writer"="CryptSvc";
    "ASR Writer"="VSS",
    "IIS Config Writer"="AppHostSvc";
    "Shadow Copy Optimization Writer"="VSS";
    "Registry Writer"="VSS";
    "COM+ REGDB Writer"="VSS";
    "IIS Metabase Writer"="IISADMIN";
    "DFS Replication service writer"="DFSR";
    "WMI Writer"="Winmgmt";
    "NTDS"="NTDS"
}
$writers.keys | foreach {

    if(checkWriter){
        write-host "Writer [$_] is good."
    } else {
        write-host "Writer [$_] has failed.  Restarting [$($writers[$_])]"
    }

    Restart-Service $writers[$_]
}