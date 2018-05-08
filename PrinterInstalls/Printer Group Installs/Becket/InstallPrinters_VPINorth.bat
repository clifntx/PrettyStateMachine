
echo ON
echo "Installing CRA/EHA Printers"

set XeroxDriverPath=C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf
set XeroxDriver=Xerox Global Print Driver PCL6
 
set KyoceraDriverPath=C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf

:: CRA Upstairs Kyocera
:: Define variables
	set location=CRA Upstairs Kyocera
	set IP=10.10.50.10
	set port=IP_%IP%
	set KyoceraDriver=Kyocera TASKalfa 3501i
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %KyoceraDriver%" /f %KyoceraDriverPath% /r "%port%" /m "%KyoceraDriver%" /Z
timeout /t 2 /nobreak 

:: EHA Xerox
:: Define variables
	set location=EHA Xerox
	set IP=10.10.12.32
	set port=IP_%IP%
	set driver=Xerox Global Print Driver PCL6
	set driverPath=C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %driverPath% /r "%port%" /m "%driver%" /Z
timeout /t 2 /nobreak

:: Newbury House 
:: Define variables
	set location=Newbury House
	set IP=10.0.0.200
	set port=IP_%IP%
	set driver=Kyocera TASKalfa 3501i
	set path=C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 2 /nobreak

:: Pike Library HP
:: Define variables
	set location=Pike Library
	set IP=192.168.163.53
	set port=IP_%IP%
	set driver=HP Universal Printing PCL 6
	set path=C:\Push\HP\UniversalDriver_PCL6\hpbuio200l.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 2 /nobreak

::display installed printers
powershell -Command "& {get-WmiObject -class Win32_printer | ft name, systemName;}"
timeout /t -1