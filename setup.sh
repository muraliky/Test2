#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#          SELENIUM TO PLAYWRIGHT MIGRATION - SETUP
# ═══════════════════════════════════════════════════════════════

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "         SELENIUM TO PLAYWRIGHT MIGRATION TOOLKIT"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check Node.js
echo "[1/4] Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo "      ❌ Node.js not installed. Get it from https://nodejs.org"
    exit 1
fi
echo "      ✅ Node.js $(node -v)"

# Install dependencies
echo ""
echo "[2/4] Installing dependencies..."
npm install
echo "      ✅ Dependencies installed"

# Install Playwright MCP Server
echo ""
echo "[3/4] Installing Playwright MCP Server..."
npm install -g @anthropic-ai/mcp-server-playwright
echo "      ✅ Playwright MCP Server installed"

# Create directories
echo ""
echo "[4/4] Creating directories..."
mkdir -p auth _source-java/pages _source-java/steps _source-java/features
mkdir -p src/pages src/steps features .github/agents
cp copilot-agents/*.agent.md .github/agents/ 2>/dev/null || true
echo "      ✅ Directories created"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                    ✅ SETUP COMPLETE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "PLAYWRIGHT MCP OPTIONS:"
echo ""
echo "  Option A: VS Code Extension (Recommended)"
echo "    → Install 'Playwright MCP' extension in VS Code"
echo ""
echo "  Option B: npx (Already configured in agent files)"
echo "    → Runs automatically when you use the agent"
echo ""
echo "NEXT STEPS:"
echo ""
echo "  1. Generate credentials:  npm run generate-creds"
echo "  2. Create .env file:      cp .env.example .env"
echo "  3. Copy Java files:       cp -r /path/to/pages/* _source-java/pages/"
echo "  4. Test login:            npm run login"
echo "  5. Start migration:       @selenium-to-playwright-migrate start"
echo ""
