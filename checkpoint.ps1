$VM_MASK = "test-*" # VM name mask
$VM_SNAPSHOT_COUNT = 4 # minimum count
$VM_SNAPSHOT_NAME_PREFIX = "Daily" #name prefix
$TELEGRAM_BOT_TOKEN = "111111111:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" #INPUT your telegram bot token
$TELEGRAM_CHAT_ID = "-111111111" #INPUT your telegram chat id (use "-" for group)


$vm_arr = Get-VM -Name $VM_MASK

# take snapshots
$vm_arr | Checkpoint-VM -SnapshotName "$VM_SNAPSHOT_NAME_PREFIX [$((Get-Date).ToShortDateString()) $((Get-Date).ToLongTimeString())]" -AsJob
Get-Job | Wait-Job


foreach($vm in $vm_arr)
{
  $snapshot_arr = $vm | Get-VMSnapshot | Where-Object Name -like "$VM_SNAPSHOT_NAME_PREFIX *"
  $i = 0
  while ( $VM_SNAPSHOT_COUNT -le $snapshot_arr.Length-$i )
  {
    Remove-VMSnapshot -VMSnapshot ($snapshot_arr[$i++])
  }
}


# remove completed jobs
Get-Job -State "Completed" | Remove-Job

# send info to telegram
$jobs = Get-Job

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

if ($jobs.Length -gt 0) { 
    Invoke-WebRequest -URI "http://api.telegram.org/bot$($TELEGRAM_BOT_TOKEN)/sendMessage?chat_id=$($TELEGRAM_CHAT_ID)&text=Checkpoints `"$($VM_SNAPSHOT_NAME_PREFIX)`" of the `"$($VM_MASK)`" group are FAILED on $($env:COMPUTERNAME)"
}
else {
    Invoke-WebRequest -URI "http://api.telegram.org/bot$($TELEGRAM_BOT_TOKEN)/sendMessage?chat_id=$($TELEGRAM_CHAT_ID)&disable_notification=true&text=Checkpoints `"$($VM_SNAPSHOT_NAME_PREFIX)`" of the `"$($VM_MASK)`" group are COMPLETED on $($env:COMPUTERNAME)"
}

exit
