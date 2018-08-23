function configAadrm($uc){
    Get-Command -Module aadrm
    Connect-AadrmService -Credential $uc
    $rmsConfig = Get-AadrmConfiguration
    $licenseUri = $rmsConfig.LicensingIntranetDistributionPointUrl
}

function connectEx($uc){
    $ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $ExchangeSession
    Import-Module MsOnline; 
    Connect-MsolService -Credential $UserCredential; 
    return $ExchangeSession
}

function fixEx($uc){
    #turn off focused inbox
    Get-OrganizationConfig
    Set-OrganizationConfig -FocusedInboxOn $false
    #set passwords to not expire
    get-msoluser | Set-MsolUser -UserPrincipalName $userEmail -PasswordNeverExpires $true
}

#enable irm
function enableIrm($uc){
    Enable-Aadrm
    $rmsConfig = Get-AadrmConfiguration
    $licenseUri = $rmsConfig.LicensingIntranetDistributionPointUrl
    $eps = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    $irmConfig = Get-IRMConfiguration
    $list = $irmConfig.LicensingLocation
    if (!$list) { $list = @() }
    if (!$list.Contains($licenseUri)) { $list += $licenseUri }
    Set-IRMConfiguration -LicensingLocation $list
    Set-IRMConfiguration -AzureRMSLicensingEnabled $true -InternalLicensingEnabled $true
    Set-IRMConfiguration -SimplifiedClientAccessEnabled $true
    Set-IRMConfiguration -ClientAccessServerEnabled $true
}

#set up email encryption
function setUpEmailEncryption($uc, $eps){
    #enable irm
    enableIrm $uc
    #create Outgoing mailflow rule
    $ruleName = "Encrypt Outgoing Tagged Messages"; 
    $ruleTags = "ENCRYPT:"; 
    New-TransportRule -Name $ruleName -SentToScope NotInOrganization -SubjectContainsWords $ruleTags -ApplyRightsProtectionTemplate Encrypt; 
    #create Incoming mailflow rule
    $ruleName = "Decrypt Incoming Messages";
    New-TransportRule -Name $ruleName -SentToScope InOrganization -RemoveOME $true; 
}

function setupSP($uc,$NameOfTenant){
    #disable external sharing
    $spurl = "https://$NameOfTenant.sharepoint-admin.sharepoint.com/" 
    Connect-SPOService -Url $spurl -credential $uc
    Set-SPOTenant -SharingCapability Disabled
}

function disableUserGroups($uc, $eps){
    #disable users's ability to create groups
    Import Module MsOnline; 
    Connect-MsolService -Credential $uc;
    Import-PSSession $eps;
    #create group that can create groups
    $gname = "SG-CanCreateO365Groups"
    $gdesc = "Group for users who are able to create groups."
    $mems = @("aait");
    $g = New-MsolGroup -DisplayName $gname -Description $gdesc
    $mems | foreach {$uid = (Get-MsolUser -SearchString $_).ObjectId; Add-MsolGroupMember -GroupObjectId $g.ObjectId -GroupMemberType User -GroupMemberObjectId $uid; }
    Connect-AzureAD -Credential $uc
    #Change user default to not be able to create groups
    $Template = Get-AzureADDirectorySettingTemplate | where {$_.DisplayName -eq 'Group.Unified'}
    $Setting = $Template.CreateDirectorySetting()
    New-AzureADDirectorySetting -DirectorySetting $Setting
    $Setting = Get-AzureADDirectorySetting -Id (Get-AzureADDirectorySetting | where -Property DisplayName -Value "Group.Unified" -EQ).id
    $Setting["EnableGroupCreation"] = $False
    $Setting["Groupname"] = (Get-AzureADGroup -SearchString $gname).objectid
    $Setting["GroupCreationAllowedGroupId"] = (Get-AzureADGroup -SearchString $gname).objectid
    Set-AzureADDirectorySetting -Id (Get-AzureADDirectorySetting | where -Property DisplayName -Value "Group.Unified" -EQ).id -DirectorySetting $Setting
    set-AzureADTenantDetail -TechnicalNotificationMails "support@allaccessinfotech.com"
    $Setting.values
}

function main {
    $NameOfTenant = Read-Host -Prompt "Input the name of the tenant.  ex. @allaccess.onmicrosoft.com would be 'allaccess'"
    $uc = Get-Credential -UserName ("aait@"+$NameOfTenant+".onmicrosoft.com") -Message "Admin Password"
    $eps = $UserCredential

    Import-Module MsOnline;
    Enable-Aadrm
    Connect-MsolService -Credential $uc;
    Import-PSSession $eps
    
    configAadrm $uc
    connectEx $uc
    fixEx $uc
    enableIrm $uc
    setUpEmailEncryption $uc $eps
    setupSP $uc $NameOfTenant
    disableUserGroups $uc $eps

    Remove-Pssession $eps;
    Disconnect-AadrmService
}

main