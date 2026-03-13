@echo off
SETLOCAL EnableDelayedExpansion

REM ═══════════════════════════════════════════════════════════════
REM          SELENIUM TO PLAYWRIGHT MIGRATION - SETUP
REM ═══════════════════════════════════════════════════════════════

echo.
echo ═══════════════════════════════════════════════════════════════
echo          SELENIUM TO PLAYWRIGHT MIGRATION TOOLKIT
echo ═══════════════════════════════════════════════════════════════
echo.

REM ───────────────────────────────────────────────────────────────
REM Step 1: Check Node.js
REM ───────────────────────────────────────────────────────────────
echo [1/6] Checking Node.js...
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo       X Node.js not installed. Get it from https://nodejs.org
    pause
    exit /b 1
)
for /f "tokens=*" %%v in ('node -v') do echo       OK Node.js %%v

REM ───────────────────────────────────────────────────────────────
REM Step 2: Install dependencies
REM ───────────────────────────────────────────────────────────────
echo.
echo [2/6] Installing dependencies...
call npm install >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo       X npm install failed
    pause
    exit /b 1
)
echo       OK Dependencies installed

REM ───────────────────────────────────────────────────────────────
REM Step 3: Install Playwright MCP Server
REM ───────────────────────────────────────────────────────────────
echo.
echo [3/6] Installing Playwright MCP Server...
call npm install -g @anthropic-ai/mcp-server-playwright >nul 2>nul
echo       OK Playwright MCP Server installed

REM ───────────────────────────────────────────────────────────────
REM Step 4: Create directories
REM ───────────────────────────────────────────────────────────────
echo.
echo [4/6] Creating directories...
if not exist "auth" mkdir auth
if not exist "_source-java\pages" mkdir "_source-java\pages"
if not exist "_source-java\steps" mkdir "_source-java\steps"
if not exist "_source-java\features" mkdir "_source-java\features"
if not exist "src\pages" mkdir "src\pages"
if not exist "src\steps" mkdir "src\steps"
if not exist "features" mkdir features
if not exist ".github\agents" mkdir ".github\agents"
echo       OK Directories created

REM ───────────────────────────────────────────────────────────────
REM Step 5: Copy agent files
REM ───────────────────────────────────────────────────────────────
echo.
echo [5/6] Copying agent files...
if exist "copilot-agents\selenium-to-playwright-migrate.agent.md" (
    copy /Y copilot-agents\*.agent.md .github\agents\ >nul
    echo       OK Agent files copied to .github\agents\
) else (
    echo       ! Agent files not found in copilot-agents\
)

REM ───────────────────────────────────────────────────────────────
REM Step 6: Copy source files
REM ───────────────────────────────────────────────────────────────
echo.
echo [6/6] Copy Selenium source files
echo.
echo ═══════════════════════════════════════════════════════════════
echo   Do you want to copy your Selenium Java source files now?
echo   (You can skip this and do it manually later)
echo ═══════════════════════════════════════════════════════════════
echo.

set /p COPY_FILES="Copy source files now? (Y/N): "

