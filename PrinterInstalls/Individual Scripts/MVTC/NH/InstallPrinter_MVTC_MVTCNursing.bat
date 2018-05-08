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
