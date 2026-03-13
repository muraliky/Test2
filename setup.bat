@echo off
REM ═══════════════════════════════════════════════════════════════
REM          SELENIUM TO PLAYWRIGHT MIGRATION - SETUP
REM ═══════════════════════════════════════════════════════════════

echo.
echo ═══════════════════════════════════════════════════════════════
echo          SELENIUM TO PLAYWRIGHT MIGRATION TOOLKIT
echo ═══════════════════════════════════════════════════════════════
echo.

echo [1/4] Checking Node.js...
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo       X Node.js not installed. Get it from https://nodejs.org
    pause
    exit /b 1
)
for /f "tokens=*" %%v in ('node -v') do echo       OK Node.js %%v

echo.
echo [2/4] Installing dependencies...
call npm install
echo       OK Dependencies installed

echo.
echo [3/4] Installing Playwright MCP Server...
call npm install -g @anthropic-ai/mcp-server-playwright
echo       OK Playwright MCP Server installed

echo.
echo [4/4] Creating directories...
if not exist "auth" mkdir auth
if not exist "_source-java\pages" mkdir "_source-java\pages"
if not exist "_source-java\steps" mkdir "_source-java\steps"
if not exist "_source-java\features" mkdir "_source-java\features"
if not exist "src\pages" mkdir "src\pages"
if not exist "src\steps" mkdir "src\steps"
if not exist "features" mkdir features
if not exist ".github\agents" mkdir ".github\agents"
copy copilot-agents\*.agent.md .github\agents\ >nul 2>nul
echo       OK Directories created

echo.
echo ═══════════════════════════════════════════════════════════════
echo                     OK SETUP COMPLETE
echo ═══════════════════════════════════════════════════════════════
echo.
echo PLAYWRIGHT MCP OPTIONS:
echo.
echo   Option A: VS Code Extension (Recommended)
echo     - Install 'Playwright MCP' extension in VS Code
echo.
echo   Option B: npx (Already configured in agent files)
echo     - Runs automatically when you use the agent
echo.
echo NEXT STEPS:
echo.
echo   1. Generate credentials:  npm run generate-creds
echo   2. Create .env file:      copy .env.example .env
echo   3. Copy Java files to _source-java folders
echo   4. Test login:            npm run login
echo   5. Start migration:       @selenium-to-playwright-migrate start
echo.
pause
