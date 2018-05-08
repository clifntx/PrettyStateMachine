cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.1.31 -h 10.10.1.31 -o raw -n 9100
timeout /t 2 /nobreak
rundll32 printui.dll,PrintUIEntry /if /b "Plymouth Academic Office - TOSHIBA Universal Printer 2" /f C:\Push\Toshiba\64bit\eSf6u.inf /r "IP_10.10.1.31" /m "TOSHIBA Universal Printer 2" /Z 