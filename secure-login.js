#!/usr/bin/env node
/**
 * Secure Login Script - Uses Desktop Chrome Browser
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

// Try to load .env if it exists
try {
  require('dotenv').config();
} catch (e) {
  // dotenv not installed or .env doesn't exist - that's ok
}

// Configuration
const AUTH_FILE = process.env.AUTH_FILE || './auth/auth.json';
const SESSION_HOURS = parseInt(process.env.AUTH_TIMEOUT_HOURS || '24');

// ═══════════════════════════════════════════════════════════════
// ENCRYPTION FUNCTIONS
// ═══════════════════════════════════════════════════════════════

function encryptWithKey(text, encryptKey) {
  if (!encryptKey || !text) return text;
  try {
    const iv = crypto.randomBytes(16);
    const key = crypto.scryptSync(encryptKey, 'salt', 32);
    const cipher = crypto.createCipheriv('aes-256-cbc', iv, key);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return iv.toString('hex') + ':' + encrypted;
  } catch (err) {
    console.error('Encryption error:', err.message);
    return text;
  }
}

function decryptWithKey(text, encryptKey) {
  if (!encryptKey || !text || !text.includes(':')) return text;
  try {
    const [ivHex, encrypted] = text.split(':');
    const iv = Buffer.from(ivHex, 'hex');
    const key = crypto.scryptSync(encryptKey, 'salt', 32);
    const decipher = crypto.createDecipheriv('aes-256-cbc', iv, key);
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
  } catch (err) {
    return text;
  }
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
// GENERATE ENCRYPTED CREDENTIALS
// ═══════════════════════════════════════════════════════════════

async function generateCreds() {
  const rl = readline.createInterface({ 
    input: process.stdin, 
    output: process.stdout 
  });

  const ask = (question) => new Promise(resolve => rl.question(question, resolve));

  console.log('');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('              GENERATE ENCRYPTED CREDENTIALS');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('');
  console.log('  Enter your details below. The username and password will be');
  console.log('  encrypted using your encryption key.');
  console.log('');
  console.log('  ⚠️  SAVE YOUR ENCRYPTION KEY! You will need it later.');
  console.log('');
  console.log('───────────────────────────────────────────────────────────────');
  console.log('');

  // Get inputs
  const encryptKey = await ask('  Encryption key (make it strong): ');
  
  if (!encryptKey || encryptKey.length < 4) {
    console.log('');
    console.log('  ❌ Encryption key is too short. Use at least 4 characters.');
    console.log('');
    rl.close();
    return;
  }

  const loginUrl = await ask('  Login URL: ');
  const username = await ask('  Username: ');
  const password = await ask('  Password: ');

  if (!loginUrl || !username || !password) {
    console.log('');
    console.log('  ❌ All fields are required.');
    console.log('');
    rl.close();
    return;
  }

  // Encrypt credentials using the key user just entered
  const encryptedUsername = encryptWithKey(username, encryptKey);
  const encryptedPassword = encryptWithKey(password, encryptKey);

  console.log('');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('              ✅ CREDENTIALS ENCRYPTED');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('');
  console.log('  Copy the following lines to your .env file:');
  console.log('');
  console.log('───────────────────────────────────────────────────────────────');
  console.log('');
  console.log(`APP_LOGIN_URL=${loginUrl}`);
  console.log(`APP_ENCRYPT_KEY=${encryptKey}`);
  console.log(`APP_USERNAME=${encryptedUsername}`);
  console.log(`APP_PASSWORD=${encryptedPassword}`);
  console.log('AUTH_FILE=./auth/auth.json');
  console.log('');
  console.log('───────────────────────────────────────────────────────────────');
  console.log('');
  console.log('  NEXT STEPS:');
  console.log('');
  console.log('  1. Create .env file:  copy .env.example .env');
  console.log('  2. Paste the above lines into .env');
  console.log('  3. Test login:        npm run login');
  console.log('');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('');

  rl.close();
}

// ═══════════════════════════════════════════════════════════════
// LOGIN FUNCTION
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
      console.log('  ✅ Valid session exists');
      console.log(`     Remaining: ${session.hours.toFixed(1)} hours`);
      console.log('     Use --force to re-login');
      console.log('');
      return;
    }
    console.log(`  ⚠️  ${session.reason}`);
  }

  // Get credentials from .env
  const loginUrl = process.env.APP_LOGIN_URL;
  const encryptKey = process.env.APP_ENCRYPT_KEY;
  const encryptedUsername = process.env.APP_USERNAME;
  const encryptedPassword = process.env.APP_PASSWORD;

  if (!loginUrl || !encryptedUsername || !encryptedPassword) {
    console.log('  ❌ Missing credentials in .env file');
    console.log('');
    console.log('     Run: npm run generate-creds');
    console.log('     Then copy the output to .env');
    console.log('');
    process.exit(1);
  }

  // Decrypt credentials
  const username = decryptWithKey(encryptedUsername, encryptKey);
  const password = decryptWithKey(encryptedPassword, encryptKey);

  console.log('  🔐 Credentials');
  console.log(`     URL:  ${loginUrl}`);
  console.log(`     User: ${username}`);
  console.log('');

  // Launch DESKTOP CHROME
  console.log('  🌐 Opening desktop Chrome browser...');
  console.log('');
  
  let browser;
  try {
    browser = await chromium.launch({
      headless: false,
      channel: 'chrome',
      slowMo: 100
    });
  } catch (err) {
    // If Chrome not found, try default
    console.log('     Chrome not found, using default browser...');
    browser = await chromium.launch({
      headless: false,
      slowMo: 100
    });
  }

  const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
  const page = await context.newPage();

  try {
    // Navigate
    console.log('  [1/5] Navigating to login page...');
    await page.goto(loginUrl, { waitUntil: 'networkidle', timeout: 30000 });
    console.log('        ✅ Page loaded');

    // Username
    console.log('  [2/5] Entering username...');
    const userSelectors = [
      '#username', '#user', '#email', '#userId', '#login',
      'input[name="username"]', 'input[name="user"]',
      'input[name="email"]', 'input[name="userId"]',
      'input[type="email"]', 'input[type="text"]',
      '[data-testid="username"]', '[data-testid="email"]'
    ];
    
    let userFilled = false;
    for (const sel of userSelectors) {
      try { 
        const el = await page.waitForSelector(sel, { timeout: 1000 });
        if (el) {
          await el.fill(username);
          console.log(`        ✅ Found: ${sel}`);
          userFilled = true;
          break;
        }
      } catch {}
    }
    if (!userFilled) {
      throw new Error('Could not find username field');
    }

    // Password
    console.log('  [3/5] Entering password...');
    const passSelectors = [
      '#password', '#pass', '#pwd',
      'input[name="password"]', 'input[name="pass"]',
      'input[type="password"]',
      '[data-testid="password"]'
    ];
    
    let passFilled = false;
    for (const sel of passSelectors) {
      try { 
        const el = await page.waitForSelector(sel, { timeout: 1000 });
        if (el) {
          await el.fill(password);
          console.log(`        ✅ Found: ${sel}`);
          passFilled = true;
          break;
        }
      } catch {}
    }
    if (!passFilled) {
      throw new Error('Could not find password field');
    }

    // Submit
    console.log('  [4/5] Clicking login button...');
    const btnSelectors = [
      'button[type="submit"]', 'input[type="submit"]',
      'button:has-text("Login")', 'button:has-text("Log in")',
      'button:has-text("Sign in")', 'button:has-text("Submit")',
      '#loginBtn', '#login', '#submit',
      '[data-testid="login-button"]', '[data-testid="submit"]'
    ];
    
    let btnClicked = false;
    for (const sel of btnSelectors) {
      try { 
        const el = await page.waitForSelector(sel, { timeout: 1000 });
        if (el) {
          await el.click();
          console.log(`        ✅ Clicked: ${sel}`);
          btnClicked = true;
          break;
        }
      } catch {}
    }
    if (!btnClicked) {
      throw new Error('Could not find login button');
    }

    // Wait
    console.log('  [5/5] Waiting for redirect...');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);
    console.log(`        ✅ Current URL: ${page.url()}`);

    // Save session
    const authDir = path.dirname(AUTH_FILE);
    if (!fs.existsSync(authDir)) {
      fs.mkdirSync(authDir, { recursive: true });
    }
    await context.storageState({ path: AUTH_FILE });

    console.log('');
    console.log('═══════════════════════════════════════════════════════════════');
    console.log('                    ✅ LOGIN SUCCESSFUL');
    console.log('═══════════════════════════════════════════════════════════════');
    console.log(`   Session saved: ${AUTH_FILE}`);
    console.log(`   Valid for:     ${SESSION_HOURS} hours`);
    console.log('');

  } catch (err) {
    console.log('');
    console.log('═══════════════════════════════════════════════════════════════');
    console.log('                    ❌ LOGIN FAILED');
    console.log('═══════════════════════════════════════════════════════════════');
    console.log(`   Error: ${err.message}`);
    console.log('');
    
    // Save screenshot
    const screenshotPath = './auth/login-error.png';
    const screenshotDir = path.dirname(screenshotPath);
    if (!fs.existsSync(screenshotDir)) {
      fs.mkdirSync(screenshotDir, { recursive: true });
    }
    await page.screenshot({ path: screenshotPath, fullPage: true });
    console.log(`   Screenshot saved: ${screenshotPath}`);
    console.log('');
    
    process.exit(1);
  } finally {
    await browser.close();
  }
}

// ═══════════════════════════════════════════════════════════════
// CHECK SESSION STATUS
// ═══════════════════════════════════════════════════════════════

function showStatus() {
  console.log('');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('                    SESSION STATUS');
  console.log('═══════════════════════════════════════════════════════════════');
  console.log('');
  
  const s = checkSession();
  if (s.valid) {
    console.log('  ✅ Session is VALID');
    console.log(`     File: ${AUTH_FILE}`);
    console.log(`     Remaining: ${s.hours.toFixed(1)} hours`);
  } else {
    console.log('  ❌ Session is INVALID');
    console.log(`     Reason: ${s.reason}`);
    console.log('');
    console.log('     Run: npm run login');
  }
  console.log('');
}

// ═══════════════════════════════════════════════════════════════
// MAIN
// ═══════════════════════════════════════════════════════════════

const args = process.argv.slice(2);

if (args.includes('--generate') || args.includes('-g')) {
  generateCreds();
} else if (args.includes('--check') || args.includes('-c')) {
  showStatus();
} else if (args.includes('--force') || args.includes('-f')) {
  login(true);
} else {
  login(false);
}
