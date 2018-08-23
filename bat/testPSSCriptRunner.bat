PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File "\\192.168.1.24\technet\Scripts\PrinterInstalls\InstallPrinters.ps1"' -Verb RunAs}"
timeout /t -1