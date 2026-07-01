import sharp from 'sharp';
import { writeFileSync } from 'node:fs';

const WA = '#25D366';

const favicon = `<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <rect width="512" height="512" fill="${WA}"/>
  <circle cx="256" cy="256" r="200" fill="white"/>
  <text x="256" y="256" font-family="DejaVu Sans, Arial, sans-serif" font-size="320" font-weight="800" fill="${WA}" text-anchor="middle" dominant-baseline="central">h</text>
</svg>`;

const og = `<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="630" viewBox="0 0 1200 630">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#0f172a"/>
      <stop offset="100%" stop-color="#1e293b"/>
    </linearGradient>
  </defs>
  <rect width="1200" height="630" fill="url(#bg)"/>
  <circle cx="220" cy="315" r="140" fill="${WA}"/>
  <text x="220" y="315" font-family="DejaVu Sans, Arial, sans-serif" font-size="220" font-weight="800" fill="white" text-anchor="middle" dominant-baseline="central">h</text>
  <text x="420" y="260" font-family="DejaVu Sans, Arial, sans-serif" font-size="56" font-weight="700" fill="${WA}">hasbi.dev</text>
  <text x="420" y="340" font-family="DejaVu Sans, Arial, sans-serif" font-size="44" font-weight="800" fill="white">Bot WhatsApp &amp; Website UMKM</text>
  <text x="420" y="395" font-family="DejaVu Sans, Arial, sans-serif" font-size="44" font-weight="800" fill="white">Jadi 1 Hari.</text>
  <text x="420" y="455" font-family="DejaVu Sans, Arial, sans-serif" font-size="28" font-weight="400" fill="#cbd5e1">Mulai 299rb — auto balas order, tampil profesional.</text>
</svg>`;

await sharp(Buffer.from(favicon)).png().toFile('public/favicon.png');
await sharp(Buffer.from(og)).png().toFile('public/og-image.png');

const m1 = await sharp('public/favicon.png').metadata();
const m2 = await sharp('public/og-image.png').metadata();
console.log('favicon', m1.width + 'x' + m1.height, m1.format);
console.log('og-image', m2.width + 'x' + m2.height, m2.format);
