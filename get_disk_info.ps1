# Retrieve disk information (size, free space, usage rate) on multiple machines on same domain

$currentDate = Get-Date -Format "yyyyMMdd"
$serverList = Get-Content "C:\serverlist.txt"
$resultFile = "C:\check_result_" + $currentDate + ".csv"
$errorLogFile = "C:\errorLog_" + $currentDate + ".txt"

# Save each disk result
$outputHashTable = @()

foreach ($server in $serverList) {
    try {
        $driveInfo = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $server -Filter DriveType=3 -ErrorAction Stop
        foreach ($drive in $driveInfo) {
            # no round up/down
            $totalSizeGB = [math]::truncate($drive.size / 1GB * 10) / 10
            $freeSpaceGB = [math]::truncate($drive.freespace / 1GB *10) / 10
            $usageRate = [math]::truncate(($drive.size - $drive.freespace) / $drive.size * 100)
            $result = [PSCustomObject]@{
                "Server Name" = $server
                "Drive Letter" = $drive.DeviceID
                "Total Size (GB)" = $totalSizeGB
                "Free Space (GB)" = $freeSpaceGB
                "Usage Rate (%)" = $usageRate
            }
            $outputHashTable += $result
        } 
    }
    catch {
        $errorMsg = "Error getting drive informartion from $server"
        Write-Host $errorMsg
        $errorMsg | Out-File -Append -FilePath $errorLogFile
    }
}

$outputHashTable | Export-Csv -Path $resultFile -NoTypeInformation
