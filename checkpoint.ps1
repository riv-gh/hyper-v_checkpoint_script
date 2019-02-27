$VM_MASK = "auto-*" # VM name mask
$VM_SNAPSHOT_COUNT = 5 # minimum count
$VM_SNAPSHOT_NAME = "Auto" #name prefix

# stop vm by mask
Get-VM $VM_MASK | Stop-VM -Force -AsJob
Get-Job | Wait-Job


# take snapshots
Get-VM $VM_MASK | Checkpoint-VM -SnapshotName "$VM_SNAPSHOT_NAME [$((Get-Date).toshortdatestring()) $((Get-Date).toshorttimestring())]" -AsJob
Get-Job | Wait-Job

$vm_arr = Get-VM -Name $VM_MASK

foreach($vm in $vm_arr)
{
  $snapshot_arr = Get-VMSnapshot ($vm);
  if ( $VM_SNAPSHOT_COUNT -le $snapshot_arr.Length )
  {
    Remove-VMSnapshot -VMSnapshot ($snapshot_arr[0])
  }
}

# start 
Get-VM $VM_MASK | Start-VM -AsJob
Get-Job | Wait-Job

# remove completed jobs
Get-Job -State "Completed" | Remove-Job

exit
