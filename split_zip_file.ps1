$sourceFile = "C:\path\to\yourfile.zip"
$destinationFolder = "C:\path\to\split\files"
$chunkSize = 64MB  # Read/Write in 64MB chunks

# Get total file size
$fileSize = (Get-Item $sourceFile).length
$halfSize = [math]::Ceiling($fileSize / 2)  # Split into 2 equal parts

# Open source file for reading
$fs = [System.IO.File]::OpenRead($sourceFile)
$fs1 = [System.IO.File]::Create("$destinationFolder\yourfile.part1")
$fs2 = [System.IO.File]::Create("$destinationFolder\yourfile.part2")

$buffer = New-Object byte[] $chunkSize
$totalRead = 0

# Read and write first half
while ($totalRead -lt $halfSize -and ($bytesRead = $fs.Read($buffer, 0, $chunkSize)) -gt 0) {
    $fs1.Write($buffer, 0, $bytesRead)
    $totalRead += $bytesRead
}

# Read and write second half
while (($bytesRead = $fs.Read($buffer, 0, $chunkSize)) -gt 0) {
    $fs2.Write($buffer, 0, $bytesRead)
}

# Close all file streams
$fs.Close()
$fs1.Close()
$fs2.Close()

Write-Output "Splitting complete. Files saved in $destinationFolder"
