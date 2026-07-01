# ADR-0006: Tech Stack Evaluation — T3 Stack vs Custom Stack

**Status**: Proposed  
**Date**: 2026-07-02  
**Context**: PRD v2.1 multi-tenant WhatsApp bot platform

---

## Context

PRD v2.1 (multi-tenant WhatsApp bot platform) originally proposed custom stack:
- Backend: Node.js + Express + Baileys + PostgreSQL + Prisma
- Frontend: Astro SSR + Tailwind
- Auth: JWT manual implementation

User question: **Apakah T3 Stack lebih cocok?**

## T3 Stack Overview

T3 Stack = [create-t3-app](https://create.t3.gg/):
- **Next.js** (app router, React 18+)
- **TypeScript** (end-to-end type safety)
- **tRPC** (end-to-end typesafe APIs, no REST/GraphQL)
- **Prisma** (TypeScript ORM)
- **NextAuth.js** (authentication)
- **Tailwind CSS** (styling)

Philosophy: "Typesafety isn't optional" — full-stack type safety from DB → API → UI.

---

## Comparison: T3 Stack vs PRD v2.1 Original Stack

### Architecture Differences

| Aspect | Original (PRD v2.1) | T3 Stack |
|--------|---------------------|----------|
| **Frontend** | Astro SSR | Next.js App Router |
| **Backend API** | Express REST | tRPC (typesafe RPC) |
| **Auth** | JWT manual | NextAuth.js (built-in) |
| **ORM** | Prisma ✅ | Prisma ✅ |
| **Type Safety** | Partial (backend only) | **End-to-end** (DB→API→UI) |
| **Deployment** | Vercel (frontend) + Railway (backend) | **Vercel full-stack** (SSR + API routes) |
| **WebSocket/Long-running** | ✅ Railway supports | ⚠️ Vercel serverless (10s limit) |

---

## Analysis: T3 Stack for WhatsApp Bot Platform

### ✅ Pros of T3 Stack

**1. End-to-End Type Safety** (Biggest Win)
```typescript
// tRPC procedure (backend)
export const keywordRouter = router({
  list: protectedProcedure
    .input(z.object({ tenantId: z.string().uuid() }))
    .query(async ({ input, ctx }) => {
      return ctx.prisma.keyword.findMany({
        where: { tenantId: input.tenantId }
      });
      // Return type inferred: Keyword[]
    }),
    
  create: protectedProcedure
    .input(z.object({
      tenantId: z.string().uuid(),
      triggerWords: z.array(z.string()),
      replyMessage: z.string()
    }))
    .mutation(async ({ input, ctx }) => {
      return ctx.prisma.keyword.create({ data: input });
    })
});

// Frontend (React component) — auto-complete + type checking!
function KeywordList() {
  const { data } = api.keyword.list.useQuery({ tenantId });
  //    ^^^^
  //    Type: Keyword[] | undefined (inferred from backend)
  
  const createMutation = api.keyword.create.useMutation();
  //                     ^^^^^^^^^^^^^^^
  //                     Type-safe input: { tenantId, triggerWords, replyMessage }
  
  return <div>{data?.map(k => k.triggerWords)}</div>
}
```

**No manual API typing, no REST endpoint mismatches, no `any` types.**

**2. NextAuth.js Built-in**
- Session management out-of-the-box
- JWT + database sessions (Prisma adapter)
- Protected routes via middleware
- No manual JWT signing/verification

**3. Next.js App Router Benefits**
- Server Components (less JS to client)
- React Server Actions (form mutations without API routes)
- Streaming SSR (faster TTFB)
- Built-in API routes (co-located with frontend)

**4. Developer Experience**
- `create-t3-app` scaffolding (project setup <5 menit)
- Type errors caught at compile-time (not runtime)
- Auto-complete everywhere (DX sangat baik)
- Hot reload frontend + backend (monorepo)

**5. Deployment Simplicity**
- Single Vercel deployment (frontend + API routes)
- No need separate Railway backend (kecuali untuk Baileys — see Cons)

**6. Community & Documentation**
- T3 Stack punya community besar (Discord, docs lengkap)
- Best practices sudah established
- Banyak starter templates untuk SaaS

---

### ❌ Cons of T3 Stack

**1. Baileys Long-Running Process Problem** (Critical Issue)

Baileys bot butuh **persistent WebSocket connection** ke WhatsApp servers:
- Connection harus stay alive 24/7
- Vercel serverless function: **max 10s execution** (Hobby), 60s (Pro)
- **Tidak bisa run Baileys di Vercel API routes** ❌

**Workaround Options**:

**Option A: Hybrid Architecture** (Recommended)
```
┌─────────────────────────────────────────────┐
│  Next.js (T3 Stack) on Vercel               │
│  - Dashboard UI (React)                     │
│  - tRPC API routes (keyword CRUD, etc.)     │
│  - NextAuth (customer login)                │
│  - Prisma (DB queries)                      │
└───────────────┬─────────────────────────────┘
                │ HTTP calls
                ▼
┌─────────────────────────────────────────────┐
│  Baileys Bot Manager on Railway/Render      │
│  - Node.js long-running process             │
│  - Baileys multi-tenant instances           │
│  - WebSocket connections to WhatsApp        │
│  - HTTP server for T3 app to call           │
│    (start/stop bot, send message, etc.)     │
└───────────────┬─────────────────────────────┘
                │ Direct queries
                ▼
┌─────────────────────────────────────────────┐
│  PostgreSQL (shared by both)                │
│  - Railway managed DB                       │
└─────────────────────────────────────────────┘
```

T3 app call Baileys service via HTTP:
```typescript
// T3 tRPC procedure
export const botRouter = router({
  getQRCode: protectedProcedure
    .input(z.object({ tenantId: z.string() }))
    .query(async ({ input }) => {
      // Call external Baileys service
      const response = await fetch(
        `${env.BAILEYS_SERVICE_URL}/bot/qr`,
        {
          method: 'POST',
          headers: { 'X-API-Key': env.BAILEYS_API_KEY },
          body: JSON.stringify({ tenantId: input.tenantId })
        }
      );
      return response.json();
    })
});
```

**Option B: Full Railway Deployment**
- Deploy entire T3 app di Railway (bukan Vercel)
- Railway support long-running Node.js processes
- Lose: Vercel edge network, preview deployments
- Gain: Baileys co-located dengan T3 app

**2. Next.js Bundle Size** (Minor Issue)
- Next.js + React lebih berat dari Astro (static/SSR)
- Dashboard page load: ~200-300KB JS (Next.js) vs ~50KB (Astro minimal JS)
- Mitigasi: Next.js App Router Server Components reduce client JS

**3. Learning Curve** (Minor Issue)
- tRPC paradigm berbeda dari REST (butuh adaptasi)
- Next.js App Router baru (vs Pages Router yang lebih established)
- Tapi: documentation T3 stack sangat baik, community active

**4. Vendor Lock-in ke Vercel Ecosystem** (Minor Issue)
- T3 stack optimized untuk Vercel deployment
- Kalau mau migrate dari Vercel → Render/Railway, effort lebih tinggi
- Astro + Express lebih "portable" (bisa deploy anywhere)

---

## Decision

### Recommendation: **Use T3 Stack (Hybrid Architecture)**

**Architecture**:
1. **T3 Stack (Next.js + tRPC + Prisma + NextAuth) on Vercel**:
   - Dashboard UI (customer-facing)
   - tRPC API untuk keyword CRUD, message history, broadcast management
   - NextAuth untuk customer login/session
   - Prisma untuk DB queries (tenants, keywords, messages)

2. **Baileys Bot Manager (Standalone Node.js Service) on Railway**:
   - Long-running process untuk maintain WebSocket connections
   - Expose HTTP API untuk T3 app to call (start bot, send message, get QR)
   - Direct PostgreSQL access (same DB as T3 app)

3. **PostgreSQL on Railway** (shared by both services)

**Why This Hybrid Approach?**
- ✅ Get T3 Stack benefits (type safety, DX, NextAuth, deployment simplicity)
- ✅ Solve Baileys long-running limitation (Railway handles bot processes)
- ✅ Clean separation: UI/API logic (T3) vs Bot engine (Baileys service)
- ✅ Scalable: Baileys service can scale independently (multiple Railway instances jika perlu)

---

## Implementation Plan (Revised from PRD v2.1)

### Project Structure

```
whatsapp-bot-platform/
├── apps/
│   ├── web/                    # T3 Stack (Next.js + tRPC + Prisma + NextAuth)
│   │   ├── src/
│   │   │   ├── app/           # Next.js App Router pages
│   │   │   │   ├── (auth)/
│   │   │   │   │   └── login/
│   │   │   │   └── dashboard/
│   │   │   │       ├── page.tsx
│   │   │   │       ├── keywords/
│   │   │   │       ├── messages/
│   │   │   │       └── broadcast/
│   │   │   ├── server/        # tRPC routers + Prisma queries
│   │   │   │   ├── api/
│   │   │   │   │   ├── routers/
│   │   │   │   │   │   ├── keyword.ts
│   │   │   │   │   │   ├── bot.ts
│   │   │   │   │   │   ├── message.ts
│   │   │   │   │   │   └── broadcast.ts
│   │   │   │   │   └── trpc.ts
│   │   │   │   └── auth.ts    # NextAuth config
│   │   │   ├── components/    # React components
│   │   │   └── lib/
│   │   │       └── baileys-client.ts  # HTTP client to call Baileys service
│   │   ├── prisma/
│   │   │   └── schema.prisma  # Shared DB schema
│   │   └── package.json
│   │
│   └── baileys-service/       # Standalone Node.js Baileys bot manager
│       ├── src/
│       │   ├── index.ts       # Express HTTP server
│       │   ├── BotManager.ts  # Baileys multi-tenant manager
│       │   └── routes/
│       │       ├── bot.ts     # POST /bot/start, /bot/qr, /bot/send
│       │       └── health.ts  # GET /health
│       ├── Dockerfile
│       └── package.json
│
├── packages/
│   └── database/              # Shared Prisma schema (monorepo)
│       └── prisma/
│           └── schema.prisma
│
├── docker-compose.yml         # Localhost: PostgreSQL + Baileys service
├── turbo.json                 # Turborepo config (optional, for monorepo build)
└── package.json               # Root workspace
```

### Tech Stack (Final)

| Layer | Technology | Deployment |
|-------|-----------|------------|
| **Frontend UI** | Next.js 14 (App Router) + React 18 + Tailwind | Vercel |
| **API Layer** | tRPC v10 (typesafe RPC) | Vercel (API routes) |
| **Auth** | NextAuth.js v4 (JWT + DB sessions) | Vercel |
| **ORM** | Prisma v5 (PostgreSQL) | - |
| **Database** | PostgreSQL 15 | Railway |
| **Bot Engine** | Baileys v6 (multi-session) | Railway |
| **Bot API** | Express.js (HTTP server) | Railway |

### Localhost Development

```bash
# Install T3 Stack
npx create-t3-app@latest apps/web
# Select: Next.js, TypeScript, Prisma, NextAuth, Tailwind, tRPC

# Setup Baileys service
cd apps/baileys-service
npm init -y
npm install baileys @prisma/client express dotenv

# Start PostgreSQL + Baileys service
docker-compose up -d

# Start T3 app (dev mode)
cd apps/web
npm run dev
# Open http://localhost:3000

# Prisma migrate
npx prisma migrate dev

# Login → dashboard → scan QR code (calls Baileys service via tRPC)
```

---

## Consequences

### Positive

1. **Type Safety End-to-End** — zero runtime type errors antara frontend-backend-database
2. **Better DX** — auto-complete, compile-time checks, hot reload
3. **NextAuth Built-in** — no manual JWT implementation
4. **Single Deployment** for UI+API (Vercel) — simpler than separate Vercel + Railway
5. **Scalable Architecture** — Baileys service can scale independently
6. **Community Support** — T3 Stack community besar, banyak resources

### Negative

1. **Hybrid Complexity** — 2 deployment targets (Vercel + Railway) vs 1 monolith
2. **Network Latency** — T3 app → Baileys service (HTTP call overhead ~50-200ms)
3. **Learning Curve** — tRPC + Next.js App Router baru (but well-documented)
4. **Cost** — Railway $5-20/month untuk Baileys service (tapi PostgreSQL bisa shared)

### Neutral

- T3 stack opinionated (good: best practices, bad: less flexibility)
- Deployment masih butuh Railway untuk Baileys (tidak bisa pure Vercel)

---

## Alternatives Considered

### Alternative 1: Stick to Original Stack (Astro + Express)
- **Pros**: Simpler (no tRPC/Next.js learning curve), lebih portable
- **Cons**: No end-to-end type safety, manual auth implementation, manual API typing
- **Verdict**: ❌ Rejected — type safety benefit terlalu besar untuk skip

### Alternative 2: Pure Next.js (no tRPC, use REST)
- **Pros**: Familiar REST paradigm, no tRPC learning curve
- **Cons**: Lose type safety benefit (main selling point T3 stack)
- **Verdict**: ❌ Rejected — kalau pakai Next.js, harus pakai tRPC untuk full benefit

### Alternative 3: Full Railway Deployment (T3 + Baileys co-located)
- **Pros**: Baileys co-located dengan T3 app (no network latency)
- **Cons**: Lose Vercel edge network, preview deployments, Vercel DX
- **Verdict**: ⚠️ Deferred — consider kalau Vercel→Railway HTTP latency jadi bottleneck

---

## Migration Path from PRD v2.1 Original Stack

PRD v2.1 already designed multi-tenant architecture — database schema unchanged.

**Changes needed**:
1. Replace Express REST → tRPC procedures
2. Replace Astro pages → Next.js App Router pages
3. Replace JWT manual → NextAuth.js
4. Add Baileys service HTTP client wrapper (`baileys-client.ts`)

**Estimated effort**: +1 minggu untuk setup T3 stack + tRPC conversion (total 9 minggu dari 8 minggu original)

---

## Re-evaluate Triggers

Re-evaluate tech stack kalau:
1. **Network latency Vercel→Railway >500ms** (user experience degraded)
2. **tRPC ecosystem bermasalah** (breaking changes, abandoned)
3. **Next.js App Router belum stable** (production bugs)
4. **Biaya Railway >Rp500rb/bulan** untuk 10-20 customers (cost too high)

---

## Final Recommendation

✅ **Adopt T3 Stack (Hybrid Architecture)** untuk PRD v2.1

**Next Steps**:
1. `npx create-t3-app@latest` untuk bootstrap project
2. Setup `baileys-service/` standalone (Docker Compose untuk localhost)
3. Implement 1 tRPC procedure (`bot.getQRCode`) → call Baileys service
4. Test QR pairing flow end-to-end

**Timeline Update**: 9 minggu (dari 8 minggu) karena T3 setup + tRPC conversion.

