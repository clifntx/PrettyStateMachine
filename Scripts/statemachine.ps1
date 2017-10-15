$csv = @(1, 2, 3)

$csv | foreach {
    if ($_ -eq 2) {Write-Host $_}
    }


$csv | foreach {
    if (!(Test-Path $_.path)) {
        #download and extract file
    }
 }
