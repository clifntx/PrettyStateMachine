:: Newbury House 
:: Define variables
	set location=Newbury House
	set IP=10.0.0.200
	set port=IP_%IP%
	set driver=Kyocera TaskAlpha 3501i 
	set path=C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %driver%" /f %path% /r "%port%" /m "%driver%" /Z
timeout /t 2 /nobreak
