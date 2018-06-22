function connectToO365 {
    $UserCredential = Get-Credential;
    Import-Module MsOnline;
    Connect-MsolService -Credential $UserCredential;
    $ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/  -Credential $UserCredential -Authentication Basic -AllowRedirection 
    Import-PSSession $ExchangeSession -AllowClobber;
    return $ExchangeSession;
}
function disconnectFromO365 ($sesh) {
    Remove-PSSession $sesh;
    return $true;
}