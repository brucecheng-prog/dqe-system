-- ============================================================
-- DQE 个人工作站 - 修复脚本
-- 请在 Supabase SQL Editor 中完整运行此脚本
-- https://supabase.com/dashboard/project/blmtgdldoqxqkjcpwexu/sql/new
-- ============================================================

-- 第一部分：gate_tracking (阶段追踪表) — 自动流转必须
CREATE TABLE IF NOT EXISTS gate_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  phase_key TEXT NOT NULL,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  planned_days INTEGER DEFAULT 7,
  UNIQUE(project_id, phase_key)
);

ALTER TABLE gate_tracking ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on gate_tracking" ON gate_tracking
  FOR ALL USING (true) WITH CHECK (true);

-- 第二部分：检查并补足 checklist_items 缺少的列
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS deadline TIMESTAMPTZ;
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS risk_status TEXT DEFAULT 'green';
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS risk_note TEXT DEFAULT '';
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS waiting_status BOOLEAN DEFAULT false;
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS waiting_for TEXT DEFAULT '';
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS waiting_since TIMESTAMPTZ;
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS task_role TEXT DEFAULT 'DQE';
ALTER TABLE checklist_items ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();

-- 第三部分：documents 表缺少的列
ALTER TABLE documents ADD COLUMN IF NOT EXISTS item_index INTEGER;
ALTER TABLE documents ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'uploaded';

-- 第四部分：创建 storage bucket (需要 service_role)
-- ⚠️ 如果 SQL 编辑器不支持 create bucket，请去 Storage 页面手动创建:
--   名称: dqe-documents
--   公开: ON
--   文件大小限制: 10MB
--   允许类型: pdf,doc,docx,xls,xlsx,png,jpg

-- 第五部分：Storage RLS 策略
-- (如果上面手动创建了 bucket，也需要执行下面的策略)

-- 允许公开读取
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname='Allow public read' AND tablename='objects') THEN
    CREATE POLICY "Allow public read" ON storage.objects
      FOR SELECT USING (bucket_id = 'dqe-documents');
  END IF;
END $$;

-- 允许上传
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname='Allow public upload' AND tablename='objects') THEN
    CREATE POLICY "Allow public upload" ON storage.objects
      FOR INSERT WITH CHECK (bucket_id = 'dqe-documents');
  END IF;
END $$;

-- 允许删除
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname='Allow public delete' AND tablename='objects') THEN
    CREATE POLICY "Allow public delete" ON storage.objects
      FOR DELETE USING (bucket_id = 'dqe-documents');
  END IF;
END $$;

-- ============================================================
-- 执行完成后，请验证：
-- 1. SELECT * FROM gate_tracking LIMIT 1; (应无错误)
-- 2. 在 Storage 页面确认 dqe-documents bucket 存在
-- 3. 刷新 DQE 个人工作站页面重新测试上传
-- ============================================================
