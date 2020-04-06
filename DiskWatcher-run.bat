@ECHO OFF
ECHO ----------------------------------------------------------------------------------------------
ECHO DiskWatcher monitor's disk space and email alert based on min Size

ECHO ----------------------------------------------------------------------------------------------
ECHO Checking Windows PowerShell Installation Status...
:proceed
ECHO.
ECHO Starting Disk Space Monitoring...
%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -File DiskWatcher.ps1
ECHO  successfully finished...
exit /b 0
