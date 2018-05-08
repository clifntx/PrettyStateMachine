# This script will check the ms17-010 vulnerability is patched using 2 methods as per the link below.
# The first method is by detecting that one of the applicable kb numbers given by microsoft are installed on a device.
# The second is by verifying the srv.sys file is patched (of an appropriate version depending upon windows version).
#
# Reference: https://support.microsoft.com/en-ca/help/4023262/how-to-verify-that-ms17-010-is-installed


# List of all HotFixes containing the patch
$KBNumbers = "KB4012216", "KB4012217", "KB4012218", "KB4012219", "KB4012220", "KB4012598", "KB4012606", "KB4013198", "KB4013429", "KB4015217", "KB4015219", "KB4015221", "KB4015549", "KB4015550", "KB4015551", "KB4015552", "KB4015553", "KB4015554", "KB4016635", "KB4016636", "KB4016637", "KB4019213", "KB4019214", "KB4019215", "KB4019216", "KB4019217", "KB4019218", "KB4019263", "KB4019264", "KB4019265", "KB4019472", "KB4019473", "KB4019474", "KB4022719", "KB4022168", "KB4022722", "KB4022726", "KB4022717", "KB4022723", "KB4022715", "KB4023680"
$hotfixes = $KBNumbers
$HotfixInstalled = '0'

Try
        {

# Search for the HotFixes
$hotfix = Get-HotFix -ComputerName $env:computername | Where-Object {$hotfixes -contains $_.HotfixID} | Select-Object -property "HotFixID"


# See if the HotFix was found
if ($hotfix) {

	$IDs = ""
	$hotfix | %{$IDs += ($(if($IDs){", "}) + $_.HotFixID)}

	Write-Host "Found HotFix(es): $IDs."
	$HotfixInstalled = '1'
	$HotfixName = "Found HotFix(es): $IDs."

} else {

    Write-Host "Did not Find HotFix. Please check and update this device."
	$HotfixInstalled = '0'
	$HotfixName = "Did not find Hotfix."
	
	}


# mark Win10v1703 as OK since its not affected by MS17-010, thanks to Andrew Harvey!
if (((Get-WmiObject Win32_OperatingSystem).Name -match 'Windows 10') -and ((Get-WmiObject Win32_OperatingSystem).Version -match '15063'))
{
	$HotfixInstalled = '1'
    $HotfixName = "Found Windows 10 v1703 which is OK without a patch KB."
}

} Catch {
	$HotfixInstalled = '0'
	$HotfixName = "Check for patch number failed."
}



 
$srvsysPatched = '0'
$srvsysVersion = "0"
 
[reflection.assembly]::LoadWithPartialName("System.Version")
$os = Get-WmiObject -class Win32_OperatingSystem
$osName = $os.Caption
$s = "%systemroot%\system32\drivers\srv.sys"
$v = [System.Environment]::ExpandEnvironmentVariables($s)

If (Test-Path "$v")
    {
    Try
        {
        $versionInfo = (Get-Item $v).VersionInfo

		
		if ($osName.Contains("Windows 10")) {
			$fileVersion = New-Object System.Version($versionInfo.ProductVersionRaw)
		}
		elseif ($osName.Contains("2016")) {
			$fileVersion = New-Object System.Version($versionInfo.ProductVersionRaw)
        }
		else {
		    $versionString = "$($versionInfo.FileMajorPart).$($versionInfo.FileMinorPart).$($versionInfo.FileBuildPart).$($versionInfo.FilePrivatePart)"
			$fileVersion = New-Object System.Version($versionString)
		}

		Write-Host $versionInfo
		Write-Host $fileVersion
		
		
        }
    Catch
        {
		$srvsysPatched = '0'
		$srvsysVersion = "Unable to retrieve file version info, please verify vulnerability state manually."
        Write-Host "Error. Unable to retrieve file version info, please verify vulnerability state manually." -ForegroundColor Yellow
        Return
        }
    }
Else
    {
	$srvsysPatched = '0'
	$srvsysVersion = "Srv.sys does not exist, please verify vulnerability state via Patch KB number."
    Write-Host "Error. Unable to locate Srv.sys/file does not exist, please verify vulnerability state via Patch KB number." -ForegroundColor Yellow
    Return
    }
