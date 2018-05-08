set XeroxDriverPath=C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf
set XeroxDriver=Xerox Global Print Driver PCL6

set KyoceraDriverPath=C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf

set ToshibaDriverPath=C:\Push\Toshiba\64bit\eSf6u.inf
set ToshibaDriver=TOSHIBA Universal Printer 2

:: Beverly 10.10.7.19
rundll32 printui.dll,PrintUIEntry /dl /n "Beverly - Kyocera TASKalfa 3501i" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.7.19 -h 10.10.7.19 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Beverly - %ToshibaDriver%" /f %ToshibaDriverPath% /r "IP_10.10.7.19" /m "%ToshibaDriver%" /Z
timeout /t 2 /nobreak 

:: Manchester 10.10.5.6
rundll32 printui.dll,PrintUIEntry /dl /n "Manchester - Kyocera TASKalfa 3501i" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.5.6 -h 10.10.5.6 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Manchester - Kyocera TASKalfa 3051ci" /f %KyoceraDriverPath% /r "IP_10.10.5.6" /m "Kyocera TASKalfa 3051ci" /Z
timeout /t 2 /nobreak 

:: North Andover 10.10.8.87
rundll32 printui.dll,PrintUIEntry /dl /n "North Andover - Kyocera TASKalfa 3501i" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.8.87 -h 10.10.8.87 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "North Andover - %ToshibaDriver%" /f %ToshibaDriverPath% /r "IP_10.10.8.87" /m "%ToshibaDriver%" /Z
timeout /t 2 /nobreak 

:: Rochester 10.10.18.199
rundll32 printui.dll,PrintUIEntry /dl /n "Rochester - Kyocera TASKalfa 3501i" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.18.199 -h 10.10.18.199 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Rochester - %ToshibaDriver%" /f %ToshibaDriverPath% /r "IP_10.10.18.199" /m "%ToshibaDriver%" /Z

::display installed printers
powershell -Command "& {get-WmiObject -class Win32_printer | ft name, systemName;}"
timeout /t -1
