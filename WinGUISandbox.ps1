function askToFix2 ([string]$title, [string]$text){
    Add-Type -AssemblyName System.Windows.Forms;
    $Form = New-Object System.Windows.Forms.Form

    $lblTitle = New-Object System.Windows.Forms.Label;
    $lblTitle.Text = 'Test Txt'
    $Form.controls.add($lblTitle);
    $lblText = New-Object System.Windows.Forms.TextBox;
    $lblText.Text = $text;
    $Form.controls.add($lblTitle);
    $res = $Form.ShowDialog();
    return $res;
}

function askBox ([string]$title, [string]$text){
    Add-Type -AssemblyName PresentationCore,PresentationFramework;
    $ButtonType = [System.Windows.MessageBoxButton]::YesNo;
    $MessageIcon = [System.Windows.MessageBoxImage]::Question;
    $MessageBody = $text;
    $MessageTitle = $title;
    $Result = [System.Windows.MessageBox]::Show($text,$title,$ButtonType,$MessageIcon)
    Write-Host "Your choice is $Result";
    return $Result;
}

function okBox ([string]$title, [string]$text){
    Add-Type -AssemblyName PresentationCore,PresentationFramework;
    $ButtonType = [System.Windows.MessageBoxButton]::OK;
    $MessageIcon = [System.Windows.MessageBoxImage]::Information;
    $MessageBody = $text;
    $MessageTitle = $title;
    $Result = [System.Windows.MessageBox]::Show($text,$title,$ButtonType,$MessageIcon)
    Write-Host "Your choice is $Result";
    return $Result;
}

$title = "Test Title";
$text = "This is test text.`n[PASS] Passed this test.`n[PASS] Passed this test.`n[PASS] Passed this test.";

$res = askBox $title $text;
okBox $title $res;
#askToFix2 $title $text;

