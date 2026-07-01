# Migrasi ke Astro static site generator

## Context

ADR-0001 memilih single HTML file + Tailwind CDN dengan alasan kesederhanaan dan deploy instan tanpa build step. Setelah v1 live di production (https://landing-page-fawn-theta.vercel.app), ditemukan tiga hambatan konversi dan profesionalitas:

1. **Performance**: Tailwind via CDN menambah ~350KB blocking JavaScript di first load. First Contentful Paint (FCP) dan Largest Contentful Paint (LCP) melambat di koneksi mobile 4G, menghambat target PRD §5 (LCP <2.5s).

2. **Share preview kosong**: Saat link di-share ke WhatsApp (kanal utama konversi, sesuai ADR-0003), preview tidak muncul karena tidak ada Open Graph image/tags. CTR share turun, penerima pesan tidak tertarik buka.

3. **Favicon hilang**: Tab browser tidak menampilkan icon brand, mengurangi profesionalitas dan trust signal.

Konten copy sudah final dan terbukti efektif — tidak ada perubahan section atau messaging yang dibutuhkan. Yang perlu diperbaiki adalah delivery mechanism dan metadata `<head>`.

ADR-0001 perlu di-revisit karena premis "no build step = lebih sederhana" tidak lagi valid ketika performance bottleneck dan metadata menjadi blocker konversi.

## Decision

Migrasi dari single HTML file ke **Astro v4+ static site generator** dengan konfigurasi `output: 'static'` dan Tailwind via Vite (precompiled).

**Stack baru**:
- Astro static output (HTML statis, zero runtime JavaScript by default)
- Tailwind via `@astrojs/tailwind` integration (precompiled, ~10KB vs 350KB CDN)
- Deploy ke Vercel sebagai static hosting (tanpa Vercel adapter — tidak diperlukan untuk static output)
- Build command: `astro build`, output: `dist/`

**Apa yang berubah**:
- Build pipeline: npm install + astro build (menambah ~1-2 menit setup lokal pertama kali)
- `<head>` tags: tambah Open Graph, Twitter Card, favicon
- GA4 wiring: script inline dengan event tracking `wa_click`
- Konfigurasi terpusat: `src/config.ts` untuk WA_NUMBER, WA_MESSAGE, GA4_ID

**Apa yang TIDAK berubah**:
- Output tetap HTML statis (bukan SSR/serverless)
- Konten copy identik 1:1 dengan versi live
- Struktur section, warna brand, font, nomor WA, pesan default
- Deployment workflow: push git → Vercel auto-deploy
- Tidak ada JavaScript interactivity tambahan (selain GA4 tracking)

**Supersedes**: ADR-0001 (single HTML file, no framework). Goal "1 halaman statis" tetap dipertahankan. Goal "no framework" diganti dengan "static-first framework dengan output HTML statis".

## Consequences

**Gain**:
- **Performance**: Tailwind precompiled ~10KB vs 350KB CDN. Lighthouse Mobile Performance score target >90, LCP <2.5s tercapai.
- **Konversi**: Share preview muncul di WhatsApp/Telegram/iMessage dengan OG image + deskripsi, meningkatkan CTR share.
- **Trust signal**: Favicon muncul di tab browser, meningkatkan profesionalitas brand.
- **Maintainability**: Konfigurasi terpusat di `src/config.ts`, mudah update nomor WA atau GA4 ID tanpa grep multiple files.
- **DX**: Hot reload via `astro dev`, Tailwind IntelliSense di editor, MDX built-in untuk iterasi blog nanti.

**Cost**:
- **Setup overhead**: Developer baru perlu `npm install` (~1-2 menit) sebelum dev/build. Tidak bisa langsung edit HTML di browser DevTools atau text editor sederhana.
- **Build step**: Deploy membutuhkan `astro build` (~10-20 detik di Vercel). Tidak lagi "edit HTML → push → live instan".
- **Dependency management**: Perlu maintain npm dependencies (Astro, Tailwind, Node.js version).
- **Learning curve ringan**: Developer yang tidak familiar dengan Astro perlu baca docs untuk component syntax (`.astro` file format), tapi untuk single-page static site learning curve minimal.

**Risk mitigation**:
- `index.html` lama tetap di git history dengan path asli — rollback = `git revert` commit migrasi.
- `vercel.json` yang lama juga di history — revert akan restore build command lama.
- Konten copy tidak diubah sama sekali — zero risk regresi messaging/konversi.

## Re-evaluate triggers

Keputusan ini perlu di-review ulang jika:

1. **Kebutuhan blog atau halaman dinamis muncul**: Jika v2 butuh blog (MDX), dashboard klien, atau halaman multi-page → Astro tetap cocok, tidak perlu migrasi lagi. Tapi jika butuh SSR/serverless (personalisasi per-user, auth, API routes) → evaluasi Next.js atau Astro SSR mode.

2. **Build time jadi bottleneck**: Jika Astro build >1 menit di Vercel atau lokal dev server lambat → investigasi alternatif (kembali ke HTML statis dengan PostCSS manual, atau framework lain).

3. **Dependency maintenance jadi beban**: Jika npm security alerts atau breaking changes di Astro/Tailwind major version bikin maintenance effort tinggi → evaluasi kembali ke zero-dependency HTML statis.

Untuk v1.1 scope saat ini (1 halaman landing), Astro adalah sweet spot antara performance, DX, dan maintainability.

---

**Supersedes**: [ADR-0001: Single HTML file, no framework](0001-single-html-file-no-framework.md)
