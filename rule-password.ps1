#Scenario: Backup rule is to take snapshot monthly, the local user's password also rotate monthly automatically
# If we roll back the snapshot (says previous month) without remembering local password, then we can not login
# This script change the password of a specific local user based on the month, year along with some random string
# We can revert the password with the input as servername, month, year
 
try {
$month = (Get-Date).Month
$year = (Get-Date).Year
$hostname = hostname
$spe1 = "@["
$spe2 = "^!"
$spe3 = "+$"
$ins = $hostname.Insert(1, $spe1)
$ins = $ins.Insert(4, $spe2)
$ins = $ins.Insert(7, $spe3)

$random1 = -join ($year, $ins, $month)
$random2 = $random1.ToCharArray()

$reverse = [Array]::Reverse($random2) 
$final = -join $random2

$password = ConvertTo-SecureString $final –AsPlainText –Force

Write-Output $final

#Get-LocalUser -Name "simple" -ErrorAction Stop | Set-LocalUser -Password $password
#Write-Output "Password change SUCCESS" 
}

catch {
Write-Output "Password change FAILED"
}

# Reverse password
$ServerName = Read-Host -Prompt 'Input server name you need to retrieve password'
$RotatedMonth = Read-Host -Prompt 'Input the month you rotate your password'
$RotatedYear = Read-Host -Prompt 'Input the year you rotate your password'
$Retrieve = $ServerName.Insert(1, $spe1)
$Retrieve = $Retrieve.Insert(4, $spe2)
$Retrieve = $Retrieve.Insert(7, $spe3)
$conca1 = -join ($RotatedYear, $Retrieve, $RotatedMonth)
$conca2 = $conca1.ToCharArray()

$restore = [Array]::Reverse($conca2) 
$hereyougo = -join $conca2

Write-Host "Your password is $hereyougo" 
