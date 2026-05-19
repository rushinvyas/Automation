# CPAutomation Java

CPAutomation Java is a common enterprise automation framework foundation built with:
- Java 17
- Maven
- Playwright for Java
- Cucumber JVM
- TestNG
- Jackson
- JDBC
- Azure Key Vault SDK
- Allure

## Current scope
- Common framework foundation
- Web-first implementation
- LoginVerify.feature only
- JSON + DB + Key Vault setup scaffolding
- Screenshots, video folders, reporting setup, and batch execution

## Main execution command
```bat
run-tests.bat UAT CompliancePortalRegression
```

## HTML report
`run-tests.bat` now attempts to generate both reports automatically after execution:
- [report.html](c:\AutomationProjects\CPAutomationJava\reports\report.html) when Node.js is available on `PATH`
- `reports\allure-report\index.html` when Allure CLI is available on `PATH`

You can also generate it manually:
```bat
generate-report.bat
```

Report inputs:
- `artifacts/cucumber-report.json`
- `artifacts/summary.txt`

## Key files
- pom.xml
- testng.xml
- generate-report.bat
- scripts/generate-html-report.cjs
- src/test/resources/config/base.json
- src/test/resources/config/Uat.json
- src/test/resources/config/Prod.json
- src/test/resources/features/web/01CandidateLogin/LoginVerify.feature
- src/test/java/com/cpautomation/runners/TestRunner.java
- src/test/java/com/cpautomation/stepdefinitions/web/CandidateLoginSteps.java
- src/main/java/com/cpautomation/web/pages/CandidateLoginPage.java
