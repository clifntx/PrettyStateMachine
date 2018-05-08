echo ON

set XeroxDriverPath=C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf
set XeroxDriver=Xerox Global Print Driver PCL6
 
set KyoceraDriverPath=C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf

set ToshibaDriverPath=C:\Push\Toshiba\64bit\eSf6u.inf
set ToshibaDriver=TOSHIBA Universal Printer 2

set HPDriverPath=C:\Push\HP\UniversalDriver_PCL6\hpbuio200l.inf
set HPDriver=HP Universal Printing PCL 6

:: Hampton 10.10.172.61
set IP=10.10.172.61
:: Death to all printers with this name!
rundll32 printui.dll,PrintUIEntry /dl /n "Plainfield Admissions - TOSHIBA Universal Printer 2" /q
:: Install Port 
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_%IP% -h %IP% -o raw -n 9100
::take a breath
timeout /t 2 /nobreak  
:: install Printer
rundll32 printui.dll,PrintUIEntry /if /b "Hampton - %ToshibaDriver%" /f %ToshibaDriverPath% /r "IP_%IP%" /m "%ToshibaDriver%" /Z
::take a breath
timeout /t 5 /nobreak 



::display installed printers
powershell -Command "& {get-WmiObject -class Win32_printer | ft name, systemName;}"
timeout /t -1