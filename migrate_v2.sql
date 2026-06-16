-- DQE v2 Migration: Add task management fields
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS deadline TIMESTAMPTZ;
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS assignee TEXT DEFAULT 'DQE';
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS risk_status TEXT DEFAULT 'green';
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS risk_note TEXT DEFAULT '';
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS waiting_status BOOLEAN DEFAULT false;
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS waiting_for TEXT DEFAULT '';
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS waiting_since TIMESTAMPTZ;
