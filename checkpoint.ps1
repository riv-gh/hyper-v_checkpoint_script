$VM_MASK = "auto-*" # VM name mask
$VM_SNAPSHOT_COUNT = 4 # minimum count
$VM_SNAPSHOT_NAME_PREFIX = "Auto" #name prefix

# stop vm by mask
#Get-VM $VM_MASK | Stop-VM -Force -AsJob
#Get-Job | Wait-Job


# take snapshots
Get-VM $VM_MASK | Checkpoint-VM -SnapshotName "$VM_SNAPSHOT_NAME_PREFIX [$((Get-Date).ToShortDateString()) $((Get-Date).ToLongTimeString())]" -AsJob
Get-Job | Wait-Job

$vm_arr = Get-VM -Name $VM_MASK

foreach($vm in $vm_arr)
{
  $snapshot_arr = $vm | Get-VMSnapshot | Where-Object Name -like "$VM_SNAPSHOT_NAME_PREFIX *"
  $i = 0
  while ( $VM_SNAPSHOT_COUNT -le $snapshot_arr.Length-$i )
  {
    Remove-VMSnapshot -VMSnapshot ($snapshot_arr[$i++])
  }
}

# start 
#Get-VM $VM_MASK | Start-VM -AsJob
#Get-Job | Wait-Job

# remove completed jobs
Get-Job -State "Completed" | Remove-Job

exit
