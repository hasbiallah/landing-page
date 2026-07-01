# hasbi.dev Landing Page & WhatsApp Bot Platform

Landing page statis untuk menjual jasa Bot WhatsApp & Website UMKM, dengan roadmap untuk membangun multi-tenant SaaS platform.

## 🚀 Current Status

### ✅ Landing Page (Live)
- **URL**: https://landing-page-fawn-theta.vercel.app
- **Tech**: Astro static + Tailwind CSS
- **Features**: Hero, Pain→Solusi, Paket (Hemat/FYP/Cuan), FAQ, Sticky CTA
- **GA4**: Ready (placeholder ID `G-XXXXXXXXXX` — needs replacement)
- **Missing**: Social proof section (awaiting early bird testimonials)

### 📋 Product Status
- ❌ **Backend not built yet** — landing page selling, but no product to deliver
- 🎯 **Next**: Build multi-tenant WhatsApp bot platform (9-week roadmap ready)

---

## 📦 Package Offerings

| Package | Price | Features | Monthly Fee |
|---------|-------|----------|-------------|
| **Hemat** | Rp299rb | Bot 5 keywords, 1x revision | Rp50k/bulan |
| **FYP** ⭐ | Rp990rb | Bot 20 keywords, Landing page, 1x revision | Rp100k/bulan |
| **Cuan** | Rp2.5jt | Bot unlimited keywords, Landing premium, Broadcast, Unlimited revision | Rp200k/bulan |

---

## 🏗️ Architecture (Planned — ADR-0006)

### Hybrid T3 Stack

```
┌─────────────────────────────────────┐
│  T3 Stack on Vercel                 │
│  - Next.js 14 (App Router)          │
│  - tRPC v10 (typesafe API)          │
│  - Prisma v5 (PostgreSQL ORM)       │
│  - NextAuth.js (auth)               │
│  - Tailwind CSS                     │
│  - Customer dashboard               │
└────────────┬────────────────────────┘
             │ HTTP
             ▼
┌─────────────────────────────────────┐
│  Baileys Bot Service on Railway     │
│  - Node.js + Express                │
│  - Baileys v6 (WhatsApp)            │
│  - Multi-tenant bot manager         │
│  - Long-running WebSocket           │
└────────────┬────────────────────────┘
             ▼
┌─────────────────────────────────────┐
│  PostgreSQL on Railway              │
│  - Multi-tenant schema              │
└─────────────────────────────────────┘
```

**Why Hybrid?**
- End-to-end type safety (tRPC)
- Baileys needs long-running process (incompatible with Vercel serverless)
- Clean separation: UI/API logic (T3) vs Bot engine (Baileys)

---

## 📚 Documentation

### Architecture Decision Records (ADRs)
- [ADR-0001](docs/adr/0001-single-html-file-no-framework.md) — Single HTML file (superseded by ADR-0005)
- [ADR-0002](docs/adr/0002-ga4-only-no-meta-pixel.md) — GA4 only, no Meta Pixel
- [ADR-0003](docs/adr/0003-direct-to-wa-no-form.md) — Direct-to-WA, no form capture
- [ADR-0004](docs/adr/0004-real-testimonials-only.md) — Real testimonials only
- [ADR-0005](docs/adr/0005-migrate-to-astro.md) — Migrate to Astro static
- [ADR-0006](docs/adr/0006-tech-stack-evaluation-t3-vs-custom.md) — T3 Stack evaluation & hybrid architecture

### Product Requirements Documents (PRDs)
- [PRD v1.1](docs/prd/v1.1-astro-migration.md) — Astro migration (completed)
- [PRD v2.0 VPS](docs/prd/v2.0-whatsapp-bot-system.md) — VPS-based approach (reference)
- [PRD v2.0 Vercel-only](docs/prd/v2.0-whatsapp-bot-system-vercel.md) — Vercel-only approach (reference)
- [PRD v2.1](docs/prd/v2.1-multi-tenant-whatsapp-platform.md) — **Multi-tenant SaaS platform (selected)**

