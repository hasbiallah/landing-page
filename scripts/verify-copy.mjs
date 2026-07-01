// Diff innerText of legacy index.html vs dist/index.html. No deps, Node built-in.
// Strips <head>, <script>, <style>, <noscript>, comments, tags. Whitespace-normalized.
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

function innerText(html) {
  // 1) remove <head>...</head>
  let s = html.replace(/<head[\s\S]*?<\/head>/i, ' ');
  // 2) remove script/style/noscript blocks
  s = s.replace(/<(script|style|noscript)[\s\S]*?<\/\1>/gi, ' ');
  // 3) remove HTML comments
  s = s.replace(/<!--[\s\S]*?-->/g, ' ');
  // 4) strip all tags
  s = s.replace(/<[^>]+>/g, ' ');
  // 5) decode common entities
  s = s.replace(/&nbsp;/g, ' ')
       .replace(/&amp;/g, '&')
       .replace(/&lt;/g, '<')
       .replace(/&gt;/g, '>')
       .replace(/&quot;/g, '"')
       .replace(/&#39;/g, "'");
  // 6) collapse whitespace
  s = s.replace(/\s+/g, ' ').trim();
  return s;
}

const legacy = readFileSync(resolve(process.cwd(), 'index.html'), 'utf8');
const built = readFileSync(resolve(process.cwd(), 'dist/index.html'), 'utf8');

const a = innerText(legacy);
const b = innerText(built);

if (a === b) {
  console.log(`OK — innerText identical (${a.length} chars)`);
  process.exit(0);
}

console.error('MISMATCH');
console.error(`legacy: ${a.length} chars`);
console.error(`built:  ${b.length} chars`);
// show first divergence
const min = Math.min(a.length, b.length);
let i = 0;
while (i < min && a[i] === b[i]) i++;
const ctx = 60;
console.error(`first diff @${i}:`);
console.error(`  legacy: ...${a.slice(Math.max(0, i - ctx), i)}[${a[i] ?? 'EOF'}]${a.slice(i + 1, i + ctx)}...`);
console.error(`  built:  ...${b.slice(Math.max(0, i - ctx), i)}[${b[i] ?? 'EOF'}]${b.slice(i + 1, i + ctx)}...`);
process.exit(1);
