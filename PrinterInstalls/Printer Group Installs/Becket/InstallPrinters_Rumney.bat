
:: Rumney
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.3.12 -h 10.10.3.12 -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "Rumney - Kyocera TASKalfa 3051ci" /f C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf /r "IP_10.10.3.12" /m "Kyocera TASKalfa 3051ci" /Z
timeout /t 2 /nobreak 

:: Plymouth Admin
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.1.210 -h 10.10.1.210 -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "Plymouth Admin - Kyocera TASKalfa 5551ci" /f C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf /r "IP_10.10.1.210" /m "Kyocera TASKalfa 5551ci" /Z
timeout /t 2 /nobreak 

::display installed printers
powershell -Command "& {get-WmiObject -class Win32_printer | ft name, systemName;}"
timeout /t -1