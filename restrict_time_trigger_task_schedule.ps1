# Restrict user from setting certain time for a task schedule (e.g: Reboot all Production servers)
# In this example, user will see a warning if he/she tries to set the time before 02:05

$task_name = "task_schedule_name"

$today = Get-Date
$tomorrow = $today.AddDays(1)
$tomorrow_object = Get-Date $tomorrow -UFormat %Y-%m-%d

$start_time = Read-Host "Enter time in format HH:mm (Hour:minute)"
$min_start_time_object = Get-Date "02:05"
$max_start_time_object = Get-Date "03:00"

$pattern = "^(?:[01]?\d|2[0-3])(?::[0-5]\d){1,2}$"

if ($start_time -eq "" -or $start_time -notmatch $pattern) {
    Write-Host "Invalid format. Try again!" -ForegroundColor Yellow
}
else {
    $start_time_object = Get-Date $start_time
    if ($start_time_object -lt $min_start_time_object -or $start_time_object -gt $max_start_time_object) {
        Write-Host "Start time must be between 02:05 and 03:00. Try again!" -ForegroundColor Yellow
    }
    else {
        $start_time = "$tomorrow_object $start_time"
        $start_time_trigger = New-ScheduledTaskTrigger -At $start_time -Once
        Set-ScheduledTask -TaskName $task_name -Trigger $start_time_trigger
        Write-Host "Trigger time for $task_name updated to $start_time" -ForegroundColor Yellow
    }
}
