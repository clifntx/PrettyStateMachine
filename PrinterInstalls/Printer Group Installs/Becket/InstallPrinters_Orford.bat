echo "Installing Orford Printers"
timeout /t 3

:: Orford Upstairs		
:: Define variables
	set location=Orford Upstairs
	set IP=192.168.123.135
	set port=IP_%IP%
	set driver=TOSHIBA Universal Printer 2
	set path=C:\Push\Toshiba\64bit\eSf6u.inf
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

