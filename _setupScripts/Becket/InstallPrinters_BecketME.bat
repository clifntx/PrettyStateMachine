@ECHO OFF
powershell.exe -command "& {Set-ExecutionPolicy Unrestricted}"
powershell.exe \\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1 -printerCsv \\192.168.1.24\technet\Scripts\setupConfigs\config_Printers_BecketME.csv
