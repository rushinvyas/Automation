@echo off
setlocal EnableExtensions

set "ROOT_DIR=%~dp0"
cd /d "%ROOT_DIR%"

set "NODE_CMD="
for %%I in (node.exe) do set "NODE_CMD=%%~$PATH:I"
if not defined NODE_CMD (
  echo Node.js executable not found.
  echo Install Node.js or add it to PATH to generate report.html.
  exit /b 1
)

call "%NODE_CMD%" scripts\write-run-summary.cjs
if errorlevel 1 exit /b %errorlevel%

call "%NODE_CMD%" scripts\generate-html-report.cjs
exit /b %errorlevel%
