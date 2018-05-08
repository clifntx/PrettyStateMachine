@ECHO OFF
powershell.exe -command "& {Set-ExecutionPolicy Unrestricted}"
PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File \\192.168.1.24\technet\Scripts\wksSetups\QAStandardSetup.ps1' -Verb RunAs}"

rem "\\192.168.1.24\technet\Setup_Workstations\scripts\clientSetup.ps1"
rem "\\192.168.1.24\technet\Setup_Workstations\Setup_MPA_Workstation\Push\scripts\config_setupClient_MPAC.csv"
timeout /t -1
