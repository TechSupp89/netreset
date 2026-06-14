@echo off
title Ultimate Stable Network Reset Script
color 0A
:: ====================================================================
:: SECTION 1: AUTOMATIC ADMIN ELEVATION
:: ====================================================================
:init
setlocal DisableDelayedExpansion
set cmdInvoke=1
set localCmd=%~0
set "%~2"=1
set "vbsTest=%val%_admin_test"

net session >nul 2>&1
if %errorLevel%==0 (
    goto :gotAdmin
)

echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
echo UAC.ShellExecute "cmd.exe", "/c ""%localCmd%"" %*", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%temp%\OEgetPrivileges.vbs"
exit /B

:gotAdmin
if exist "%temp%\OEgetPrivileges.vbs" ( del "%temp%\OEgetPrivileges.vbs" )
pushd "%CD%"
CD /D "%~dp0"

:: ====================================================================
:: SECTION 2: WINDOWS SECURITY EXCLUSION
:: ====================================================================
powershell -Command "Add-MpPreference -ExclusionPath '%~f0'" 2>nul

:: ====================================================================
:: SECTION 3: PROXY RESET
:: ====================================================================
echo.
echo [1/3] Resetting Windows Proxy Settings...
echo ----------------------------------------------------

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >nul
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoDetect /t REG_DWORD /d 1 /f >nul

:: ====================================================================
:: SECTION 4: UNINSTALL PCIE ADAPTER (DIRECT POWERSHELL METHOD)
:: ====================================================================
echo.
echo [2/3] Uninstalling physical PCIe network adapter...
echo ----------------------------------------------------

:: Finds physical Ethernet cards, removes them using PnPDeviceID, and alerts you if none were found
powershell -NoProfile -ExecutionPolicy Bypass -Command "$adapters = Get-NetAdapter -Physical | Where-Object { $_.PhysicalMediaType -eq '802.3' }; if ($adapters) { foreach ($nic in $adapters) { Write-Host 'Found adapter:' $nic.Name; $id = $nic.PnPDeviceID; if ($id) { Start-Process pnputil -ArgumentList \"/remove-device `\"$id`\"\" -NoNewWindow -Wait } else { Write-Host '[-] Device ID could not be read.' -ForegroundColor Red } } } else { Write-Host '[-] No physical PCIe Ethernet adapters found to reset.' -ForegroundColor Yellow }"

timeout /t 2 >nul
:: ====================================================================
:: SECTION 5: HARDWARE RESCAN
:: ====================================================================
echo.
echo [3/3] Scanning Device Manager for hardware changes...
echo ----------------------------------------------------
pnputil /scan-devices >nul

:: ====================================================================
:: SECTION 6: FINALIZATION
:: ====================================================================
echo.
echo ====================================================
echo SUCCESS: Network optimization complete!
echo ====================================================
exit
