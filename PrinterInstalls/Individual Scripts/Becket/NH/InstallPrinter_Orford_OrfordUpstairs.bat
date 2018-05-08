cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.123.135 -h 192.168.123.135 -o raw -n 9100
timeout /t 2 /nobreak
rundll32 printui.dll,PrintUIEntry /if /b "Orford Upstairs - TOSHIBA Universal Printer 2" /f C:\Push\Toshiba\64bit\eSf6u.inf /r "IP_192.168.123.135" /m "TOSHIBA Universal Printer 2" /Z
timeout /t 2 /nobreak