# Single HTML file, no framework

Ini landing page statis dengan satu tujuan konversi. Next.js dan framework sejenis overkill untuk v1 — tidak ada routing multi-halaman, SSR, atau integrasi API yang dibutuhkan. Kami memilih 1 file HTML + Tailwind CDN karena deploy instan ke Vercel tanpa build step, mudah diedit tanpa toolchain, dan scope v1 tidak membutuhkan lebih dari itu. Migrasi ke Next.js baru relevan kalau muncul kebutuhan blog, CMS, atau halaman tambahan.
