function createDir($path) {
    if(Test-Path($path)){
        write-host "...dir already exists.";
    } else {
        mkdir $path;
        }
}

function makeTimeClockShortcut {
    $Shell = New-Object -ComObject ("WScript.Shell")
    $fav = $Shell.CreateShortcut("C:\Users\Public\Desktop\Time and Labor.lnk");
    $fav.IconLocation = "c:\Push\Time and Labor Icon.ico";
    $fav.TargetPath = "https://becketfamilyofservices.attendanceondemand.com/ess/";
    $fav.Save();
}

function makeShortcut($lnkName, $url, $icoPath){
    $lnkPath = "C:\Users\Public\Desktop\$lnkName.lnk";
    foreach ($e in @($lnkPath, $url, $icoPath)){ write-host $e; }

    $Shell = New-Object -ComObject ("WScript.Shell")
    $fav = $Shell.CreateShortcut($lnkPath);
    $fav.IconLocation = $icoPath;
    $fav.TargetPath = $url;
    $fav.Save();
}

function removeDesktopShortcuts ($killList) {
    foreach ($k in $killList){
        $path1 = "c:\users\public\desktop\$k";
        $path2 = "C:\Users\TimeclockUser\desktop\$k";
        foreach($p in @($path1, $path2)){
            write-host "...checking $p)";
            if(test-path($p)){
                del $p;
                write-host "...deleted $p";
            } else {
                write-host "...no file at $p";
            }
        }
    }
}

createDir("c:\push\");
makeTimeClockShortcut;
makeShortcut "Time and Labor" "https://becketfamilyofservices.attendanceondemand.com/ess/" "c:\Push\Time and Labor Icon.ico";
makeShortcut "WebClock Login" "https://webtime2.paylocity.com/webtime/webclock" "c:\Push\paylocityicon.ico";
$killList = @("Time and Labor.url");
removeDesktopShortcuts ($killList);