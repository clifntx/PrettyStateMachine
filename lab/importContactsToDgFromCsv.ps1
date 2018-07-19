function createDG($GroupName, $GroupEmailAddress){
    try {
        New-DistributionGroup -Name $GroupName -DisplayName "DG_$groupName" -PrimarySmtpAddress $GroupEmailAddress -ErrorAction Stop
    } catch {
        write-host ">> UNCAUGHT ERROR: createDG($GroupName)"
    }
}

function addEmailToDG($group, $userEmail){
    #Write-Host "    >calling addEmailToDG($groupName, $userEmail)"
    #$group = Get-Group $GroupName
    #Write-Host "  retrieved group [$($group.Name)]"
    $recipient = Get-Recipient $userEmail
    #Write-Host "  retrieved recipient [$($recipient.Alias)]"
    #write-host "  Adding $($recipient.Alias) to $($group.Name)"
    if($group.Members -contains $recipient) { 
        #Write-Host "  Found $userEmail in $groupName!" 
    } Else { 
        #Write-Host "  NOT FOUND!!!  Adding $recipient to group."; 
        $res = Add-DistributionGroupMember -Identity $group.Name -Member $recipient.Alias 
        #$group = get-group $group.Name
        #write-host "  $($group.Name) now now contains $($group.Members.Count) members."
    } 
    return $group   
}

#Check to see if a mail contact exists.  Returns a boolean.
function contactExists($EmailAddress){
    $e1 = [bool](Get-MailContact $EmailAddress -ErrorAction SilentlyContinue)
    $e2 = [bool](Get-MailBox $EmailAddress -ErrorAction SilentlyContinue)
    return ($e1 -or $e2)
}

#Check to see if each row in a csv exists as a mail contact, creates it if it doesn't.
function verifyContact($name, $email){
    #Write-Host "    >calling verifyContact($name, $email)"
    If(contactExists $email -ErrorAction SilentlyContinue) { 
        #Write-Host "  Found contact for [$email]"
        return $true
    } Else { 
        #Write-Host "  Did not find [$email].  Creating!";
        New-MailContact -Name $name.trim() -ExternalEmailAddress $email.trim()
        return $true
    }
}

#Check to see if each row in a csv exists as a mail contact, creates it if it doesn't.
function main($csvPath, $groupName, $groupEmailAddress){
    createDG $groupName $groupEmailAddress
    $csv = Import-Csv $csvPath
    $group = Get-Group $GroupName
    Write-Host "  ..retrieved group [$($group.Name)]"
    $csv | ForEach { 
        write-host "  Processing user name:[$($_.name)] email:[$($_.email)]..."
        $email = $_.email.trim() -replace " ", ""
        $name = $_.name.trim() -replace " ", ""
        if($name.Length -lt 1) {
            $name = $email
        }
        $res = verifyContact $name $email
        $group = addEmailToDG $group $email
        write-host "  ..[$($group.Name)] -contains [$name] = $($group.Members -contains $recipient.Name)"
        write-host "  ..completed user"
    }
    $group = Get-Group $GroupName
    write-host "Script complete.  [$($group.Name)].Members.Count = $($group.Members.Count)"
}
main