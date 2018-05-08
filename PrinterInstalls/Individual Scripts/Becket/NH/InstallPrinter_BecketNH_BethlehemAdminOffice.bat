:: Bethlehem Admin Office 
:: Define variables
	set location=Bethlehem Admin Office
	set IP=192.168.125.200
	set port=IP_192.168.125.200
	set driver=Kyocera Classic Universaldriver PCL6
	set path=C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf

:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.125.200 -h 192.168.125.200 -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "Bethlehem Admin Office - Kyocera Classic Universaldriver PCL6" /f C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf /r "IP_192.168.125.200" /m "Kyocera Classic Universaldriver PCL6" /Z
timeout /t 2 /nobreak
