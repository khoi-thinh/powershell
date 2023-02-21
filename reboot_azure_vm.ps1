# run from Azure Cloud shell

$azure_data = @(
    [PSCustomObject]@{SubscriptionName='Subscription_A'},
    [PSCustomObject]@{SubscriptionName='Subscription_B'},
    [PSCustomObject]@{SubscriptionName='Subscription_C'})

foreach ($data in $azure_data) {
    #select Azure subscription to work on and get the list of VM
    $SubscriptionName = $data.SubscriptionName
    Select-AzureRmSubscription -SubscriptionName $SubscriptionName

    $server_List = get-azvm | where {($_.Tags['wins_reboot'] -eq "true")}

    ForEach ($server in $server_List) {
        $job_progress = Restart-AzVM -ResourceGroupName $server.ResourceGroupName -Name $server.Name -AsJob
        while ($job_progress.State -eq "Running") {
        Start-Sleep 1
        } # while loop
        Write-Host "$job_progress is completed"

        $job_result = Receive-Job -Job $job_progress 

        $result = [PSCustomObject]@{
        ServerName       = $server.Name
        Reboot_Status   = $job_result.Status
        }
        $result >> result.txt
    } #for loop

} # for loop
