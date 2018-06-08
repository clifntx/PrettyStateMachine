function log ($str, $fc="white"){
# fc can be any of these [Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White]
    $fc = $fc.ToLower()
    switch ($fc) {
        "red"      {$priority = 5}
        "yellow"   {$priority = 4}
        "green"    {$priority = 2} 
        "white"    {$priority = 1}
        "gray"     {$priority = 0; $str = "  "+$str;}
        "darkgray" {$priority = -1}
        }
    if ($priority -ge $logLevel) {
        write-host $str -ForegroundColor $fc
        }
    }
function disableDefaultsSettings {
    log "Calling disableDefaultsSettings(`n>>> no args`n>>> )" "darkgray"
    #try {
        # Disable Deliver optimization that shares out windows updates 
        $dump = reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /t REG_DWORD /v DODownloadMode /d 0 /f
        $dump = reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DownloadMode" /t REG_DWORD /d 0 /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /t REG_DWORD /v SystemSettingsDownloadMode /d 3 /f
        $dump = reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d 0 /f

        # Disable onedrive or onedrive personal folder (depending on how it's set up) in file explorer
        $dump = reg add "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /t REG_DWORD /v "System.IsPinnedToNameSpaceTree" /d 0 /f  

        # a slew of privacy settings
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /t REG_DWORD /v Enabled /d 0 /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /t REG_DWORD /v EnableWebContentEvaluation /d 0 /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Input\TIPC" /t REG_DWORD /v Enabled /d 0  /f
        $dump = reg add "HKCU\Control Panel\International\User Profile" /t REG_DWORD /v HttpAcceptLanguageOptOut /d 1 /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /t REG_SZ /v Value /d DENY /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E5323777-F976-4f5b-9B55-B94699C46E44}" /t REG_SZ /v Value /d DENY /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{2EEF81BE-33FA-4800-9670-1CD474972C3F}" /t REG_SZ /v Value /d DENY /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{C1D23ACC-752B-43E5-8448-8D0E519CD6D6}" /t REG_SZ /v Value /d DENY /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E5323777-F976-4f5b-9B55-B94699C46E44}" /t REG_SZ /v Value /d DENY /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{D89823BA-7180-4B81-B50C-7E471E6121A3}" /t REG_SZ /v Value /d DENY /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{992AFA70-6F47-4148-B3E9-3003349C1548}" /t REG_SZ /v Value /d DENY /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{A8804298-2D5F-42E3-9531-9C8C39EB29CE}" /t REG_SZ /v Value /d DENY /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /t REG_SZ /v Value /d DENY /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{D89823BA-7180-4B81-B50C-7E471E6121A3}" /t REG_SZ /v Value /d DENY /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /t REG_DWORD /v AcceptedPrivacyPolicy /d 0 /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /t REG_DWORD /v Enabled /d 0 /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /t REG_DWORD /v RestrictImplicitTextCollection /d 1 /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /t REG_DWORD /v RestrictImplicitInkCollection /d 1 /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /t REG_DWORD /v HarvestContacts /d 0 /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /t REG_DWORD /v NumberOfSIUFInPeriod /d 0 /f

        # Disable cortana anad web/bing search
        $dump = reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d 0 /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f
        $dump = reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f

        # Disable scheduled tasks
        $dump = schtasks /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Disable
        $dump = schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable 
        $dump = schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable 
        #$dump = schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable
        $dump = schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable
        $dump = schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable
        $dump = schtasks /Change /TN "Microsoft\Windows\NetTrace\GatherNetworkInfo" /Disable
        $dump = schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable
    #} catch [UnauthorizedAccessException] {
        #log ">> Caught Error: UnauthorizedAccessException" "yellow"
    #    log "...running in an unelevated session.  Rerun script as admin." "red"
    #} catch {
    #    log ">> Uncaught Error: $($Error[0].Exception.getType().FullName)" "red"
    #    log ">> ... $($Error[0].Exception)" "red"
    #    }
    log "...disableDefaultsSettings process complete." "green"
}

disableDefaultsSettings
#pause