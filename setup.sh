#!/bin/bash

# ═══════════════════════════════════════════════════════════════
#          SELENIUM TO PLAYWRIGHT MIGRATION - SETUP
# ═══════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "         SELENIUM TO PLAYWRIGHT MIGRATION TOOLKIT"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ───────────────────────────────────────────────────────────────
# Step 1: Check Node.js
# ───────────────────────────────────────────────────────────────
echo "[1/6] Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo "      ❌ Node.js not installed. Get it from https://nodejs.org"
    exit 1
fi
echo "      ✅ Node.js $(node -v)"

# ───────────────────────────────────────────────────────────────
# Step 2: Install dependencies
# ───────────────────────────────────────────────────────────────
echo ""
echo "[2/6] Installing dependencies..."
npm install > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "      ❌ npm install failed"
    exit 1
fi
echo "      ✅ Dependencies installed"

# ───────────────────────────────────────────────────────────────
# Step 3: Install Playwright MCP Server
# ───────────────────────────────────────────────────────────────
echo ""
echo "[3/6] Installing Playwright MCP Server..."
npm install -g @anthropic-ai/mcp-server-playwright > /dev/null 2>&1
echo "      ✅ Playwright MCP Server installed"

# ───────────────────────────────────────────────────────────────
# Step 4: Create directories
# ───────────────────────────────────────────────────────────────
echo ""
echo "[4/6] Creating directories..."
mkdir -p auth
mkdir -p _source-java/pages _source-java/steps _source-java/features
mkdir -p src/pages src/steps
mkdir -p features
mkdir -p .github/agents
echo "      ✅ Directories created"

# ───────────────────────────────────────────────────────────────
# Step 5: Copy agent files
# ───────────────────────────────────────────────────────────────
echo ""
echo "[5/6] Copying agent files..."
if [ -f "copilot-agents/selenium-to-playwright-migrate.agent.md" ]; then
    cp copilot-agents/*.agent.md .github/agents/
    echo "      ✅ Agent files copied to .github/agents/"
else
    echo "      ⚠️  Agent files not found in copilot-agents/"
fi

# ───────────────────────────────────────────────────────────────
# Step 6: Copy source files
# ───────────────────────────────────────────────────────────────
echo ""
echo "[6/6] Copy Selenium source files"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Do you want to copy your Selenium Java source files now?"
echo "  (You can skip this and do it manually later)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

read -p "Copy source files now? (y/n): " COPY_FILES

if [[ "$COPY_FILES" =~ ^[Yy]$ ]]; then
    echo ""
    echo "───────────────────────────────────────────────────────────────"
    echo "  Enter the FULL PATH to your Selenium project folders."
    echo "  Leave blank and press Enter to skip any folder."
    echo ""
    echo "  Example paths:"
    echo "    /Users/you/projects/selenium-tests/src/main/java/pages"
    echo "    /Users/you/projects/selenium-tests/src/main/java/steps"
    echo "    /Users/you/projects/selenium-tests/src/test/resources/features"
    echo "───────────────────────────────────────────────────────────────"
    echo ""
    
    # ─────────────────────────────────────────────────────────────
    # Get Pages path
    # ─────────────────────────────────────────────────────────────
    read -p "Path to PAGES folder: " PAGES_PATH
    
    if [ -n "$PAGES_PATH" ]; then
        if [ -d "$PAGES_PATH" ]; then
            echo "      Copying pages..."
            cp -r "$PAGES_PATH"/* _source-java/pages/ 2>/dev/null
            PAGE_COUNT=$(find _source-java/pages -name "*.java" 2>/dev/null | wc -l | tr -d ' ')
            echo "      ✅ Copied $PAGE_COUNT page files"
        else
            echo "      ❌ Path not found: $PAGES_PATH"
        fi
    else
        echo "      ⏭️  Skipped pages"
    fi
    
    # ─────────────────────────────────────────────────────────────
    # Get Steps path
    # ─────────────────────────────────────────────────────────────
    echo ""
    read -p "Path to STEPS folder: " STEPS_PATH
    
    if [ -n "$STEPS_PATH" ]; then
        if [ -d "$STEPS_PATH" ]; then
            echo "      Copying steps..."
            cp -r "$STEPS_PATH"/* _source-java/steps/ 2>/dev/null
            STEP_COUNT=$(find _source-java/steps -name "*.java" 2>/dev/null | wc -l | tr -d ' ')
            echo "      ✅ Copied $STEP_COUNT step files"
        else
            echo "      ❌ Path not found: $STEPS_PATH"
        fi
    else
        echo "      ⏭️  Skipped steps"
    fi
    
    # ─────────────────────────────────────────────────────────────
    # Get Features path
    # ─────────────────────────────────────────────────────────────
    echo ""
    read -p "Path to FEATURES folder: " FEATURES_PATH
    
    if [ -n "$FEATURES_PATH" ]; then
        if [ -d "$FEATURES_PATH" ]; then
            echo "      Copying features..."
            cp -r "$FEATURES_PATH"/* _source-java/features/ 2>/dev/null
            FEATURE_COUNT=$(find _source-java/features -name "*.feature" 2>/dev/null | wc -l | tr -d ' ')
            echo "      ✅ Copied $FEATURE_COUNT feature files"
        else
            echo "      ❌ Path not found: $FEATURES_PATH"
        fi
    else
        echo "      ⏭️  Skipped features"
    fi
    
    # ─────────────────────────────────────────────────────────────
    # Show summary
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "───────────────────────────────────────────────────────────────"
    echo "  COPY SUMMARY"
    echo "───────────────────────────────────────────────────────────────"
    
    PAGE_COUNT=$(find _source-java/pages -name "*.java" 2>/dev/null | wc -l | tr -d ' ')
    STEP_COUNT=$(find _source-java/steps -name "*.java" 2>/dev/null | wc -l | tr -d ' ')
    FEATURE_COUNT=$(find _source-java/features -name "*.feature" 2>/dev/null | wc -l | tr -d ' ')
    TOTAL=$((PAGE_COUNT + STEP_COUNT + FEATURE_COUNT))
    
    echo "  Pages:    $PAGE_COUNT Java files"
    echo "  Steps:    $STEP_COUNT Java files"
    echo "  Features: $FEATURE_COUNT feature files"
    echo "  ─────────────────────────────────"
    echo "  Total:    $TOTAL files"
    echo ""
    
else
    echo ""
    echo "      Skipped. To copy files manually later, run:"
    echo ""
    echo "      cp -r /path/to/pages/* _source-java/pages/"
    echo "      cp -r /path/to/steps/* _source-java/steps/"
    echo "      cp -r /path/to/features/* _source-java/features/"
    echo ""
fi

# ───────────────────────────────────────────────────────────────
# Setup Complete
# ───────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                      ✅ SETUP COMPLETE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "  NEXT STEPS:"
echo ""
echo "  1. Generate encrypted credentials:"
echo "     npm run generate-creds"
echo ""
echo "  2. Create .env file:"
echo "     cp .env.example .env"
echo "     (Paste the encrypted values from step 1)"
echo ""
echo "  3. Test login to your application:"
echo "     npm run login"
echo ""
echo "  4. Start migration in VS Code:"
echo "     - Open Copilot Chat: Cmd+Shift+I (Mac) or Ctrl+Shift+I"
echo "     - Type: @selenium-to-playwright-migrate start migration"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""
