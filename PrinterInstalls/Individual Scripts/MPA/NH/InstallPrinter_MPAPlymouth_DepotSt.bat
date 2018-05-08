:: Depot St
:: Define variables
	set location=Depot St
	set IP=10.10.24.129
	set port=IP_%IP%
	set driver=TOSHIBA Universal Printer 2
	set driverPath=C:\Push\Toshiba\Toshiba-Print-Driver-Uni-3264bit-717638516\64bit\eSf6u.inf
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %driverPath% /r "%port%" /m "%driver%" /Z
timeout /t 2 /nobreak 
