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

function getAllTheIps {
    $routes = get-netroute;    
    $adapters = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet,Wi-Fi;
    $deviceIp = ($adapters | ? {$_.AddressState -eq "Preferred"}).IPAddress;
    $rootIp = $deviceIp.Substring(0,$deviceIp.LastIndexOf('.'))
    $gatewayIps = (Get-NetIPConfiguration | Foreach IPv4DefaultGateway).NextHop;        
    $activeGateway = $gatewayIps | ? {$_.Substring(0,($_.lastIndexOf('.'))) -eq $rootIp}
    $wanIp = "8.8.8.8"
    return @{
        'rootIp' = $rootIp;
        'deviceIp' = $deviceIp;
        'gatewayIps' = $gatewayIps;
        'activeGateway' = $activeGateway;
        'wanIp' = $wanIp     
    }
}

function testIp($ip){
    try{ 
        $res = test-connection $ip -Count 4 -ErrorAction Stop 
        #write-host "PASS" -ForegroundColor "Green"
        return $true
    } catch [System.Management.Automation.RuntimeException] { 
        #write-host "FAIL: System.Management.Automation.RuntimeException"  -ForegroundColor "Red"
        return $false
    } catch { 
        #write-host "FAIL" -ForegroundColor "Red"
        return $false
    }
}

function testLAN {
    try{
        $res1 = test-connection (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet,Wi-Fi -AddressState Preferred).IPAddress; 
        write-host "[LAN Connection Confirmed]" -ForegroundColor "Green"
    }catch{
        Write-Host "FAIL" -ForegroundColor "Red"
        return $false
    }
    try{
        
        $res2 = test-connection "8.8.8.8"; 
        write-host "[WAN Connection Confirmed]" -ForegroundColor "Green"
    }catch{
        write-host "FAIL" -ForegroundColor "Red"
        return $false
    }
    return $true
}

function testConnections($ips){
    $ipsKeys = @("activeGateway","wanIp")
    $ipsKeys | foreach {
        testIp $_
    }
}

function testDns {
    try {
        function log($s,$c){write-host $s -ForegroundColor $c}; 
        Resolve-DnsName blah.blah -ea Stop; log "DNS PASS" "green"
    } catch {
        log "DNS FAILED" "red"
    }
}

function refreshArpTable {
    $ips = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet,Wi-Fi | select IPAddress,InterfaceAlias,AddressState,PrefixOrigin
    $ips | foreach {
        $bip = $_.IpAddress.Substring(0,($ips.IPAddress[0].LastIndexOf('.'))) + ".255";$ping = ping $bip -n 1
    }
    arp -a
}

function showAdapter {
    Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet,Wi-Fi | select IPAddress,InterfaceAlias,AddressState,PrefixOrigin
}

getAllTheIps



write-host "Testing network..." -BackgroundColor "White"; try{$res1 = test-connection (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet,Wi-Fi -AddressState Preferred).IPAddress; write-host "[LAN Connection Confirmed]" -ForegroundColor "Green"}catch{write-host "FAIL" -ForegroundColor "Red"};try{$res2 = test-connection "8.8.8.8"; write-host "[WAN Connection Confirmed]" -ForegroundColor "Green"}catch{write-host "FAIL" -ForegroundColor "Red"};pause


