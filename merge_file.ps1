# Define paths
$outputFilePath = "C:\Users\thinh\OneDrive\Desktop\script_after.zip"  # Path to save the recombined file
$inputFiles = @("C:\Users\thinh\OneDrive\Desktop\file_part1.zip", "C:\Users\thinh\OneDrive\Desktop\file_part2.zip")  # List of split files

# Create the output file stream
$outputStream = [System.IO.File]::Create($outputFilePath)

# Combine the split files
foreach ($file in $inputFiles) {
    $inputStream = [System.IO.File]::OpenRead($file)
    $inputStream.CopyTo($outputStream)
    $inputStream.Close()
}

# Close the output stream
$outputStream.Close()
Write-Host "File recombined successfully."
