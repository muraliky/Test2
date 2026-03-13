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
echo ""
echo "  NOTE: All subfolders and files will be copied recursively,"
echo "        preserving your module/folder structure."
echo "═══════════════════════════════════════════════════════════════"
echo ""

read -p "Copy source files now? (y/n): " COPY_FILES

if [[ "$COPY_FILES" =~ ^[Yy]$ ]]; then
    echo ""
    echo "───────────────────────────────────────────────────────────────"
    echo "  Enter the FULL PATH to your Selenium project folders."
    echo "  Leave blank and press Enter to skip any folder."
    echo ""
    echo "  All subfolders will be copied with their structure:"
    echo ""
    echo "  Example: If your pages folder has:"
    echo "    /projects/selenium/pages/"
    echo "      ├── accounts/"
    echo "      │   ├── AccountListPage.java"
    echo "      │   └── AccountDetailsPage.java"
    echo "      ├── trading/"
    echo "      │   └── TradePage.java"
    echo "      └── common/"
    echo "          └── BasePage.java"
    echo ""
    echo "  It will copy to:"
    echo "    _source-java/pages/"
    echo "      ├── accounts/"
    echo "      │   ├── AccountListPage.java"
    echo "      │   └── AccountDetailsPage.java"
    echo "      ├── trading/"
    echo "      │   └── TradePage.java"
    echo "      └── common/"
    echo "          └── BasePage.java"
    echo "───────────────────────────────────────────────────────────────"
    echo ""
    
    # ─────────────────────────────────────────────────────────────
    # Get Pages path
    # ─────────────────────────────────────────────────────────────
    read -p "Path to PAGES folder: " PAGES_PATH
    
    if [ -n "$PAGES_PATH" ]; then
        if [ -d "$PAGES_PATH" ]; then
            echo "      Copying pages with folder structure..."
            cp -R "$PAGES_PATH"/* _source-java/pages/ 2>/dev/null
            
            # Count files and folders
            FILE_COUNT=$(find _source-java/pages -name "*.java" 2>/dev/null | wc -l | tr -d ' ')
            FOLDER_COUNT=$(find _source-java/pages -type d 2>/dev/null | wc -l | tr -d ' ')
            FOLDER_COUNT=$((FOLDER_COUNT - 1))  # Exclude root folder
            
            echo "      ✅ Copied $FILE_COUNT Java files in $FOLDER_COUNT folders"
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
            echo "      Copying steps with folder structure..."
            cp -R "$STEPS_PATH"/* _source-java/steps/ 2>/dev/null
            
            # Count files and folders
            FILE_COUNT=$(find _source-java/steps -name "*.java" 2>/dev/null | wc -l | tr -d ' ')
            FOLDER_COUNT=$(find _source-java/steps -type d 2>/dev/null | wc -l | tr -d ' ')
            FOLDER_COUNT=$((FOLDER_COUNT - 1))
            
            echo "      ✅ Copied $FILE_COUNT Java files in $FOLDER_COUNT folders"
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
            echo "      Copying features with folder structure..."
            cp -R "$FEATURES_PATH"/* _source-java/features/ 2>/dev/null
            
            # Count files and folders
            FILE_COUNT=$(find _source-java/features -name "*.feature" 2>/dev/null | wc -l | tr -d ' ')
            FOLDER_COUNT=$(find _source-java/features -type d 2>/dev/null | wc -l | tr -d ' ')
            FOLDER_COUNT=$((FOLDER_COUNT - 1))
            
            echo "      ✅ Copied $FILE_COUNT feature files in $FOLDER_COUNT folders"
        else
            echo "      ❌ Path not found: $FEATURES_PATH"
        fi
    else
        echo "      ⏭️  Skipped features"
    fi
    
    # ─────────────────────────────────────────────────────────────
    # Show summary with folder structure
    # ─────────────────────────────────────────────────────────────
    echo ""
    echo "───────────────────────────────────────────────────────────────"
    echo "  COPY SUMMARY"
    echo "───────────────────────────────────────────────────────────────"
    
    PAGE_FILES=$(find _source-java/pages -name "*.java" 2>/dev/null | wc -l | tr -d ' ')
    PAGE_FOLDERS=$(find _source-java/pages -type d 2>/dev/null | wc -l | tr -d ' ')
    PAGE_FOLDERS=$((PAGE_FOLDERS - 1))
    
    STEP_FILES=$(find _source-java/steps -name "*.java" 2>/dev/null | wc -l | tr -d ' ')
    STEP_FOLDERS=$(find _source-java/steps -type d 2>/dev/null | wc -l | tr -d ' ')
    STEP_FOLDERS=$((STEP_FOLDERS - 1))
    
    FEATURE_FILES=$(find _source-java/features -name "*.feature" 2>/dev/null | wc -l | tr -d ' ')
    FEATURE_FOLDERS=$(find _source-java/features -type d 2>/dev/null | wc -l | tr -d ' ')
    FEATURE_FOLDERS=$((FEATURE_FOLDERS - 1))
    
    echo ""
    echo "  Pages:    $PAGE_FILES Java files in $PAGE_FOLDERS folders"
    echo "  Steps:    $STEP_FILES Java files in $STEP_FOLDERS folders"
    echo "  Features: $FEATURE_FILES feature files in $FEATURE_FOLDERS folders"
    echo "  ─────────────────────────────────────────────────────────"
    TOTAL_FILES=$((PAGE_FILES + STEP_FILES + FEATURE_FILES))
    TOTAL_FOLDERS=$((PAGE_FOLDERS + STEP_FOLDERS + FEATURE_FOLDERS))
    echo "  Total:    $TOTAL_FILES files in $TOTAL_FOLDERS folders"
    echo ""
    
    # Show folder structure preview
    echo "  FOLDER STRUCTURE PREVIEW:"
    echo "  ─────────────────────────────────────────────────────────"
    echo ""
    echo "  _source-java/"
    
    if [ -d "_source-java/pages" ]; then
        echo "    pages/"
        for dir in _source-java/pages/*/; do
            if [ -d "$dir" ]; then
                echo "      $(basename "$dir")/"
            fi
        done
    fi
    
    if [ -d "_source-java/steps" ]; then
        echo "    steps/"
        for dir in _source-java/steps/*/; do
            if [ -d "$dir" ]; then
                echo "      $(basename "$dir")/"
            fi
        done
    fi
    
    if [ -d "_source-java/features" ]; then
        echo "    features/"
        for dir in _source-java/features/*/; do
            if [ -d "$dir" ]; then
                echo "      $(basename "$dir")/"
            fi
        done
    fi
    echo ""
    
else
    echo ""
    echo "      Skipped. To copy files manually later (with folder structure):"
    echo ""
    echo "      cp -R /path/to/pages/* _source-java/pages/"
    echo "      cp -R /path/to/steps/* _source-java/steps/"
    echo "      cp -R /path/to/features/* _source-java/features/"
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
