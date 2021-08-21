function listIPRDP{
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
}

function getCritical_Error_WarningLog($type){
    Write-Host "If you see ERROR: No events were found"
    Get-WinEvent –FilterHashtable @{logname=$type; level=1,2,3}  | Sort-Object -Property TimeCreated | Format-Table -Wrap
}

function main {
    Write-Host "TRACKING WINDOW LOGS TOOL"
    Write-Host "1. List RDP Remote IP"
    Write-Host "2. Show Applications Log"
    Write-Host "3. Show System Log"
    $option = Read-Host -Prompt 'Your Options'
    switch ($option)
    {
        1 {listIPRDP}
        2 {getCritical_Error_WarningLog('Application')}
        3 {getCritical_Error_WarningLog('system')}
        4 {Write-Host 'It is nothing. Author: Night Barron'}
    }
}

main