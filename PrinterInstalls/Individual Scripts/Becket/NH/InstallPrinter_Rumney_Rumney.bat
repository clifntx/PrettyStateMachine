rundll32 printui.dll,PrintUIEntry /dl /n "Rumney - Kyocera TASKalfa 3501i" /q

cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r IP_10.10.3.12 -h 10.10.3.12 -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "Rumney - Kyocera TASKalfa 3501i" /f C:\Push\Kyocera\xxx1i_xxx1ci_PCL_Uni\oemsetup.inf /r "IP_10.10.3.12" /m "Kyocera TASKalfa 3501i" /Z

0127boar