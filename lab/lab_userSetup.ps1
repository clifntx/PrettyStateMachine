function setLibraryPaths {
    # Set-ItemProperty `
    #    -path ".\User Shell Folders\" `
    #    -name Personal "C:\users\KamishaBryant\OneDrive - Becket Academy, Inc\Documents"
    # Set-ItemProperty -path $key1 -name $d "C:\users\KamishaBryant\OneDrive - Becket Academy, Inc\Desktop"

    $u = (Get-WmiObject -class Win32_ComputerSystem).UserName.split("\")[1]
    $odDir = (dir "c:\users\$u\OneDrive -*").Name
    $odRoot = "C:\users\$u\$odDir"

    write-host "`$odRoot: $odRoot"

    $kvpsToUpdate = @{
        "Desktop"="$odRoot\Desktop";
        "My Pictures"="$odRoot\Pictures";
        "Personal"="$odRoot\Documents"
    }
    
    $key1Name = "User Shell Folders"
    $key1Name = "Shell Folders"

    $key1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"  
    $key2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" 

    $key1Data = Get-ItemProperty $key1
    $key2Data = Get-ItemProperty $key2
    
    foreach ($k in $kvpsToUpdate.keys) {
        write-host "Setting regkeys for [$k] :"
        write-host 'Set-ItemProperty -path "$key1" -name "$k" "$($kvpsToUpdate.$k)"' 
        Set-ItemProperty -path "$key1" -name "$k" "$($kvpsToUpdate.$k)"
        Set-ItemProperty -path "$key2" -name "$k" "$($kvpsToUpdate.$k)"
    }

    foreach ($k in $kvpsToUpdate.keys) {
        write-host "$k :"
        write-host "  `$key1 : $($key1Data.$k)"
        write-host "  `$key2 : $($key2Data.$k)"
    }
}

