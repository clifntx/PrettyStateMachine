@ECHO OFF
powershell.exe -command "& {Set-ExecutionPolicy Unrestricted}"
PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Setup_Workstations\scripts\clientSetup.ps1 -configPath \\192.168.1.24\technet\Scripts\setupConfigs\config_setupClient_BecketMA.csv' -Verb RunAs}"
rem "\\192.168.1.24\technet\Setup_Workstations\scripts\clientSetup.ps1"
rem "\\192.168.1.24\technet\Setup_Workstations\Setup_Becket_Workstation\Push\Scripts\config_setupClient_BecketMA.csv"
timeout /t -1
