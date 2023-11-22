#Add timeout to drop any jobs that takes long time, in this example the Control Script will call the check_update_state.ps1 to check servers that are fully updated or not and output to a CSV file

$serverList = Get-Content "$env:USERPROFILE\serverlist.txt"
$resultFile = "$env:USERPROFILE\check_result.csv"
$scriptFile = "$env:USERPROFILE\check_update_state.ps1"
$connectionErrors = "$env:USERPROFILE\check_error.csv"

$timeOut = 120

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

$remote_trigger = Invoke-Command @Command -AsJob
$remote_trigger | Wait-Job -Timeout $timeOut
$results = $remote_trigger | Receive-Job 

$results | Select-Object ServerName,Status | Export-Csv -Path $resultFile -Append -NoTypeInformation -Force

Remove-PSSession -Session $Sessions 
