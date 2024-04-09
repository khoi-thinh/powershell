# This script will scan java.exe path on remote windows machines, search for its Digital Signature and finally output to a CSV file

# Define input, output files
$currentDate = Get-Date -Format "yyyyMMdd"
$server_list = Get-Content "C:\serverlist.txt"
$result_csv_file = "C:\check_result_" + $currentDate + ".csv"
$final_csv_file = "C:\final_result_" + $currentDate + ".csv"
$errorLogFile = "C:\errorLog_" + $currentDate + ".txt"

# Define account
$service_user = "account_here"
$service_password = ConvertTo-SecureString "password_here" -AsPlainText -Force
$service_creds = New-Object System.Management.Automation.PSCredential -ArgumentList $service_user, $service_password
$Skip = New-PSSessionOption -SkipCACheck -SkipCNCheck 

# Define script block 

$script_block_drive = {
    $drive_path = ""
    $driveName = Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $server -Filter DriveType=3 | Select-Object -ExpandProperty DeviceID
    foreach ($drive in $driveName) {
        $drive_path += "$drive\,"
    }
    $drive_path = $drive_path.TrimEnd(",")
    $drive_path = $drive_path -split ","
    $Java_Paths = Get-ChildItem -Path $drive_path -Recurse -Filter java.exe | Select-Object fullname
    $Java_Paths
}
       
# Output server and Java path to a csv file#

foreach ($servername in $server_list) {
    try {
        $session = New-PSSession -ComputerName $servername -port 5986 -Credential $service_creds -useSSL -SessionOption $Skip -ErrorAction Stop
        $get_results = Invoke-Command -Session $session -ScriptBlock $script_block_drive
        foreach ($result in $get_results) {
            $resultObject = [pscustomobject]@{"Server Name"=$servername; "Java Path"=$result.FullName}
            $resultObject | Export-Csv -Path $result_csv_file -NoTypeInformation -Append
}
        Remove-PSSession $session
    }
    catch {
        $errorMsg = "Failed to connect to $servername"
        Write-Host $errorMsg
        $errorMsg | Out-File -Append -FilePath $errorLogFile
    }
}

# Check the Digital Signature and output it along with server, Java path to a different csv file#

$data = Import-Csv -Path $result_csv_file

$script_block_signature = {
        $path_props = Get-ChildItem $using:javapath | Get-AuthenticodeSignature
        $Issuer = $path_props.SignerCertificate.Subject.Split(',')[0].Substring(3)
        $Issuer
}
foreach ($row in $data) {
    $servername = $row."Server Name"
    $javapath = $row."Java Path"

    $bundle = Invoke-Command -ComputerName $servername -port 5986 -Credential $service_creds -useSSL -SessionOption $Skip -ScriptBlock $script_block_signature

    $issuer_object = [pscustomobject]@{"Server Name"=$servername; "Java Path"=$javapath; "Type"=$bundle}
    $issuer_object | Export-Csv -Path $final_csv_file -NoTypeInformation -Append
} 
