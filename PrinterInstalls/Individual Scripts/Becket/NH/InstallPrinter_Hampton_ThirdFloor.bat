rundll32 printui.dll,PrintUIEntry /dl /n "Hampton Third Floor - TOSHIBA Universal Printer 2" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.172.63 -h 10.10.172.63 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Hampton Third Floor - TOSHIBA Universal Printer 2" /f C:\Push\Toshiba\64bit\eSf6u.inf /r "IP_10.10.172.63" /m "TOSHIBA Universal Printer 2" /Z
