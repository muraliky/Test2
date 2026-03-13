# Selenium to Playwright Migration Toolkit

**Automated migration using GitHub Copilot agents and desktop Chrome browser**

---

## Quick Start

```bash
# 1. Setup
./setup.sh          # Mac/Linux
setup.bat           # Windows

# 2. Generate credentials
npm run generate-creds

# 3. Create .env
cp .env.example .env
# Paste encrypted values

# 4. Copy source files
cp -r /path/to/selenium/pages/* _source-java/pages/
cp -r /path/to/selenium/steps/* _source-java/steps/

# 5. Test login
npm run login

# 6. Start migration (in VS Code Copilot Chat)
@selenium-to-playwright-migrate start migration

# 7. If interrupted
@selenium-to-playwright-migrate resume

# 8. Debug failures
@selenium-to-playwright-debug
Navigate to https://myapp.com/accounts and fix failing locators
```

---

## Features

- ✅ Uses **desktop Chrome** (your installed browser)
- ✅ **100% verification** - counts all locators/methods
- ✅ **Checkpoint/resume** - survives network errors
- ✅ **Encrypted credentials** - secure .env storage
- ✅ **Live browser debug** - inspects actual DOM

---

## Commands

| Command | Description |
|---------|-------------|
| `npm run login` | Login and save session |
| `npm run generate-creds` | Generate encrypted credentials |
| `npm run check-session` | Check session status |
| `npm test` | Run tests |

---

## Documentation

See **[docs/Migration_Setup_Guide.md](docs/Migration_Setup_Guide.md)** for complete instructions.

---

## Timeline

| Phase | Time |
|-------|------|
| Setup | 15-30 min |
| Migration | 2-3 hours |
| Testing & Debug | 1-2 hours |
| **Total** | **~4-5 hours** |

**vs Manual: 4-6 weeks**
