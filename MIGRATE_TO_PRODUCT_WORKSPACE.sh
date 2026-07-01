#!/bin/bash

# Script untuk copy dokumentasi ke workspace product baru
# Usage: bash MIGRATE_TO_PRODUCT_WORKSPACE.sh /path/to/new/workspace

set -e

if [ -z "$1" ]; then
  echo "❌ Error: Target workspace path required"
  echo "Usage: bash MIGRATE_TO_PRODUCT_WORKSPACE.sh /path/to/whatsapp-bot-platform"
  exit 1
fi

TARGET_DIR="$1"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         📦 Migrating Documentation to Product Workspace        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Create target directory structure
echo "📁 Creating directory structure..."
mkdir -p "$TARGET_DIR/docs/adr"
mkdir -p "$TARGET_DIR/docs/prd"

# Copy critical ADR
echo "📄 Copying ADR-0006 (Tech Stack)..."
cp docs/adr/0006-tech-stack-evaluation-t3-vs-custom.md "$TARGET_DIR/docs/adr/"

# Copy PRD v2.1
echo "📄 Copying PRD v2.1 (Multi-tenant platform)..."
cp docs/prd/v2.1-multi-tenant-whatsapp-platform.md "$TARGET_DIR/docs/prd/"

# Copy Implementation Roadmap
echo "📄 Copying Implementation Roadmap..."
cp IMPLEMENTATION_ROADMAP.md "$TARGET_DIR/"

# Optional: Copy GA4 ADR
read -p "❓ Copy ADR-0002 (GA4 analytics)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  cp docs/adr/0002-ga4-only-no-meta-pixel.md "$TARGET_DIR/docs/adr/"
  echo "✅ ADR-0002 copied"
fi

# Create new README for product workspace
echo "📄 Creating product-specific README.md..."
cat > "$TARGET_DIR/README.md" << 'README_EOF'
# WhatsApp Bot Multi-Tenant Platform

Multi-tenant SaaS platform untuk bot WhatsApp dengan dashboard customer self-service.

## 🏗️ Tech Stack

- **Frontend**: Next.js 14 + tRPC + NextAuth + Tailwind (Vercel)
- **Backend**: Node.js + Express + Baileys v6 (Railway)
- **Database**: PostgreSQL 15 + Prisma ORM (Railway)

## 📚 Documentation

- [ADR-0006: Tech Stack Evaluation](docs/adr/0006-tech-stack-evaluation-t3-vs-custom.md)
- [PRD v2.1: Multi-Tenant Platform](docs/prd/v2.1-multi-tenant-whatsapp-platform.md)
- [Implementation Roadmap](IMPLEMENTATION_ROADMAP.md)

## 🚀 Quick Start

```bash
# Bootstrap T3 app
npx create-t3-app@latest apps/web

# Setup Baileys service
mkdir -p apps/baileys-service/src

# Start development
docker-compose up -d
cd apps/web && npm run dev
```

## 📦 Project Structure

```
whatsapp-bot-platform/
├── apps/
│   ├── web/              # T3 Stack (Next.js + tRPC)
│   └── baileys-service/  # Baileys bot manager
├── docs/
│   ├── adr/             # Architecture decisions
│   └── prd/             # Product requirements
├── docker-compose.yml
└── README.md
```

## 🎯 Development Timeline

See [IMPLEMENTATION_ROADMAP.md](IMPLEMENTATION_ROADMAP.md) for 9-week development plan.

## 📞 Related Repos

- Landing Page: https://github.com/hasbiallah/landing-page
README_EOF

echo "✅ README.md created"

# Create CONTEXT.md for product workspace
echo "📄 Creating product-specific CONTEXT.md..."
cat > "$TARGET_DIR/CONTEXT.md" << 'CONTEXT_EOF'
# WhatsApp Bot Platform Context

Platform multi-tenant untuk bot WhatsApp dengan customer self-service dashboard.

## Language

**Tenant**:
Customer yang berlangganan platform (1 tenant = 1 bisnis UMKM). Setiap tenant punya bot WhatsApp sendiri yang terisolasi dari tenant lain.
_Avoid_: user, client, subscriber

**Bot Instance**:
Satu koneksi WhatsApp Web yang aktif untuk satu tenant. Setiap tenant hanya bisa punya 1 bot instance aktif.
_Avoid_: session, connection, agent

**Keyword**:
Trigger word yang di-match untuk auto-reply. Case-insensitive, support multiple trigger words per keyword rule.
_Avoid_: command, message template, response rule

**Package Type**:
Tingkatan layanan tenant: "hemat" (5 keywords), "fyp" (20 keywords), "cuan" (unlimited).
_Avoid_: plan, tier, subscription level

**Multi-Tenant Isolation**:
Setiap query database HARUS filter by `tenant_id`. Zero tolerance untuk cross-tenant data leak.
_Avoid_: shared data, global scope

**Baileys**:
Library WhatsApp Web API (unofficial) yang dipakai untuk bot engine. Butuh long-running process (tidak bisa serverless).
_Avoid_: whatsapp-web.js, WA API, WhatsApp Business API

**T3 Stack**:
Next.js + tRPC + Prisma + NextAuth + Tailwind. End-to-end type safety dari database ke UI.
_Avoid_: custom stack, REST API, separate backend

**Hybrid Architecture**:
T3 app di Vercel (frontend + tRPC API) + Baileys service di Railway (long-running bot process). Keduanya share 1 PostgreSQL database.
_Avoid_: monolith, microservices, separate databases
CONTEXT_EOF

echo "✅ CONTEXT.md created"

# Create .gitignore
echo "📄 Creating .gitignore..."
cat > "$TARGET_DIR/.gitignore" << 'GITIGNORE_EOF'
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/

# Next.js
.next/
out/
build/
dist/

# Vercel
.vercel

# Environment
.env
.env*.local

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# OS
.DS_Store
*.pem

# IDE
.idea/
.vscode/
*.swp
*.swo

# Prisma
prisma/migrations/
*.db
*.db-journal

# Docker
.dockerignore

# Misc
.turbo
GITIGNORE_EOF

echo "✅ .gitignore created"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                     ✅ MIGRATION COMPLETE                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Files copied to: $TARGET_DIR"
echo ""
echo "✅ Mandatory files:"
echo "   • docs/adr/0006-tech-stack-evaluation-t3-vs-custom.md"
echo "   • docs/prd/v2.1-multi-tenant-whatsapp-platform.md"
echo "   • IMPLEMENTATION_ROADMAP.md"
echo ""
echo "✅ New files created:"
echo "   • README.md (product-specific)"
echo "   • CONTEXT.md (product vocabulary)"
echo "   • .gitignore (Node.js + Next.js)"
echo ""
echo "🚀 Next steps:"
echo "   1. cd $TARGET_DIR"
echo "   2. git init"
echo "   3. npx create-t3-app@latest apps/web"
echo "   4. Follow IMPLEMENTATION_ROADMAP.md Week 1 tasks"
echo ""
