@echo off
REM Windows batch wrapper for MySQL Docker Backup Tool
REM @abdansyakuro.id

IF "%~1"=="" (
  echo Usage: backup.bat ^<server_name^>
  echo Available servers:
  dir /b configs\*.cfg | findstr /r ".*\.cfg$" | findstr /v "\.example\.cfg$" | FINDSTR /r /e ".cfg" | FINDSTR /r /v "\\" | FINDSTR /r /v " " | FINDSTR /r /v "=" | FINDSTR /r /v ":" | FINDSTR /r /v "/" | FINDSTR /r /v "\"
  exit /b 1
)

echo Running MySQL Docker Backup for %1...

powershell.exe -ExecutionPolicy Bypass -File "%~dp0backup.ps1" %1

if %ERRORLEVEL% EQU 0 (
  echo Backup completed successfully.
) else (
  echo Backup failed with error level %ERRORLEVEL%.
)

exit /b %ERRORLEVEL% 