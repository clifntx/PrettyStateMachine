param(
    [string]$csv = $(throw 'No csv path provided.  Please include a valid path to a csv to import.  ex. -csv "c:\push\test.csv"'),
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
function connectO365 {
    log " Calling connectO365(`n>>> no args`n>>> )" "darkgray"
    log "connecting..."
    $UserCredential = Get-Credential;
    $domain = $UserCredential.UserName.substring(($UserCredential.UserName.indexof("@")))
    Import-Module MsOnline ;
    Connect-MsolService -Credential $UserCredential;
    $ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/  -Credential $UserCredential -Authentication Basic -AllowRedirection 
    Import-PSSession $ExchangeSession -AllowClobber #-WarningAction ContinueSilently

    return @($ExchangeSession,$domain)
}

function disconnectO365 ($ExchangeSession){
    log " Calling disconnectO365(`n>>> no args`n>>> )" "darkgray"
    log "disconnecting..."
    #Remove-PSSession $ExchangeSession
    Remove-PSSession *
}

function convertCsvToLod($csv,$map){
    log " Calling convertCsvToLod(`n>>> `$csv=csv`n>>> `$map=$map`n>>> )" "darkgray"  
    log "Converting $($csv.Length) rows to lod." 
    $lod = @()
    #$keys = @('City','Country','Department','DisplayName','Fax','FirstName',
        #        'LastName','MobilePhone','Office','PasswordNeverExpires','PhoneNumber',
        #        'PostalCode','PreferredLanguage','State','StreetAddress','Title','UsageLocation')
    $keys = $map.keys
    $csv = import-csv $csvPath
    $i = 2
    foreach ($r in $csv){
        log "processing ($i)[$($r.($map['UserPrincipalName']))]..." "gray"
        $nr = @{}
        $rs = "  ...adding row @{"
        foreach ($k in $keys){ 
            #write-host "$_ = $($map[$_])"; 
            $v = $r.($map[$k])
            if ($v -and ($v.gettype() -eq [String])){
                $v = $v.trim()
            }
            if ($v.Length -gt 0){
                $nr.Add($k, $v)
                $rs += "$k=`"$v`"; "
            } else {
                $nr.Add($k, $null)
                $rs += "$k=`"$null`"; "
            }
        }
        $nr.Add("rowNumber",$i)
        $rs += "rowNumber=`"$($nr.rowNumber)`"; "
        $rs += "}"
        log $rs "gray"
        $lod += $nr 
        $i+=1
    }

    return $lod
}

function creatFailureO($ob, $causeOfFailure){
    log " Calling creatFailureO(`n>>> `$ob=$ob  type=$($ob.gettype())`n>>> `$causeOfFailure=$causeOfFailure`n>>> )" "darkgray"  
    #$fo = New-Object PsObject
    #$ob.psobject.properties | % {
    #    $fo | Add-Member -MemberType $_.MemberType -Name $_.Name -Value $_.Value
    #}
    if($ob){
        $fo = $ob.clone()
    } else {
        $fo = @{
            "UserPrincipalName" = "NULL";
            "rowNumber" = "NULL"
        }
    }
    $fo["causeOfFailure"]="$causeOfFailure"
    return $fo
}

function updateUserDetails($lod){
    log " Calling updateUserDetails(`n>>> `$lod=$lod`n>>> )" "darkgray"  
    log "Updating $($lod.Length) users' details."  
    $res = @{"succeed"=@(); "fail"=@()}
    $lod | foreach {
        try {
            $un = $_.UserPrincipalName
            $u = $_
            if ($un.Length -gt 0){
                Set-MsolUser -UserPrincipalName $un `
                             -City $_.City `
                             -Country $_.Country `
                             -Department $_.Department `
                             -DisplayName $_.DisplayName `
                             -Fax $_.Fax `
                             -FirstName $_.FirstName `
                             -LastName $_.LastName `
                             -MobilePhone $_.MobilePhone `
                             -Office $_.Office `
                             -PasswordNeverExpires $_.PasswordNeverExpires `
                             -PhoneNumber $_.PhoneNumber `
                             -PostalCode $_.PostalCode `
                             -PreferredLanguage $_.PreferredLanguage `
                             -State $_.State `
                             -StreetAddress $_.StreetAddress `
                             -Title $_.Title `
                             -UsageLocation $_.UsageLocation `
                             -ea Stop
                log "+ updated user ($($_.rowNumber))[$un]." "gray"
                $res['succeed'] += $_
            } else {
                log "- Skipping blank user name [$un] (csv row $($_.rowNumber))" "yellow"
                $res['fail'] += (creatFailureO $_ "Blank primaryUserName.")
            }
        } catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException]{
            log "- Could not locate user [$un] (csv row $($u.rowNumber))" "yellow"
            $res['fail'] += (creatFailureO $u "Could not locate user.")
        } catch {
            log "UNCAUGHT ERROR: $($ERROR[0].Exception.gettype().Fullname)" "red"
            log "$($ERROR[0].Exception.Message)" "red"
            $res['fail'] += (creatFailureO $_ ($ERROR[0].Exception.Message))
        }
    }
    log "Completed user details updates."  
    log "Successfully updated $($res['succeed'].Length) users." 
    log "Failed to update $($res['fail'].Length) users." "red"
    #log "Primary Name, Csv row #" "red"
    #$res['fail'] | foreach {
    #    log "   - $($_.UserPrincipalName), $($_.rowNumber), $($_.causeOfFailure))" "red"
    #}
    return $res
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

function main ($csvPath, $map, $exportPath) {
    $s = connectO365

    $csv = import-csv $csvPath
    $lod = convertCsvToLod $csv $map
    $res = updateUserDetails $lod
    exportData $res['fail'] $exportPath
    
    disconnectO365 $s
}


#$csvPath = "c:\push\MS_Report-BP_07-23-2018_csv.csv"
#$exportPath = "c:\push\log_userUpdateFailure.csv"
$map = @{
    "UserPrincipalName"="Work Email";
    'City'="";
    'Country'="";
    'Department'="Program Code (cc1)";
    'DisplayName'="";
    'Fax'="";
    'FirstName'="";
    'LastName'="";
    'MobilePhone'="";
    'Office'="Program Description (cc1)";
    'PasswordNeverExpires'=$true;
    'PhoneNumber'="Work Phone";
    'PostalCode'="";
    'PreferredLanguage'="";
    'State'="";
    'StreetAddress'="";
    'Title'="Title";
    'UsageLocation'="";
}
main $csvPath $map $exportPath