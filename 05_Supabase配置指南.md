# DQE管理系统 - Supabase 云端配置指南

> 预计耗时：10分钟 | 全部免费 | 数据不占本地空间

---

## 第一步：注册 Supabase 账号

1. 打开 https://supabase.com
2. 点击「Start your project」→ 用 GitHub 账号登录（推荐）
3. 进入 Dashboard

## 第二步：创建项目

1. 点击「New project」
2. 填写：
   - **Name**: `dqe-manager`（随意）
   - **Database Password**: 生成一个强密码并**记下来**
   - **Region**: 选 `Southeast Asia (Singapore)` 或 `Northeast Asia (Tokyo)`
3. 点击「Create new project」→ 等待1-2分钟创建完成

## 第三步：获取连接信息

创建完成后，进入项目 Dashboard：
- **Project URL**: 左侧能看到，格式 `https://xxxxx.supabase.co` — **复制保存**
- **Anon Key**: 左侧 Settings → API → `anon public` 密钥 — **复制保存**

> Anon Key 是公开密钥，内嵌在前端代码中是安全的。真机密数据应该用 Service Role Key（服务端）。

## 第四步：创建数据库表

1. 左侧菜单 → **SQL Editor**
2. 点击「New query」
3. 复制粘贴 `DQE/web-app/supabase-schema.sql` 文件的全部内容
4. 点击「Run」执行

## 第五步：创建文件存储

1. 左侧菜单 → **Storage**
2. 点击「New bucket」
3. 名称填 `dqe-documents`（**必须完全一致**）
4. 勾选「Public bucket」
5. 文件大小限制设为 `10MB`
6. 允许的文件类型：`pdf,doc,docx,xls,xlsx,csv,png,jpg,jpeg`
7. 创建

然后设置存储策略：
1. 在 `dqe-documents` bucket → 「Policies」
2. 分别创建3条策略：
   - **SELECT** → 名称 `Allow public read` → USING `true`
   - **INSERT** → 名称 `Allow public upload` → WITH CHECK `true`
   - **DELETE** → 名称 `Allow public delete` → USING `true`

## 第六步：连接系统

1. 打开 DQE 管理系统网页
2. 首次打开会弹出配置框
3. 填入 Project URL 和 Anon Key
4. 点击「连接」

搞定！之后所有数据自动存储到 Supabase 云端。

---

## 免费层额度

| 资源 | 免费额度 | 够用年限 |
|------|---------|---------|
| 数据库 | 500MB | 够存数万个项目 |
| 文件存储 | 1GB | 够存~500份报告 |
| API 调用 | 无限 | 随时可用 |
| 项目数 | 2个 | 够用 |

## 常见问题

**Q: 数据安全吗？**
A: Supabase 是开源平台，数据加密存储，全球有数十万开发者在用。虽然我们设置了公开访问策略（为方便），建议后续开启 Row Level Security 做更严格的权限管理。

**Q: 1GB不够了怎么办？**
A: 付费升级到 Pro（$25/月）就有 8GB。按你当前的报告量，1GB至少够用2-3年。

**Q: 换电脑怎么办？**
A: 所有数据在云端，打开网页输入相同 Supabase 配置，数据全在。

**Q: 能团队协作吗？**
A: 当前是单用户模式。多人协作需要加登录认证，后续可以升级。
