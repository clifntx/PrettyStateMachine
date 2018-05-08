@echo off


REM nable parameters: 
REM Run using Device Credentials
REM runas.exe /user:localhost/administrator CreateO365Link.bat


SETLOCAL ENABLEDELAYEDEXPANSION
SET LinkName=Secure Email Portal
SET Esc_LinkDest=c:\users\public\desktop\!LinkName!.url
SET Esc_LinkTarget=https://us2.securepem.com/becket/web/
SET cSctVBS=CreateShortcut.vbs
SET LOG=".\%~N0_runtime.log"
((
  echo Set oWS = WScript.CreateObject^("WScript.Shell"^) 
  echo sLinkFile = oWS.ExpandEnvironmentStrings^("!Esc_LinkDest!"^)
  echo Set oLink = oWS.CreateShortcut^(sLinkFile^) 
  echo oLink.TargetPath = oWS.ExpandEnvironmentStrings^("!Esc_LinkTarget!"^)
  echo oLink.Save
)1>!cSctVBS!
cscript //nologo .\!cSctVBS!
DEL !cSctVBS! /f /q
)1>>!LOG! 2>>&1

REM ......................................
REM Creates a shortcut to https://outlook.office.com on the public desktop.
REM NEeds to be run as user with local admin rights
REM ......................................