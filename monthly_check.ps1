<#
Logs
FreeDiskSpace
exchange health test - mailflow and Queues
EXCHANGE mailbox store and mailboxes
BPA
WAN test
Email sent out the result
WSUS - UPDATES approval
AD/LDAP
DNS
WINS
DHCP
VEEAM BACKUP STATUS CHECK
#>

param(
    #[string] $server = (Read-Host "hostname"),
    [array]$servers = @("tpdc01", "tpex01", "tporcl01", "tpvbr01", "rds01"),
    [array]$exchangeservers = @("tpex01"),
    $output = "C:\temp\abc.txt"

)

Get-Date -Format g | out-file $output -Append
###### Mon Sep 17 11:42:30 AEST 2018  freediskspace
<# Invoke-Command -ComputerName $servers {`
        get-wmiobject win32_volume | `
        Where-Object { $_.DriveType -eq 3 -and $_.Label -notlike "System Reserved"} | `
        ForEach-Object { get-psdrive $_.DriveLetter[0] }} | `
    Sort-Object pscomutpername, Root #>


get-wmiobject Win32_LogicalDisk -ComputerName $servers -Filter "DriveType=3"  | `
    Select-Object systemname, Name, volumename, FileSystem, FreeSpace, BlockSize, Size | `
    ForEach-Object {$_.BlockSize = (($_.FreeSpace) / ($_.Size)) * 100; $_.FreeSpace = ($_.FreeSpace / 1GB); $_.Size = ($_.Size / 1GB); $_} | `
    Format-Table systemname, Name, volumename, @{n = 'FS'; e = {$_.FileSystem}}, @{n = 'Free(Gb)'; e = {'{0:N2}' -f $_.FreeSpace}}, @{n = 'Capacity(Gb)'; e = {'{0:N2}' -f $_.Size}}, @{n = '%Free'; e = {'{0:N2}' -f $_.BlockSize}} -AutoSize



Get-MailboxDatabase -status | Format-List | out-file $output -Append ; `
    get-mailboxstatistics -Server tpex01 | `
    Add-Member -MemberType ScriptProperty -Name TotalItemSizeinMB -Value {$this.totalitemsize.value.ToMB()} -PassThru |`
    Sort-Object totalitemsize, lastlogontime | `
    Format-Table DisplayName, itemcount, totalitemsize, lastlogontime -AutoSize | out-file $output -Append

Test-ServiceHealth

Get-WsusComputer | Sort-Object last*
Get-WsusUpdate -Classification Critical, Security -Approval Unapproved -Status FailedOrNeeded | Approve-WsusUpdate -Action Install -TargetGroupName "All Computers"
