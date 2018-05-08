rundll32 printui.dll,PrintUIEntry /dl /n "Plymouth Admin - Kyocera TASKalfa 5551ci" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.1.190 -h 10.10.1.190 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Plymouth Admin - Kyocera TASKalfa 5551ci" /f C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf /r "IP_10.10.1.190" /m "Kyocera TASKalfa 5551ci" /Z
