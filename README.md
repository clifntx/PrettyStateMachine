# Win10DesktopDeployment

TODO:<br>
<ol>
<li>[ ] Automate standard wks setup</li>
<li>[ ] Automate client wks setup</li>
<li>[ ] Automate user wks setup</li>
</ol>

<ol>
  <li>[ ] General Setup ( scripting goal #1 ) \\192.168.1.24\technet\Setup_Workstations\main.bat</li>
  <ol>
    <li>Change AllAccess profile picture \\192.168.1.24\technet \AAIT Graphics\AllAccessLogo01.jpg</li>
    <li>Setup 3 GPOs (Group Policy)</li>
    <ol>
      <li>Computer Configuration > Administrative Templates > Windows Components > Cloud Content > Turn off Microsoft consumer experience</li>
      <li>User Configuration > Administrative Templates > StartMenu and Taskbar >  Remove Game Links from Start Menu</li>
      <li>User Configuration > Administrative Templates > Desktop > Desktop > Desktop Wallpaper (Path to desktop =  c:\push\wallpaper.jpg)</li>
    </ol>
  <li>Lenovo System Update</li>
    <ol>
      <li>Run System Update.  Update if necessary.</li>
      <li>Install all updates</li>
      <li>Run System Update again and check for additional updates.</li>
      <li>Windows Updates</li>
      <li>Check for updates</li>
      <li>Install all updates</li>
      <li>Reboot</li>
    </ol>
  </ol>
<li>[ ] Setup for client (scripting goal #2)</li>
  <ol>
    <li>Run client printer install script</li>
    <li>Run client wireless ssid script</li>
    <li>Move client push folder to c:\</li>
    <li>Move client users folder to c:\</li>
    <li>Install Nable</li>
    <li>Install AV</li>
    <li>Webroot or BitDefender(Nable's)</li>
    <li>Install all client specific software</li>
    <li>Installer in c:\push\install_these. (Forticlient, BestNotes, SharpDesk, etc)</li>
  </ol>
<li>[ ] Setup for user (scripting goal #3)</li>
  <ol>
<li>Join to Azure AD (if applicable)</li>
<li>https://allaccess365.itglue.com/DOC-1343305-626779</li>
<li>Create user account</li>
<li>Office</li>
    <ol>
      <li>Install Office (if applicable. If User has ProPlus license, use \\192.168.1.24\O365\installProPlus32.bat)</li>
      <li>Setup Start Menu</li>
      <li>Unpin unneeded tiles and clean up menu (Should have Office apps and browsers only pinned, also client software if applicable</li>
      <li>Configure Outlook</li>
    </ol>
  <li>OneDrive</li>
    <ol>
      <li>Setup OneDrive</li>
      <li>Sync OneDrive</li>
      <li>Redirect Desktop, Documents and Pictures to OneDrive</li>
      <li>Setup needed Sharepoint sync folders</li>
      <li>Verify that Sites are syncing via OneDrive, not OneDrive for Business</li>
      <li>Sync all sites the user has permissions to.</li>
    </ol>
  <li>Open Chrome and enable Webroot extension (if applicable)</li>
  <li>Camera</li>
    <ol>
      <li>Verify Camera	</li>
      <li>Open Camera App and make sure that camera displays video</li>
    </ol>
  </ol>
<li>[ ] QA (scripting goal #4)</li>
  <ol>
    <li>Check laptop against QA Checklist. https://allaccess365.itglue.com/DOC-1343305-537486 > QA sheet</li>
  </ol>
</ol>
