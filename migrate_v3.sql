-- v3 Migration: Gate tracking + template versions + project types
ALTER TABLE projects ADD COLUMN IF NOT EXISTS project_type TEXT DEFAULT 'default';
ALTER TABLE projects ADD COLUMN IF NOT EXISTS health_status TEXT DEFAULT 'green';

CREATE TABLE IF NOT EXISTS gate_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  phase_key TEXT NOT NULL,
  started_at TIMESTAMPTZ DEFAULT now(),
  completed_at TIMESTAMPTZ,
  planned_days INT NOT NULL,
  UNIQUE(project_id, phase_key)
);

CREATE TABLE IF NOT EXISTS template_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_key TEXT NOT NULL,
  version TEXT NOT NULL DEFAULT 'v1',
  filename TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE gate_tracking ENABLE ROW LEVEL SECURITY;
CREATE POLICY gp ON gate_tracking FOR ALL USING (true) WITH CHECK (true);

ALTER TABLE template_versions ENABLE ROW LEVEL SECURITY;
CREATE POLICY tp ON template_versions FOR ALL USING (true) WITH CHECK (true);
