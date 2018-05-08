:: Doe Drive 
:: Define variables
	set location=Doe Drive
	set IP=192.168.124.22
	set port=IP_%IP%
	set driver=TOSHIBA Universal Printer 2
	set path=C:\Push\Toshiba\Toshiba-Print-Driver-Uni-3264bit-717638516\64bit\eSf6u.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 2 /nobreak
