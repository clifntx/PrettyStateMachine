echo ON

set XeroxDriverPath=C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf
set XeroxDriver=Xerox Global Print Driver PCL6
 
:: Does not work for WIn10 set KyoceraDriverPath=C:\Push\Kyocera\KyoClassicUniversalPCL6_v1.56\OEMsetup.inf
:: Does not work for WIn10 set KyoceraDriver=Kyocera Classic Universaldriver PCL6

set KyoceraDriverPath=C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf

set ToshibaDriverPath=C:\Push\Toshiba\64bit\eSf6u.inf
set ToshibaDriver=TOSHIBA Universal Printer 2

set HPDriverPath=C:\Push\HP\UniversalDriver_PCL6\hpbuio200l.inf
set HPDriver=HP Universal Printing PCL 6

..\createBFSTechAccount.bat

:: FitchburgOffice 10.10.15.105
	set location=FitchburgOffice
	set IP=10.10.15.105
	set port=IP_10.10.15.105
	set ToshibaDriver=Toshiba
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100 
:: install Color Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% (Color) - %KyoceraDriver%" /f %KyoceraDriverPath% /r "%port%" /m "%KyoceraDriver%" /Z
timeout /t 5 /nobreak 

:: Agawam 192.168.20.21
	set location=Agawam
	set IP=192.168.20.21
	set port=IP_192.168.20.21
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
timeout /t 2 /nobreak 
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %XeroxDriver%" /f %XeroxDriverPath% /r "%port%" /m "%XeroxDriver%" /Z
timeout /t 5 /nobreak 

:: Bourne 192.168.33.200
	set location=Bourne
	set IP=192.168.33.200
	set port=IP_192.168.33.200
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
timeout /t 2 /nobreak 
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %XeroxDriver%" /f %XeroxDriverPath% /r "%port%" /m "%XeroxDriver%" /Z
timeout /t 5 /nobreak 

:: Fitchburg House 10.10.112.103
set IP=10.10.112.103
rundll32 printui.dll,PrintUIEntry /dl /n "Fitchburg House - %ToshibaDriver%" /q ;
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_%IP% -h %IP% -o raw -n 9100
timeout /t 2 /nobreak  
rundll32 printui.dll,PrintUIEntry /if /b "Fitchburg House - %ToshibaDriver%" /f %ToshibaDriverPath% /r "IP_%IP%" /m "%ToshibaDriver%" /Ztimeout /t 5 /nobreak 
timeout /t 5 /nobreak  

:: Lakeville 192.168.35.110
:: Define variables
	set location=Lakeville
	set IP=192.168.35.110
	set port=IP_192.168.35.110
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %XeroxDriver%" /f %XeroxDriverPath% /r "%port%" /m "%XeroxDriver%" /Z
::take a breath
timeout /t 5 /nobreak 

:: Southwick 192.168.21.2
:: Define variables
	set location=Southwick
	set IP=192.168.21.2
	set port=IP_192.168.21.2
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %XeroxDriver%" /f %XeroxDriverPath% /r "%port%" /m "%XeroxDriver%" /Z
::take a breath
timeout /t 5 /nobreak 

:: Attleboro 10.10.16.150
:: Define variables
	set location=Attleboro
	set IP=10.10.16.150
	set port=IP_10.10.16.150
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %ToshibaDriver%" /f %ToshibaDriverPath% /r "%port%" /m "%ToshibaDriver%" /Z
::take a breath
timeout /t 5 /nobreak 

:: Clearview 192.168.141.5
:: Define variables
	set location=Clearview
	set IP=192.168.141.5
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_%IP% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %XeroxDriver%" /f %XeroxDriverPath% /r "%port%" /m "%XeroxDriver%" /Z
::take a breath
timeout /t 5 /nobreak 



:: New Bedford 192.168.64.100
:: Define variables
	set location=New Bedford
	set IP=192.168.64.100
	set port=IP_192.168.64.100
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_%IP% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %XeroxDriver%" /f %XeroxDriverPath% /r "%port%" /m "%XeroxDriver%" /Z
::take a breath
timeout /t 5 /nobreak

:: Leicester 192.168.28.90
:: Define variables
	set location=Leicester
	set IP=192.168.28.90
	set port=IP_192.168.28.90
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_%IP% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %XeroxDriver%" /f %XeroxDriverPath% /r "%port%" /m "%XeroxDriver%" /Z
::take a breath
timeout /t 5 /nobreak

:: Leominster 192.168.25.90
:: Define variables
	set location=Leominster
	set IP=192.168.25.90
	set port=IP_192.168.25.90
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_%IP% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %XeroxDriver%" /f %XeroxDriverPath% /r "%port%" /m "%XeroxDriver%" /Z
::take a breath
timeout /t 5 /nobreak

:: Westfield 192.168.37.90
:: Define variables
	set location=Westfield
	set IP=192.168.37.90
	set port=IP_192.168.37.90
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_%IP% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %XeroxDriver%" /f %XeroxDriverPath% /r "%port%" /m "%XeroxDriver%" /Z
::take a breath
timeout /t 5 /nobreak

:: Westminster 10.10.114.40
set IP=10.10.114.40
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_%IP% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "Westminster - %HPDriver%" /f %HPDriverPath% /r "IP_%IP%" /m "%HPDriver%" /Z
::take a breath
timeout /t 5 /nobreak 

:: Wilbraham 192.168.22.50 
set IP=192.168.22.50 
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_%IP% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "Wilbraham - %ToshibaDriver%" /f %ToshibaDriverPath% /r "IP_%IP%" /m "%ToshibaDriver%" /Z
::take a breath
timeout /t 5 /nobreak 

:: Winchendon  192.168.15.111
set IP=192.168.15.111
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_%IP% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "Winchendon - %HPDriver%" /f %HPDriverPath% /r "IP_%IP%" /m "%HPDriver%" /Z
::take a breath
timeout /t 5 /nobreak 

::display installed printers
powershell -Command "& {get-WmiObject -class Win32_printer | ft name, systemName;}"
timeout /t -1