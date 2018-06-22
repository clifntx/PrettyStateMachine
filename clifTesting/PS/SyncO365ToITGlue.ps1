Param(
  [string]$itGlueOrgId = "",
  [int]$logLevel = -1,
  [string]$key = "ITG.ab8ed4b03e2c131e806e7b9031ba460b.dE71XYP8jV7VbKL1rBJkMn-FNyA9vLPPc9L324afViB9WYxgp9O3dd5Go3j24nPx",
  [string]$assetTypeId = "",
  [string]$baseURI = "https://api.itglue.com"
)

$testOrgId = "2672661"
$arcOrgId = "1383693"
$O36_ASSET_ID = "81964"
$assetTypeId = $O36_ASSET_ID

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

#works
function startMsolSession($creds=$null) {
#Connects an O365 MsolSession
    log "Calling startMsolSession(`n>>> -creds $creds`n>>> )" "darkgray"
    log "...Connecting to MsolSession." "white"    
    Import-Module MsOnline;
    if($creds) {
        log "...Using provided O365 credentials." "Gray"
        $UserCredential = $creds
    } else {
        log "...Need O365 credentials." "Gray"
        $UserCredential = Get-Credential;
        }
    Connect-MsolService -Credential $UserCredential;
#    $ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/  -Credential $UserCredential -Authentication Basic -AllowRedirection 
#    Import-PSSession $ExchangeSession
#    return $ExchangeSession
    return ""
}

#works
function endMsolSession($session) {
#Ends an O365 MsolSession
    log "Calling endMsolSession(`n>>> -session $session`n>>> )" "darkgray"
    if($session.Length -ne "") {
        log "...Ending session. $session" "Gray"
        Remove-PSSession $session; 
    } else {
        log "...Session is empty.  Continuing." "Gray"
        }
}
   
#works
function GetITGlueOrganization($id, $key) {
# takes a customer id# and an api key
# returns all data for customer
    log "Calling GetITGlueOrganization(`n>>> -id $id`n>>> -key <private api key>`n>>> )" "darkgray"    
    $headers = @{
        "x-api-key" = $key
    }
    $array = @()
    $get = "organizations/$id"
    $uri = "$baseURI/$get"
    write-host "--Attempting rest call.  uri [$uri] headers [$headers]"
    write-host "--Using api key [$key]"
    try {
        #https://api.itglue.com/organizations?sort=id
        $body = Invoke-RestMethod -Method get -Uri $uri -Headers $headers -ContentType application/vnd.api+json
        write-host "--Rest call returned: [$body]"
        $array += $body.data
        Write-Host "Retrieved $($array.Count) items"
    } catch {
        if(($_.Exception.Message).length -gt 0){$ErrorMessage = $_.Exception.Message; write-host " >> ErrorMessage [$ErrorMessage]";}
        if(($_.Exception.ItemName).length -gt 0){$FailedItem = $_.Exception.ItemName; write-host " >> FailedItem [$FailedItem]";}
    }     
    if ($body.links.next) {
        do {
            $body = Invoke-RestMethod -Method get -Uri $body.links.next -Headers $headers -ContentType application/vnd.api+json
            $array += $body.data
            Write-Host "Retrieved $($array.Count) items"
        } while ($body.links.next)
    }
    return $array
}

#works
function GetAllITGlueOrganizations($key) {
# takes a customer id# and an api key
# returns all data for customer
    log "Calling GetAllITGlueOrganizations(`n>>> -key <private api key>`n>>> )" "darkgray"        
    $headers = @{
        "x-api-key" = $key
    }
    $array = @()
    $get = "organizations?sort=id"
    $uri = "$baseURI/$get"
    write-host "--Attempting rest call.  uri [$uri] headers [$headers]"
    write-host "--Using api key [$key]"
    try {
        #https://api.itglue.com/organizations?sort=id
        $body = Invoke-RestMethod -Method get -Uri $uri -Headers $headers -ContentType application/vnd.api+json
        write-host "--Rest call returned: [$body]"
        $array += $body.data
        Write-Host "Retrieved $($array.Count) items"
    } catch {
        if(($_.Exception.Message).length -gt 0){$ErrorMessage = $_.Exception.Message; write-host " >> ErrorMessage [$ErrorMessage]";}
        if(($_.Exception.ItemName).length -gt 0){$FailedItem = $_.Exception.ItemName; write-host " >> FailedItem [$FailedItem]";}
    }     
    if ($body.links.next) {
        do {
            $body = Invoke-RestMethod -Method get -Uri $body.links.next -Headers $headers -ContentType application/vnd.api+json
            $array += $body.data
            Write-Host "Retrieved $($array.Count) items"
        } while ($body.links.next)
    }
    return $array
}

#works
function GetAllITGlueItems($Resource, $key) {
# takes a resource string and an api key
# returns an array of ITGlue data
    log "Calling GetAllITGlueItems(`n>>> -Resource $Resource`n>>> -key <private api key>`n>>> )" "darkgray"        
    $array = @()
    $headers = @{
        "x-api-key" = $key
    } 
    $body = Invoke-RestMethod -Method get -Uri "$baseUri/$Resource" -Headers $headers -ContentType application/vnd.api+json
    $array += $body.data
    Write-Host "Retrieved $($array.Count) items"
       
    if ($body.links.next) {
        do {
            $body = Invoke-RestMethod -Method get -Uri $body.links.next -Headers $headers -ContentType application/vnd.api+json
            $array += $body.data
            Write-Host "Retrieved $($array.Count) items"
        } while ($body.links.next)
    }
    return $array
}
   
