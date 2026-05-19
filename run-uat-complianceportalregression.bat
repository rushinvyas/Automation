@echo off
setlocal
call "%~dp0run-tests.bat" UAT CompliancePortalRegression
exit /b %errorlevel%
