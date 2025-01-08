# Remove all videos that have the second-to-last number in their filename that is lower than 157. Filename examples below
# DJI_20241221095539_0157_D
# DJI_20241221095751_0158_D
# DJI_xxxxxxxxxxxxxx_0xxx_D

# Define path
$folderPath = "C:\travel"

# Threshold value
$threshold = 157

Get-ChildItem -Path $folderPath -File | ForEach-Object {
    $parts = $_.BaseName -split "_"
    if ($parts[-2] -as [int]) {
        $lastPart = [int]$parts[-2] 

        if ($lastPart -lt $threshold) {
            Write-Host "Deleting file: $($_.FullName)" -ForegroundColor Yellow
            Remove-Item -Path $_.FullName -Force
        }
    }
}
