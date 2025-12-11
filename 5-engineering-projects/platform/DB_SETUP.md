# Database Setup Guide

To get the backend working, you need a running PostgreSQL database.

## Option 1: Docker (Recommended for Local Dev)
If you have Docker installed, run:

```bash
docker run --name 5amclub-postgres -e POSTGRES_PASSWORD=mysecretpassword -e POSTGRES_DB=5amclub -p 5432:5432 -d postgres
```

Then update your `.env` file:
```env
DATABASE_URL="postgresql://postgres:mysecretpassword@localhost:5432/5amclub?schema=public"
```

## Option 2: Supabase / Neon (Cloud)
1. Create a free project on [Supabase](https://supabase.com) or [Neon](https://neon.tech).
2. Get the connection string (Transaction Mode for Supabase).
3. Update your `.env` file.

## After Setup
Run the migrations to create the tables:

```bash
npx prisma migrate dev --name init
```

## Running the App
```bash
npm run dev
```

