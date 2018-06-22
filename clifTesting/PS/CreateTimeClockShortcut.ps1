function makeTimeClockShortcut {
    $Shell = New-Object -ComObject ("WScript.Shell")
    $fav = $Shell.CreateShortcut("C:\Users\Public\Desktop\Time and Labor.lnk");
    $fav.IconLocation = "c:\Push\Time and Labor Icon.ico";
    $fav.TargetPath = "https://becketfamilyofservices.attendanceondemand.com/ess/";
    $fav.Save();
}

funciton makeShortcut($lnkName, $url, $icoPath){
    $Shell = New-Object -ComObject ("WScript.Shell")
    $fav = $Shell.CreateShortcut($env:USERPROFILE + "$lnkName.lnk");
    $fav.IconLocation = $icoPath;
    $fav.TargetPath = $url;
    $fav.Save();
}

mkdir c:\push\;
makeTimeClockShortcut;
