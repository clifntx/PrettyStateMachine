

FOR /F "tokens=* USEBACKQ" %%P IN (`wmic /node:"localhost" printer get name`) DO rundll32.exe printui.dll,PrintUIEntry /dl /n "%%P"