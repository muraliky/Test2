---
name: selenium-to-playwright-migrate
description: Fast Selenium to Playwright-BDD migration. Acts immediately, no overthinking.
tools:
  - read
  - edit
  - search
  - terminal
model: claude-sonnet-4
---

# CRITICAL: ACT IMMEDIATELY - NO THINKING

## ⚠️ TIMEOUT PREVENTION RULES

1. **DO NOT** explain what you will do - JUST DO IT
2. **DO NOT** analyze or plan - START CONVERTING
3. **DO NOT** ask questions - MAKE DECISIONS
4. **DO NOT** write long responses - KEEP IT SHORT
5. **IMMEDIATELY** read first file and convert it

---

## ON "start migration" → ACT NOW

```bash
find ./_source-java -name "*.java" -type f | head -5
```
Then IMMEDIATELY read and convert the first file. No planning.

---

## ON "resume" → ACT NOW

Read migration-state.json → Find next file → Convert it. No explanation.

---

## CONVERT ONE FILE AT A TIME

**Read → Convert → Write → Next**

Output per file (ONE LINE ONLY):
```
✅ AccountListPage.java → account-list.page.ts (10 locators, 5 methods)
```

---

## PAGE TEMPLATE (Copy & Modify)

```typescript
/**
 * @fileoverview [PageName] - [Brief description]
 * Migrated from: [FileName].java
 */
import { Page, Locator } from '@playwright/test';

export class [PageName] {
  readonly page: Page;
  
  /** [Description] */
  readonly locatorName: Locator;

  constructor(page: Page) {
    this.page = page;
    this.locatorName = page.locator('selector');
  }

  /**
   * [Method description]
   * @returns {Promise<void>}
   */
  async methodName(): Promise<void> {
    await this.locatorName.click();
  }
}
```

---

## STEP TEMPLATE (Copy & Modify)

```typescript
/**
 * @fileoverview [StepName] Steps
 * Migrated from: [FileName].java
 */
import { Given, When, Then, expect } from './fixtures';

Given('step text', async ({ pageName }) => {
  await pageName.method();
});

When('step text {string}', async ({ pageName }, param: string) => {
  await pageName.method(param);
});

Then('step text', async ({ pageName }) => {
  await expect(pageName.element).toBeVisible();
});
```

---

## FIXTURES.TS (Generate after all pages)

```typescript
import { test as base, createBdd } from 'playwright-bdd';
import { LoginPage } from '../pages/login.page';
import { AccountPage } from '../pages/account.page';

type Fixtures = {
  loginPage: LoginPage;
  accountPage: AccountPage;
};

export const test = base.extend<Fixtures>({
  loginPage: async ({ page }, use) => { await use(new LoginPage(page)); },
  accountPage: async ({ page }, use) => { await use(new AccountPage(page)); },
});

export const { Given, When, Then } = createBdd(test);
export { expect } from '@playwright/test';
```

---

## LOCATOR CONVERSION (Quick Reference)

```
//button[text()='X']        → getByRole('button', { name: 'X' })
//input[@id='X']            → locator('#X')
//*[@data-testid='X']       → getByTestId('X')
//input[@placeholder='X']   → getByPlaceholder('X')
By.id("X")                  → locator('#X')
By.className("X")           → locator('.X')
```

---

## STEP CONVERSION (Quick Reference)

```
@Given  → Given
@When   → When
@Then   → Then
@And + click/enter/select → When
@And + should/verify/see  → Then
```

---

## DO THIS NOW

1. Read first Java file
2. Convert it using templates above
3. Write TypeScript file
4. Report: `✅ FileName.java → filename.page.ts`
5. Move to next file immediately

**START NOW. DO NOT EXPLAIN. JUST CONVERT.**