if ($osName.Contains("Vista") -or ($osName.Contains("2008") -and -not $osName.Contains("R2")))
    {
    if ($versionString.Split('.')[3][0] -eq "1")
        {
        $currentOS = "$osName GDR"
        $expectedVersion = New-Object System.Version("6.0.6002.19743")
        } 
    elseif ($versionString.Split('.')[3][0] -eq "2")
        {
        $currentOS = "$osName LDR"
        $expectedVersion = New-Object System.Version("6.0.6002.24067")
        }
    else
        {
        $currentOS = "$osName"
        $expectedVersion = New-Object System.Version("9.9.9999.99999")
        }
    }
elseif ($osName.Contains("Windows 7") -or $osName.Contains("2008 R2") -or $osName.Contains("Server 2011"))
    {
    $currentOS = "$osName LDR"
    $expectedVersion = New-Object System.Version("6.1.7601.23689")
    }
elseif ($osName.Contains("Windows 8.1") -or $osName.Contains("2012 R2"))
    {
    $currentOS = "$osName LDR"
    $expectedVersion = New-Object System.Version("6.3.9600.18604")
    }
elseif ($osName.Contains("Windows 8") -or $osName.Contains("2012"))
    {
    $currentOS = "$osName LDR"
    $expectedVersion = New-Object System.Version("6.2.9200.22099")
    }
elseif ($osName.Contains("Windows 10"))
    {
    if ($os.BuildNumber -eq "10240")
        {
        $currentOS = "$osName TH1"
        $expectedVersion = New-Object System.Version("10.0.10240.17319")
        }
    elseif ($os.BuildNumber -eq "10586")
        {
        $currentOS = "$osName TH2"
        $expectedVersion = New-Object System.Version("10.0.10586.839")
        }
    elseif ($os.BuildNumber -eq "14393")
        {
        $currentOS = "$($osName) RS1"
        $expectedVersion = New-Object System.Version("10.0.14393.953")
        }
    elseif ($os.BuildNumber -eq "15063")
        {
        $currentOS = "$osName RS2"
        
		$srvsysPatched = '1'
		$srvsysVersion = "System is patched. Version of srv.sys: $($fileVersion.ToString()). No need to Patch. RS2 is released as patched. "
        return
        }
    elseif ($os.BuildNumber -eq "16199")
        {
        $currentOS = "$osName RS3"
        
		$srvsysPatched = '1'
		$srvsysVersion = "System is patched. Version of srv.sys: $($fileVersion.ToString()). No need to Patch. RS3 is released as patched. "
        return
        }		
    }
elseif ($osName.Contains("2016"))
    {
    $currentOS = "$osName"
    $expectedVersion = New-Object System.Version("10.0.14393.953")
    }
elseif ($osName.Contains("Windows XP"))
    {
    $currentOS = "$osName"
    $expectedVersion = New-Object System.Version("5.1.2600.7208")
    }
elseif ($osName.Contains("Server 2003"))
    {
    $currentOS = "$osName"
    $expectedVersion = New-Object System.Version("5.2.3790.6021")
    }
else
    {
	$srvsysPatched = '0'
	$srvsysVersion = "Unable to determine OS applicability, please verify vulnerability state via Patch KB number."
    Write-Host "Error. Unable to determine OS applicability, please verify vulnerability state manually." -ForegroundColor Yellow
    $currentOS = "$osName"
    $expectedVersion = New-Object System.Version("9.9.9999.99999")
    }
	
	Write-Host "`n`nCurrent OS: $currentOS (Build Number $($os.BuildNumber))" -ForegroundColor Cyan
	Write-Host "`nExpected Version of srv.sys: $($expectedVersion.ToString())" -ForegroundColor Cyan
	Write-Host "`nActual Version of srv.sys: $($fileVersion.ToString())" -ForegroundColor Cyan
If ($($fileVersion.CompareTo($expectedVersion)) -lt 0)
    {
    Write-Host "`n`n"
    Write-Host "System is NOT Patched" -ForegroundColor Red
	
	$srvsysPatched = '0'
	Write-Host "System is NOT Patched $srvsysPatched"
	$srvsysVersion = "System does not appear to be patched, please verify vulnerability state via Patch KB number. Version of srv.sys: $($fileVersion.ToString()), Expected version: $expectedVersion or higher."
    }
Else
    {
    Write-Host "`n`n"
    Write-Host "System is Patched" -ForegroundColor Green
	$srvsysPatched = '1'
	Write-Host "System is Patched $srvsysPatched"
	$srvsysVersion = "System is patched. Version of srv.sys: $($fileVersion.ToString()). Expected version: $expectedVersion or higher."

    }
#

 pause