### Implementation
- [Implementation Roadmap](IMPLEMENTATION_ROADMAP.md) — 9-week development timeline

---

## 🛠️ Tech Stack

### Landing Page (Current)
- **Framework**: Astro v4 (static output)
- **Styling**: Tailwind CSS v3
- **Deployment**: Vercel (free tier)
- **Analytics**: Google Analytics 4 (placeholder)

### WhatsApp Bot Platform (Planned)
- **Frontend**: Next.js 14 + tRPC + NextAuth + Tailwind
- **Backend**: Node.js + Express + Baileys v6
- **Database**: PostgreSQL 15 (Prisma ORM)
- **Deployment**: Vercel (frontend) + Railway (backend+DB)

---

## 🚀 Quick Start

### Landing Page (Local Development)

```bash
# Install dependencies
npm install

# Start dev server
npm run dev
# Open http://localhost:4321

# Build for production
npm run build

# Preview production build
npm run preview
```

### Configuration

Edit `src/config.ts`:
```typescript
export const WA_NUMBER = '6281286057569';
export const WA_MESSAGE = 'Halo kak mau tanya layanan hasbi.dev';
export const GA4_ID = 'G-XXXXXXXXXX';  // ⚠️ Replace with real GA4 ID
```

### Deployment

```bash
# Vercel (auto-deploy on git push)
git push origin main

# Manual deploy
vercel --prod
```

---

## 📈 Success Metrics

### Landing Page (Current)
- Lighthouse Performance: >90 (mobile)
- LCP: <2.5s
- CLS: <0.1
- WhatsApp click-through rate: track via GA4 `wa_click` events

### Platform (Post-Launch — Month 12 Target)
- **MRR**: Rp2jt/bulan (20 customers × Rp100k avg)
- **Churn**: <10%/bulan
- **Bot uptime**: >99%
- **Customer NPS**: >50

---

## 💰 Business Model

### One-Time Setup Fee
- Paket Hemat: Rp299rb
- Paket FYP: Rp990rb
- Paket Cuan: Rp2.5jt

### Recurring Revenue (Hosting Fee)
- Paket Hemat: Rp50rb/bulan
- Paket FYP: Rp100rb/bulan
- Paket Cuan: Rp200rb/bulan

### Break-Even Analysis
- Fixed cost: Rp300rb/bulan (Railway hosting)
- Break-even: 3 paying customers
- Profitable: 4+ customers

---

## 🗺️ Roadmap

### Phase 0: Landing Page ✅ (DONE — 2026-07)
- Astro migration complete
- GA4 wiring ready
- Vercel deployment live

### Phase 1: Platform Development (9 weeks — 2026-07 to 2026-09)
- **Week 1-2**: Project setup, Baileys POC, QR pairing
- **Week 3-4**: Keyword auto-reply, message history
- **Week 5-6**: Authentication, multi-tenant isolation
- **Week 7**: Broadcast feature (Cuan)
- **Week 8**: Landing page editor (FYP/Cuan)
- **Week 9**: Production deployment, beta testing (3 early birds)

### Phase 2: Launch & Growth (2026-10 onwards)
- Collect testimonials from early birds
- Update landing page Social Proof section
- Marketing push (LinkedIn, Twitter, UMKM communities)
- Target: 10 paying customers by Month 3

---

## 📞 Contact

- **WhatsApp**: [+62 812-8605-7569](https://wa.me/6281286057569?text=Halo%20kak%20mau%20tanya%20layanan%20hasbi.dev)
- **Website**: [landing-page-fawn-theta.vercel.app](https://landing-page-fawn-theta.vercel.app)
- **GitHub**: This repo

---

## 📄 License

Private repository — all rights reserved by hasbi.dev.

---

**Built with ❤️ by hasbi.dev**
