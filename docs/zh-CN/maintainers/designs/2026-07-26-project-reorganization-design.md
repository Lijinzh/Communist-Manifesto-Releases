<!-- section:s001 -->
# 项目整理与双语文档设计

<!-- section:s002 -->
## 目标

在不破坏现有公开文档路径、不丢失必要内容的前提下，将仓库整理为两个主要 README、两棵严格对应的中英文文档树、一个共享资源区、一个独立 Skill 发布区和一套可验证的双平台发布流程。

<!-- section:s003 -->
## 已确认的问题

- 三份双语源文件生成六份公开文档，源文件与生成文件混在同一文档层级，维护职责不清。
- `docs/software-interface-manual/` 下存在多份实质性 README，读者难以判断入口和事实来源。
- 部分文档自动生成，部分文档手工维护，语言覆盖和 CI 触发规则不一致。
- Skill 技术参考只有英文树，未纳入项目级双语约束。
- 软件界面图片包含完全重复文件和未被文档引用的完整截图中间产物。
- `gitee_release_sync.py verify` 只检查 Gitee 元数据存在，没有比较 GitHub/Gitee 最新 Release，也没有验证匿名附件读取。
- 当前线上 `v0.3.51` 不一致：GitHub 有 8 个附件，Gitee 有 7 个；Linux 安装包和 `latest.json` 也不同。

<!-- section:s004 -->
## 文档信息架构

根目录只保留两个实质性 README：

```text
README.md       中文主入口、下载说明、快速开始和中文文档树
README.en.md    English main entry, downloads, quick start, and English tree
```

详细文档进入相对路径完全对应的两棵树：

```text
docs/
├─ zh-CN/
│  ├─ user-guide.md
│  ├─ software-interface-manual.md
│  ├─ agent-signal-setup.md
│  ├─ ch343-driver-installation.md
│  └─ maintainers/
│     ├─ gitee-publishing.md
│     └─ designs/
├─ en/
│  └─ 与 zh-CN 相同的相对路径集合
└─ assets/
   ├─ user-guide/
   └─ software-interface-manual/
```

Skill 保持平台要求的固定入口，同时将技术参考拆成两棵树：

```text
skills/ai-coding-handle/
├─ SKILL.md
└─ references/
   ├─ zh-CN/
   └─ en/
```

`AGENTS.md`、`SKILL.md` 和 `LICENSE` 因平台发现规则或法律文本保留固定路径；`AGENTS.md` 同时提供中英文规则，`SKILL.md` 将 Codex 路由到对应语言参考树。

<!-- section:s005 -->
## 兼容策略

现有公开文档路径不删除。旧路径改为简短、自动生成的兼容页，链接到新的中文或英文规范文档。兼容页不再承载第二份正文，因此既保留外部链接，又消除实质内容重复。

包括但不限于：

- `docs/user-guide.zh-CN.md`
- `docs/user-guide.en.md`
- `docs/software-interface-manual/README.md`
- `docs/software-interface-manual/README.en.md`
- `docs/ch343-driver-installation*.md`
- `docs/agent-signal-setup.md`
- `docs/gitee-publishing.md`
- 三个现有 `.bilingual.md` 路径
- `skills/ai-coding-handle/references/*.md`

<!-- section:s006 -->
## 防误删迁移流程

1. 先用 `git mv` 将现有公开正文迁移到规范路径，保留历史。
2. 为缺少的语言补齐对应文档，不在迁移阶段压缩正文。
3. 生成并验证旧路径兼容页。
4. 在两棵树完整、链接有效后，才删除完全重复图片和未引用中间产物。
5. 主 README 只移除已在详细文档完整保留的重复说明，并改为摘要加链接。
6. 每次删除前检查引用、哈希和 Git diff，确保事实至少在每种语言的一处规范文档中保留。

<!-- section:s007 -->
## 双语同步机制

新增统一文档工具 `scripts/sync_docs.py`，负责：

- 检查 `docs/zh-CN` 与 `docs/en` 的相对 Markdown 路径集合完全一致。
- 检查 `skills/ai-coding-handle/references/zh-CN` 与 `en` 的路径集合完全一致。
- 检查每对文档的稳定 `section` ID 集合和顺序一致。
- 检查根目录两个 README 的文档导航目标对应存在。
- 检查所有规范文档和兼容页的本地链接。
- 生成旧公开路径的兼容页，并在 `--check` 模式下拒绝过期内容。

`AGENTS.md` 明确规定所有人类可读文档必须在同一次修改中更新中英文对应文件，并要求运行同步与检查命令。GitHub Actions 对所有 Markdown、共享图片、文档脚本和工作流变更执行相同检查。

<!-- section:s008 -->
## 图片整理

共享图片统一放在 `docs/assets/`。软件界面手册的派生裁剪图放在 `docs/assets/software-interface-manual/`。构建脚本直接使用共享完整截图作为输入，不再提交重复的完整截图或未引用的重编码副本。

只删除已经通过 SHA-256 和引用扫描确认的冗余文件；所有实际被文档引用的裁剪图继续保留。

<!-- section:s009 -->
## 发布同步修复

`gitee_release_sync.py verify` 必须验证：

- GitHub 与 Gitee 最新 Release 标签完全一致。
- 附件名称集合完全一致。
- 每个同名附件大小完全一致。
- Gitee 每个附件 URL 在无令牌条件下可以建立响应并读取数据。
- GitHub/Gitee 的 `main` 和历史标签引用一致。

正式同步命令默认使最新 Release 附件精确对齐；只清理当前最新 Gitee Release 中 GitHub 不存在的多余附件，不删除历史 Gitee Release。同步完成后再次执行匿名验证，任何不一致都返回非零退出码。

本轮将在代码验证通过后修复线上 `v0.3.51`：上传缺少的 `CH343SER.EXE`，替换错误的 Linux 安装包和 `latest.json`，然后逐项复核 8 个附件。

<!-- section:s010 -->
## 测试与完成标准

- 文档双语树、章节 ID、兼容页和本地链接检查通过。
- Python 单元测试覆盖文档树比较、兼容页生成和 Release 差异检测。
- PowerShell 脚本语法检查通过。
- `git diff --check` 通过。
- GitHub 与 Gitee `main`、标签、最新 Release 标签、附件名称和附件大小一致。
- Gitee 最新 Release 的全部附件可匿名读取。
- 工作区最终干净，相关提交已推送到两个平台。

<!-- section:s011 -->
## 非目标

- 不搬运启用 Gitee 镜像之前的历史 Release 附件。
- 不删除已同步的历史 Gitee Release。
- 不修改 AutoClipboard 或固件私有源码。
- 不为了减少文件数量而合并职责不同的用户指南、界面手册、维护文档或 Skill 协议。
