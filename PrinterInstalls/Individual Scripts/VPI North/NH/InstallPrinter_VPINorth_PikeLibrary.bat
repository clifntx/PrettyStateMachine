rundll32 printui.dll,PrintUIEntry /dl /n "Pike Library - TOSHIBA Universal Printer 2" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.163.52 -h 192.168.163.52 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Pike Library - TOSHIBA Universal Printer 2" /f C:\Push\Toshiba\64bit\eSf6u.inf /r "IP_192.168.163.52" /m "TOSHIBA Universal Printer 2" /Z 