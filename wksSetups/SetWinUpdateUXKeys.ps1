param(
    [int]$logLevel = -1
    )

function keysAreCorrect ($path, $key, $valueKeyShouldBe) {
    $msg = ""
    $msg = "Checking key [ $key ] against value [ $valueKeyShouldBe ]: "
    $val = (get-ItemProperty -Path $path -Name $key).key
    if($key -eq $valueKeyShouldBe) { 
        $msg += "...value for [$key] is correct: $val"
        $res = $true
    } else {
        $msg += " ...value for [$key] is incorrect: $val"
        $res = $false
        }
    log $msg
    $script:msg += "$msg `n"
    return $res
    }

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

function doesKeyExist($path, $key) {
    log "Calling doesKeyExist(`n>>> path=$path`n>>> key=$key`n>>> )" "darkgray"
    log "...Checking for key [$path$key]: " "white"
    $res = $true
    if(test-path $path) {
        log "......path found.  Continuing." "gray"
        try {
            $val = (get-ItemProperty -Path $path -Name $key -ErrorAction Stop).$key
            log "......key found.  <$val>  Returning true." "gray"
            $res = $true
        } catch [System.Management.Automation.PSArgumentException] {
            log  "......key not found.  Returning false." "gray"
            $res = $false
        } catch {
            log ">> UNCAUGHT ERROR: [$($Error[0].Exception.GetType().FullName)]" "red"
            $res = $false
        }
    } else {
        log "...path not found. Returning false." "gray"
        return $false
    }
    return $res
}

function checkKeyVal($path, $key, $val) {
    log "Calling checkKeyVal(`n>>> path=$path,`n>>> key=$key`n>>> val=$val`n>>> )" "darkgray"    
    log "...Checking key [$path$key] for value [$val]: " "white"
    $res = $true
    if(doesKeyExist $path $key) {
        $checkedVal = (get-ItemProperty -Path $path -Name $key).$key
        log "...checking if [$val] -eq [$checkedVal]." "gray"
        $isCorrect = $val -eq $checkedVal
        log "...isCorrect == $isCorrect" "gray"
        if($isCorrect) {
            log "......[CORRECT] $key : $checkedVal;" "gray"
            $res = $true
        } else { 
            log "......[WRONG] $key : $checkedVal" "red"
            $res = $false
            }
    } else {
        log "......key does not exist.  Returning false."
        $res = $false
    }
    return $res
    }

function updateKeys($path, $key, $val, $type) {
    log "Calling updateKeys(`n>>> path=$path,`n>>> key=$key`n>>> val=$val`n>>> type=$type`n>>> )" "darkgray"        
    log "Updating key [$path$key]:" "gray"
    #test for key
    if(doesKeyExist $path $key) {
        #key exists
        log "...key exists.  Updating..." "gray"
        Set-ItemProperty -Path $path -Name $key -Value $val
    } else {
        #key does not exist
        log "...key does not exist.  Creating..." "gray"
        if (!(test-path $path)){ New-Item -Path $path -ItemType Directory }
        New-ItemProperty -Path $path -Name $key -Value $val -PropertyType $type -Force
    }
    log "...keys updated." "gray"
    }

function checkAll ($regkeys) {
    log "Calling checkAll(`n>>> regkeys=$regkeys`n>>> )" "darkgray"        
    $out = @()
    foreach($k in $regkeys) {
        log "...checking key: $($k.path)$($k.key) $($k.val)"
        $res = checkKeyVal $k.path $k.key $k.val
        $msg = "[$res]  ..\$($k.key) (`"$($k.note)`") : $($k.val)"
        $out += $msg
    }
    $out | foreach { 
        log $_ "green"
        }
    }

function main($regkeys) {    
    log "Calling main(`n>>> regkeys=$regkeys`n>>> )" "darkgray"        
    checkAll $regkeys
    foreach($k in $regkeys) {
        if(checkKeyVal $k.path $k.key $k.val) {
            log "Keys are correct.  Doing nothing." "green"
        } else {
            updateKeys $k.path $k.key $k.val $k.type
            if(checkKeyVal $k.path $k.key){
                log "Key is correct.  Update suceeded." "green"
            } else {
                log "Key is incorrect.  Update failed." "red"
                }
            }
        }
    checkAll $regkeys
    }

$regkeys = @(
    @{ key="Enabled"; val="00000000"; keyType="DWORD"; note="Disables Windows Hello."; path="hklm:\SOFTWARE\Policies\Microsoft\PassportForWork\" },
    @{ key="AllowDomainPINLogon"; val="00000000"; keyType="DWORD"; note="Disables Windows pin requirement."; path="hklm:\SOFTWARE\Policies\Microsoft\Windows\System\" },
    @{ key="NoDriveTypeAutoRun"; val="00000091"; keyType="DWORD"; note="Disables Windows Hello."; path="hklm:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\" },
    @{ key="NoStartMenuMyGames"; val="00000001"; keyType="DWORD"; note="Disables Windows Hello."; path="hklm:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\" },
    @{ key="DisableWindowsConsumerFeatures"; val="00000001"; keyType="DWORD"; note="Disables Windows Hello."; path="hklm:\SOFTWARE\Policies\Microsoft\Windows\CloudContent\" }
    )

clear
main $regkeys
pause

