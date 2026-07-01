# Implementation Roadmap: hasbi.dev WhatsApp Bot Platform

**Last Updated**: 2026-07-02  
**Status**: Ready to Start Development  

---

## Current State ✅

### 1. Landing Page (DONE)
- ✅ Migrated from single HTML to Astro static site
- ✅ Live at: https://landing-page-fawn-theta.vercel.app
- ✅ Paket definitions clear: Hemat (Rp299k), FYP (Rp990k), Cuan (Rp2.5jt)
- ✅ GA4 wiring ready (placeholder ID)
- ✅ OG image + favicon (placeholder, ready to replace)
- ⚠️ **Missing**: Social proof section (need 2-3 early bird testimonials)

### 2. Documentation (DONE)
- ✅ ADR-0001 to ADR-0006 (architecture decisions documented)
- ✅ PRD v2.0 (VPS-based, Vercel-only) — reference only
- ✅ PRD v2.1 (multi-tenant SaaS platform) — selected approach
- ✅ ADR-0006 (T3 Stack evaluation & hybrid architecture decision)

### 3. Product Status
- ❌ **No product to deliver yet** — landing page selling, but backend doesn't exist
- 🎯 **Next step**: Build WhatsApp Bot multi-tenant platform

---

## Final Tech Stack Decision (ADR-0006)

### Hybrid Architecture

```
┌─────────────────────────────────────────────┐
│  T3 Stack on Vercel                         │
│  - Next.js 14 (App Router)                  │
│  - tRPC v10 (typesafe API)                  │
│  - Prisma v5 (ORM)                          │
│  - NextAuth.js (authentication)             │
│  - Tailwind CSS (styling)                   │
│  - Customer dashboard UI                    │
└─────────────┬───────────────────────────────┘
              │ HTTP calls
              ▼
┌─────────────────────────────────────────────┐
│  Baileys Bot Service on Railway             │
│  - Node.js + Express (HTTP server)          │
│  - Baileys v6 (WhatsApp Web API)            │
│  - Multi-tenant bot manager                 │
│  - Long-running WebSocket connections       │
└─────────────┬───────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────┐
│  PostgreSQL on Railway                      │
│  - Multi-tenant schema                      │
│  - Shared by T3 app & Baileys service      │
└─────────────────────────────────────────────┘
```

**Why Hybrid?**
- ✅ Get T3 Stack benefits (end-to-end type safety, NextAuth, great DX)
- ✅ Solve Baileys limitation (needs long-running process, not serverless)
- ✅ Clean separation: UI/API logic vs Bot engine
- ✅ Scalable independently

---

## Phase 1: Development Roadmap (9 Weeks)

### Week 1-2: Project Setup & Baileys POC

**Goal**: Localhost environment running, 1 bot can connect via QR

**Tasks**:
1. Bootstrap T3 app: `npx create-t3-app@latest`
   - Select: Next.js, TypeScript, Prisma, NextAuth, Tailwind, tRPC
2. Setup `baileys-service/` (standalone Node.js)
   - Express HTTP server
   - Baileys bot manager (1 instance POC)
   - `/bot/qr` endpoint (return QR code)
   - `/bot/start` endpoint (start bot instance)
3. Docker Compose for localhost:
   - PostgreSQL container
   - Baileys service container
   - T3 app dev server (not containerized, use `npm run dev`)
4. Prisma schema (multi-tenant):
   - `tenants`, `bots`, `keywords`, `messages` tables
5. Test flow: Scan QR → bot connected → manual test send message

**Deliverable**:
- [ ] `docker-compose up` runs PostgreSQL + Baileys service
- [ ] T3 app accessible at `http://localhost:3000`
- [ ] 1 tenant can scan QR code via dashboard
- [ ] Bot receives message, logs to console

