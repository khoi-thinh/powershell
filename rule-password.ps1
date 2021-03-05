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

Write-Output
Write-Host "Your password is $hereyougo" 
