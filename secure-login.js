#!/usr/bin/env node
/**
 * Secure Login Script - Uses Desktop Chrome Browser
 * 
 * This script:
 * 1. Opens your installed Chrome browser (not Playwright's bundled browser)
 * 2. Reads encrypted credentials from .env
 * 3. Logs into your application
 * 4. Saves session to auth/auth.json (valid for 24 hours)
 * 
 * USAGE:
 *   npm run login           - Login and save session
 *   npm run generate-creds  - Generate encrypted credentials
 *   npm run check-session   - Check if session is valid
 */

const { chromium } = require('playwright');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

require('dotenv').config();

// Configuration
const AUTH_FILE = process.env.AUTH_FILE || './auth/auth.json';
const SESSION_HOURS = parseInt(process.env.AUTH_TIMEOUT_HOURS || '24');
const ENCRYPT_KEY = process.env.APP_ENCRYPT_KEY || '';

// ═══════════════════════════════════════════════════════════════
// ENCRYPTION FUNCTIONS
// ═══════════════════════════════════════════════════════════════

function decrypt(text) {
  if (!ENCRYPT_KEY || !text?.includes(':')) return text;
  try {
    const [iv, encrypted] = text.split(':');
    const key = crypto.scryptSync(ENCRYPT_KEY, 'salt', 32);
    const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(iv, 'hex'), key);
    return decipher.update(encrypted, 'hex', 'utf8') + decipher.final('utf8');
  } catch {
    return text;
  }
}

function encrypt(text) {
  if (!ENCRYPT_KEY) return text;
  const iv = crypto.randomBytes(16);
  const key = crypto.scryptSync(ENCRYPT_KEY, 'salt', 32);
  const cipher = crypto.createCipheriv('aes-256-cbc', iv, key);
  return iv.toString('hex') + ':' + cipher.update(text, 'utf8', 'hex') + cipher.final('hex');
}

// ═══════════════════════════════════════════════════════════════
// SESSION CHECK
// ═══════════════════════════════════════════════════════════════

function checkSession() {
  if (!fs.existsSync(AUTH_FILE)) {
    return { valid: false, reason: 'No session file' };
  }
  const hours = (Date.now() - fs.statSync(AUTH_FILE).mtimeMs) / 3600000;
  if (hours >= SESSION_HOURS) {
    return { valid: false, reason: `Session expired (${hours.toFixed(1)}h old)` };
  }
  return { valid: true, hours: SESSION_HOURS - hours };
}

// ═══════════════════════════════════════════════════════════════
// LOGIN FUNCTION - USES DESKTOP CHROME
// ═══════════════════════════════════════════════════════════════

