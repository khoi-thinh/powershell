#Script for RDP/MSTSC auto login
#———————————-
function connect{
param ([Parameter(Mandatory=$true)]
[string[]]$Computer )
$User = “Domain\UserName”

if (-not (Test-Path .\Pass.txt))
{
read-host -assecurestring “Enter Password” | convertfrom-securestring | out-file .\Pass.txt
}
$password = cat .\pass.txt | convertto-securestring
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $User, $password
$pass = $cred.GetNetworkCredential().Password
$ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
$Process = New-Object System.Diagnostics.Process
$ProcessInfo.FileName = “$($env:SystemRoot)\system32\cmdkey.exe”
$ProcessInfo.Arguments = ” /generic:TERMSRV/$Computer /user:$User /pass:$Pass”
$Process.StartInfo = $ProcessInfo
$Process.Start()

$ProcessInfo.FileName = “$($env:SystemRoot)\system32\mstsc.exe”
$ProcessInfo.Arguments = ” /v $Computer”
$Process.StartInfo = $ProcessInfo
$Process.Start()

Start-Sleep -s 20
$ProcessInfo.FileName = “$($env:SystemRoot)\system32\cmdkey.exe”
$ProcessInfo.Arguments = “/delete TERMSRV/$Computer”
$Process.StartInfo = $ProcessInfo
$Process.Start()

}
#———————————-
Example:

Connect ServerName