function CreateITGlueItem ($resource, $body, $key) {
    log "Calling CreateITGlueItem(`n>>> -resource $resource`n>>> -body $body`n>>> -key <private api key>`n>>> )" "darkgray"            
    $headers = @{
        "x-api-key" = $key
    }
    $item = Invoke-RestMethod -Method POST -ContentType application/vnd.api+json -Uri $baseURI/$resource -Body $body -Headers $headers
    return $item
}
   
function UpdateITGlueItem ($resource, $existingItem, $newBody, $key) {
    log "Calling UpdateITGlueItem(`n>>> -resource $resource`n>>> -existingItem $existingItem`n>>> -newBody $newBody`n>>> -key <private api key>`n>>> )" "darkgray"                
    $headers = @{
        "x-api-key" = $key
    }
    $updatedItem = Invoke-RestMethod -Method Patch -Uri "$baseUri/$Resource/$($existingItem.id)" -Headers $headers -ContentType application/vnd.api+json -Body $newBody
    return $updatedItem
}

#works
function buildO365TenantData($orgId) {
#takes in an itglue org id, and uses existing Msol Session
#returns an object with data about regarding O365 tenant
    log "Calling buildO365TenantData(`n>>> -orgId $orgId`n>>> )" "darkgray"                
    $companyInfo = Get-MsolCompanyInformation
    Write-Host "Gathering company info for $($companyInfo.DisplayName)" -ForegroundColor Green
    $domains = Get-MsolDomain | Where-Object {$_.status -contains "Verified"}
    $initialDomain = ($customerDomains | where {$_.IsInitial -eq "True"}).Name
    $o365TenantData = @{
        itglueId         = $orgId
        tenantName       = $companyInfo.DisplayName
        tenantId         = $companyInfo.ObjectId
        initialDomain    = $initialDomain
        verifiedDomains  = $domains
    }
    return $o365TenantData
}

function GetAllMsolCustomers {
    log "Calling GetAllMsolCustomers( no args )" "darkgray"           
    return Get-MsolPartnerContract -All
}

#works
function GetMsolLicenseData {
#uses existing Msol session to pull data from O365 tenant
#returns a list of objects with license data and all users with that license
    log "Calling GetMsolLicenseData( no args )" "darkgray"            
    log "...Gathering license data from existing Msol session." "White"
    $lod = @()
    $licenseData = @{}
    $users = Get-MsolUser
    Get-MsolAccountSku | foreach {
        $lsku = $_.AccountSkuId
        $uwl = @();
#        write-host "Looking for $lsku in users"
        $users | foreach { 
            $usku = $_.Licenses.AccountSkuId
#            write-host "Comparing $usku to $lsku"
            if($usku -eq $lsku) { 
                $uwl += $_.DisplayName
#                write-host "YES!!" $_.DisplayName
                }
            }
#        write-host $uwl
        $licenseData = ($_ | select AccountSkuId, ActiveUnits, ConsumedUnits, Users)
        $licenseData.Users = $uwl
#        write-host "licenseData: " $licenseData
        $lod += $licenseData
        }
    return $lod
}

#works
function build0365Asset($assetTypeId, $o365TenantData, $licenseData, $key){
# takes in an assetTypeId, o365TenantData object, licenseData object, and api key
# returns a json object ready to post to ITGlue
    log "Calling build0365Asset(`n>>> -assetTypeId $assetTypeId`n>>> -o365TenantData $o365TenantData`n>>> -licenseData $licenseData`n>>> -key <private key>`n>>> )" "darkgray"                    
    Write-Host "Building O365 data object for [ $($o365TenantData.tenantName) ]" -ForegroundColor Green
    $licenses = ""
    $licenseUsers = ""
    $licenseData | foreach {
        $licenses += "License Sku: $($_.AccountSkuId)<br>Purchased: $($_.ActiveUnits)<br>Assigned: $($_.ConsumedUnits)<br><br>"
        $licenseUsers += "<b>$($_.AccountSkuId) Users:</b><br>"
        $_.Users | foreach {
            $licenseUsers += "$_, "
        }
        $licenseUsers += "<br><br>"
    }
    $body = @{
        data = @{
            type       = "flexible-assets"
            attributes = @{
                "organization-id"        = $o365TenantData.itglueId
                "flexible-asset-type-id" = $assetTypeId
                traits                   = @{
                    "tenant-name"      = $o365TenantData.tenantName
                    "tenant-id"        = $o365TenantData.tenantId
                    "initial-domain"   = $o365TenantData.initialDomain
                    "verified-domains" = $o365TenantData.verifiedDomains.Name
                    "licenses"         = $licenses
                    "licensed-users"   = $licenseUsers
                }
            }
        }
    }
    $postBodyJson = $body | ConvertTo-Json -Depth 10
    return $postBodyJson
}

function main ($orgId, $assetTypeId, $key) {
    log "Calling main(`n>>> -orgId $orgId`n>>> -assetTypeId $assetTypeId`n>>> -key <private api key>`n>>> )" "darkgray"
    $session = startMsolSession
    log "Gathering data for asset for organization [ $orgId ]..." "white"
    $ldata = GetMsolLicenseData
    $odata = buildO365TenantData $orgId
    $postBody = build0365Asset $assetTypeId $odata $ldata $key
    log "Creating Office 365 Asset for [ $($odata.tenantName) ]..." "white"
    $newItem = CreateITGlueItem -resource flexible_assets -body $postBody -key $key
    endMsolSession $session 
}

main $itGlueOrgId $assetTypeId $key