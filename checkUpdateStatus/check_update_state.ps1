# Checking if a Windows Server VM is fully up to date 

# GET HOSTNAME
$hostname = hostname

# Create criteria for searching
$criteria = "IsAssigned=1 and IsHidden=0 and IsInstalled=0"

# Create update seacher
$searcher = (New-Object -COM Microsoft.Update.Session).CreateUpdateSearcher()

# Search 
$updates = $searcher.Search($criteria).Updates

# Check the number of pending packages

if ($updates.Count -ne 0) {
   $data=[pscustomobject]@{
        "ServerName" = $hostname
        "Status" = "Pending"
}
} else {
   $data=[pscustomobject]@{
        "ServerName" = $hostname
        "Status" = "Updated"
}
}
$data

