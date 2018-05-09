@ECHO OFF
powershell.exe -command "& {Set-ExecutionPolicy Unrestricted}"
PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Setup_Workstations\scripts\clientSetup.ps1 -configPath \\192.168.1.24\technet\Scripts\setupConfigs\config_setupClient_BecketMVTC.csv' -Verb RunAs}"
timeout /t -1


