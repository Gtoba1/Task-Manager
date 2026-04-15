# CLAUDE.md — TD Africa Data Team Dashboard
## Complete project reference for AI-assisted development

This file gives any future Claude session full context about this project — what was built,
why decisions were made, and how to replicate or extend it. Read this before touching any code.

---

## What this app is

An internal task and project management dashboard built specifically for the **TD Africa Data Team**.
It replaces spreadsheets and WhatsApp threads with a single place to manage projects, assign tasks,
track progress, collaborate via comments, and chat as a team — all in real time.

**Live users:** datateam@tdafrica.com (admin), Samuel Ogundele (SO), Tobi Gbadamosi (TG),
Samuel Adeyemi (SA), Jumoke Adeyemi (JA), Dotun Olawale (DO).

**Brand colours:** Burgundy `#8B1A2B`, Charcoal `#363435`, Gray `#848688`

---

## Tech stack

| Layer | Technology | Notes |
|---|---|---|
| Frontend | React 18 + Vite | Single JSX file (`index.jsx`) + small component files in `src/` |
| Styling | Inline styles only | No CSS files, no Tailwind — all styles are JS objects |
| Icons | lucide-react | |
| Charts | recharts | Used in the Analytics view |
| HTTP client | axios | Centralised in `src/api.js` |
| Real-time | socket.io-client | Chat + desktop notifications |
| Backend | Express (Node.js) | CommonJS (`require`/`module.exports`) — not ES modules |
| Real-time server | socket.io | Runs on the same port as Express via `http.createServer` |
| Auth | JWT (jsonwebtoken) | 7-day tokens stored in localStorage |
| Password hashing | bcrypt (cost 10) | |
| Database | PostgreSQL | Accessed via `pg` connection pool |
| File uploads | multer | Avatar photos saved to `server/public/uploads/avatars/` |
| Security | helmet + express-rate-limit | Headers hardened; login limited to 10/15 min per IP |

---

## Project structure

```
Data Team Task Manager/
├── CLAUDE.md                   ← This file
├── .gitignore                  ← Excludes .env, node_modules, dist, uploads
├── package.json                ← Frontend deps (React, Vite, axios, socket.io-client, recharts)
├── vite.config.js              ← Dev proxy: /api + /uploads → localhost:3001; input: app.html
├── app.html                    ← HTML entry point (not index.html)
├── main.jsx                    ← React root: Auth check → Login / App / ResetPasswordPage
├── index.jsx                   ← Main dashboard (~1300+ lines): all views, state, components
│
├── src/
│   ├── api.js                  ← All axios calls — single source of truth for backend comms
│   ├── AuthContext.jsx         ← useAuth() hook: login, logout, user state, JWT storage
│   ├── SocketContext.jsx       ← useSocket() hook + showDesktopNotification() helper
│   ├── Login.jsx               ← Login form + Forgot password form (two screens, one component)
│   └── ResetPasswordPage.jsx   ← Shown when URL has ?reset_token=xxx
│
└── server/
    ├── index.js                ← Express entry point: middleware, routes, Socket.io, static serving
    ├── .env                    ← Secrets — NEVER commit (gitignored)
    ├── .env.example            ← Safe template — commit this
    ├── package.json            ← Server deps (express, pg, bcrypt, jwt, multer, helmet, etc.)
    │
    ├── controllers/
    │   ├── authController.js       ← login, getMe, forgotPassword, resetPassword
    │   ├── userController.js       ← getUsers, createUser, updateUser, updateUserRole, deleteUser, uploadAvatar
    │   ├── taskController.js       ← CRUD tasks + status updates (logs activity on status change)
    │   ├── projectController.js    ← CRUD projects
    │   ├── commentController.js    ← getComments, addComment, deleteComment + logActivity() utility
    │   └── notificationController.js ← getNotifications, markAllRead
    │
    ├── routes/
    │   ├── auth.js             ← POST /login, GET /me, POST /forgot-password, POST /reset-password
    │   ├── users.js            ← GET+POST /, GET+PUT+DELETE /:id, PATCH /:id/role, PATCH /:id/avatar
    │   ├── tasks.js            ← CRUD /tasks + /:id/status + /:id/comments + /:id/comments/:cid
    │   ├── projects.js         ← CRUD /projects
    │   └── notifications.js    ← GET /, PATCH /read-all
    │
    ├── middleware/
    │   ├── auth.js             ← requireAuth middleware — verifies JWT Bearer token
    │   └── upload.js           ← multer config: avatars only, 3 MB max, jpeg/png/gif/webp
    │
    └── db/
        ├── pool.js             ← Shared pg.Pool instance (all controllers import this)
        ├── setup-admin.js      ← One-time script: creates admin account + password_reset_tokens table
        └── reset-passwords.js  ← Utility script for manual password resets if needed
```

---

## Database schema

All tables are in the default `taskmanager` PostgreSQL database.

```sql
-- Core users table
users (
  id            SERIAL PRIMARY KEY,
  initials      VARCHAR(3)  UNIQUE NOT NULL,   -- e.g. 'SO', 'DT'
  name          VARCHAR     NOT NULL,
  email         VARCHAR     UNIQUE NOT NULL,
  password_hash VARCHAR     NOT NULL,
  role          VARCHAR     DEFAULT 'member',  -- 'admin' | 'member'
  job_title     VARCHAR,
  status        VARCHAR     DEFAULT 'active',  -- 'active' | 'away' | 'busy'
  avatar_url    VARCHAR,                        -- e.g. /uploads/avatars/3-1710000000.jpg
  created_at    TIMESTAMPTZ DEFAULT NOW()
)

-- Projects
projects (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR   NOT NULL,
  description TEXT,
  status      VARCHAR   DEFAULT 'active',
  color       VARCHAR,                          -- hex colour for the project badge
  created_at  TIMESTAMPTZ DEFAULT NOW()
)

-- Tasks
tasks (
  id           SERIAL PRIMARY KEY,
  title        VARCHAR    NOT NULL,
  description  TEXT,
  status       VARCHAR    DEFAULT 'Backlog',   -- 'Backlog' | 'In Progress' | 'Review' | 'Done'
  priority     VARCHAR    DEFAULT 'Medium',    -- 'Low' | 'Medium' | 'High'
  project_id   INTEGER    REFERENCES projects(id) ON DELETE SET NULL,
  assignee_id  INTEGER    REFERENCES users(id) ON DELETE SET NULL,
  due_date     DATE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
)

-- Task comments (shown in the task detail panel)
task_comments (
  id         SERIAL PRIMARY KEY,
  task_id    INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content    TEXT    NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
)

-- Task activity log (auto-generated on status changes)
task_activity (
  id         SERIAL PRIMARY KEY,
  task_id    INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  action     VARCHAR NOT NULL,                 -- e.g. 'status_changed'
  detail     TEXT,                             -- e.g. 'Backlog → In Progress'
  created_at TIMESTAMPTZ DEFAULT NOW()
)

-- Team chat messages
chat_messages (
  id         SERIAL PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content    TEXT    NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
)

-- Notifications (in-app bell icon)
notifications (
  id         SERIAL PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title      VARCHAR NOT NULL,
  body       TEXT,
  read       BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
)

-- Password reset tokens (one-time use, 1-hour expiry)
password_reset_tokens (
  id         SERIAL PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token      VARCHAR(64) NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  used       BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
)
```

---

## Features

### Dashboard / Home
- Summary cards: tasks by status, overdue count, team members online
- Recent tasks list

### Task Board (Kanban)
- Four columns: Backlog → In Progress → Review → Done
- Drag-less — status changed via dropdown in the task detail panel
- Clicking any task opens a **detail panel** on the right with:
  - Task metadata (project, assignee, due date, priority)
  - **Comments** — any team member can post; own comments (and admin) can delete
  - **Activity log** — auto-generated entry every time status changes
  - Comments and activity are merged into a single timeline sorted by date

### Projects
- Create, edit, delete projects
- Each project has a name, description, colour badge, and status

### Team / Members
- View all team members, their role, job title, status (active/away/busy)
- Edit name, email, job title, status via modal
- Upload profile photo (JPEG/PNG/GIF/WebP, max 3 MB) — stored as `/uploads/avatars/filename`
- Photos appear in avatars everywhere in the app via module-level `AVATAR_URLS` map

### Analytics
- Charts using recharts: tasks by status, tasks by project, team workload
- Built with the recharts library

### Team Chat
- Team-wide room (no direct messages)
- Real-time via Socket.io — messages appear instantly for all connected users
- Own messages right-aligned (burgundy bubble), others left-aligned (gray)
- Date separators when the day changes
- Loads last 50 messages on open (chat history)
- Unread badge on the sidebar chat icon when a message arrives and user isn't on chat view

### Desktop Notifications
- Browser Web Notifications API
- Permission requested once on first login; browser remembers it
- Fires when a `notify:receive` socket event arrives (e.g. task assigned, new chat message while not on chat view)
- Auto-closes after 5 seconds; clicking it focuses the browser tab

### Admin Panel (admin role only)
- Stats overview cards
- User management table: promote/demote role, reset password, delete user
- Create new team members with name, email, password, job title, role
- **Reset Password modal** — admin can set a new password for any user without knowing old one

### Forgot Password
- User enters email on login page → server logs a one-time reset link to the Terminal
- Admin copies the link and sends it to the user (via Teams, email, etc.)
- Link contains `?reset_token=xxx` — clicking it shows `ResetPasswordPage`
- Token is one-time use and expires after 1 hour
- SMTP config is available in `.env` (commented out) if you want to send emails automatically

### Authentication
- JWT tokens, 7-day expiry, stored in localStorage
- Auto-logout when token expires
- Protected routes: all pages require login; Admin Panel requires `role === 'admin'`

---

## Environment variables (`server/.env`)

```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=taskmanager
DB_USER=postgres
DB_PASSWORD=your_db_password

PORT=3001

# IMPORTANT: change this to your real domain in production
APP_URL=http://localhost:5173

# Generate with: node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"
JWT_SECRET=long_random_string_here
JWT_EXPIRES_IN=7d

# Optional — fill in to send real password reset emails
# SMTP_HOST=smtp.office365.com
# SMTP_PORT=587
# SMTP_USER=datateam@tdafrica.com
# SMTP_PASS=your_password
# SMTP_FROM=TD Africa Data Team <datateam@tdafrica.com>
```

---

## Running locally (development)

**Prerequisites:** Node.js 18+, PostgreSQL running, `taskmanager` database created with the schema above.

```bash
# Terminal 1 — backend
cd "Data Team Task Manager/server"
npm install
node db/setup-admin.js     # run ONCE on first setup
npm run dev                # nodemon starts on port 3001

# Terminal 2 — frontend
cd "Data Team Task Manager"
npm install
npm run dev                # Vite starts on port 5173
```

Open `http://localhost:5173/app.html`

Default admin login: `datateam@tdafrica.com` / `password123` — **change this immediately via Admin Panel**

---

## Deploying to production (Railway recommended)

Vercel does NOT work for this app — Socket.io requires persistent WebSocket connections
which Vercel's serverless model doesn't support.

**Railway** (railway.app) hosts both the Node.js server and PostgreSQL in one place.

```bash
# 1. Build the frontend
cd "Data Team Task Manager"
npm run build              # creates dist/ folder

# 2. Commit dist/ to git (or configure Railway build command)
# 3. In Railway: set environment variables from .env
#    - Set NODE_ENV=production
#    - Set APP_URL=https://yourdomain.railway.app
# 4. Railway start command: node server/index.js
```

In production mode (`NODE_ENV=production`), Express serves the built React app from `dist/`
automatically — only one process, one port.

**CORS and Socket.io** both read `APP_URL` from `.env` — update it to your live domain or
browsers will be blocked.

---

## Key architectural decisions

**Why one big `index.jsx`?**
All views, state, and components live in a single file for simplicity. The codebase is small
enough that splitting into many files would add navigation overhead without real benefit.
Module-level mutable maps (`MEMBER_NAMES`, `MEMBER_ROLES`, `AVATAR_URLS`) let every Avatar
component instance update automatically when data is loaded or changed.

**Why inline styles (no CSS files)?**
Keeps everything co-located. No class name collisions, no build-time CSS processing, easy
to read what a component looks like without jumping between files.

**Why CommonJS on the server?**
The frontend uses ES modules (Vite), but the server uses CommonJS `require`/`module.exports`
consistently throughout. Don't mix them — pick one per side and stick to it.

**Why Socket.io on the same port as Express?**
`http.createServer(app)` wraps Express in a plain Node HTTP server, then Socket.io attaches
to that. Both REST API and WebSocket live on port 3001 — no extra process needed.

**Password reset without email**
The app logs the reset link to the server Terminal. The admin copies it and sends it to the
user manually (Teams, email). SMTP config is available in `.env` to automate this when ready.

**Avatar storage**
Files saved to `server/public/uploads/avatars/`, served at `/uploads/avatars/filename`.
The Vite dev proxy forwards `/uploads` to the Express server. In production, Express serves
them directly. These files are gitignored — back them up separately in production.

---

## Replicating for another department (e.g. Marketing, Sales, Procurement)

This app is generic enough to reuse with minimal changes. Here's what to change:

### Step 1 — Fork the repo
Create a new GitHub repo: `marketing-team-dashboard`, copy this codebase in.

### Step 2 — Branding (5 minutes)
In `src/Login.jsx` and `index.jsx`:
- `COLORS.burg` — change the primary colour (e.g. `#1A4D8B` for blue)
- `LOGO_PATH` — update to the new team's logo
- The tagline in the Login left panel: "Your team's work, in one place."

### Step 3 — Team avatars on login screen
In `src/Login.jsx`:
```js
const TEAM = ['AB', 'CD', 'EF'];   // initials of the new team
const AVATAR_COLORS = {
  AB: { bg: '#E8EFF9', fg: '#3A6FD8' },
  // ...
};
```

### Step 4 — Database
Create a new PostgreSQL database (e.g. `marketing_taskmanager`) and run the same schema.
Update `server/.env` with the new DB name.

### Step 5 — Admin setup
Update `server/db/setup-admin.js`:
- Change `datateam@tdafrica.com` → `marketing@tdafrica.com`
- Change `'Data Team'` → `'Marketing Team'`
- Remove the Samuel demotion block (or update initials to match)
Run `node db/setup-admin.js` once.

### Step 6 — Deploy
Same Railway process as above, pointing to the new repo.

### What you do NOT need to change
- All the logic (tasks, projects, comments, chat, notifications, auth) works for any team
- The Admin Panel lets you create team members via UI — no code needed
- The database schema is team-agnostic

---

## Security measures in place

- **JWT secret**: 96-character hex string, never committed to git
- **Helmet**: HTTP security headers on every response (XSS protection, no sniffing, etc.)
- **Rate limiting**: Login endpoint limited to 10 attempts per 15 minutes per IP
- **CORS**: Locked to `APP_URL` env variable — blocks all other origins
- **Password minimum**: 8 characters, enforced on server and all client forms
- **SQL injection**: All queries use parameterised values (`$1`, `$2`, ...) via `pg` pool
- **Avatar uploads**: Only jpeg/png/gif/webp accepted, 3 MB limit, files served from `/uploads/`
- **Password reset tokens**: One-time use, 1-hour expiry, old tokens deleted on new request
- **`.gitignore`**: `.env`, `node_modules/`, `dist/`, `uploads/` all excluded

---

## Repo and project history

Built from scratch across two Claude Code sessions (April 2025).
This is the TD Africa internal tool — not open source.
Replicate for other departments by following the "Replicating" section above.
