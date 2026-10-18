// render-test.mjs: open the generated pages in Chromium and check that they work.
// Usage: node tests/render-test.mjs <docs/visual folder from build-fixtures.sh>
// Libraries load from jsDelivr. To test offline, set CDN_DIR to a folder laid
// out like jsDelivr's /npm/ path (e.g. CDN_DIR/mermaid@11.4.1/dist/mermaid.min.js).
import { chromium } from 'playwright';
import fs from 'node:fs';
import path from 'node:path';

const dir = process.argv[2];
if (!dir) { console.error('usage: node tests/render-test.mjs <docs/visual folder>'); process.exit(2); }
const CDN_DIR = process.env.CDN_DIR;
let pass = 0, fail = 0;
const check = (label, ok, detail = '') => {
  if (ok) { pass++; console.log(`  PASS  ${label}`); }
  else { fail++; console.log(`  FAIL  ${label}${detail ? `: ${detail}` : ''}`); }
};

async function open(file, opts, offline = false) {
  const browser = await chromium.launch();
  const ctx = await browser.newContext(opts);
  const page = await ctx.newPage();
  const errors = [];
  page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
  page.on('pageerror', e => errors.push(e.message));
  if (offline || CDN_DIR) {
    await page.route('https://cdn.jsdelivr.net/**', route => {
      if (offline) return route.abort();
      const local = path.join(CDN_DIR, new URL(route.request().url()).pathname.replace(/^\/npm\//, ''));
      if (!fs.existsSync(local)) return route.abort();
      return route.fulfill({ status: 200, contentType: 'application/javascript',
        headers: { 'Access-Control-Allow-Origin': '*' }, body: fs.readFileSync(local) });
    });
  }
  await page.goto('file://' + path.resolve(dir, file));
  await page.waitForTimeout(3000);
  return { browser, page, errors };
}

const views = {
  light: { viewport: { width: 1280, height: 900 }, colorScheme: 'light' },
  dark: { viewport: { width: 1280, height: 900 }, colorScheme: 'dark' },
  phone: { viewport: { width: 390, height: 844 }, colorScheme: 'light', isMobile: true, hasTouch: true },
};

for (const [view, opts] of Object.entries(views)) {
  console.log(`\n== rich page (${view})`);
  const { browser, page, errors } = await open('rich-demo.html', opts);
  const r = await page.evaluate(() => ({
    toc: document.querySelectorAll('#toc-list a').length,
    svgs: document.querySelectorAll('pre.mermaid svg').length,
    diagrams: document.querySelectorAll('pre.mermaid').length,
    charts: [...document.querySelectorAll('.chart canvas')].filter(c => window.Chart && window.Chart.getChart(c)).length,
    chartCount: document.querySelectorAll('.chart canvas').length,
    tables: document.querySelectorAll('.table-wrap > table').length,
    hScroll: document.documentElement.scrollWidth > document.documentElement.clientWidth,
  }));
  check('contents sidebar built', r.toc >= 5, `${r.toc} entries`);
  check('every diagram drawn (including the one in a hidden tab)', r.svgs === r.diagrams && r.diagrams === 3, `${r.svgs}/${r.diagrams}`);
  check('every chart drawn (including the one in a hidden tab)', r.charts === r.chartCount && r.chartCount === 3, `${r.charts}/${r.chartCount}`);
  check('tables wrapped for sideways scrolling', r.tables >= 1);
  check('no sideways page scroll', !r.hScroll);
  await page.click('.tab-list .tab:nth-child(2)');
  check('tabs switch', await page.evaluate(() => !document.querySelectorAll('.tabs .tab-panel')[1].classList.contains('is-hidden')));
  await page.click('.steps-nav .btn:last-child');
  check('step-through moves on', (await page.textContent('.steps-count')) === 'Step 2 of 3');
  check('no console errors', errors.length === 0, errors.join(' | '));
  await page.screenshot({ path: path.join(dir, `shot-rich-${view}.png`), fullPage: true });
  await browser.close();

  console.log(`\n== quick page from Markdown (${view})`);
  const q = await open('features-demo.html', opts);
  const m = await q.page.evaluate(() => ({
    h2: [...document.querySelectorAll('main h2')].map(h => h.textContent),
    toc: document.querySelectorAll('#toc-list a').length,
    tip: !!document.querySelector('aside.callout.tip'),
    warning: !!document.querySelector('aside.callout.warning'),
    svg: document.querySelectorAll('pre.mermaid svg').length,
    chart: [...document.querySelectorAll('.chart canvas')].filter(c => window.Chart && window.Chart.getChart(c)).length,
    apiLink: [...document.querySelectorAll('main a')].map(a => a.getAttribute('href')).find(h => h && h.startsWith('api.html')),
    inputsLink: [...document.querySelectorAll('main a')].map(a => a.getAttribute('href')).find(h => h && h.includes('inputs')),
    scriptText: [...document.querySelectorAll('main pre code')].some(c => c.textContent.includes('</script>')),
    injected: document.querySelectorAll('main script:not([type])').length,
    unicode: document.body.textContent.includes('日本語') && document.body.textContent.includes('café'),
    checkboxes: document.querySelectorAll('main li input[type="checkbox"]').length,
    title: document.title,
  }));
  check('Markdown rendered (headings)', m.h2.includes('How it works') && m.h2.includes('Numbers'), m.h2.join(', '));
  check('first heading used as the page title', m.title === 'Demo feature', m.title);
  check('contents sidebar built', m.toc >= 3);
  check('GitHub alerts became callouts', m.tip && m.warning);
  check('mermaid block drawn', m.svg === 1, String(m.svg));
  check('chart block drawn', m.chart === 1, String(m.chart));
  check('link to another doc points at its page', m.apiLink === 'api.html#endpoints', String(m.apiLink));
  check('link to a non-doc file points at the file', m.inputsLink === '../../inputs/README.md', String(m.inputsLink));
  check('"</script>" inside a code block stays text', m.scriptText && m.injected === 0);
  check('Unicode decoded correctly', m.unicode);
  check('task list checkboxes kept', m.checkboxes === 2, String(m.checkboxes));
  check('no console errors', q.errors.length === 0, q.errors.join(' | '));
  await q.page.screenshot({ path: path.join(dir, `shot-quick-${view}.png`), fullPage: true });
  await q.browser.close();
}

console.log('\n== index page');
{
  const { browser, page, errors } = await open('index.html', views.light);
  const href = await page.evaluate(() => [...document.querySelectorAll('main a')].map(a => a.getAttribute('href')));
  check('index links to the feature page', href.includes('features-demo.html'), href.join(', '));
  check('index links to the charter page', href.includes('charter.html'));
  check('no console errors', errors.length === 0, errors.join(' | '));
  await browser.close();
}

console.log('\n== quick page offline');
{
  const { browser, page } = await open('features-demo.html', views.light, true);
  const raw = await page.evaluate(() => ({
    pre: [...document.querySelectorAll('main pre')].some(p => p.textContent.includes('## How it works')),
    note: [...document.querySelectorAll('.load-note')].some(n => n.textContent.includes('raw text')),
  }));
  check('offline: raw Markdown shown with a note', raw.pre && raw.note);
  await browser.close();
}

console.log(`\nRESULT: ${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);
