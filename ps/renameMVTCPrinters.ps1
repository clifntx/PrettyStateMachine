(get-printer).Name | foreach {
    if($_.contains("MVTC")){ 
        $nn = "Pike" + -join $_[4..$_.Length]; 
        write-host "$_ >> $nn"; 
        Rename-Printer -Name $_ -NewName $nn 
        }
    }