@ECHO OFF
powershell.exe -command "& {Set-ExecutionPolicy Unrestricted}"
PowerShell.exe -Command "& {Start-Process PowerShell.exe -ArgumentList '-ExecutionPolicy Bypass -File "\\192.168.1.24\technet\Scripts\lab\main_lab.ps1"' -Verb RunAs}"
rem powershell.exe -command "& {Set-ExecutionPolicy RemoteSigned}"