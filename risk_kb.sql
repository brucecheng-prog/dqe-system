-- ============================================================
-- DQE 风险预防知识库 - 建表脚本
-- 在 Supabase SQL Editor 中运行
-- ============================================================

-- 表1：历史失效与客诉库
CREATE TABLE IF NOT EXISTS failure_library (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_code TEXT,
  project_name TEXT,
  failure_stage TEXT NOT NULL CHECK (failure_stage IN ('G2设计验证','G3工程验证','G4试产导入','售后客诉')),
  risk_category TEXT NOT NULL CHECK (risk_category IN ('模具/结构','电子/功能控制','软件/固件','安规认证','包装/物流暴力跌落')),
  failure_desc TEXT NOT NULL,
  root_cause TEXT,
  report_path TEXT,
  report_name TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE failure_library ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on failure_library" ON failure_library FOR ALL USING (true) WITH CHECK (true);

-- 表2：FMEA 规则与知识库
CREATE TABLE IF NOT EXISTS fmea_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rule_code TEXT NOT NULL UNIQUE,
  knowledge_category TEXT NOT NULL CHECK (knowledge_category IN ('模具工艺','硬件功能设计','可靠性测试方案','合规与安规')),
  failure_mode TEXT NOT NULL,
  design_requirements TEXT,
  dqe_inspection TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE fmea_rules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on fmea_rules" ON fmea_rules FOR ALL USING (true) WITH CHECK (true);

-- 表3：阶段避坑 Checklist
CREATE TABLE IF NOT EXISTS avoidance_checklist (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_name TEXT NOT NULL,
  project_code TEXT,
  project_name TEXT,
  review_phase TEXT NOT NULL CHECK (review_phase IN ('G1','G2','G3','G4','G5')),
  rule_id UUID REFERENCES fmea_rules(id) ON DELETE SET NULL,
  review_conclusion TEXT DEFAULT 'N/A' CHECK (review_conclusion IN ('Pass','Fail','N/A')),
  remaining_risk TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE avoidance_checklist ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all on avoidance_checklist" ON avoidance_checklist FOR ALL USING (true) WITH CHECK (true);

-- 预置示例数据 (FMEA 规则)
INSERT INTO fmea_rules (rule_code, knowledge_category, failure_mode, design_requirements, dqe_inspection) VALUES
('FMEA-001','模具工艺','外壳注塑缩水/拉白','模具需增加2度拔模斜度，浇口位置需避开外观面，保压压力需≥80MPa','强制要求供应商提供DFM模流分析报告，试模时现场确认缩水等级≤V1'),
('FMEA-002','模具工艺','结构件装配干涉/间隙超标','Boss柱高度公差±0.05mm，卡扣弹性变形量≤0.3mm','首件需进行3D扫描对比，公差需在±0.1mm内'),
('FMEA-003','硬件功能设计','主板宽电压烧毁','电源输入端需增加TVS管+PPTC自恢复保险，耐压≥36V/2A','EVT阶段进行±30%电压波动测试，连续运行24h无异常'),
('FMEA-004','硬件功能设计','ESD静电击穿IC','信号接口需添加ESD保护器件(≥8KV接触/15KV空气)，PCB layout保留屏蔽罩焊盘','EVT阶段进行IEC 61000-4-2 ESD测试，每个测试点正负各10次'),
('FMEA-005','可靠性测试方案','跌落测试后内部焊点断裂','BGA/大尺寸QFN底部需填充underfill，连接器需点胶加固','DVT阶段进行1.5m 6面各2次跌落测试，跌落前后进行X-ray对比'),
('FMEA-006','可靠性测试方案','按键/接口寿命不足','按键需选用≥100万次寿命规格，USB-C接口需≥1万次插拔','DVT阶段抽样≥20pcs进行加速寿命测试，需达到宣称寿命×1.2'),
('FMEA-007','合规与安规','FCC/CE认证未通过','PCB layout需预留共模电感和Y电容位置，时钟线需包地处理','EVT阶段进行预扫EMC，辐射/传导裕量需≥6dB'),
('FMEA-008','合规与安规','ROHS/REACH不合规','所有物料需签核ROHS/REACH合规声明，高风险物料需提供第三方检测报告','DVT前完成所有物料ROHS/REACH合规证据收集，核验证书有效期')
ON CONFLICT (rule_code) DO UPDATE SET
  knowledge_category=EXCLUDED.knowledge_category,
  failure_mode=EXCLUDED.failure_mode,
  design_requirements=EXCLUDED.design_requirements,
  dqe_inspection=EXCLUDED.dqe_inspection,
  updated_at=now();

-- 预置示例数据 (失效库)
INSERT INTO failure_library (project_code, project_name, failure_stage, risk_category, failure_desc, root_cause) VALUES
('F1-251204Z','3018i雕刻机','售后客诉','模具/结构','客户反馈机器运行2个月后Y轴导轨松动，雕刻精度下降','导轨固定螺丝未使用螺纹胶，运输振动导致松动'),
('AE-LUO260227Z','一种便携式户外储能电源','G3工程验证','电子/功能控制','EVT测试中发现AC逆变输出在满载时电压下降超过10%','DC-DC升压电路电感饱和电流选型偏小，更换大电流电感后解决'),
('R1-YYD260301Z','智能音频眼镜2代','G4试产导入','包装/物流暴力跌落','ISTA 3A运输测试后镜腿铰链断裂','铰链处未设计防跌落缓冲结构，改为加装TPU缓冲垫')
ON CONFLICT DO NOTHING;

-- 预置示例数据 (避坑Checklist - 关联项目 D1-OFN260301Z)
INSERT INTO avoidance_checklist (task_name, project_code, project_name, review_phase, rule_id, review_conclusion, remaining_risk) 
SELECT '外壳模具评审', 'D1-OFN260301Z', '一种双面加热控温帽子烫印设备', 'G2', id, 'Pass', '保压压力需调至85MPa以上'
FROM fmea_rules WHERE rule_code='FMEA-001'
UNION ALL SELECT '装配公差检查', 'D1-OFN260301Z', '一种双面加热控温帽子烫印设备', 'G2', id, 'N/A', NULL
FROM fmea_rules WHERE rule_code='FMEA-002'
UNION ALL SELECT '宽电压测试', 'D1-OFN260301Z', '一种双面加热控温帽子烫印设备', 'G3', id, 'Pass', NULL
FROM fmea_rules WHERE rule_code='FMEA-003'
UNION ALL SELECT 'EMC预扫', 'D1-OFN260301Z', '一种双面加热控温帽子烫印设备', 'G3', id, 'Pass', '辐射裕量仅5dB，建议量产前优化'
FROM fmea_rules WHERE rule_code='FMEA-007';
