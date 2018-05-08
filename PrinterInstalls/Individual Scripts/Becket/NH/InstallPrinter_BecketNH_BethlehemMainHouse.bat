:: Bethlehem Main House 
:: Define variables
	set location=Bethlehem Main House
	set IP=192.168.125.105
	set port=IP_192.168.125.105
	set driver=TOSHIBA Universal Printer 2
	set path=C:\Push\Toshiba\64bit\eSf6u.inf

:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.125.105 -h 192.168.125.105 -o raw -n 9100
:: Install printer
rundll32 printui.dll,PrintUIEntry /if /b "Bethlehem Main House - TOSHIBA Universal Printer 2" /f C:\Push\Toshiba\64bit\eSf6u.inf /r "IP_192.168.125.105" /m "TOSHIBA Universal Printer 2" /Z
