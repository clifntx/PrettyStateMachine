$pc = (Get-ItemProperty -path "HKLM\SOFTWARE\ESET\ESET Security\CurrentVersion\Info" -Name ProductCode).ProductCode
msiexec /x $pc /qb REBOOT="ReallySuppress"
#msiexec /x $pc /qb REBOOT="ReallySuppress" PASSWORD=""