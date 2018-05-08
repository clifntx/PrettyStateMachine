echo ON

set XeroxDriverPath=C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf
set XeroxDriver=Xerox Global Print Driver PCL6
 
set KyoceraDriverPath=C:\Push\Kyocera\KyoClassicUniversalPCL6_v1.56\OEMsetup.inf
set KyoceraDriver=Kyocera Classic Universaldriver PCL6

set KMC3110DriverPath=C:\Push\KonicaMinolta\C3110\bizhubC3110_Win10_PCL_PS_XPS_FAX_v1.2.1.0\bizhubC3110_Win10_PCL_PS_XPS_FAX_v1.2.1.0\Drivers\Win_x64\KOBK4J__.inf
set KMC3110Driver=KONICA MINOLTA C3110 PCL6

set KM4750DriverPath=C:\Push\KonicaMinolta\bizhub4750Series_Win10_PCL_PS_XPS_FAX_v3.1.0.0\Drivers\Win_x64\KOBK1J__.inf
set KM4750Driver=KONICA MINOLTA 4750 Series PCL6

set C3850fsDriverPath=C:\Push\KonicaMinolta\BizhubC3850fs_MFP_Win_x64\PCL\english\KOBJ_J__.inf
set C3850fsDriver=KONICA MINOLTA C3850 Series PCL6

:: MVTC Residential 10.10.10.64
:: Define variables
	set location=MVTC Residential
	set IP=10.10.10.64
	set port=IP_%IP%
	set driver=%C3850fsDriver%
	set path=%C3850fsDriverPath%
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
::take a breath
timeout /t 10 /nobreak 

:: MVTC Creamery 10.10.10.200
:: Define variables
	set location=MVTC Creamery
	set IP=10.10.10.200
	set port=IP_%IP%
	set driver=%KMC3110Driver%
	set path=%KMC3110DriverPath%
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
::take a breath
timeout /t 10 /nobreak 

:: MVTC Clinical 10.10.10.118
:: Define variables
	set location=MVTC Clinical
	set IP=10.10.10.118
	set port=IP_%IP%
	set driver=%KM4750Driver%
	set path=%KM4750DriverPath%
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
::take a breath
timeout /t 10 /nobreak 

:: MVTC Farmhouse 10.10.10.145
:: Define variables
	set location=MVTC Farmhouse
	set IP=10.10.10.145
	set port=IP_10.10.10.145
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %XeroxDriver%" /f %XeroxDriverPath% /r "%port%" /m "%XeroxDriver%" /Z

:: MVTC Nursing
:: Define variables
	set location=MVTC Nursing
	set IP=10.10.10.105
	set port=IP_%IP%_1
	set driver=Xerox Global Print Driver PCL6
	set path=C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf
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
