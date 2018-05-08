:: Fitchburg (Busin. Office) 
:: Define variables
	set location=Fitchburg (Busin. Office)
	set IP=10.10.15.105
	set port=IP_%IP%
	set driver=TOSHIBA Universal Printer 2
	set path=C:\Push\Toshiba\64bit\eSf6u.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 2 /nobreak

cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.15.105 -h 10.10.15.105 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Fitchburg (Busin. Office) - TOSHIBA Universal Printer 2" /f C:\Push\Toshiba\64bit\eSf6u.inf /r "IP_10.10.15.105" /m "TOSHIBA Universal Printer 2" /Z