**Files to create**:
```
whatsapp-bot-platform/
├── apps/
│   ├── web/                    # T3 Stack
│   │   ├── src/
│   │   │   ├── app/
│   │   │   │   ├── page.tsx   # Landing/login
│   │   │   │   └── dashboard/
│   │   │   │       └── page.tsx
│   │   │   ├── server/
│   │   │   │   ├── api/
│   │   │   │   │   ├── routers/
│   │   │   │   │   │   └── bot.ts  # getQRCode, startBot
│   │   │   │   │   └── trpc.ts
│   │   │   │   └── auth.ts
│   │   │   └── lib/
│   │   │       └── baileys-client.ts  # HTTP client
│   │   └── prisma/
│   │       └── schema.prisma
│   │
│   └── baileys-service/
│       ├── src/
│       │   ├── index.ts       # Express server
│       │   ├── BotManager.ts  # Baileys manager
│       │   └── routes/
│       │       └── bot.ts     # /bot/qr, /bot/start
│       ├── Dockerfile
│       └── package.json
│
└── docker-compose.yml
```

---

### Week 3-4: Keyword Auto-Reply & Message History

**Goal**: Bot can auto-reply based on keywords, save message history to DB

**Tasks**:
1. Prisma schema: finalize `keywords` table
2. Baileys service: implement keyword matching logic
   - Receive incoming message
   - Query keywords table (filter by `tenant_id`)
   - Match trigger words (case-insensitive, array contains)
   - Send auto-reply
   - Save incoming + outgoing message to `messages` table
3. T3 app: tRPC routers for keyword CRUD
   - `keyword.list` (query)
   - `keyword.create` (mutation)
   - `keyword.update` (mutation)
   - `keyword.delete` (mutation)
4. T3 app: Dashboard pages
   - `/dashboard/keywords` (list, add, edit, delete)
   - `/dashboard/messages` (message history, pagination)
5. Package limits enforcement:
   - Hemat: max 5 keywords
   - FYP: max 20 keywords
   - Cuan: unlimited
   - Show UI indicator: "3/5 keywords used"

**Deliverable**:
- [ ] Bot auto-replies when keyword matched
- [ ] Message history saved to DB
- [ ] Dashboard can manage keywords (CRUD)
- [ ] Dashboard shows message history (paginated)
- [ ] Package limits enforced (UI + backend validation)

---

### Week 5-6: Authentication & Multi-Tenant Isolation

**Goal**: Customer can login, manage their own bot (tenant isolation)

**Tasks**:
1. NextAuth.js setup:
   - JWT strategy (or database sessions)
   - Prisma adapter (store sessions in DB)
   - Login page (`/login`)
   - Protected routes middleware (`/dashboard/*`)
2. Manual tenant creation (hasbi.dev creates via SQL/admin panel):
   - INSERT tenant → return credentials to customer
   - No self-signup yet (manual onboarding untuk v1)
3. Multi-tenant isolation testing:
   - Create 2 test tenants
   - Verify tenant A cannot access tenant B's data
   - Test: keyword CRUD, message history, bot control
4. Session management:
   - Logout functionality
   - Session expiry (7 days default)
   - "Remember me" option

**Deliverable**:
- [ ] Customer can login with email/password
- [ ] Dashboard shows only their tenant's data
- [ ] Multi-tenant isolation verified (2+ tenants tested)
- [ ] Session persists across browser refresh

---

### Week 7: Broadcast Feature (Cuan Only)

**Goal**: Cuan package customers can send broadcast messages

**Tasks**:
1. Prisma schema: `broadcasts` table
2. Baileys service: `/bot/broadcast` endpoint
   - Accept: `{ tenantId, message, targetNumbers[] }`
   - Send message to each number (with delay to avoid spam detection)
   - Update broadcast status in DB (`pending` → `sending` → `completed`)
3. T3 app: tRPC router for broadcast
   - `broadcast.create` (mutation)
   - `broadcast.list` (query — history)
   - `broadcast.getStatus` (query — check progress)
