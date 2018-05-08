cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.21.2  -h 192.168.21.2  -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Southwick - Xerox Global Print Driver PCL6" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.21.2 " /m "Xerox Global Print Driver PCL6" /Z
