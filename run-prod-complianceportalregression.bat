@echo off
setlocal
call "%~dp0run-tests.bat" PROD CompliancePortalRegression
exit /b %errorlevel%
