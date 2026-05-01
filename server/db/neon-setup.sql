-- ============================================================
-- TD Africa — Data Team Task Manager
-- Neon Setup Script — paste this entire file into the
-- Neon SQL Editor and click Run.
-- ============================================================


-- ── USERS ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id            SERIAL PRIMARY KEY,
  initials      VARCHAR(4)   NOT NULL UNIQUE,
  name          VARCHAR(120) NOT NULL,
  email         VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role          VARCHAR(20)  NOT NULL DEFAULT 'member',
  job_title     VARCHAR(120),
  status        VARCHAR(40)  DEFAULT 'Online',
  avatar_url    TEXT,
  created_at    TIMESTAMPTZ  DEFAULT NOW()
);


-- ── PROJECTS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS projects (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(160) NOT NULL,
  type        VARCHAR(80),
  status      VARCHAR(40)  DEFAULT 'planning',
  progress    INTEGER      DEFAULT 0,
  color       VARCHAR(20)  DEFAULT '#0E8C88',
  start_date  VARCHAR(40),
  due_date    VARCHAR(40),
  created_by  INTEGER REFERENCES users(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ  DEFAULT NOW()
);


-- ── PROJECT MEMBERS ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS project_members (
  project_id  INTEGER REFERENCES projects(id) ON DELETE CASCADE,
  user_id     INTEGER REFERENCES users(id)    ON DELETE CASCADE,
  PRIMARY KEY (project_id, user_id)
);


-- ── PROJECT TAGS ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS project_tags (
  id         SERIAL PRIMARY KEY,
  project_id INTEGER REFERENCES projects(id) ON DELETE CASCADE,
  tag        VARCHAR(60) NOT NULL
);


-- ── TASKS ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tasks (
  id          SERIAL PRIMARY KEY,
  title       VARCHAR(200) NOT NULL,
  description TEXT,
  status      VARCHAR(40)  DEFAULT 'backlog',
  priority    VARCHAR(10)  DEFAULT 'm',
  dept        VARCHAR(10)  DEFAULT 'bu',
  due_date    VARCHAR(40),
  assignee_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  project_id  INTEGER REFERENCES projects(id),
  created_by  INTEGER REFERENCES users(id) ON DELETE SET NULL,
  created_at  TIMESTAMPTZ  DEFAULT NOW()
);


-- ── TASK COLLABORATORS ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS task_collaborators (
  task_id  INTEGER REFERENCES tasks(id) ON DELETE CASCADE,
  user_id  INTEGER REFERENCES users(id) ON DELETE CASCADE,
  PRIMARY KEY (task_id, user_id)
);


-- ── TASK COMMENTS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS task_comments (
  id         SERIAL PRIMARY KEY,
  task_id    INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content    TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ── TASK ACTIVITY LOG ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS task_activity (
  id         SERIAL PRIMARY KEY,
  task_id    INTEGER NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  user_id    INTEGER      REFERENCES users(id) ON DELETE SET NULL,
  action     VARCHAR(50) NOT NULL,
  detail     TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_task_comments_task ON task_comments(task_id);
CREATE INDEX IF NOT EXISTS idx_task_activity_task ON task_activity(task_id);


-- ── CHAT MESSAGES ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS chat_messages (
  id         SERIAL PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content    TEXT    NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ── NOTIFICATIONS ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
  id         SERIAL PRIMARY KEY,
  user_id    INTEGER REFERENCES users(id) ON DELETE CASCADE,
  message    TEXT NOT NULL,
  is_read    BOOLEAN     DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ── PASSWORD RESET TOKENS ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id         SERIAL PRIMARY KEY,
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token      VARCHAR(64) NOT NULL UNIQUE,
  expires_at TIMESTAMPTZ NOT NULL,
  used       BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);


-- ── CHAT READ RECEIPTS ────────────────────────────────────────
-- Tracks the last message each user has read — used to show
-- "Seen" indicators and unread counts in the team chat.
CREATE TABLE IF NOT EXISTS chat_last_read (
  user_id    INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  message_id INTEGER,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);


-- ============================================================
-- SEED DATA
-- All passwords are 'password123' — change after first login
-- ============================================================

INSERT INTO users (initials, name, email, password_hash, role, job_title, status) VALUES
  ('SO', 'Samuel Oluwadamilola Oyeniran',  'samuel@tdafrica.com',    '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member', 'Data Team Lead',  'Online'),
  ('TG', 'Oloruntoba Toluwalase Gabriel',  'toluwalase@tdafrica.com','$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member', 'Data Analyst',    'Online'),
  ('SA', 'Sharon Oluwapelumi Adedeji',     'sharon@tdafrica.com',    '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member', 'Data Analyst',    'Online'),
  ('JA', 'Olusola John Abodunrin',         'john@tdafrica.com',      '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member', 'Data Analyst',    'Online'),
  ('DO', 'Deborah Ilashe Ogunmola',        'deborah@tdafrica.com',   '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member', 'Data Analyst',    'Online'),
  ('DT', 'Data Team',                      'datateam@tdafrica.com',  '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin',  'Administrator',   'Online')
ON CONFLICT DO NOTHING;


-- No demo data — database starts clean.
