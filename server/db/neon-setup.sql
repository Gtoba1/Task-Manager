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
  created_by  INTEGER REFERENCES users(id),
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
  assignee_id INTEGER REFERENCES users(id),
  project_id  INTEGER REFERENCES projects(id),
  created_by  INTEGER REFERENCES users(id),
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
  user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE SET NULL,
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


-- ============================================================
-- SEED DATA
-- All passwords are 'password123' — change after first login
-- ============================================================

INSERT INTO users (initials, name, email, password_hash, role, job_title, status) VALUES
  ('SO', 'Samuel Oluwadamilola Oyeniran',  'samuel@tdafrica.com',    '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member', 'Data Team Lead',  'Online'),
  ('TG', 'Oloruntoba Toluwalase Gabriel',  'toluwalase@tdafrica.com','$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member', 'Data Analyst',    'Online'),
  ('SA', 'Sharon Oluwapelumi Adedeji',     'sharon@tdafrica.com',    '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member', 'Data Analyst',    'Online'),
  ('JA', 'Olusola John Abodunrin',         'john@tdafrica.com',      '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member', 'Data Engineer',   'Online'),
  ('DO', 'Deborah Ilashe Ogunmola',        'deborah@tdafrica.com',   '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member', 'Data Analyst',    'Online'),
  ('DT', 'Data Team',                      'datateam@tdafrica.com',  '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin',  'Administrator',   'Online')
ON CONFLICT DO NOTHING;


INSERT INTO projects (name, type, status, progress, color, start_date, due_date, created_by) VALUES
  ('Data Migration',                          'Data Migration',      'active',   55, '#0E8C88', 'Mar 1',  'May 15', 1),
  ('Power BI Inventory Dashboard',            'Dashboard / Report',  'active',   78, '#3A6FD8', 'Mar 10', 'Mar 25', 1),
  ('Power BI Sales Dashboard',                'Dashboard / Report',  'active',   42, '#C88A18', 'Mar 5',  'Apr 10', 1),
  ('Power BI Customer Performance Dashboard', 'Dashboard / Report',  'planning', 10, '#D05A2A', 'Apr 1',  'May 20', 1),
  ('Weekly Snapshot',                         'ETL Pipeline',        'active',   90, '#7A50D0', 'Feb 15', 'Ongoing',1),
  ('Process Automation',                      'Process Automation',  'draft',     8, '#22A55A', 'Mar 18', 'May 30', 1)
ON CONFLICT DO NOTHING;


INSERT INTO project_members (project_id, user_id)
SELECT p.id, u.id FROM projects p, users u WHERE
  (p.name = 'Data Migration'                          AND u.initials IN ('SO','JA','SA')) OR
  (p.name = 'Power BI Inventory Dashboard'            AND u.initials IN ('TG','SA'))     OR
  (p.name = 'Power BI Sales Dashboard'                AND u.initials IN ('TG','DO'))     OR
  (p.name = 'Power BI Customer Performance Dashboard' AND u.initials IN ('SO','TG'))     OR
  (p.name = 'Weekly Snapshot'                         AND u.initials IN ('JA','DO'))     OR
  (p.name = 'Process Automation'                      AND u.initials IN ('JA','SO'))
ON CONFLICT DO NOTHING;


INSERT INTO project_tags (project_id, tag)
SELECT p.id, t.tag FROM projects p
JOIN (VALUES
  ('Data Migration',                          'BU'),
  ('Data Migration',                          'BG'),
  ('Data Migration',                          'ETL'),
  ('Data Migration',                          'SQL Server'),
  ('Power BI Inventory Dashboard',            'BU'),
  ('Power BI Inventory Dashboard',            'Power BI'),
  ('Power BI Inventory Dashboard',            'DAX'),
  ('Power BI Sales Dashboard',                'BU'),
  ('Power BI Sales Dashboard',                'Power BI'),
  ('Power BI Sales Dashboard',                'Sales Data'),
  ('Power BI Customer Performance Dashboard', 'BG'),
  ('Power BI Customer Performance Dashboard', 'Power BI'),
  ('Power BI Customer Performance Dashboard', 'CRM Data'),
  ('Weekly Snapshot',                         'BU'),
  ('Weekly Snapshot',                         'BG'),
  ('Weekly Snapshot',                         'Automated'),
  ('Weekly Snapshot',                         'SQL'),
  ('Process Automation',                      'BG'),
  ('Process Automation',                      'Python'),
  ('Process Automation',                      'Power Automate')
) AS t(proj_name, tag) ON p.name = t.proj_name;


INSERT INTO tasks (title, description, status, priority, dept, due_date, assignee_id, project_id)
SELECT t.title, t.description, t.status, t.pri, t.dept, t.due_date, u.id, p.id
FROM (VALUES
  ('Map legacy database schema for migration',    'Document all tables, relationships and data types in the legacy SQL Server database.', 'backlog',  'h', 'bu', 'Mar 28', 'JA', 'Data Migration'),
  ('Write ETL scripts for customer master data',  'Build Python ETL scripts to extract, transform and load customer master data.',        'backlog',  'm', 'bg', 'Apr 5',  'JA', 'Data Migration'),
  ('Define KPIs for Customer Performance Dashboard','Work with BG stakeholders to define key customer performance metrics.',              'backlog',  'm', 'bg', 'Apr 8',  'SO', 'Power BI Customer Performance Dashboard'),
  ('Set up Power Automate flow for weekly reports','Create Power Automate flow to generate and email weekly snapshot PDF.',              'backlog',  'l', 'bg', 'Apr 12', 'JA', 'Process Automation'),
  ('Build DAX measures for Inventory Dashboard',  'Create DAX measures for stock turnover rate, days of supply, reorder alerts.',        'progress', 'h', 'bu', 'Mar 25', 'TG', 'Power BI Inventory Dashboard'),
  ('Create data model for Sales Dashboard',       'Design star schema data model in Power BI. Link fact_sales to dimension tables.',     'progress', 'h', 'bu', 'Mar 30', 'TG', 'Power BI Sales Dashboard'),
  ('Validate migrated inventory records — Batch 1','Run validation queries on 15,000 migrated inventory records.',                      'progress', 'm', 'bu', 'Mar 29', 'SA', 'Data Migration'),
  ('Optimize Weekly Snapshot SQL queries',        'Current query takes 45s. Target: under 10s. Profile execution plan.',                'progress', 'm', 'bu', 'Apr 3',  'JA', 'Weekly Snapshot'),
  ('Clean and standardize customer address data', 'Standardize 8,400 customer address records. Normalize, deduplicate.',                'progress', 'm', 'bg', 'Mar 28', 'DO', 'Data Migration'),
  ('Review Inventory Dashboard — UAT sign-off',   'Conduct user acceptance testing with warehouse team.',                               'review',   'h', 'bu', 'Mar 25', 'SO', 'Power BI Inventory Dashboard'),
  ('QA data migration — financial records batch', 'Validate migrated financial records. Cross-check GL balances.',                      'review',   'h', 'bu', 'Mar 26', 'SA', 'Data Migration'),
  ('Weekly Snapshot report template — final review','Review the automated report template layout and chart formatting.',                'review',   'm', 'bg', 'Mar 27', 'DO', 'Weekly Snapshot'),
  ('Sales data source connection — test environment','Test DirectQuery connection to sales database in staging.',                       'review',   'm', 'bu', 'Mar 26', 'TG', 'Power BI Sales Dashboard'),
  ('Publish Weekly Snapshot v2.0 to Power BI Service','Publish updated snapshot report. Configure scheduled refresh.',                 'approved', 'm', 'bu', 'Mar 24', 'JA', 'Weekly Snapshot'),
  ('Data dictionary — inventory tables documentation','Complete data dictionary for all 12 inventory-related tables.',                 'approved', 'l', 'bu', 'Mar 23', 'SA', 'Data Migration'),
  ('Data Migration Phase 1 — product catalog complete','All 24,000 product catalog records successfully migrated. 99.8% accuracy.',    'done',     'h', 'bu', 'Mar 20', 'JA', 'Data Migration'),
  ('Weekly Snapshot v1.0 deployed',               'Initial weekly snapshot report deployed to production.',                            'done',     'l', 'bg', 'Mar 21', 'DO', 'Weekly Snapshot'),
  ('Historical sales data backfill — 2023-2024',  'Backfilled 2 years of historical sales data (142K records).',                      'done',     'l', 'bu', 'Mar 15', 'SA', 'Power BI Sales Dashboard')
) AS t(title, description, status, pri, dept, due_date, ass_initials, proj_name)
JOIN users u ON u.initials = t.ass_initials
JOIN projects p ON p.name = t.proj_name;


INSERT INTO notifications (user_id, message, is_read)
SELECT u.id, n.message, n.is_read FROM (VALUES
  ('Toluwalase completed Power BI Inventory Dashboard draft — ready for review.', FALSE),
  ('Sharon submitted Data Migration Phase 1 validation report. All checks passed.', FALSE),
  ('Deadline Tomorrow: Power BI Inventory Dashboard is due March 25.', FALSE),
  ('John completed Weekly Snapshot ETL pipeline — automated run successful.', TRUE),
  ('Deborah moved Customer Data Cleanup to Done. 4,200 records processed.', TRUE)
) AS n(message, is_read)
JOIN users u ON u.initials = 'SO'
ON CONFLICT DO NOTHING;
