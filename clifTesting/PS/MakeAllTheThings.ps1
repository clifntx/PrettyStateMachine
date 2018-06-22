function makeCsv ($csvPath){
    $csv = Import-Csv $csvPath;
    $l = ($csv[0] | Get-Member -MemberType NoteProperty).length;
    $h = ($csv[0] | Get-Member -MemberType NoteProperty).Name;
    log("Imported csv with $l columns: [ $h ]");
    return $csv
}
function createRoom($row){
    log("calling method createRoom(" +$row.dname+ ")");
    $res = "ROOM [" + $row.DisplayName + "].";

    try { $o365email = (get-mailbox -Identity $row.email -ErrorAction SilentlyContinue).PrimarySmtpAddress; } catch { $o365email = ""; }

    if ($o365email.length -gt 0) {
        log("Room already exists [row: $row.email ][ from O365: $mbemail ], doing nothing.");
        Set-CalendarProcessing -Identity $r.Identity -AutomateProcessing AutoAccept -AddOrganizerToSubject $False -DeleteSubject $False;
    } else {    
        log("Mailbox not found, creating mailbox."); 
        $r = New-Mailbox -Room -PrimarySmtpAddress $row.email -Name $row.dname -ErrorAction SilentlyContinue;
        Set-CalendarProcessing -Identity $r.Identity -AutomateProcessing AutoAccept -AddOrganizerToSubject $False -DeleteSubject $False;

        $row.members | foreach {             
            Add-MailboxPermission -Identity $r.Identity -User $_ -AccessRights FullAccess -InheritanceType All -ErrorAction SilentlyContinue;
            Add-MailboxFolderPermission ($r.PrimerySMTPAddress + ":\Calendar") -User $_ -AccessRights Editor -ErrorAction SilentlyContinue;
        }
        
        log("Created mailbox [ " +(get-mailbox -Identity $row.email).PrimarySmtpAddress+ " ]"); 
    }
   
    log("...leaving createSharedMailbox(" +$row.dname+ ")");
    return $res;
}
function createSharedMailbox($row){
    log("calling method createSharedMailbox(" +$row.dname+ ")");
    $res = "Shared Mailbox [" + $row.dname + "].";

    try { $o365email = (get-mailbox -Identity $row.email -ErrorAction SilentlyContinue).PrimarySmtpAddress; } catch { $o365email = ""; }

    if ($o365email.length -gt 0) {
        log("Shared mailbox already exists [row: $row.email ][ from O365: $mbemail ], doing nothing.");
    } else {
        log("Mailbox not found, creating mailbox.");
        New-Mailbox -Shared -Name $row.dname  -DisplayName $row.dname -Alias $row.alias -PrimarySmtpAddress $row.email;
        Set-Mailbox -Identity $row.email -DeliverToMailboxAndForward $true;

        $row.members | foreach {             
            Add-MailboxPermission -Identity $row.alias -User $_ -AccessRights FullAccess -InheritanceType All -ErrorAction SilentlyContinue;
        }
        
        log("Created mailbox [ " +(get-mailbox -Identity $row.email).PrimarySmtpAddress+ " ]"); 
    }
   
    log("...leaving createSharedMailbox(" +$row.dname+ ")");
    return $res;
}
function createSharedCalendar($row){
    log("calling method createSharedCalendar(" +$row.dname+ ")");
    $res = "DEFAULT SharedCalendar";

    try { $o365email = (get-mailbox -Identity $row.email -ErrorAction SilentlyContinue).PrimarySmtpAddress; } catch { $o365email = ""; }

    if ($o365email.length -gt 0) {
        log("Shared mailbox already exists [row: $row.email ][ from O365: $mbemail ], doing nothing.");
    } else {
        log("Mailbox not found, creating mailbox.");
        $c = New-Mailbox -Shared -Name $row.dname  -DisplayName $row.dname -Alias $row.alias -PrimarySmtpAddress $row.email;
        Set-Mailbox -Identity $c.Identity -DeliverToMailboxAndForward $true;
        Set-CalendarProcessing -Identity $c.Identity -AutomateProcessing AutoAccept -AddOrganizerToSubject $False -DeleteSubject $False

        $row.members | foreach {             
            Add-MailboxPermission -Identity $c.Identity -User $_ -AccessRights FullAccess -InheritanceType All -ErrorAction SilentlyContinue;
            Add-MailboxFolderPermission ($c.PrimerySMTPAddress + ":\Calendar") -User $_ -AccessRights Editor -ErrorAction SilentlyContinue;
        }
        
        log("Created Shared Calendar [ " +(get-mailbox -Identity $row.email).PrimarySmtpAddress+ " ]"); 
    }
    return $res;
}
function createSG($row){
    log("calling method createSG(" +$row.dname+ ")");
    $res = "Creating SG [ " +$row.dname+ " ] ";

    try { $o365name = (get-MsolGroup -SearchString $row.alias -ErrorAction SilentlyContinue).DisplayName; } catch { $o365name = ""; }

    if($o365name.length -gt 0){
        $res += "SG already exists. ";
    } else {
        $g = New-MsolGroup -DisplayName $row.dname -Description $row.desc -ErrorAction SilentlyContinue;
        $res += "Created SG [ " +$g.DisplayName+ " ]. ";
    }

    if ($members.length -gt 0){
        $res = "Added the following members to ["+$g.DisplayName+"]: ";
        $row.members | foreach {
            try { 
                $u = Get-MsolUser -UserPrincipalName $_ -ErrorAction SilentlyContinue; 
            } catch { 
                write-host "createDG:catch- Error finding user [ $_ ]"; $u = $null; 
            }

            $u = Get-MsolUser -UserPrincipalName $_ -ErrorAction SilentlyContinue;
            if (!($u -eq $null)){
                Add-MsolGroupMember -GroupObjectId $g.ObjectId -GroupMemberType User -GroupMemberObjectId $u.ObjectId -ErrorAction SilentlyContinue; 
                $res += ($u.UserPrincipalName+", ");
            }
        }
    res += "Member import complete.";    
    } else {
        $res += "No members added.";
    }
    
    return $res;    
}

