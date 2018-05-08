:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.5.4.10 -h 10.5.4.10 -o raw -n 9100
::take a breath
timeout /t 2 /nobreak
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "Litchfield - Xerox Global Print Driver PCL6" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_10.5.4.10" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak
