# Setup - Score & Tasks

## 1. Create a Supabase Project

Create a Supabase account and project at:

https://supabase.com

---

## 2. Apply Edge Functions

Apply the required Edge Functions inside your Supabase Dashboard:

**Dashboard → Edge Functions**

Only apply the functions you need:

- Delivery only → Apply Delivery
- ReportTerminal only → Apply ReportTerminal
- Both → Apply both

Quick links:

- [Delivery Edge Function](Delivery/edge-function.js)
- [ReportTerminal Edge Function](ReportTerminal/edge-function.js)

---

## 3. Apply Database Migrations

Open the Supabase SQL Editor and apply the required migrations.

**Do not apply `security.sql` yet.**

Only apply the migrations you need:

- Delivery only → Apply Delivery migration
- ReportTerminal only → Apply ReportTerminal migration
- Both → Apply both migrations

Quick links:

- [Delivery Migration](Delivery/migration.sql)
- [ReportTerminal Migration](ReportTerminal/migration.sql)

---

## 4. Apply Security Policies

Apply:

[security.sql](./security.sql)

inside the Supabase SQL Editor.

---

## 5. Configure Supabase Keys

Get your Supabase project URL and anon key from:

**Supabase Dashboard → Project Settings → API**

Add them to all required scripts.

You can edit these using a code editor or directly inside SCP: Roleplay.

---

## 6. Configure Interaction Parts

Load `props2` and find an interaction part.

Duplicate the part and rename it depending on which system you are setting up.

### Delivery

Start:

```text
DeliveryStart
