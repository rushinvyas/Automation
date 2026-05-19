@echo off
setlocal EnableExtensions

set "ENV_NAME=%~1"
set "CATEGORY=%~2"
set "SCENARIO_NAME=%~3"
set "EXTRA_TAG_FILTER=%~4"

if "%ENV_NAME%"=="" set "ENV_NAME=UAT"
if "%CATEGORY%"=="" set "CATEGORY=CompliancePortalRegression"

for %%A in ("%ENV_NAME%") do set "ENV_NAME=%%~A"
for %%A in ("%CATEGORY%") do set "CATEGORY=%%~A"

set "ROOT_DIR=%~dp0"
cd /d "%ROOT_DIR%"
set "LOCAL_M2=%ROOT_DIR%.m2\repository"
if not exist "%LOCAL_M2%" mkdir "%LOCAL_M2%"
if not exist "%ROOT_DIR%reports" mkdir "%ROOT_DIR%reports"

if exist "%ROOT_DIR%allure-results" if not exist "%ROOT_DIR%reports\allure-results" move "%ROOT_DIR%allure-results" "%ROOT_DIR%reports\allure-results" >nul
if exist "%ROOT_DIR%allure-report" if not exist "%ROOT_DIR%reports\allure-report" move "%ROOT_DIR%allure-report" "%ROOT_DIR%reports\allure-report" >nul
if exist "%ROOT_DIR%report.html" if not exist "%ROOT_DIR%reports\report.html" move "%ROOT_DIR%report.html" "%ROOT_DIR%reports\report.html" >nul

set "MVN_CMD="
if defined MAVEN_HOME if exist "%MAVEN_HOME%\bin\mvn.cmd" set "MVN_CMD=%MAVEN_HOME%\bin\mvn.cmd"
if not defined MVN_CMD if defined M2_HOME if exist "%M2_HOME%\bin\mvn.cmd" set "MVN_CMD=%M2_HOME%\bin\mvn.cmd"
if not defined MVN_CMD for %%I in (mvn.cmd) do set "MVN_CMD=%%~$PATH:I"
if not defined MVN_CMD (
  echo Maven executable not found.
  echo Set MAVEN_HOME or M2_HOME, or add Maven bin to PATH.
  exit /b 1
)

for /f %%i in ('powershell -NoProfile -Command "(Get-Date).ToString(\"yyyyMMdd_HHmmss\")"') do set RUN_TIMESTAMP=%%i
set "CP_ENV=%ENV_NAME%"
set "CP_CATEGORY=%CATEGORY%"
set "CP_RUN_TIMESTAMP=%RUN_TIMESTAMP%"
set "CUCUMBER_TAGS=@%CP_CATEGORY%"
if not "%EXTRA_TAG_FILTER%"=="" set "CUCUMBER_TAGS=@%CP_CATEGORY% and %EXTRA_TAG_FILTER%"

echo ==============================================
echo CPAutomation Java Runner
echo Environment : %CP_ENV%
echo Category    : %CP_CATEGORY%
if not "%SCENARIO_NAME%"=="" echo Scenario    : %SCENARIO_NAME%
if not "%EXTRA_TAG_FILTER%"=="" echo Extra Tags  : %EXTRA_TAG_FILTER%
echo Timestamp   : %RUN_TIMESTAMP%
echo ==============================================

if "%SCENARIO_NAME%"=="" (
  call "%MVN_CMD%" -Dmaven.repo.local="%LOCAL_M2%" -Dallure.results.directory=reports/allure-results test -Dcp.env=%CP_ENV% -Dcp.category=%CP_CATEGORY% -Dcucumber.filter.tags="%CUCUMBER_TAGS%"
) else (
  call "%MVN_CMD%" -Dmaven.repo.local="%LOCAL_M2%" -Dallure.results.directory=reports/allure-results test -Dcp.env=%CP_ENV% -Dcp.category=%CP_CATEGORY% -Dcucumber.filter.tags="%CUCUMBER_TAGS%" -Dcucumber.filter.name="%SCENARIO_NAME%"
)
set "TEST_EXIT_CODE=%errorlevel%"

set "NODE_CMD="
for %%I in (node.exe) do set "NODE_CMD=%%~$PATH:I"
if defined NODE_CMD (
  call "%NODE_CMD%" scripts\write-run-summary.cjs
  call "%NODE_CMD%" scripts\generate-html-report.cjs
) else (
  echo Node.js not found. Skipping HTML report generation.
)

set "ALLURE_CMD="
for %%I in (allure.bat allure.cmd allure.exe) do if not defined ALLURE_CMD set "ALLURE_CMD=%%~$PATH:I"
if defined ALLURE_CMD (
  call "%ALLURE_CMD%" generate reports\allure-results --clean -o reports\allure-report
) else (
  echo Allure CLI not found. Skipping Allure HTML report generation.
)

if exist "%ROOT_DIR%reports\allure-results" if exist "%ROOT_DIR%allure-results" rd /s /q "%ROOT_DIR%allure-results"
if exist "%ROOT_DIR%reports\allure-report" if exist "%ROOT_DIR%allure-report" rd /s /q "%ROOT_DIR%allure-report"
if exist "%ROOT_DIR%reports\report.html" if exist "%ROOT_DIR%report.html" del /f /q "%ROOT_DIR%report.html"

exit /b %TEST_EXIT_CODE%
