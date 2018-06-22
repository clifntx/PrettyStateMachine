function removeAllContacts {
    $contacts = (Get-MailContact).Name;
    $contacts | foreach { Remove-MailContact $_ -Confirm:$false;}
    Write-Host "All mail contacts removed."
    Get-MailContact
}
function importCsv($path, $map){ # DOESNT WORK
    Write-Host "path: "$path; Write-Host "map: "$map;
    $oldcsv = Import-Csv $path;$csv = $oldcsv; $te = $oldcsv;
    #foreach ($r in $oldcsv){
    for ($i=0; $i -lt $oldcsv.Length; $i++){
        $cmd = "`$oldcsv[`$i] | Select "; $exclude = @();
        foreach($m in $map.keys){
            $com = "@{Name='"+$m+"';Expression={`$_.('"+$map.$m+"')}}, ";
            $cmd += $com;
            $exclude += $map.$m;
        }
        $cmd += "* | Select -ExcludeProperty";
        foreach ($ex in $exclude){ $cmd += " '"+$ex+"',"; }
        $cmd = $cmd.Substring(0,$cmd.Length-1);
        $cmd += " ;";
        
        $cmd2 = "`$te[`$i] | Select -ExcludeProperty";
        foreach ($ex in $exclude){ $cmd2 += " '"+$ex+"',"; }
        $cmd2 = $cmd2.Substring(0,$cmd2.Length-1);
        $cmd2 += " ;";

        Write-Host "--------------"             
        Write-host "cmd---->" $cmd; 
        $te[$i] = Invoke-Expression $cmd;
        
        
        Write-Host "--------------"             
        Write-host "cmd2---->" $cmd2; 
        $csv[$i] = Invoke-Expression $cmd2;

        #$csv[0] = $oldcsv[0] | Select @{Name="Web Site"; Expression={$_.("Web Page")}}, * | Select -ExcludeProperty "Web Page";
    }
    Write-Host "--------------"
    Write-Host "--------------"
    foreach ($a in ($oldcsv,$te,$csv)) { Write-Host "len: " (($a | Get-Member -Type NoteProperty).Name).Length}
    Write-Host "--------------"
    $names = ($csv | Get-Member -Type NoteProperty).Name;$test="PASS";$f=@();foreach($k in $map.keys){if($names.Contains($map.$k)){$test="FAIL!";$f+=$map.$k;}}if(!($csv.length -gt 1)){Write-host "FAIL! `$csv is empty";}Write-host $test " " $f;
    return $csv;
}
function getP($c){
    $map = @{
    "Business Street" = "StreetAddress";
    "Business City" = "City";
    "Business State" = "StateOrProvince";
    "Business Postal Code" = "PostalCode";
    "Business Country/Region" = "CountryOrRegion";
    "Business Phone" = "Phone";
    "Business Fax" = "Fax";
    "Home Phone" = "HomePhone";
    "Job Title" = "Title";
    }
    $validKeys = @("StreetAddress","City","StateOrProvince","PostalCode","CountryOrRegion","Company","Fax","Phone","FirstName","LastName","Initials","ExternalEmailAddress","Notes","HomePhone","MobilePhone","Department");
    if($map.ContainsKey($c)){
        Write-Host $c "getP(`$c)--------->in map.  setting p to" $map.$c;
        $p = $map.$c;
    }elseif($validKeys.Contains($c)){
        Write-Host $c "getP(`$c)--------->NOT in map, but in validKeys.  setting p to" $c;
        $p = $c;
    }elseif($c.Length -lt 1){
        Write-Host $c "getP(`$c)--------->`$c is empty.  Setting p to null";        
        $p = "";
    }else{
        Write-Host $c "getP(`$c)--------->NOT in map or a valid key.  setting p to null";        
        $p = "";
    }
    return $p
}
function importContacts($csv){
    $err = @()
    foreach($r in $csv){ 
        $n = "";foreach($c in $r){ foreach($_ in ("First Name", "Middle Name", "Last Name", "Suffix")) {if($r.$_.Length -gt 0){ $n=$n+$r.$_+" " }}}; 
        $e=$r.('E-mail Address'); 
        $cmd1="& New-MailContact -Name '"+$n.trim()+"' -ExternalEmailAddress '"+$e.trim()+"'";
        Write-Host $cmd1;Invoke-Expression $cmd1
        foreach($c in $header){
            $p = getP($c);
            if(($r.$c.Length -gt 0) -and ($p.Length -gt 0)){
                try {
                    $cmd2="& Set-Contact -identity '"+$n.trim()+"'"+" -"+($p -replace '\s','')+" '"+$r.$c.trim()+"'";
                    Write-Host $cmd2;Invoke-Expression $cmd2
                }catch{
                    $e+=$r.$c.trim();
                }
            }
        };
        Write-Host "-------------------------------------";        
        Write-Host "Failed to write these params:";
        Write-Host $err;        
        Write-Host "-------------------------------------";        
    }
}



$csv = importCsv ".\NPContacts.CSV" $map;
$csv = Import-Csv ".\NPContacts.CSV";
$header = ($csv | Get-Member -MemberType 'NoteProperty').Name;
#$csv = $csv[0..5];
importContacts $csv;