4. T3 app: Dashboard page `/dashboard/broadcast`
   - Compose message form
   - Upload CSV or manual input target numbers
   - Send button
   - Broadcast history table (status, sent count, failed count)
5. Package enforcement: only Cuan package can access broadcast

**Deliverable**:
- [ ] Cuan customer can send broadcast to 10+ numbers
- [ ] Broadcast status tracked in DB
- [ ] Dashboard shows broadcast history
- [ ] Hemat/FYP customers cannot access broadcast page (403 error)

---

### Week 8: Landing Page Editor (FYP & Cuan)

**Goal**: FYP/Cuan customers can manage their landing page via dashboard

**Tasks**:
1. Prisma schema: `landing_pages` table (JSONB config)
2. T3 app: tRPC router for landing page
   - `landing.get` (query)
   - `landing.update` (mutation)
3. T3 app: Dashboard page `/dashboard/landing`
   - Form to edit `site-config.yml` (JSON editor or form fields)
   - Preview iframe (show rendered landing page)
   - Publish button (set `is_published = true`)
4. Public landing page route: `/p/:slug`
   - Astro-like template rendered from JSONB config
   - Static sections: Hero, Katalog Produk, FAQ, CTA WA
5. Custom domain support (Cuan only):
   - DNS CNAME setup guide
   - Vercel custom domain integration (manual for v1)

**Deliverable**:
- [ ] FYP/Cuan customer can edit landing page config via dashboard
- [ ] Landing page accessible at `/p/:slug`
- [ ] Preview works in dashboard
- [ ] Custom domain guide documented (manual setup)

---

### Week 9: Deployment & Beta Testing

**Goal**: Deploy to production (Railway + Vercel), onboard 3 early bird customers

**Tasks**:
1. Deploy Baileys service to Railway:
   - Connect GitHub repo
   - Add PostgreSQL service (Railway managed)
   - Environment variables setup
   - Health check endpoint `/health`
2. Deploy T3 app to Vercel:
   - Connect GitHub repo
   - Environment variables (DATABASE_URL, BAILEYS_SERVICE_URL)
   - Domain setup: `dashboard.hasbi.dev`
3. Production testing:
   - Create 3 test tenants (early bird customers)
   - Onboard via Zoom call (guide setup, scan QR, test keywords)
   - Monitor bot stability (uptime, message latency)
4. Monitoring setup:
   - Sentry (error tracking)
   - UptimeRobot (health check ping every 5 min)
   - Vercel Analytics (dashboard page views)
5. Documentation:
   - Customer onboarding guide (PDF or Notion page)
   - Video tutorial (Loom recording)

**Deliverable**:
- [ ] Production deployed to Railway + Vercel
- [ ] 3 early bird customers onboarded
- [ ] Bot uptime >99% for 7 days
- [ ] Zero critical bugs reported
- [ ] Customer testimonials collected (for landing page Social Proof)

---

## Phase 2: Post-Launch (Week 10+)

### Week 10-12: Polish & Marketing

**Tasks**:
1. Update landing page Social Proof section:
   - Add 3 early bird testimonials (real names, photos optional)
   - Screenshot hasil bot auto-reply
   - Customer quotes: "Bot hasbi.dev bantu saya handle 50+ chat/hari tanpa manual reply!"
2. Launch announcement:
   - Post di LinkedIn, Twitter, Instagram
   - Reach out ke UMKM communities (WhatsApp groups, Facebook groups)
3. Pricing refinement:
   - Validate monthly hosting fee (Rp50k-200k/bulan acceptable?)
   - Offering: "Bulan pertama gratis, bayar mulai bulan ke-2"
4. Feature enhancements (based on early bird feedback):
   - Keyword priority (kalau multiple match, highest priority wins)
   - Reply with image/document (not just text)
   - Scheduled broadcast (send at specific time)

---

## Success Metrics

