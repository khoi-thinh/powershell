Function Add-VMInformation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$InventoryExcelPath,
        [Parameter(Mandatory=$true)]
        [string]$InputCSVPath,
        [Parameter(Mandatory=$true)]
        [string]$OutputExcelPath
    )

$csv_data = Import-Csv -Path $InputCSVPath
$inventory_data = import-excel $InventoryExcelPath -worksheet "Japan Servers" -headerrow 2

foreach ($row in $csv_data) {

    $server_name = $row."Server Name"
 
    foreach ($server in $inventory_data) {
        $bu = $server.'GI/Life'
        $environment = $server.'Environment'
        $app_software = $server.'Application / Software'
        $roll = $server.'Roll / Description'
        $pam_owner = $server.'Server Owner for PAM'

        if ($server.Hostname -eq $server_name) {
                $row.'GI/LIFE' = $bu
                $row.'Environment' = $environment
                $row.'Application / Software' = $app_software
                $row.'Roll / Description' = $roll
                $row.'Server Owner for PAM' = $pam_owner
            }
    }
     $row | Export-excel $OutputExcelPath -WorksheetName "Japan Servers" -Append
} 
}
