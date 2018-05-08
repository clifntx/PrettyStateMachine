cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.34.31 -h 192.168.34.31 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "ALTC (Admin. Office) - Xerox Global Print Driver PCL6" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.34.31" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak
