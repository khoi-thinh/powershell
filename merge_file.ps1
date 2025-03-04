$part1 = "C:\path\to\split\files\yourfile.part1"
$part2 = "C:\path\to\split\files\yourfile.part2"
$mergedFile = "C:\path\to\merged\merged.zip"

# Open the target file for writing
$fsMerged = [System.IO.File]::Create($mergedFile)

# Read and write the first part
$fsPart1 = [System.IO.File]::OpenRead($part1)
$buffer = New-Object byte[] 64MB
while (($bytesRead = $fsPart1.Read($buffer, 0, $buffer.Length)) -gt 0) {
    $fsMerged.Write($buffer, 0, $bytesRead)
}
$fsPart1.Close()

# Read and write the second part
$fsPart2 = [System.IO.File]::OpenRead($part2)
while (($bytesRead = $fsPart2.Read($buffer, 0, $buffer.Length)) -gt 0) {
    $fsMerged.Write($buffer, 0, $bytesRead)
}
$fsPart2.Close()

# Close the merged file stream
$fsMerged.Close()

Write-Output "Merge complete. File saved as $mergedFile"