### Development Phase (Week 1-9)
- [ ] Localhost setup <5 minutes
- [ ] 1 tenant QR pairing <2 minutes
- [ ] Keyword auto-reply latency <500ms
- [ ] Dashboard load time <2s (Lighthouse Performance >90)
- [ ] Multi-tenant isolation: 0 cross-tenant data leaks

### Beta Phase (Week 9-12)
- [ ] 3 early bird customers onboarded
- [ ] Bot uptime >99% for 7 days
- [ ] Customer NPS >50
- [ ] Zero critical bugs (P0/P1)

### Post-Launch (Q1 2027)
- **MRR target**: 10 customers × Rp100k avg = Rp1jt/bulan recurring
- **Churn rate**: <10%/bulan
- **Support burden**: <5 jam/minggu
- **New signups**: 5-10/bulan organic (via landing page + word-of-mouth)

---

## Cost Structure

### Development Cost (hasbi.dev time)
- Week 1-9: ~9 minggu × 40 jam/minggu = 360 jam total
- Opportunity cost: Rp50k/jam × 360 = Rp18jt (3 bulan full-time development)

### Hosting Cost (Monthly Recurring)
- Railway (PostgreSQL + Baileys service): ~$20/bulan = Rp300k/bulan
- Vercel (T3 app): $0 (free tier cukup untuk 100+ customers)
- **Total**: Rp300k/bulan fixed cost

### Break-Even Point
- Fixed cost: Rp300k/bulan
- Revenue per customer: Rp100k/bulan avg (Hemat Rp50k, FYP Rp100k, Cuan Rp200k)
- **Break-even**: 3 paying customers (Rp300k revenue = Rp300k cost)
- **Profitable**: 4+ customers (setiap customer tambahan = profit Rp100k/bulan)

### Revenue Projection (Conservative)
- Month 1-3 (beta): 3 early bird × Rp0 (gratis) = Rp0
- Month 4: 5 customers × Rp100k = Rp500k (profit Rp200k)
- Month 6: 10 customers × Rp100k = Rp1jt (profit Rp700k)
- Month 12: 20 customers × Rp100k = Rp2jt (profit Rp1.7jt)

---

## Next Immediate Action

**Today (2026-07-02)**:
1. Push all commits ke GitHub: `git push origin main`
2. Update GA4_ID di `src/config.ts` (kalau GA4 property sudah ready)
3. Deploy landing page update ke Vercel

**Tomorrow (2026-07-03)**:
1. Bootstrap T3 app: `npx create-t3-app@latest apps/web`
2. Setup project structure (`baileys-service/` folder)
3. Docker Compose for PostgreSQL
4. First commit: "feat: init T3 stack + Baileys service structure"

**This Week (Week 1)**:
- Complete Week 1-2 tasks (Project Setup & Baileys POC)
- Goal: QR pairing flow working di localhost

---

## Questions to Resolve

1. **Hosting fee pricing**: Apakah Rp50k-200k/bulan acceptable untuk UMKM target? (validate dengan early bird)
2. **Payment method**: Transfer bank manual dulu, atau integrate payment gateway (Midtrans)?
3. **Customer domain**: Custom domain untuk landing page (Cuan only) — Vercel support atau manual DNS setup?
4. **WhatsApp ban risk**: Dokumentasi untuk customer: "gunakan nomor baru, bukan nomor bisnis utama"
5. **Early bird incentive**: Gratis berapa bulan? (suggest: 3 bulan gratis untuk 3 early bird pertama)

---

## Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| WhatsApp ban (unofficial API) | Dokumentasi jelas, gunakan nomor baru, migration path ke WA Business API |
| Railway downtime | Multi-region deployment (future), monitoring + alert |
| Customer churn | NPS monitoring, retention campaign, value proposition jelas |
| Development delay | MVP scope ketat (no gold-plating), weekly sprint review |
| Competitor copy | Build brand trust via social proof, focus on customer success |

---

**Ready to start?** 🚀

Let's build Week 1-2: Project Setup & Baileys POC!
