# School ERP System

A modern, low-cost ERP system for educational institutions built with Next.js and Supabase.

## 🚀 Quick Start

### 1. Complete Supabase Setup (7 minutes)

**⚡ Quick Setup**: Follow [SETUP-INSTRUCTIONS.md](./SETUP-INSTRUCTIONS.md) for a 3-step guide

**📚 Detailed Guide**: See [MIGRATION.md](./MIGRATION.md) for complete documentation

Quick summary:
1. Create a Supabase project at https://app.supabase.com
2. Update `src/supabase/config.ts` with your credentials
3. Run the SQL commands to create tables and enable RLS

### 2. Install Dependencies

```bash
npm install
```

### 3. Run Development Server

```bash
npm run dev
```

Open [http://localhost:9002](http://localhost:9002) in your browser.

## 📝 Default Login Credentials

The system automatically creates two default users:
- **Admin**: userId: `admin`, password: `password`
- **Finance**: userId: `finance`, password: `password`

## 📚 Documentation

- **Migration Guide**: See [MIGRATION.md](./MIGRATION.md) for complete setup instructions
- **Supabase Dashboard**: https://app.supabase.com

## 🏗️ Tech Stack

- **Frontend**: Next.js 15, React 18, TypeScript
- **Database**: Supabase (PostgreSQL)
- **UI**: Radix UI, Tailwind CSS
- **Forms**: React Hook Form, Zod
- **Charts**: Recharts
