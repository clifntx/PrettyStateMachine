Param(
    [string]$filePath = "c:\users\public\desktop\WebClock Login.url"
    )

function log($str) {
    write-host $str;
    }

function checkForFile($path) {
    log("Checking for existance of file[$path]:");
    if(test-path $path) {
        $res = $true;
        log("..successfully located file.");
    } else {
        $res = $false;
        log("..failed to locate file.");
        }
    return $res;
    }


function removeFile($path){
    log("Removing file [$path]:");
    Remove-Item $path;
    $res = checkForFile $path;
    return !$res;
    }

function main($filePath) {
    if (checkForFile $filePath) {
        $res = removeFile $filePath;
        log("..file removed? $res");
    }else{
        log("File does not exist.  Doing nothing.");
    }
}

main $filePath;