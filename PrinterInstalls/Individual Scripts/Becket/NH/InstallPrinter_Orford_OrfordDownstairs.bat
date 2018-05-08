cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_192.168.123.100 -h 192.168.123.100 -o raw -n 9100
timeout /t 2 /nobreak
rundll32 printui.dll,PrintUIEntry /if /b "Orford Downstairs - Kyocera TASKalfa 5551ci" /f C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf /r "IP_192.168.123.100" /m "Kyocera TASKalfa 5551ci" /Z
timeout /t 2 /nobreak

	
