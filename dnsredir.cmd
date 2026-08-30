@echo off
:: Check if we're already running elevated; if not, relaunch ourselves as
:: Administrator via UAC. This means double-clicking this file works the
:: same as manually opening an elevated cmd and running it — no more
:: silently closing because Windows never asked for admin rights.
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -NoProfile -WindowStyle Hidden -Command "Start-Process -FilePath '%~f0' -WorkingDirectory '%~dp0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
"%~dp0python\python.exe" byebyedpi.py --ttl 3 --dns-redirect 1.1.1.1:53
pause
