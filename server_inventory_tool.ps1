# A simple app to manage servers or whatever you want. Supports add, edit, delete, search functions. Data stored on LiteDB.
# Import-Module c:\temp\PSLiteDB\module\PSLiteDB.psd1 -verbose
#$dbPath = "C:\temp\LiteDB\Inventory.db"

# Create new DB: 
#New-LiteDBDatabase -Path $dbPath -Verbose

#Open-LiteDBConnection -Database $dbPath

#New-LiteDBCollection -Collection Inventory

# $dataset = @"
# serverName,ip,owner,os,role,status
# JPWWSUS02,10.1.1.1,Khoi,Windows,Patching JP server,ON
# JPWCIDDDV01,10.2.2.2,Jewel,Linux,CICD Server,OFF
# "@

# $inventory = $dataset | ConvertFrom-Csv | Select-Object serverName, ip, owner, os, role, status

# $inventory | ConvertTo-LiteDbBSON | Add-LiteDBDocument -Collection Inventory

function displayMenu {
    $menu = @"
--------------------------------------------------     
Japan Server Inventory Tool

1. Show all servers: Press '1'
2. Add a new server: Press '2'
3. Edit a server: Press '3'
4. Delete a server: Press '4'
5. Search a server: Press '5'
6. Quit: Press 'q'
--------------------------------------------------
"@
    Write-Host $menu
}

function showAll {
    $retrieveAll = Find-LiteDBDocument Inventory -Sql "Select $ from Inventory"
    $retrieveAll | Select-Object serverName,role,owner,status,ip,os | Format-Table -AutoSize
}
function addServer {
    Write-Host "Enter information to add a new server"
    $serverName = Read-Host "Type server name"
    $ip = Read-Host "Type IP"
    $owner = Read-Host "Type server owner"
    $os = Read-Host "Type server OS (Windows/Linux)"
    $role = Read-Host "Type server role"
    $status = Read-Host "Type server status: ON/OFF"
    $record = [PSCustomObject]@{
        serverName = $serverName
        ip = $ip
        owner = $owner
        os = $os
        role = $role
        status = $status
    }
    $record | ConvertTo-LiteDbBSON | Add-LiteDBDocument -Collection Inventory
    Write-Host "$serverName was added to inventory"
}

function editServer {
    $inputHashTable = @{}
    $serverName = Read-Host "Enter the server name you want to edit"
    $retrieveInfo = Find-LiteDBDocument Inventory -Sql "Select $ from Inventory where serverName = '$serverName'"
    if ($null -eq $retrieveInfo) {
        Write-Host "$serverName is not existed. Please try again!"
        return
    }

    # Output result in table format
    $retrieveInfo | Select-Object serverName,role,owner,status,ip,os | Format-Table -AutoSize
  
    # Grap column data user want to change
    $userInput = Read-Host "Type information fields you want to edit, separated by space (e.g: ip os). Acceptable fields: serverName, ip, role, owner, os, status"
    foreach ($info in $userInput.split()) {
        $value = Read-Host "Type $info"
        $inputHashTable[$info] = $value
    }

    # build SQL query
    $sqlCommand = "UPDATE Inventory SET "
    foreach ($key in $inputHashTable.Keys) {
        $sqlCommand += "$key='$($inputHashTable[$key])',"
    }
    $sqlCommand = $sqlCommand.TrimEnd(',')
    $sqlCommand += " where serverName='$serverName'"

    # query
    Update-LiteDBDocument 'Inventory' -sql $sqlCommand
    Write-Host "Updated inventory for $serverName successfully"
}

function deleteServer {
    $serverName = Read-Host "Enter the server name you want to delete"
    $retrieveInfo = Find-LiteDBDocument Inventory -Sql "Select $ from Inventory where serverName = '$serverName'"
    if ($null -eq $retrieveInfo) {
        Write-Host "$serverName is not existed. Please try again!"
        return
    }
    $retrieveInfo | Select-Object serverName,role,owner,status,ip,os | Format-Table -AutoSize

    $confirm = Read-Host "Are you sure you want to delete $serverName Yes/No?"
    if ($confirm -eq "Yes") {
        Remove-LiteDBDocument 'Inventory' -Sql "delete Inventory where serverName = '$serverName'"
        Write-Host "$serverName was deleted successfully from inventory"
    }
    elseif ($confirm -eq "No") {
        Write-Host "Nothing changes. $serverName will not be deleted from inventory"
    }
    else {
        Write-Host "Please choose Yes or No"
    }
}
function searchServer {
    $inputHashTable = @{}
    $userInput = Read-Host "Enter the server information you want to search. Acceptable fields: serverName, ip, role, owner, os, status"
    foreach ($info in $userInput.split()) {
        $value = Read-Host "Type $info"
        $inputHashTable[$info] = $value
    }
    # build SQL query
    $sqlCommand = "Select $ from Inventory where "
    foreach ($key in $inputHashTable.Keys) {
        $sqlCommand += "$key='$($inputHashTable[$key])' and "
    }
    $sqlCommand = $sqlCommand.TrimEnd('and ')

    # query
    $retrieveInfo = Find-LiteDBDocument Inventory -sql $sqlCommand
    if ($null -eq $retrieveInfo) {
        Write-Host "No servers found. Please try again!"
        return
    }
    $retrieveInfo | Select-Object serverName,role,owner,status,ip,os | Format-Table -AutoSize
}

do {
    displayMenu
    $user_input = Read-Host "Please choose options"
    switch ($user_input) {
        '1' {
            showAll
        }
        '2' {
            addServer
        }
        '3' {
            editServer
        }
        '4' {
            deleteServer
        }
        '5' { 
            searchServer
        }
        'q' {
            return
        }
    }
}
until ($user_input -eq 'q')

# Close-LiteDBConnection
