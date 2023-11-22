#Control script to trigger a local script file (check available disk storage) against multiple remore machines and output data object to a local CSV
#Due to the dynamic column data (some machines might have C:, D: while some machines dont), we can pre-define the columns for CSV to prevent data missing

$serverList = Get-Content "$env:USERPROFILE\serverlist.txt"
$resultFile = "$env:USERPROFILE\check_result.csv"
$scriptFile = "$env:USERPROFILE\check_available_disk.ps1"
$connectionErrors = "$env:USERPROFILE\check_error.csv"

if (Test-Path -Path $resultFile) {
    $data =  Import-Csv -Path $resultFile | Select-Object -ExpandProperty 'ServerName' -Unique
    $serversList = $serverList | Where-Object { $_ -notin $data}
}
[System.Collections.Generic.List[PSObject]]$Sessions = @()

foreach ($server in $serverList) {

try {
    $session = New-PSSession -ComputerName $server -ErrorAction Stop
    $Sessions.Add($session)
}

catch {
    [pscustomobject]@{
        ServerName = $server
        Date = Get-Date
        ErrorMesssage = $_
    } | Export-Csv -Path $connectionErrors -Append -Encoding UTF8 -NoTypeInformation
}
}

$Command = @{
    Session = $Sessions
    FilePath = $scriptFile
}

$results = Invoke-Command @Command

$results | Select-Object * -ExcludeProperty RunSpaceID,PSComputerName,PSShowComputerName | Export-Csv -Path $resultFile -Append -NoTypeInformation -Force

Remove-PSSession -Session $Sessions 
