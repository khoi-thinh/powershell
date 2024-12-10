# Path to the Excel file
$excelFile = "C:\path\to\your\file.xlsx"

# Import Excel file
$data = Import-Excel -Path $excelFile -WorksheetName "Sheet1"

# Loop through each row in the Excel file
foreach ($row in $data) {
    $record = $row.Record
    $expectedCName = $row.CNAME

    # Resolve the DNS Name
    try {
        $dnsResult = Resolve-DnsName -Name $record -Type CNAME -ErrorAction Stop
        $actualCName = $dnsResult.NameHost

        # Compare the expected CNAME with the actual CNAME
        if ($actualCName -eq $expectedCName) {
            Write-Output "Match: $record -> $actualCName"
        } else {
            Write-Output "Mismatch: $record -> Expected: $expectedCName, Found: $actualCName"
        }
    } catch {
        Write-Output "Error resolving $record: $_"
    }
}
