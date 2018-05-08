rundll32 printui.dll,PrintUIEntry /dl /n "Campton Admin - Kyocera Classic Universaldriver PCL6" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.2.242 -h 10.10.2.242 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Campton Admin - Kyocera Classic Universaldriver PCL6" /f C:\Push\Kyocera\KyoClassicUniversalPCL6_v1.56\oemsetup.inf /r "IP_10.10.2.242" /m "Kyocera Classic Universaldriver PCL6" /Z

