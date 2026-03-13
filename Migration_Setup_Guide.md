# Selenium to Playwright Migration Toolkit

## Complete Setup & User Guide

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Prerequisites](#2-prerequisites)
3. [Installation](#3-installation)
4. [Configuration](#4-configuration)
5. [Prepare Source Files](#5-prepare-source-files)
6. [Setup Copilot Agents](#6-setup-copilot-agents)
7. [Run Migration](#7-run-migration)
8. [Debug Failures](#8-debug-failures)
9. [Commands Reference](#9-commands-reference)
10. [Troubleshooting](#10-troubleshooting)
11. [Appendix](#11-appendix)

---

## 1. Introduction

### What This Toolkit Does

Automatically converts **Selenium + Java + QAF/Cucumber** projects to **Playwright + TypeScript + playwright-bdd**.

### Key Features

| Feature | Description |
|---------|-------------|
| **Desktop Browser** | Uses your installed Chrome (not Playwright's bundled browser) |
| **100% Verification** | Counts all locators/methods - ensures nothing is missed |
| **Checkpoint/Resume** | Network error? Just say "resume" |
| **Secure Credentials** | Encrypted in .env, never in prompts |
| **Live DOM Inspection** | Debug agent opens browser to find correct selectors |

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│  VS Code with GitHub Copilot                                │
│                                                             │
│  @selenium-to-playwright-migrate                            │
│  ├── Reads Java files from _source-java/                    │
│  ├── Counts locators & methods                              │
│  ├── Converts to TypeScript                                 │
│  ├── Verifies 100% converted                                │
│  └── Saves checkpoint after each file                       │
│                                                             │
│  @selenium-to-playwright-debug                              │
│  ├── Opens YOUR Chrome browser (desktop)                    │
│  ├── Uses saved session (auth.json)                         │
│  ├── Inspects actual DOM                                    │
│  └── Fixes failing locators                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Prerequisites

### Required Software

| Software | Version | Check Command |
|----------|---------|---------------|
| **Node.js** | 18+ | `node --version` |
| **VS Code** | Latest | - |
| **GitHub Copilot** | Extension | - |
| **Chrome Browser** | Any recent | Already installed |

### Required Accounts

- **GitHub Copilot** subscription (Pro, Business, or Enterprise)
- **Test account** for your application

---

## 3. Installation

### Step 3.1: Extract Toolkit

**Windows:**
```
Right-click ZIP → Extract All → Choose location
```

**Mac/Linux:**
```bash
unzip Selenium_Playwright_Migration_Toolkit.zip
cd migration-toolkit
```

### Step 3.2: Run Setup

**Windows:**
```cmd
setup.bat
```

**Mac/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

### Step 3.3: What Setup Does

```
[1/3] Checking Node.js...
      ✅ Node.js v20.10.0

[2/3] Installing dependencies...
      ✅ Dependencies installed

[3/3] Creating directories...
      ✅ Directories created

═══════════════════════════════════════════════════════════════
                    ✅ SETUP COMPLETE
═══════════════════════════════════════════════════════════════
```

**Important:** This toolkit uses your **installed Chrome browser**, not Playwright's bundled browsers. No additional browser download required!

---

## 4. Configuration

### Step 4.1: Generate Encrypted Credentials

Run this command:

```bash
npm run generate-creds
```

You will see:

```
═══════════════════════════════════════════════════════════════
              GENERATE ENCRYPTED CREDENTIALS
═══════════════════════════════════════════════════════════════

Encryption key: MySecretKey123!
Login URL: https://myapp.com/login
Username: testuser
Password: Test@123

═══════════════════════════════════════════════════════════════
              COPY TO YOUR .env FILE
═══════════════════════════════════════════════════════════════

APP_LOGIN_URL=https://myapp.com/login
APP_ENCRYPT_KEY=MySecretKey123!
APP_USERNAME=a1b2c3d4e5f6:7890abcdef1234567890
APP_PASSWORD=f6e5d4c3b2a1:fedcba09876543210fed
AUTH_FILE=./auth/auth.json

═══════════════════════════════════════════════════════════════
```

> ⚠️ **IMPORTANT:** Save your encryption key! You'll need it to regenerate credentials.

### Step 4.2: Create .env File

```bash
# Copy template
cp .env.example .env

# Open in editor and paste your encrypted values
```

Your `.env` should look like:
```env
APP_LOGIN_URL=https://myapp.com/login
APP_ENCRYPT_KEY=MySecretKey123!
APP_USERNAME=a1b2c3d4e5f6:7890abcdef1234567890
APP_PASSWORD=f6e5d4c3b2a1:fedcba09876543210fed
AUTH_FILE=./auth/auth.json
```

### Step 4.3: Test Login

```bash
npm run login
```

Expected output:
```
═══════════════════════════════════════════════════════════════
              SECURE LOGIN (Desktop Chrome)
═══════════════════════════════════════════════════════════════

🔐 Credentials
   URL:  https://myapp.com/login
   User: testuser

🌐 Opening desktop Chrome browser...
   (Using your installed Chrome, not Playwright browser)

[1/5] Navigating to login page...
      ✅ Page loaded
[2/5] Entering username...
      ✅ #username
[3/5] Entering password...
      ✅ #password
[4/5] Clicking login...
      ✅ button[type="submit"]
[5/5] Waiting for redirect...
      ✅ https://myapp.com/dashboard

═══════════════════════════════════════════════════════════════
                    ✅ LOGIN SUCCESSFUL
═══════════════════════════════════════════════════════════════
   Session: ./auth/auth.json
   Valid:   24 hours
```

---

## 5. Prepare Source Files

### Step 5.1: Directory Structure

Your Java files go in `_source-java/`:

```
migration-toolkit/
└── _source-java/
    ├── pages/          ← Java page objects
    │   ├── AccountListPage.java
    │   ├── TradePage.java
    │   └── ...
    ├── steps/          ← Java step definitions
    │   ├── AccountSteps.java
    │   ├── TradeSteps.java
    │   └── ...
    └── features/       ← Cucumber feature files
        ├── account.feature
        └── ...
```

### Step 5.2: Copy Files

**Windows:**
```cmd
xcopy /E C:\Projects\selenium\src\pages _source-java\pages\
xcopy /E C:\Projects\selenium\src\steps _source-java\steps\
xcopy /E C:\Projects\selenium\features _source-java\features\
```

**Mac/Linux:**
```bash
cp -r /path/to/selenium/pages/* _source-java/pages/
cp -r /path/to/selenium/steps/* _source-java/steps/
cp -r /path/to/selenium/features/* _source-java/features/
```

### Step 5.3: Verify

```bash
# Count files
find _source-java -name "*.java" | wc -l
find _source-java -name "*.feature" | wc -l
```

---

## 6. Setup Copilot Agents

### Step 6.1: Copy Agent Files

```bash
mkdir -p .github/agents
cp copilot-agents/*.agent.md .github/agents/
```

### Step 6.2: Choose Playwright MCP Option

The debug agent needs Playwright MCP to open a browser. Choose ONE option:

#### Option A: VS Code Extension (Easiest)

1. Open VS Code Extensions (`Ctrl+Shift+X`)
2. Search for "Playwright MCP"
3. Install the extension
4. Done! No configuration needed.

#### Option B: npx (Default - Already Configured)

The agent files are pre-configured to use npx:

```yaml
mcp-servers:
  playwright:
    type: 'local'
    command: 'npx'
    args: 
      - '@anthropic-ai/mcp-server-playwright'
      - '--browser=chrome'
      - '--headless=false'
```

This runs automatically when you use the agent. The setup script already installed the MCP server globally.

#### Option C: Organization URL

If your organization hosts a central MCP server, edit the agent files:

```yaml
mcp-servers:
  playwright:
    type: 'url'
    url: 'https://playwright.mcp.your-org.com/sse'
    tools: ['*']
```

### Step 6.3: Verify in VS Code

1. Open VS Code: `code .`
2. Open Copilot Chat: `Ctrl+Shift+I` (Windows) or `Cmd+Shift+I` (Mac)
3. Click the agent dropdown
4. You should see:
   - `@selenium-to-playwright-migrate`
   - `@selenium-to-playwright-debug`

---

## 7. Run Migration

### Step 7.1: Start Migration

In Copilot Chat:

```
@selenium-to-playwright-migrate

Start migration.
Source: ./_source-java/
Target: ./src/
```

### Step 7.2: What Happens

```
═══════════════════════════════════════════════════════════════
                    MIGRATION PLAN
═══════════════════════════════════════════════════════════════

Source: ./_source-java/
Target: ./src/

Files to migrate:
  • Pages:    45 files
  • Steps:    55 files
  • Features: 30 files
  • Total:   130 files

Progress saved to: migration-state.json
Starting migration...

═══════════════════════════════════════════════════════════════

[1/130] Processing: AccountListPage.java
        Locators found: 15
        Methods found: 8
        Converting...
        ✅ Locators: 15/15 (100%)
        ✅ Methods: 8/8 (100%)
        → account-list.page.ts

[2/130] Processing: TradePage.java
        ...
```

### Step 7.3: If Network Error

Just say:
```
@selenium-to-playwright-migrate resume
```

It continues from where it stopped!

### Step 7.4: Check Status

```
@selenium-to-playwright-migrate status
```

### Step 7.5: Final Report

```
═══════════════════════════════════════════════════════════════
                    MIGRATION COMPLETE
═══════════════════════════════════════════════════════════════

PAGES:     45/45 ✅
  Locators: 523 → 523 converted
  Methods:  287 → 287 converted

STEPS:     55/55 ✅
  Step defs: 412 → 412 converted

FEATURES:  30/30 ✅

OVERALL: 100% COMPLETE ✅

NEXT: npm test
═══════════════════════════════════════════════════════════════
```

---

## 8. Debug Failures

### Step 8.1: Run Tests

```bash
npm install
npm test
```

### Step 8.2: Check Session

```bash
npm run check-session
```

If expired:
```bash
npm run login
```

### Step 8.3: Debug with Live Browser

```
@selenium-to-playwright-debug

Navigate to https://myapp.com/accounts
Fix these failing locators:
- tradeButton: element not found
- accountDropdown: timeout
```

### Step 8.4: What Happens

The debug agent:
1. Opens YOUR Chrome browser (desktop)
2. Uses your saved session (already logged in)
3. Navigates to the page
4. Inspects actual DOM
5. Finds correct selectors
6. Updates your TypeScript files

```
🔐 Using pre-authenticated session
🌐 Opening desktop Chrome browser...

[1] Navigating to /accounts...
    ✅ Page loaded

[2] Screenshot captured 📸

[3] Inspecting tradeButton...
    Found: <button data-testid="trade-action">Trade Now</button>
    
    🔧 FIX:
    ❌ OLD: getByRole('button', { name: 'Trade' })
    ✅ NEW: getByTestId('trade-action')

[4] Updating file...
    ✅ Fixed

═══════════════════════════════════════════════════════════════
DEBUG COMPLETE
Files updated: src/pages/account-list.page.ts
═══════════════════════════════════════════════════════════════
```

---

## 9. Commands Reference

### NPM Commands

| Command | Description |
|---------|-------------|
| `npm run login` | Login and save session |
| `npm run generate-creds` | Generate encrypted credentials |
| `npm run check-session` | Check session status |
| `npm run force-login` | Force new login |
| `npm test` | Run Playwright tests |

### Migration Agent

| Command | Description |
|---------|-------------|
| `start migration` | Begin migration |
| `resume` | Continue from checkpoint |
| `status` | Show progress |
| `verify [file]` | Re-verify a file |
| `reprocess [file]` | Re-convert a file |
| `report` | Final report |

### Debug Agent

| Command | Description |
|---------|-------------|
| `Navigate to [URL] and fix [locators]` | Debug locators |
| `Fix all failing locators in [file]` | Fix entire file |

---

## 10. Troubleshooting

### Agents Not Appearing

1. Ensure `.github/agents/` folder exists
2. Files must have `.agent.md` extension
3. Restart VS Code
4. Update Copilot extension

### Login Fails

1. Check `APP_LOGIN_URL` is correct
2. Re-run `npm run generate-creds`
3. Check for MFA (use account without MFA)
4. Check `auth/error.png` for screenshot

### Session Expired

```bash
npm run login
```

### Migration Stops

```
@selenium-to-playwright-migrate resume
```

### Missing Locators

```
@selenium-to-playwright-migrate reprocess AccountListPage
```

---

## 11. Appendix

### Locator Conversion

| Selenium | Playwright |
|----------|------------|
| `//button[text()='X']` | `getByRole('button', { name: 'X' })` |
| `//button[contains(text(),'X')]` | `getByRole('button', { name: /X/i })` |
| `//input[@id='X']` | `locator('#X')` |
| `//input[@placeholder='X']` | `getByPlaceholder('X')` |
| `//*[@data-testid='X']` | `getByTestId('X')` |
| Complex XPath | `locator(\`//xpath\`)` |

### And/But Conversion

| Original | Converts To | When Contains |
|----------|-------------|---------------|
| `@And` | `@When` | click, enter, select, navigate |
| `@And` | `@Then` | should see, verify, is displayed |
| `@And` | `@Given` | is logged in, is on page |

### File Naming

| Java | TypeScript |
|------|------------|
| `AccountListPage.java` | `account-list.page.ts` |
| `TradeSteps.java` | `trade.steps.ts` |

### Timeline

| Phase | Time |
|-------|------|
| Setup | 15-30 min |
| Migration (100 files) | 2-3 hours |
| Testing | 15 min |
| Debug | 1-2 hours |
| **Total** | **~4-5 hours** |

**vs Manual: 4-6 weeks**

---

*Version 4.0 | Uses Desktop Chrome Browser*
