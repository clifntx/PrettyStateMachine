param(
    [string]$u,
    [string]$p,
    [int]$logLevel = 2
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

function setupAdmin ($userName, $userPassword) {
    try {
        if ((get-localuser).Name.Contains($userName)) {
            log "...found user [$userName]" "gray" 
        } else {
            log "...did not find user [$userName].  Adding." "gray"        
            net user $userName $userPassword /add /expires:never
        }
        
        if (!(net localgroup Administrators).contains($userName)) {
            log "...$userName not in Admin group.  Adding." "gray"
            net localgroup administrators $userName /add
        } else {
            log "...$userName already in Admin group" "gray"
        }

        if (($res -like "TRUE*").Length -gt 0) {
            log "...setting password to not expire" "gray"
            WMIC USERACCOUNT WHERE "Name='$userName'" SET PasswordExpires=FALSE
        } else {
            log "...password already set to not expire." "gray"
        } 

        return (get-localuser).Name.Contains($userName)
                   
    } catch [Microsoft.Management.Infrastructure.CimException] {
        log ">> ERROR: Please rerun as admin" "yellow"
    } catch {
        log ">> UNCAUGHT ERROR: $error[0].Exception.GetType().fullname" "red"
        log ">> $error[0]" "red"
        }
}

function main ($userName, $userPassword) {
    log "Checking for local admin [$userName]" "white"
    $res = setupAdmin $userName $userPassword
    if ($res) {
        log "[X] PASS: $userName is a local admin." "green"
    } else {
        log "[ ] FAIL: $userName is not a local admin." "Red"
    }
}

main $u $p

#pause