param(
    [string]$exportPath = $(throw 'No exportpath provided.  Please include a valid path to export csv to.  ex. -exportpath "c:\push\test.csv"'),
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
function connectO365($UserCredential) {
    log " Calling connectO365(`n>>> no args`n>>> )" "darkgray"
    log "connecting..."
    Import-Module MsOnline ;
    Connect-MsolService -Credential $UserCredential;
    $ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/  -Credential $UserCredential -Authentication Basic -AllowRedirection 
    Import-PSSession $ExchangeSession -AllowClobber #-WarningAction ContinueSilently

    return $ExchangeSession
}

function disconnectO365 ($ExchangeSession){
    log " Calling disconnectO365(`n>>> no args`n>>> )" "darkgray"
    log "disconnecting..."
    #Remove-PSSession $ExchangeSession
    Remove-PSSession *
}

function getDGData($id){
    log " Calling getDGData(`n>>> `$id=$id`n>>> )" "darkgray"        
    $ng = @{}
    $mgroup = get-msolgroup -objectid $id
    $members = Get-MsolGroupMember -GroupObjectId $mgroup.ObjectId
    try {

        $group = Get-DistributionGroup $mgroup.DisplayName -ea Stop
        $keys = @('ObjectId','DisplayName','GroupType','EmailAddress')
        $keys | foreach {
            $ng[$_] = $group.$_;
        }
        $ng['Members'] = Get-MsolGroupMember -GroupObjectId $mgroup.ObjectId
        return $ng

    } catch [System.Management.Automation.RemoteException]{
        if($Error[0].Exception.Message -eq "The current operation is not supported on GroupMailbox."){
            #group mailbox
            return getSGData $id
        }else{
            #throw error
            log "ERROR: $($Error[0].Exception.Message)" "Red"
        }
    } catch [System.Management.Automation.ParameterBindingException]{
        log "ERROR: Unabled to retrieve DG information for [$($mgroup.DisplayName)].  gid: [$($mgroup.ObjectId)]" "red"
        if($ERROR[0].Exception.Message.Contains("Cannot bind parameter 'GroupObjectId' to the target")){
            log "Invalid GroupObjectId" "red" 
        }
        log "$ERROR.Exception.Message" "red"
    } catch {
        log "$ERROR[0].Exception.gettype().fullname" "red"
        log "$ERROR.Exception.Message" "red"
    }
}
function getSGData($id){
    log " Calling getSGData(`n>>> `$id=$id`n>>> )" "darkgray"    
    $keys = @('ObjectId','DisplayName','GroupType')
    $ng = @{}
    $group = get-msolgroup -objectid $id
    $members = Get-MsolGroupMember -GroupObjectId $group.ObjectId
    $keys | foreach {
        $ng[$_] = $group.$_;
    }
    $ng['Members'] = $members

    return $ng
}

function buildGroupList(){
    log " Calling buildGroupList(`n>>> no args`n>>> )" "darkgray"
    $groupList = @()   
    #$mgs =  
    Get-MsolGroup | foreach {
        log "processing [$($_.DisplayName)]..." "gray"
        $ng = @{
            "id"= $_.ObjectId;
            "type"= $_.GroupType;
            "name"= $_.DisplayName;    
        }
        log "adding @{ObjectId=$($ng.id);GroupType=$($ng.type);DisplayName=$($ng.name);}" "gray"
        $groupList += $ng 
    }
    return $groupList
}

function getGroupsData($groupList){
    log " Calling getGroupsData(`n>>> `$groupList=$groupList`n>>> )" "darkgray" 
    log "Building list of groups..."  
    $data = @()
    foreach ($g in $groupList){
        if ($g.type -eq "DistributionList"){
            $ng = getDGData $g.id
        } elseif (($g.type -eq "Security") -or ($g.type -eq "MailEnabledSecurity")){
            $ng = getSGData $g.id            
        } else {
            throw "ERROR: Invalid groupType [$($g.type)] for [$($g.name)]."
        }
        $data += $ng
    }    
    log "Completed getGroupsData.  Returning group list." "gray"
    return $data
}
function convertGroupListToMemberList($data){
    log " Calling convertGroupListToMemberList(`n>>>`$data=$data`n>>>)" "darkgray"
    log "Converting group data to list of users"
    $ndata = @()
    foreach ($d in $data){
        log "processing members for group [$($d.DisplayName)]:" "gray"
        foreach ($m in $d.Members){
            $nr = $d.Clone()
            $nr['User Email'] = $m.EmailAddress
            $nr['User Display Name'] = $m.DisplayName
            log "Adding row for member [$m]" "gray"
            $ndata += $nr
        }
        log "...completed processing member for group [$($d.DisplayName)]:" "gray"        
    }
    log "returning `$ndata of length $($ndata.Length)" "darkgray"
    return $ndata
}
function exportData($data, $path){
    log " Calling exportData(`n>>>`$data=$data`n>>>`$path=$path`n>>> )" "darkgray"
    log "Exporting to [$path]"
    $odata = @()
    $data | %{
        $o = New-Object psobject;
        foreach ($key in $_.keys) {
            $o | Add-Member -MemberType NoteProperty -Name $key -Value $_[$key]
            }
            $odata += $o;
    }
    try {
        log "Exporting odata with length $($odata.length) to [$path]" "gray"
        $odata | Export-Csv -Path $path -NoTypeInformation -ea Stop
    } catch {
        log "ERROR: Failed to export csv.  `$odata len $($odata.Length)." "red"
        log "`$odata[0]= $($odata[0])" "red"
        log "`$odata[10]= $($odata[10])" "red"
    }
}

function main($exportPath){
    log " Calling main(`n>>> `$exportpath=$exportPath`n>>> )" "darkgray"    
    $UserCredential = Get-Credential;
    $domain = $UserCredential.UserName.substring(($UserCredential.UserName.indexof("@")))
    $s = connectO365 $UserCredential
    log "Pulling group membership list for [$domain]..."
    $list = buildGroupList
    #Building list of groups
    $data = getGroupsData $list
    #Converting group data to list of users
    $mdata = convertGroupListToMemberList $data
    #Exporting data
    exportData $mdata $exportPath
    log "Exported data to csv [$exportPath]" "green"
    disconnectO365 $s
}

clear
main $exportPath $logLevel