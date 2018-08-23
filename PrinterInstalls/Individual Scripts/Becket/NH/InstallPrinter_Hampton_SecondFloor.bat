rundll32 printui.dll,PrintUIEntry /dl /n "Hampton Second Floor - TOSHIBA Universal Printer 2" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.172.62 -h 10.10.172.62 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Hampton Second Floor - TOSHIBA Universal Printer 2" /f C:\Push\Toshiba\64bit\eSf6u.inf /r "IP_10.10.172.62" /m "TOSHIBA Universal Printer 2" /Z
