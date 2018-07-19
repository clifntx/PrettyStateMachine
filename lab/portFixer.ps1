function fixPort($portName){
    $port = get-printerport $portName
    $p = @{
        "Name"= $port.Name -replace " ", "";
        "ip"= $port.PrinterHostAddress -replace " ", "";
    }
    Remove-PrinterPort $port.Name
    timeout /t 10
    Add-PrinterPort -Name $p.Name -PrinterHostAddress $p.IP
    timeout /t 10
    return !((get-printerport -Name $portName).PrinterHostAddress -contains " ")
}

function changePrinterPort($printerName,$printerPortName, $printerPortIP) {
    set-printer -Name $printerName -PortName (get-printerport)[0].Name
    timeout /t 30
    remove-printerport $printerPortName
    timeout /t 10
    add-printerport -Name $printerPortName -PrinterHostAddress $printerPortIP
    timeout /t 5
    set-printer -Name $printerName -PortName $printerPortName
    timeout /t 30
    $res = get-printer -name $printerName | select *
    return ((get-printerport -Name (get-printer $printerName).PortName).PrinterHostAddress -eq $printerPortIP)
}

function testPrinter($printerName){
    $res = (get-wmiobject win32_printer) | ? {$_.Name -like "$printerName"}.printTestPage()
    #0 = win.  Anything else = fail.
    return $res.ReturnValue -eq 0
}

function main(){
    $ports = Get-PrinterPort | ? {$_.Description -eq "Standard TCP/IP Port"}
    $flag = $true
    get-printer | foreach {
        $res = fixPort($_.PortName)
        if(!($res)){
            $flag = $false
        }
    }
    return $flag
}


$printerName = "CRA - *"
$printerPortName
main