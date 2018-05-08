:: Stag Dr Xerox 
:: Install Port
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.1.7.90 -h 10.1.7.90 -o raw -n 9100
:: Install Printer
rundll32 printui.dll,PrintUIEntry /if /b "Stag Dr Xerox - Xerox Global Print Driver PCL6" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_10.1.7.90" /m "Xerox Global Print Driver PCL6" /Z

