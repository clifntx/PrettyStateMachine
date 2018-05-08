set location=Campton Step Office
set IP=10.10.2.220
set port=IP_%IP%
rundll32 printui.dll,PrintUIEntry /dl /n "%location% - Kyocera ECOSYS M2535dn KX" /q
cscript c:\Windows\System32\Printing_Admin_Scripts\en-US\prnport.vbs -a -r %port% -h %IP% -o raw -n 9100
rundll32 printui.dll,PrintUIEntry /if /b "%location% - Kyocera ECOSYS M2535dn KX" /f C:\Push\Kyocera\KXPrintDriverv7.3.1207\64bit\oemsetup.inf /r %port% /m "Kyocera ECOSYS M2535dn KX" /Z