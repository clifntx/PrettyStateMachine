echo ON

set XeroxDriverPath=C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf
set XeroxDriver=Xerox Global Print Driver PCL6
 
set KyoceraDriverPath=C:\Push\Kyocera\KyoClassicUniversalPCL6_v1.56\OEMsetup.inf
set KyoceraDriver=Kyocera Classic Universaldriver PCL6

:: FitchburgOffice 10.10.15.105
:: Define variables
	set location=FitchburgOffice
	set IP=10.10.15.103
	set port=IP_10.10.15.103
	set driver=Kyocera TASKalfa 5501i
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Color Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% (Color) - %driver%" /f %KyoceraDriverPath% /r "%port%" /m "%driver%" /Z

timeout /t 2 /nobreak 

echo "Installing Orford Printers"
timeout /t 3

:: Orford Upstairs		
:: Define variables
	set location=Orford Upstairs
	set IP=192.168.123.135
	set port=IP_%IP%
	set driver=TOSHIBA Universal Printer 2
	set path=C:\Push\Toshiba\Toshiba-Print-Driver-Uni-3264bit-717638516\64bit\eSf6u.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 5 /nobreak

:: Orford Downstairs	
:: Define variables
	set location=Orford Downstairs
	set IP=192.168.123.100
	set port=IP_%IP%
	set driver=Kyocera TASKalfa 5551ci
	set path=C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 5 /nobreak

echo "Installing NH Printers"
timeout /t 3

:: Bethlehem Main House 			
:: Define variables
	set location=Bethlehem Main House
	set IP=192.168.125.105
	set port=IP_%IP%
	set driver=TOSHIBA Universal Printer 2
	set path=C:\Push\Toshiba\Toshiba-Print-Driver-Uni-3264bit-717638516\64bit\eSf6u.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 5 /nobreak

:: Bethlehem Carriage House 
:: Define variables
	set location=Bethlehem Carriage House
	set IP=192.168.125.90
	set port=IP_%IP%
	set driver=Xerox Global Print Driver PCL6
	set path=C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 5 /nobreak

:: Bethlehem Admin Office 
:: Define variables
	set location=Bethlehem Admin Office
	set IP=192.168.125.200
	set port=IP_%IP%
	set driver=Kyocera Classic Universaldriver PCL6
	set path=C:\Push\Kyocera\KyoClassicUniversalPCL6_v1.56\oemsetup.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 5 /nobreak

:: Doe Drive 
:: Define variables
	set location=Doe Drive
	set IP=192.168.124.22
	set port=IP_%IP%
	set driver=Xerox Global Print Driver PCL6
	set path=C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 5 /nobreak

:: Stag Dr Xerox 
:: Define variables
	set location=Stag Dr Xerox
	set IP=10.1.7.90
	set port=IP_%IP%
	set driver=Xerox Global Print Driver PCL6
	set path=C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 10 /nobreak

:: Stag Dr Kyocera
:: Define variables
	set location=Stag Dr Kyocera
	set IP=10.1.7.123
	set port=IP_%IP%
	set driver=Kyocera Classic Universaldriver PCL6
	set path=C:\Push\Kyocera\KyoClassicUniversalPCL6_v1.56\oemsetup.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 5 /nobreak

::display installed printers
powershell -Command "& {get-WmiObject -class Win32_printer | ft name, systemName;}"
timeout /t -1

