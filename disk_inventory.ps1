# Retrieve disk information (size, free space, usage rate) on multiple machines on different domain
# service account is used for the purpose of non-interactive automation

$currentDate = Get-Date -Format "yyyyMMdd"
$serverList = Get-Content "C:\serverlist.txt"
$resultFile = "C:\check_result_" + $currentDate + ".csv"
$errorLogFile = "C:\errorLog_" + $currentDate + ".txt"

$service_user = "service_account_here"
$service_password = ConvertTo-SecureString "password_here" -AsPlainText -Force
$service_creds = New-Object System.Management.Automation.PSCredential -ArgumentList $service_user, $service_password
$Skip = New-PSSessionOption -SkipCACheck -SkipCNCheck 

# Define script block for easy on the eyes
$script_block = {
    $drives = Get-CimInstance -ClassName Win32_LogicalDisk  -Filter DriveType=3 | Select-Object DeviceID, Size, FreeSpace
    $drives
}

foreach ($server in $serverList) {
    try {
        $session = New-PSSession -ComputerName $server -port 5986 -Credential $service_creds -useSSL -SessionOption $Skip -ErrorAction Stop
        $get_results = Invoke-Command -Session $session -ScriptBlock $script_block
        foreach ($drive in $get_results) {
            $totalSizeGB = [math]::truncate($drive.size / 1GB * 10) / 10
            $freeSpaceGB = [math]::truncate($drive.freespace / 1GB *10) / 10
            $usageRate = [math]::truncate(($drive.size - $drive.freespace) / $drive.size * 100)

            $result = [PSCustomObject]@{
                "Server Name" = $drive.PSComputerName
                "Drive Letter" = $drive.DeviceID
                "Total Size (GB)" = $totalSizeGB
                "Free Space (GB)" = $freeSpaceGB
                "Usage Rate (%)" = $usageRate
             }
             $result | Export-Csv -Path $resultFile -NoTypeInformation -Append
}
        Remove-PSSession $session
    }
    catch {
        $errorMsg = "Failed to connect to $server"
        Write-Host $errorMsg
        $errorMsg | Out-File -Append -FilePath $errorLogFile
    }
}
