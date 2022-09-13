Get-EventLog -LogName Security -after (Get-date -hour 0 -minute 0 -second 0)| ?{(4624,4778) -contains $_.EventID -and $_.Message -match 'logon type:\s+(10)\s'}| %{
(new-object -Type PSObject -Property @{
TimeGenerated = $_.TimeGenerated
ClientIP = $_.Message -replace '(?smi).*Source Network Address:\s+([^\s]+)\s+.*','$1'
UserName = $_.Message -replace '(?smi).*Account Name:\s+([^\s]+)\s+.*','$1'
UserDomain = $_.Message -replace '(?smi).*Account Domain:\s+([^\s]+)\s+.*','$1'
LogonType = $_.Message -replace '(?smi).*Logon Type:\s+([^\s]+)\s+.*','$1'
})
} | sort TimeGenerated -Descending | Select TimeGenerated, ClientIP `
, @{N='Username';E={'{0}\{1}' -f $_.UserDomain,$_.UserName}} `
, @{N='LogType';E={
switch ($_.LogonType) {
2 {'Interactive - local logon'}
3 {'Network connection to shared folder)'}
4 {'Batch'}
5 {'Service'}
7 {'Unlock (after screensaver)'}
8 {'NetworkCleartext'}
9 {'NewCredentials (local impersonation process under existing connection)'}
10 {'RDP'}
11 {'CachedInteractive'}
default {"LogType Not Recognised: $($_.LogonType)"}
}
}}





# Other Tool by Night Barron

$Events = Get-WinEvent -logname "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational" | where {($_.Id -eq "25")} | Sort-Object -Property TimeCreated
$Results = Foreach ($Event in $Events) {
    $Result = "" | Select TimeCreated, ClientIP, Username
    $Result.TimeCreated = $Event.TimeCreated
    Foreach ($MsgElement in ($Event.Message -split "`n")) {
        $Element = $MsgElement -split ":"
        If ($Element[0] -like "User") {$Result.Username = $Element[1].Trim(" ")}
        If ($Element[0] -like "Source Network Address") {$Result.ClientIP = $Element[1].Trim(" ")}
    }
    $Result
} 
#$Results | Select TimeCreated, ClientIP, Username | Export-Csv C:\RDS.csv -NoType
$tables = $Results | Format-Table -Wrap | Out-String 
Write-Host $tables
