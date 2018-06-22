# ref https://blogs.technet.microsoft.com/heyscriptingguy/2013/06/15/weekend-scripter-use-powershell-to-find-auto-connect-wireless-networks/
function getAllSavedWifiNetworks() {
    $GUID = (Get-NetAdapter -Name "wi-fi").interfaceGUID
    #$GUID
    #{E1B35DF1-F73B-4BAC-A529-4FD79D8B4939}
    $path = "C:\ProgramData\Microsoft\Wlansvc\Profiles\Interfaces\$GUID"

    $ssids = Get-ChildItem -path $path -Recurse |
        foreach {
            [xml]$c = Get-Content -Path $_.fullname
            New-Object pscustomobject -Property @{
            'name' = $c.WLANProfile.name;
            'mode' = $c.WLANProfile.connectionMode;
            'ssid' = $c.WLANProfile.SSIDConfig.SSID.hex
            } 
        }
}

function exportXml() {
    #export xml
    netsh wlan export profile name="WifiNetwork" folder="C:\path\" key=clear
    #import xml
    netsh wlan add profile filename="C:\path\WifiNetwork.xml"
}


# ref: https://blogs.technet.microsoft.com/heyscriptingguy/2015/03/23/use-powershell-to-enable-wi-fi/
