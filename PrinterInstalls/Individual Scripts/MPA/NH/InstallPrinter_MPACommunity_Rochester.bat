cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.18.50 -h 10.10.18.50 -o raw -n 9100


timeout /t 2 /nobreak

rundll32 printui.dll,PrintUIEntry /if /b "Rochester - Xerox Global Print Driver PCL6" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_10.10.18.50" /m "Xerox Global Print Driver PCL6" /Z


