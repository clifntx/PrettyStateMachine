$cid = (get-ItemProperty -Path HKLM:\SOFTWARE\WOW6432Node\Eaglesoft\ -Name ClientID).ClientID
$cidIsCorrect = $cid -eq "710200744"
$lnum = (get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Eaglesoft\" -Name LicenseNumber).LicenseNumber
$lnumIsCorrect = $lnum -eq "710200744-011160-018257-026784-00188063"
$res = "ClientID correct: $cidIsCorrect; LicenseNumber correct: $lnumIsCorrect;"
if(!($cidIsCorrect)) { $res += " ...wrong cid: $cid" }
if(!($lnumIsCorrect)) { $res += " ...wrong license num: $lnum" }

write-host $res