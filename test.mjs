import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { test } from 'node:test';
import { parse_cirru_edn, to_js_data } from '@calcit/procs';

test('crawl continues after timers and saves only the first two languages', async (t) => {
  const originalCwd = process.cwd();
  const originalToken = process.env.GITHUB_API_TOKEN;
  const originalTimeout = globalThis.setTimeout;
  mkdirSync(resolve('.calcit'), { recursive: true });
  const fixture = mkdtempSync(resolve('.calcit/crawl-test-'));
  mkdirSync(resolve(fixture, 'data'));
  writeFileSync(resolve(fixture, 'data/languages.json'), '["Cirru","Common Lisp","Not Requested"]');
  process.chdir(fixture);
  process.env.GITHUB_API_TOKEN = 'fixture-token';
  t.after(() => {
    process.chdir(originalCwd);
    if (originalToken === undefined) delete process.env.GITHUB_API_TOKEN;
    else process.env.GITHUB_API_TOKEN = originalToken;
  });
  const requested = [];
  t.mock.method(globalThis, 'fetch', async (url, options) => {
    requested.push(url);
    assert.equal(options.headers.get('Authorization'), 'token fixture-token');
    assert.equal(options.headers.get('User-Agent'), 'calcit-repos-rank');
    return new Response(JSON.stringify({ total_count: requested.length * 12 }));
  });
  let ticks = 0;
  let finish;
  const finished = new Promise((resolveDone) => { finish = resolveDone; });
  t.mock.method(globalThis, 'setTimeout', (callback, ms) => {
    assert.equal(ms, 4500);
    return originalTimeout(() => {
      callback();
      if (++ticks === 2) finish();
    }, 1);
  });
  await import('./main.mjs');
  await finished;
  assert.deepEqual(requested, [
    'https://api.github.com/search/repositories?q=language:Cirru&per_page=1',
    'https://api.github.com/search/repositories?q=language:Common+Lisp&per_page=1',
  ]);
  const saved = parse_cirru_edn(readFileSync('data/result.cirru', 'utf8'));
  assert.deepEqual(to_js_data(saved), { Cirru: 12, 'Common Lisp': 24 });
});
