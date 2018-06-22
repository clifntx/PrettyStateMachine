
$keys = @(
  @{path="HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PassportForWork"; key="Enabled"; val="dword:00000000"; },

  @{path="HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System"; key="Wallpaper"; val="c:\\push\\wallpaper.jpg"; },
  @{path="HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System"; key="WallpaperStyle"; val="0";},

  @{path="HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; key="DisableWindowsConsumerFeatures"; val="dword:00000001"; },

  @{path="HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"; key="NoDriveTypeAutoRun"; val="dword:00000091"; },
  @{path="HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"; key="NoStartMenuMyGames"; val="dword:00000001"; },

  @{path="HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System"; key="NoStartMenuMyGames"; val="dword:00000000"; },
)

$keys | foreach {
    Set-ItemProperty -Path $path -Key $key -Value $val
    }