if /i "!COPY_FILES!"=="Y" (
    echo.
    echo ───────────────────────────────────────────────────────────────
    echo   Enter the FULL PATH to your Selenium project folders.
    echo   Leave blank and press Enter to skip any folder.
    echo.
    echo   Example paths:
    echo     C:\Projects\selenium-tests\src\main\java\pages
    echo     C:\Projects\selenium-tests\src\main\java\steps  
    echo     C:\Projects\selenium-tests\src\test\resources\features
    echo ───────────────────────────────────────────────────────────────
    echo.
    
    REM ─────────────────────────────────────────────────────────────
    REM Get Pages path
    REM ─────────────────────────────────────────────────────────────
    set "PAGES_PATH="
    set /p PAGES_PATH="Path to PAGES folder: "
    
    if defined PAGES_PATH (
        if exist "!PAGES_PATH!" (
            echo       Copying pages...
            xcopy /E /I /Y "!PAGES_PATH!" "_source-java\pages\" >nul 2>nul
            for /f %%a in ('dir /b "_source-java\pages\*.java" 2^>nul ^| find /c /v ""') do (
                echo       OK Copied %%a page files
            )
        ) else (
            echo       X Path not found: !PAGES_PATH!
        )
    ) else (
        echo       - Skipped pages
    )
    
    REM ─────────────────────────────────────────────────────────────
    REM Get Steps path
    REM ─────────────────────────────────────────────────────────────
    echo.
    set "STEPS_PATH="
    set /p STEPS_PATH="Path to STEPS folder: "
    
    if defined STEPS_PATH (
        if exist "!STEPS_PATH!" (
            echo       Copying steps...
            xcopy /E /I /Y "!STEPS_PATH!" "_source-java\steps\" >nul 2>nul
            for /f %%a in ('dir /b "_source-java\steps\*.java" 2^>nul ^| find /c /v ""') do (
                echo       OK Copied %%a step files
            )
        ) else (
            echo       X Path not found: !STEPS_PATH!
        )
    ) else (
        echo       - Skipped steps
    )
    
    REM ─────────────────────────────────────────────────────────────
    REM Get Features path
    REM ─────────────────────────────────────────────────────────────
    echo.
    set "FEATURES_PATH="
    set /p FEATURES_PATH="Path to FEATURES folder: "
    
    if defined FEATURES_PATH (
        if exist "!FEATURES_PATH!" (
            echo       Copying features...
            xcopy /E /I /Y "!FEATURES_PATH!" "_source-java\features\" >nul 2>nul
            for /f %%a in ('dir /b "_source-java\features\*.feature" 2^>nul ^| find /c /v ""') do (
                echo       OK Copied %%a feature files
            )
        ) else (
            echo       X Path not found: !FEATURES_PATH!
        )
    ) else (
        echo       - Skipped features
    )
    
    REM ─────────────────────────────────────────────────────────────
    REM Show summary
    REM ─────────────────────────────────────────────────────────────
    echo.
    echo ───────────────────────────────────────────────────────────────
    echo   COPY SUMMARY
    echo ───────────────────────────────────────────────────────────────
    
    set PAGE_COUNT=0
    set STEP_COUNT=0
    set FEATURE_COUNT=0
    
    for /f %%a in ('dir /b /s "_source-java\pages\*.java" 2^>nul ^| find /c /v ""') do set PAGE_COUNT=%%a
    for /f %%a in ('dir /b /s "_source-java\steps\*.java" 2^>nul ^| find /c /v ""') do set STEP_COUNT=%%a
    for /f %%a in ('dir /b /s "_source-java\features\*.feature" 2^>nul ^| find /c /v ""') do set FEATURE_COUNT=%%a
    
    echo   Pages:    !PAGE_COUNT! Java files
    echo   Steps:    !STEP_COUNT! Java files
    echo   Features: !FEATURE_COUNT! feature files
    echo   ─────────────────────────────────
    set /a TOTAL=!PAGE_COUNT!+!STEP_COUNT!+!FEATURE_COUNT!
    echo   Total:    !TOTAL! files
    echo.
    
) else (
    echo.
    echo       Skipped. To copy files manually later, run:
    echo.
    echo       xcopy /E /I "C:\path\to\pages" "_source-java\pages\"
    echo       xcopy /E /I "C:\path\to\steps" "_source-java\steps\"
    echo       xcopy /E /I "C:\path\to\features" "_source-java\features\"
    echo.
)

REM ───────────────────────────────────────────────────────────────
REM Setup Complete
REM ───────────────────────────────────────────────────────────────
echo.
echo ═══════════════════════════════════════════════════════════════
echo                        SETUP COMPLETE
echo ═══════════════════════════════════════════════════════════════
echo.
echo   NEXT STEPS:
echo.
echo   1. Generate encrypted credentials:
echo      npm run generate-creds
echo.
echo   2. Create .env file:
echo      copy .env.example .env
echo      (Paste the encrypted values from step 1)
echo.
echo   3. Test login to your application:
echo      npm run login
echo.
echo   4. Start migration in VS Code:
echo      - Open Copilot Chat: Ctrl+Shift+I
echo      - Type: @selenium-to-playwright-migrate start migration
echo.
echo ═══════════════════════════════════════════════════════════════
echo.
pause

ENDLOCAL
