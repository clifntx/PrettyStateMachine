rundll32 printui.dll,PrintUIEntry /dl /n "Fitchburg Nathan's office - TOSHIBA Universal Printer 2" /q
timeout /t 2 /nobreak
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.15.128 -h 10.10.15.128 -o raw -n 9100
timeout /t 2 /nobreak
rundll32 printui.dll,PrintUIEntry /if /b "Fitchburg Nathan's office - TOSHIBA Universal Printer 2" /f C:\Push\Toshiba\64bit\eSf6u.inf /r "IP_10.10.15.128" /m "TOSHIBA Universal Printer 2" /Z
timeout /t 2 /nobreak
