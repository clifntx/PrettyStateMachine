:: Hall Farm 
:: Define variables
	set location=Hall Farm
	set IP=10.10.12.32
	set port=IP_%IP%
	set driver=unknown
	set path=None
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
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