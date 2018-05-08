
echo "Installing Becket Maine Printers"

:: ALTC Admin Office 192.168.34.31
rundll32 printui.dll,PrintUIEntry /dl /n "ALTC (Admin. Office)" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.34.31 -h 192.168.34.31 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "ALTC Admin Office - Xerox Global Print Driver PCL6" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.34.31" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

:: ALTC Main Office 192.168.34.60
rundll32 printui.dll,PrintUIEntry /dl /n "ALTC Main Office" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.34.60 -h 192.168.34.60 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "ALTC Main Office - Xerox AltaLink B8055 PCL6" /f C:\Push\Xerox\ALB80XX_5.528.10.0_PCL6_x64_Driver.inf\x2ASNOX.inf /r "IP_192.168.34.60" /m "Xerox AltaLink B8055 PCL6" /Z
timeout /t 2 /nobreak

:: ALTC Conference Room 192.168.34.44
rundll32 printui.dll,PrintUIEntry /dl /n "ALTC Conference Room" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.34.44 -h 192.168.34.44 -o raw -n 9100
timeout /t 2 /nobreak
rundll32 printui.dll,PrintUIEntry /if /b "ALTC Conference Room - Xerox Global Print Driver PCL6" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.34.44" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

:: ALTC Workcentre 192.168.1.24
rundll32 printui.dll,PrintUIEntry /dl /n "ALTC Workcentre" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.1.24 -h 192.168.1.24 -o raw -n 9100
timeout /t 2 /nobreak
rundll32 printui.dll,PrintUIEntry /if /b "ALTC Workcentre - Xerox Global Print Driver PCL6" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.1.24" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

:: ALTC Phaser 192.168.1.19
rundll32 printui.dll,PrintUIEntry /dl /n "ALTC Phaser" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.1.19 -h 192.168.1.19 -o raw -n 9100
timeout /t 2 /nobreak
rundll32 printui.dll,PrintUIEntry /if /b "ALTC Phaser - Xerox Global Print Driver PCL6" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.1.19" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

:: Auburn 10.5.3.90
rundll32 printui.dll,PrintUIEntry /dl /n "Auburn - Xerox Global Print Driver PCL6" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.5.3.253 -h 10.5.3.253 -o raw -n 9100
timeout /t 2 /nobreak
rundll32 printui.dll,PrintUIEntry /if /b "Auburn - Xerox Global Print Driver PCL6" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_10.5.3.253" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

:: Belgrade 192.168.11.220
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.11.220 -h 192.168.11.220 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Belgrade (Color)" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.11.220" /m "Xerox Global Print Driver PCL6" /Z
rundll32 printui.dll,PrintUIEntry /if /b "Belgrade (BW)" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.11.220" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

:: CMLC Phaser 192.168.12.143
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.12.143 -h 192.168.12.143 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "CMLC Phaser (Color)" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.12.143" /m "Xerox Global Print Driver PCL6" /Z
rundll32 printui.dll,PrintUIEntry /if /b "CMLC Phaser (BW)" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.12.143" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

:: CMLC Workcentre 192.168.12.167
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.12.167 -h 192.168.12.167 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "CMLC Workcentre (Color)" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.12.167" /m "Xerox Global Print Driver PCL6" /Z
rundll32 printui.dll,PrintUIEntry /if /b "CMLC Workcentre (BW)" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.12.167" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

:: Gorham 10.5.2.90
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.5.2.90 -h 10.5.2.90 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Gorham (Color)" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_10.5.2.90" /m "Xerox Global Print Driver PCL6" /Z
rundll32 printui.dll,PrintUIEntry /if /b "Gorham (BW)" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_10.5.2.90" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

:: Litchfield 10.5.4.10
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.5.4.10 -h 10.5.4.10 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Litchfield (Color)" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_10.5.4.10" /m "Xerox Global Print Driver PCL6" /Z
rundll32 printui.dll,PrintUIEntry /if /b "Litchfield (BW)" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_10.5.4.10" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

:: Belgrade Main School Building 192.168.11.20
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.11.20 -h 192.168.11.20 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Belgrade Main School Building (Color)" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.11.20" /m "Xerox Global Print Driver PCL6" /Z
rundll32 printui.dll,PrintUIEntry /if /b "Belgrade Main School Building (BW)" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_192.168.11.20" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

:: Lewiston 10.10.109.126
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.109.126 -h 10.10.109.126 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Lewiston" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r "IP_10.10.109.126" /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

:: Lewiston Conference Room 10.10.109.127
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.109.127 -h 10.10.109.127 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Lewiston Conference Room - Xerox Global Print Driver PCL6" /f C:\Push\Xerox\X-GPD_5.404.8.0_PCL6_x64_Driver.inf\x2UNIVX.inf /r IP_10.10.109.127 /m "Xerox Global Print Driver PCL6" /Z
timeout /t 2 /nobreak

::display installed printers
powershell -Command "& {get-WmiObject -class Win32_printer | ft name, systemName;}"
timeout /t -1