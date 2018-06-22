function addMembersToDGs($importDir) {
    $csvs | foreach { 
        write-host "Processing [ $_ ]..."
        $gname = $_.Substring(0,$_.Length-4)
        #write-host "group name [$gname]"
        try {
            $g = Get-DistributionGroup -Identity $gname;
        } catch {
            write-host "Could not find group [ $gname ]";
        }
        $csv = Import-Csv ($importDir + $_);
        $csv.Members | foreach { 
            try {
                $u = Get-Mailbox -Identity $_;
                $glist = (Get-DistributionGroupMember -Identity 5_star_leaders@tss-cpa.com).Name
                if ($glist -contains "Mitchell.Stagnone") {
                    write-host "...Already a member [ $_ ].";
                } else {
                    write-host "...Not a member.  Adding [ $_ ] to [ $gname ].";
                    Add-DistributionGroupMember -Identity $g.Identity -Member $u.Identity;
                }
            } catch {
                write-host "<ERROR> addMembersToDGs:Add-DGMember:catch -> could not add member [ $_ ]";
            }
        }
    }
}

clear;

$scriptpath = $MyInvocation.MyCommand.Path;
$dir = Split-Path $scriptpath;
. $dir\ConnectToO365.ps1;
. $dir\logger.ps1;

$pushPath = "c:\push\";
$logName = "TSO365Migration_MailObjectCreation.txt";
$sw = startLogging $pushPath $logName;
log("Importing $dir\ConnectToO365.ps1...");

$ExchangeSession = connectToO365;
log("Connected to O365.");

$importDir = "C:\Users\ClifBoyd\All-Access Infotech, LLC\Service Desk - Service Operations\Projects\TSO365Migration\DG_Groups_CSVs\";
addMembersToDGs($importDir)

disconnectFromO365($ExchangeSession);
endLogging ($sw);