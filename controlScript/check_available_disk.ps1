#retrieve available storage of all drives except for no drive letter and no capacity drives

$data=[pscustomobject]@{
        "ServerName" = [System.Environment]::MachineName
}
[System.Collections.Generic.List[PSObject]]$driveList=@()

$driveInfo = Get-WmiObject win32_volume | Where-Object {$_.DriveLetter -ne $null -and $_.Capacity -ne $null} 

foreach ($drive in $driveInfo) {
    $driveLetter = $drive.DriveLetter.Substring(0,1)
    $driveList.Add($driveLetter)
}

$driveCount = $driveList.Count

for ($i = 0; $i -lt $driveCount; $i++) {
    $element = $driveList[$i]
    $freeSpace = (Get-PSDrive $element).Free / 1GB
    $freeSpace = "{0:N1}" -f $FreeSpace
    $freeSpace_obj = @{
        "FreeDisk $element (GB)" = $freeSpace
    }
    $data | Add-Member $freeSpace_obj
}

$data
