rem powershell.exe \\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1 -printerCsv c:\push\printerDrivers\Printers_MVTC.csv

PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File "\\192.168.1.24\technet\Setup_Workstations\scripts\QAStandardSetup.ps1"' -Verb RunAs}"