echo ON

set XeroxDriverPath=C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf
set XeroxDriver=Xerox Global Print Driver PCL6
 
:: Does not work for WIn10 set KyoceraDriverPath=C:\Push\Kyocera\KyoClassicUniversalPCL6_v1.56\OEMsetup.inf
:: Does not work for WIn10 set KyoceraDriver=Kyocera Classic Universaldriver PCL6

set KyoceraDriverPath=C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf

:: Plymouth Admin
:: Define variables
	set location=Plymouth Admin
	set IP=10.10.1.210
	set port=IP_10.10.1.210
	set KyoceraDriver=Kyocera TASKalfa 5551ci
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %KyoceraDriver%" /f %KyoceraDriverPath% /r "%port%" /m "%KyoceraDriver%" /Z
timeout /t 2 /nobreak 

:: Plymouth Res
:: Define variables
	set location=Plymouth Res
	set IP=10.10.1.190
	set port=IP_10.10.1.190
	set KyoceraDriver=Kyocera TASKalfa 4501i
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %KyoceraDriver%" /f %KyoceraDriverPath% /r "%port%" /m "%KyoceraDriver%" /Z
timeout /t 2 /nobreak 

:: Campton
:: Define variables
	set location= Campton
	set IP=10.10.2.36
	set port=IP_10.10.2.36
	set KyoceraDriver=Kyocera TASKalfa 3501i
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %KyoceraDriver%" /f %KyoceraDriverPath% /r "%port%" /m "%KyoceraDriver%" /Z
timeout /t 2 /nobreak 

:: Depot St
:: Define variables
	set location=Depot St
	set IP=10.10.24.129
	set port=IP_%IP%
	set driver=TOSHIBA Universal Printer 2
	set driverPath=C:\Push\Toshiba\64bit\eSf6u.inf
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %driverPath% /r "%port%" /m "%driver%" /Z
timeout /t 2 /nobreak 