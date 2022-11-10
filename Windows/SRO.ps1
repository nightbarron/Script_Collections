# Global Variables
#$INTERFACE = "Ethernet0"

function getInterfaces() {
    $interfaceAlias = (
        Get-NetIPConfiguration |ß
        Where-Object {
            $_.IPv4DefaultGateway -ne $null -and
            $_.NetAdapter.Status -ne "Disconnected"
        }).InterfaceAlias
    return $interfaceAlias
}

function chooseInterface() {
    $itf = getInterfaces
    if ($itf.Length -lt 7) {
        $count = 0
        $banner =  "Please choose target Interface:"
        foreach ($interface in $itf) {
            $count += 1
            $ip = getIP $interface
            $banner += "`n$count : $interface - $ip"
        }
        $choice = Read-Host -Prompt "$banner `nYour choice"
        return $itf[$choice - 1]
    } else {
        return $itf
    }
        
}

function createArpRetryCount() {
    $path = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
    $key = try {
        Get-Item -Path $path -ErrorAction Stop
    }
    catch {
        New-Item -Path $path -Force
    }
    New-ItemProperty -Path $key.PSPath -Name ArpRetryCount -Value 0 -Force
}

function addIpFw32([string]$ipFW) {
    try {
        New-NetIPAddress –IPAddress $ipFW –PrefixLength 32 –InterfaceAlias $INTERFACE –SkipAsSource $False
    } catch {
        echo "$ipFW/32 is added as alias!"
    }
}

function addProxyBat($ipFW, $ipVPS) {
    $proxypath = "C:\Documents and Settings\Administrator\Start Menu\Programs\Startup"
    New-Item -Path $proxypath -Name "proxy.bat" -ItemType "file" `
    -Value "netsh interface portproxy reset
netsh interface portproxy add v4tov4 listenaddress=$ipVPS listenport=15779 connectport=15779 connectaddress=$ipFW
netsh interface portproxy add v4tov4 listenaddress=$ipVPS listenport=15880 connectport=15880 connectaddress=$ipFW
netsh interface portproxy add v4tov4 listenaddress=$ipVPS listenport=15881 connectport=15881 connectaddress=$ipFW
netsh interface portproxy add v4tov4 listenaddress=$ipVPS listenport=15884 connectport=15884 connectaddress=$ipFW" -Force
}

function getIP($INTERFACE) {
    $ipVPS = (
    Get-NetIPConfiguration |
    Where-Object {
        $_.IPv4DefaultGateway -ne $null -and
        $_.NetAdapter.Status -ne "Disconnected" -and
        $_.InterfaceAlias -eq $INTERFACE
    }).IPv4Address.IPAddress
    return $ipVPS
}

function main() {
    createArpRetryCount

    $ipFW = Read-Host -Prompt 'Public IP FW'
    $interface = chooseInterface
    $ipVPS = getIP $interface
    addIpFw32 $ipFW
    addProxyBat $ipFW $ipVPS
    #BECAREFUL TO UNCOMMENT THE OPTIONS BELOW
    shutdown -r -t 0
}

main