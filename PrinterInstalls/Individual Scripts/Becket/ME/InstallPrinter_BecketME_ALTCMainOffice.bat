cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.34.60 -h 192.168.34.60 -o raw -n 9100; 
rundll32 printui.dll,PrintUIEntry /if /b "ALTC Main Office - Xerox AltaLink B8055 PCL6" /f C:\Push\Xerox\ALB80XX_5.528.10.0_PCL6_x64_Driver.inf\x2ASNOX.inf /r "IP_192.168.34.60" /m "Xerox AltaLink B8055 PCL6" /Z; 
