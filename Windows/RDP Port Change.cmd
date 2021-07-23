@echo off
echo -------------------------------------------------
echo - %~nx0 
echo - 
echo - Author: tan.ta@vietnix.com.vn
echo -
echo - Allows you to change the RDP port
echo -   (Note: RDP default is 3389 0xd3d in hex)
echo - 
echo - Here is the current setting (in hex):
reg query "hklm\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "PortNumber"
echo -------------------------------------------------
:: check admin
net session >nul 2>&1
if %errorLevel% == 0 (echo [Admin confirmed]) else (echo ERR: Admin denied. Right-click and run as administrator. & pause & goto :EOF)
:: check admin
set /p rdp_port="Change to port to (Press enter for default 3389):"
if "%rdp_port%" EQU "" set rdp_port=3389
echo - Continuing will set it to to %rdp_port%
pause
reg add "hklm\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "PortNumber" /t REG_DWORD /d %rdp_port% /f
echo - Here is the new setting     (in hex):
reg query "hklm\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "PortNumber"
echo ---------- Next we will add the port to firewall, then disconnect any running terminal services
echo ---------- You should be able to reconnect using the new port (if you get disconnected)
pause
echo -- Adding to firewall rules ...
netsh advfirewall firewall add rule name="RDP Port %rdp_port%" profile=any protocol=TCP action=allow dir=in localport=%rdp_port%
echo -- Stopping and starting services ...
net stop termservice /yes
net start termservice
:DONE
echo ---------- Done
pause
