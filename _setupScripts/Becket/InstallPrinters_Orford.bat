powershell.exe -command "& {Set-ExecutionPolicy Unrestricted}"
PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1 -printerCsv \\192.168.1.24\technet\Scripts\setupConfigs\config_Printers_Orford.csv' -Verb RunAs}"
