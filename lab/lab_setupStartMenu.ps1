function setupStartMenu ($pathToSlayoutXML="c:\push\startMenu\slayout.xml") {
    
    Import-StartLayout –LayoutPath $pathToSlayoutXML –MountPath %systemdrive%

}

$pathToSlayoutXML = ""