function createDG($row){
    log("calling method createDG(" +$row.dname+ ")");
    $res = "Creating DG [ "+$row.dname+" ]: ";

    try { $o365group = (get-DistributionGroup -Identity $row.alias -ErrorAction SilentlyContinue).DisplayName; } catch { $o365name = ""; }

    if($o365group.length -gt 0){
        $res += "DG already exists [ "+$g.DisplayName+" ].";
    } else {
        $g = New-DistributionGroup -DisplayName $row.dname -Name $row.alias -PrimarySmtpAddress $row.email -Type "Distribution" -RequireSenderAuthenticationEnabled $false -ErrorAction SilentlyContinue;
        $res += "Created DG [ "+$g.DisplayName+" ]";       
    }

    if ($members.length -gt 0){
        $res = "Added the following members to ["+$g.DisplayName+"]: ";
        $row.members | foreach {
            try { $u = Get-MsolUser -UserPrincipalName $_ -ErrorAction SilentlyContinue; } catch { write-host "createDG:catch, error finding user [ $_ ]"; $u = $null; }

            if (!($u -eq $null)){
                Add-DistributionGroupMember -Identity $g.Identity -Member $u.Identity -ErrorAction SilentlyContinue;
                $res += ($u.UserPrincipalName+", ");
            }
        }
    $res += "Member import complete.";    
    } else {
        $res += "No members added.";
    }    
    return $res;
}
function createStuffs($csv) {
    log("...createStuffs()...");
    $res = @();
    $csv | foreach {
        try { $members = $_.Members.Split(",") } catch { $members = ""; }
        try { $desc = $row.desc; } catch { $desc = "";}
        $row = @{
            email = $_.Email;
            alias = $_."Display Name" -replace '\s','_';
            dname = $_."Display Name";
            desc = $members;
            members = $desc;
        }
        #write-host "Created row: [$row]"
        if (($row.email).length -gt 0) {
            switch($_.Type) {
                "Room"{$msg = createRoom $row }
                "Shared Mailbox"{$msg = createSharedMailbox $row }
                "Distribution Group - Universal"{$msg = createDG $row }
                "Shared Calendar"{$msg = createSharedCalendar $row}
                default{$msg = "ERROR: Did not find method for [$_].";}
            }
        } else {
            log("...Email is empty string.  Doing nothing. [ " +$row.email+ " ]");
        }
        log($msg);
        #$res += $msg;
        #write-host $msg;
    }
    return $res;
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

#$ExchangeSession = connectToO365;
log("Connected to O365.");

$p = "$dir\mailObjects.csv";
log("Importing data from [$p]");

$res = createStuffs(makeCsv $p);
#$res | foreach { log($_); }

#disconnectFromO365($ExchangeSession);
#endLogging ($sw);