@ECHO OFF
powershell.exe -command "& {Set-ExecutionPolicy Unrestricted}"
PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Scripts\wksSetups\clientSetup.ps1 -configPath \\192.168.1.24\technet\Scripts\setupConfigs\config_setupClient_BecketNH.csv' -Verb RunAs}"

rem "\\192.168.1.24\technet\Scripts\wksSetups\clientSetup.ps1"
rem "\\192.168.1.24\technet\Scripts\setupConfigs\config_setupClient_BecketInventory.csv"
timeout /t -1
