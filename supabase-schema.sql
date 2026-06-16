-- ============================================================
-- DQE项目管理系统 - Supabase 数据库建表脚本
-- 在 Supabase SQL Editor 中运行此脚本
-- ============================================================

-- 1. 项目表
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  category TEXT,
  supplier TEXT,
  start_date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. 交付物检查清单 (按阶段/项目追踪)
CREATE TABLE IF NOT EXISTS checklist_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  phase_key TEXT NOT NULL,
  item_index INTEGER NOT NULL,
  completed BOOLEAN DEFAULT false,
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(project_id, phase_key, item_index)
);

-- 3. 文档/报告文件表
CREATE TABLE IF NOT EXISTS documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  phase_key TEXT NOT NULL,
  document_name TEXT NOT NULL,
  document_type TEXT NOT NULL, -- 'report', 'test', 'standard', 'review', 'certification'
  storage_path TEXT NOT NULL,  -- path in Supabase Storage bucket
  file_size INTEGER,
  file_mime TEXT,
  uploaded_at TIMESTAMPTZ DEFAULT now(),
  notes TEXT
);

-- 4. 评论/备注表 (用于协作、审核意见)
CREATE TABLE IF NOT EXISTS comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  phase_key TEXT,
  content TEXT NOT NULL,
  author TEXT DEFAULT 'DQE',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 行级安全策略 (RLS) - 允许匿名访问
-- 注意：仅用于内部工具，公网部署时建议开启认证
-- ============================================================

-- Projects
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all access on projects" ON projects
  FOR ALL USING (true) WITH CHECK (true);

-- Checklist items
ALTER TABLE checklist_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all access on checklist_items" ON checklist_items
  FOR ALL USING (true) WITH CHECK (true);

-- Documents
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all access on documents" ON documents
  FOR ALL USING (true) WITH CHECK (true);

-- Comments
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all access on comments" ON comments
  FOR ALL USING (true) WITH CHECK (true);

-- ============================================================
-- 索引 (优化查询)
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_checklist_project ON checklist_items(project_id);
CREATE INDEX IF NOT EXISTS idx_documents_project ON documents(project_id);
CREATE INDEX IF NOT EXISTS idx_comments_project ON comments(project_id);

-- ============================================================
-- 文件存储 Bucket
-- ⚠️ 这需要在 Supabase Dashboard → Storage 中手动创建
-- Bucket名称: dqe-documents
-- 公开访问: 开启
-- 文件大小限制: 10MB
-- 允许的文件类型: pdf,doc,docx,xls,xlsx,png,jpg,zip
-- ============================================================
-- Storage Policy SQL (在 Supabase Storage → Policies 中创建):
/*
-- 允许读取
CREATE POLICY "Allow public read" ON storage.objects
  FOR SELECT USING (bucket_id = 'dqe-documents');

-- 允许上传
CREATE POLICY "Allow public upload" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'dqe-documents');

-- 允许删除
CREATE POLICY "Allow public delete" ON storage.objects
  FOR DELETE USING (bucket_id = 'dqe-documents');
*/
