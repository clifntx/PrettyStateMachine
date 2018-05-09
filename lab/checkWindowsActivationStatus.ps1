function log ($str, $fc="white") {
    write-host $str -ForegroundColor $fc
}

function Get-ActivationStatusForManyComputers {
[CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DNSHostName = $Env:COMPUTERNAME
    )
    process {
        try {
            $wpa = Get-WmiObject SoftwareLicensingProduct -ComputerName $DNSHostName `
            -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" `
            -Property LicenseStatus -ErrorAction Stop
        } catch {
            $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
            $wpa = $null    
        }
        $out = New-Object psobject -Property @{
            ComputerName = $DNSHostName;
            Status = [string]::Empty;
        }
        if ($wpa) {
            :outer foreach($item in $wpa) {
                switch ($item.LicenseStatus) {
                    0 {$out.Status = "Unlicensed"}
                    1 {$out.Status = "Licensed"; break outer}
                    2 {$out.Status = "Out-Of-Box Grace Period"; break outer}
                    3 {$out.Status = "Out-Of-Tolerance Grace Period"; break outer}
                    4 {$out.Status = "Non-Genuine Grace Period"; break outer}
                    5 {$out.Status = "Notification"; break outer}
                    6 {$out.Status = "Extended Grace"; break outer}
                    default {$out.Status = "Unknown value"}
                }
            }
        } else {$out.Status = $status.Message}
        $out
    }
}

function Get-ActivationStatus {
    try {
        $wpa = Get-WmiObject SoftwareLicensingProduct`
            -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" -ComputerName $Env:COMPUTERNAME`
            -Property LicenseStatus -ErrorAction Stop
    } catch {
        $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
        $wpa = $null    
    }
    $res = [string]::Empty;
    if ($wpa) {
        :outer foreach($item in $wpa) {
            switch ($item.LicenseStatus) {
                0 {$res = 0; log "Unlicensed"}
                1 {$res = 1; log "Licensed"; break outer}
                2 {$res = 2; log "Out-Of-Box Grace Period"; break outer}
                3 {$res = 3; log "Out-Of-Tolerance Grace Period"; break outer}
                4 {$res = 4; log "Non-Genuine Grace Period"; break outer}
                5 {$res = 5; log "Notification"; break outer}
                6 {$res = 6; log "Extended Grace"; break outer}
                default {$res = $null; log  "Unknown value"}
            }
        }
    } else {$res = $null; log ">> ERROR: No wpa!" "red"}
    return $res
}

$r = Get-ActivationStatus
write-host $r