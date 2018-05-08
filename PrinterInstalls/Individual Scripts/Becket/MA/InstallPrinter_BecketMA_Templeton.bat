set ToshibaDriverPath=C:\Push\Toshiba\64bit\eSf6u.inf
set ToshibaDriver=TOSHIBA Universal Printer 2

set location=Templeton Upstairs
set IP=10.10.120.21
set port=IP_%IP%
rundll32 printui.dll,PrintUIEntry /dl /n "%location% - %ToshibaDriver%" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
timeout /t 2 /nobreak
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %ToshibaDriver%" /f %ToshibaDriverPath% /r "%port%" /m "%ToshibaDriver%" /Z
timeout /t 5 /nobreak

set location=Templeton Downstairs
set IP=10.10.120.22
set port=IP_%IP%
rundll32 printui.dll,PrintUIEntry /dl /n "%location% - %ToshibaDriver%" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
timeout /t 2 /nobreak
rundll32 printui.dll,PrintUIEntry /if /b "%location% - %ToshibaDriver%" /f %ToshibaDriverPath% /r "%port%" /m "%ToshibaDriver%" /Z
timeout /t 2 /nobreak
