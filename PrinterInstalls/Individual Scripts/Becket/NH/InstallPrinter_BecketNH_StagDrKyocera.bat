rundll32 printui.dll,PrintUIEntry /dl /n "Stag Dr Kyocera - Kyocera Classic Universaldriver PCL6" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.1.7.123 -h 10.1.7.123 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Stag Dr Kyocera - KX DRIVER for Universal Printing" /f C:\Push\printerDrivers\Kyocera\KXPrintDriverv7.3.1207\64bit\oemsetup.inf /r "IP_10.1.7.123" /m "KX DRIVER for Universal Printing" /z
