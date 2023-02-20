# run from Azure Cloud shell

$azure_data = @(
    [PSCustomObject]@{SubscriptionName='Sub1_name'},
    [PSCustomObject]@{SubscriptionName='Sub2_name'},
    [PSCustomObject]@{SubscriptionName='Sub3_name'})

foreach ($data in $azure_data) {
    $SubscriptionName = $data.SubscriptionName

    #select Azure subscription to work on and get the list of VM based on tag 
    Select-AzureRmSubscription -SubscriptionName $SubscriptionName

    $server_List = get-azvm | where {($_.Tags['wins_reboot'] -eq "true")}

    ForEach ($server in $server_List) {
        $job_progress = Restart-AzVM -ResourceGroupName $server.ResourceGroupName -Name $server.Name -AsJob
    } #for loop

   #check for result of job and output it to a text file
    while ($job_progress.State -eq "Running") {
        Start-Sleep 1
    }
    Write-Host "$job_progress is completed"

    $job_result = Receive-Job -Job $job_progress 

    $result = [PSCustomObject]@{
        ServerName       = $server.Name
        Status   = $job_result.Status
    }
    $result >> result.txt
}
