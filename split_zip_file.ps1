# Define paths and settings
$zipFilePath = "C:\Users\thinh\OneDrive\Desktop\script.zip"
$outputPath = "C:\Users\thinh\OneDrive\Desktop"        
$partSize = (Get-Item $zipFilePath).Length / 2 

# Ensure the output directory exists
if (-not (Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath | Out-Null
}

# Open the .zip file for reading
$fileStream = [System.IO.File]::OpenRead($zipFilePath)
$buffer = New-Object byte[] $partSize

# Split the file into two parts
for ($i = 1; $i -le 2; $i++) {
    $bytesRead = $fileStream.Read($buffer, 0, $buffer.Length)
    $partFilePath = "$outputPath\file_part$i.zip"
    [System.IO.File]::WriteAllBytes($partFilePath, $buffer[0..($bytesRead - 1)])
    Write-Host "Created part: $partFilePath"
}

# Close the file stream
$fileStream.Close()
Write-Host "File split completed."
