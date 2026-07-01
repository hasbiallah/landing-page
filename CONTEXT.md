# hasbi.dev Landing Page

Landing page statis untuk menjual jasa Bot WhatsApp & Website UMKM, dengan satu tujuan: konversi pengunjung menjadi chat WhatsApp.

## Language

**Konversi**:
Pengunjung yang menekan tombol CTA dan memulai chat WhatsApp. Satu-satunya metrik keberhasilan halaman ini.
_Avoid_: lead, signup, register

**CTA (Call to Action)**:
Tombol "Chat WA Sekarang" yang mengarah ke wa.me. Satu-satunya conversion point di seluruh halaman.
_Avoid_: form, tombol submit, tombol hubungi

**Paket**:
Tiga tingkatan layanan yang dijual — Hemat, FYP, dan Cuan — dengan harga dan fitur berbeda.
_Avoid_: produk, tier, plan

**Social Proof**:
Testimoni dan portofolio asli dari klien nyata. Tidak boleh menggunakan angka atau klaim fiktif.
_Avoid_: fake review, angka palsu, placeholder testimoni

**Early Bird**:
Slot klien perdana yang ditawarkan gratis atau diskon untuk mendapatkan testimoni asli sebelum launch.
_Avoid_: beta user, pilot

**Brand**:
hasbi.dev — nama tunggal yang dipakai untuk identitas produk dan studio di v1.
_Avoid_: Wabotix (ditangguhkan untuk v1)

**Nomor WA**:
6281286057569 — satu nomor WhatsApp Business dedicated untuk semua CTA di halaman.
_Avoid_: nomor pribadi, multiple nomor

**Tech Stack**:
Astro static site generator dengan output HTML statis + Tailwind CSS via Vite (precompiled). Build command `astro build`, deploy ke Vercel static hosting dari `dist/`. Zero runtime JavaScript kecuali GA4 tracking. Dokumentasi keputusan stack ada di ADR-0005.
_Avoid_: "no framework", "vanilla HTML", "single HTML file", "Tailwind CDN"
