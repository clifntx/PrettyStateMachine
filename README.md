# Win10DesktopDeployment

TODO:<br>
<ol>
<li>[ ] Automate standard wks setup</li>
<li>[ ] Automate client wks setup</li>
<li>[ ] Automate user wks setup</li>
</ol>

[ ] General Setup ( scripting goal #1 ) \\192.168.1.24\technet\Setup_Workstations\main.bat<br>
  Change AllAccess profile picture \\192.168.1.24\technet \AAIT Graphics\AllAccessLogo01.jpg<br>
  Setup 3 GPOs (Group Policy)<br>
    Computer Configuration > Administrative Templates > Windows Components > Cloud Content > Turn off Microsoft consumer experience<br>
      Enable<br>
    User Configuration > Administrative Templates > StartMenu and Taskbar >  Remove Game Links from Start Menu<br>
      Enable<br>
    User Configuration > Administrative Templates > Desktop > Desktop > Desktop Wallpaper<br>
      Enable<br>
  Path to desktop =  c:\push\wallpaper.jpg<br>
  Lenovo System Update<br>
  Run System Update.  Update if necessary.<br>
  Install all updates<br>
  Run System Update again and check for additional updates.<br>
  Windows Updates<br>
  Check for updates<br>
  Install all updates<br>
  Reboot<br>
[ ] Setup for client (scripting goal #2)<br>
  Run client printer install script<br>
  Run client wireless ssid script<br>
  Move client push folder to c:\<br>
  Move client users folder to c:\<br>
  Install Nable<br>
  Install AV<br>
  Webroot or BitDefender(Nable's)<br>
  Install all client specific software<br>
    Installer in c:\push\install_these.<br>
    Forticlient, BestNotes, SharpDesk, etc<br>		
[ ] Setup for user (scripting goal #3)<br>
  Join to Azure AD (if applicable)<br>
  https://allaccess365.itglue.com/DOC-1343305-626779<br>
  Create user account<br>
  Office<br>
    Install Office (if applicable. If User has ProPlus license, use \\192.168.1.24\O365\installProPlus32.bat)<br>
    Setup Start Menu<br>
    Unpin unneeded tiles and clean up menu (Should have Office apps and browsers only pinned, also client software if applicable)<br>
    Configure Outlook<br>
  OneDrive<br>
    Setup OneDrive<br>
    Sync OneDrive<br>
    Redirect Desktop, Documents and Pictures to OneDrive<br>
    Setup needed Sharepoint sync folders<br>
    Verify that Sites are syncing via OneDrive, not OneDrive for Business<br>
    Sync all sites the user has permissions to<br>
  Open Chrome and enable Webroot extension (if applicable)<br>
  Camera<br>
    Verify Camera	<br>
    Open Camera App and make sure that camera displays video<br>
[ ] QA (scripting goal #4)<br>
  Check laptop against QA Checklist. https://allaccess365.itglue.com/DOC-1343305-537486 > QA sheet<br>
