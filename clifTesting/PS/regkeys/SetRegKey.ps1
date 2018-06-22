param(
    [string]$path =  "",
    [string]$key = "",
    [string]$value = "",
    [string]$processName = ""
)

function log ($str) {
    write-host $str -ForegroundColor Green
    }

function doesKeyExist($path, $key) {
    $msg = "...Checking for key [$path$key]: `n"
    $res = $true
    if(test-path $path) {
        #$msg += "......path found, continuing. `n"
        try {
            $val = (get-ItemProperty -Path $path -Name $key -ErrorAction Stop).$key
            $msg +=  "......key found.  Returning true."
            $res = $true
        } catch [System.Management.Automation.PSArgumentException] {
            $msg +=  "......key not found.  Returning false."
            $res = $false
        } catch {
            $msg +=  "......UNCAUGHT ERROR: [$($Error[-1].Exception.GetType().FullName)]"
            $res = $false
        } finally {
            
        }
    } else {
        $msg += "...path not found. Returning false. `n"
        return $false
    }
    $script:msg += "$msg `n"
    log $msg
    return $res
}

function checkKeyVal($path, $key, $val) {
    $msg = "...Checking key [$path$key] for value [$val]: `n"
    $res = $true
    if(doesKeyExist $path $key) {
        $checkedVal = (get-ItemProperty -Path $path -Name $key).$key
        $isCorrect = $val -eq $checkedVal
        if($isCorrect) {
            $msg += "......[CORRECT] $key : $checkedVal; `n"
            $res = $true
        } else { 
            $msg += " ......[WRONG] $key : $checkedVal `n" 
            $res = $false
            }
    } else {
        $msg += "......key does not exist.  Returning false."
        $res = $false
    }
    #log $msg
    $script:msg += "$msg `n"
    log $msg
    return $res
    }

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

function updateKeys($path, $key, $val, $type) {
    $msg = "Updating key [$path$key]: `n"
    #test for key
    if(doesKeyExist $path $key) {
        #key exists
        $msg += "...key exists.  Updating... `n"
        Set-ItemProperty -Path $path -Name $key -Value $val
    } else {
        #key does not exist
        $msg += "...key does not exist.  Creating... `n"
        if (!(test-path $path)){ New-Item -Path $path -ItemType Directory }
        New-ItemProperty -Path $path -Name $key -Value $val -PropertyType $type -Force
    }
    $msg += "...keys updated. `n"
    log $msg
    $script:msg += "$msg `n"
    }

function main($path, $key, $val, $type) {
    $msg = ""
    if(checkKeyVal $path $key $val) {
        $msg += "Keys are correct.  Doing nothing. `n"
    } else {
        updateKeys $path $key $val $type
        if(checkKeyVal $path $key){
            $msg += "Key is correct.  Update suceeded. `n"
        } else {
            $msg += "Key is incorrect.  Update failed. `n"
            }
        }
    log $msg -ForegroundColor Green
    }

main $path $key $val $keyType