async function login(force = false) {
  console.log('');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('              SECURE LOGIN (Desktop Chrome)');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('');

  // Check existing session
  if (!force) {
    const session = checkSession();
    if (session.valid) {
      console.log('✅ Valid session exists');
      console.log(`   Remaining: ${session.hours.toFixed(1)} hours`);
      console.log('   Use --force to re-login');
      return;
    }
    console.log(`⚠️  ${session.reason}`);
  }

  // Get credentials
  const loginUrl = process.env.APP_LOGIN_URL;
  const username = decrypt(process.env.APP_USERNAME);
  const password = decrypt(process.env.APP_PASSWORD);

  if (!loginUrl || !username || !password) {
    console.log('❌ Missing credentials in .env');
    console.log('   Run: npm run generate-creds');
    process.exit(1);
  }

  console.log('🔐 Credentials');
  console.log(`   URL:  ${loginUrl}`);
  console.log(`   User: ${username}`);
  console.log('');

  // Launch DESKTOP CHROME (not Playwright's bundled browser)
  console.log('🌐 Opening desktop Chrome browser...');
  console.log('   (Using your installed Chrome, not Playwright browser)');
  console.log('');
  
  const browser = await chromium.launch({
    headless: false,
    channel: 'chrome',  // Uses installed Chrome
    slowMo: 100
  });

  const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
  const page = await context.newPage();

  try {
    // Navigate
    console.log('[1/5] Navigating to login page...');
    await page.goto(loginUrl, { waitUntil: 'networkidle', timeout: 30000 });
    console.log('      ✅ Page loaded');

    // Username
    console.log('[2/5] Entering username...');
    const userSelectors = ['#username', '#user', '#email', 'input[name="username"]', 
      'input[name="email"]', 'input[type="email"]', '[data-testid="username"]'];
    for (const sel of userSelectors) {
      try { await page.fill(sel, username, { timeout: 1500 }); console.log(`      ✅ ${sel}`); break; } catch {}
    }

    // Password
    console.log('[3/5] Entering password...');
    const passSelectors = ['#password', 'input[name="password"]', 'input[type="password"]'];
    for (const sel of passSelectors) {
      try { await page.fill(sel, password, { timeout: 1500 }); console.log(`      ✅ ${sel}`); break; } catch {}
    }

    // Submit
    console.log('[4/5] Clicking login...');
    const btnSelectors = ['button[type="submit"]', 'button:has-text("Login")', 
      'button:has-text("Sign in")', '#loginBtn', '[data-testid="login-button"]'];
    for (const sel of btnSelectors) {
      try { await page.click(sel, { timeout: 1500 }); console.log(`      ✅ ${sel}`); break; } catch {}
    }

    // Wait
    console.log('[5/5] Waiting for redirect...');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);
    console.log(`      ✅ ${page.url()}`);

    // Save session
    fs.mkdirSync(path.dirname(AUTH_FILE), { recursive: true });
    await context.storageState({ path: AUTH_FILE });

    console.log('');
    console.log('═══════════════════════════════════════════════════════════════');
    console.log('                    ✅ LOGIN SUCCESSFUL');
    console.log('═══════════════════════════════════════════════════════════════');
    console.log(`   Session: ${AUTH_FILE}`);
    console.log(`   Valid:   ${SESSION_HOURS} hours`);
    console.log('');

  } catch (err) {
    console.log('');
    console.log('❌ Login failed:', err.message);
    await page.screenshot({ path: './auth/error.png' });
    console.log('   Screenshot: ./auth/error.png');
    process.exit(1);
  } finally {
    await browser.close();
  }
}

// ═══════════════════════════════════════════════════════════════
// GENERATE CREDENTIALS
// ═══════════════════════════════════════════════════════════════

async function generateCreds() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  const ask = q => new Promise(r => rl.question(q, r));

  console.log('');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('              GENERATE ENCRYPTED CREDENTIALS');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('');

  const key = await ask('Encryption key: ');
  process.env.APP_ENCRYPT_KEY = key;
  
  const url = await ask('Login URL: ');
  const user = await ask('Username: ');
  const pass = await ask('Password: ');

  console.log('');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('              COPY TO YOUR .env FILE');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('');
  console.log(`APP_LOGIN_URL=${url}`);
  console.log(`APP_ENCRYPT_KEY=${key}`);
  console.log(`APP_USERNAME=${encrypt(user)}`);
  console.log(`APP_PASSWORD=${encrypt(pass)}`);
  console.log(`AUTH_FILE=./auth/auth.json`);
  console.log('');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('');

  rl.close();
}

// ═══════════════════════════════════════════════════════════════
// CHECK SESSION STATUS
// ═══════════════════════════════════════════════════════════════

function showStatus() {
  console.log('');
  const s = checkSession();
  if (s.valid) {
    console.log('✅ Session VALID');
    console.log(`   Remaining: ${s.hours.toFixed(1)} hours`);
  } else {
    console.log('❌ Session INVALID');
    console.log(`   Reason: ${s.reason}`);
    console.log('   Run: npm run login');
  }
  console.log('');
}

// ═══════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════

const args = process.argv.slice(2);
if (args.includes('--generate') || args.includes('-g')) generateCreds();
else if (args.includes('--check') || args.includes('-c')) showStatus();
else if (args.includes('--force') || args.includes('-f')) login(true);
else login(false);
