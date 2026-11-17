# 发布仓库项目规则 / Release Repository Rules

## 中文规则

### 文档必须成对同步

- 根目录只有两个主要文档入口：`README.md`（中文）和 `README.en.md`（英文）。两者必须拥有相同顺序的 `<!-- section:... -->` 章节 ID 和对应的树状导航。
- 项目规范文档分别位于 `docs/zh-CN/` 与 `docs/en/`；Skill 技术参考分别位于 `skills/ai-coding-handle/references/zh-CN/` 与 `skills/ai-coding-handle/references/en/`。两棵树的相对 Markdown 路径和章节 ID 必须完全一致。
- 修改任何人类可读文档时，必须在同一轮、同一提交中同步修改另一种语言的对应文件。不得提交只有一种语言的新文档或章节。
- 旧公开路径是由 `scripts/sync_docs.py` 生成的兼容跳转页，不得直接编辑正文。
- 文档修改后必须运行：

  ```powershell
  uv run --no-project python scripts/sync_docs.py
  uv run --no-project python scripts/sync_docs.py --check
  uv run --no-project python -m unittest discover -s tests -v
  ```

### 双平台发布是强制要求

- GitHub 是正式构建和主发布源，Gitee 是中国大陆网络备用发布源。任何正式版本必须同时完成两个平台的发布。
- GitHub Release 构建完成后，统一运行仓库内的 `scripts/sync-github-to-gitee.ps1`。该命令必须同步 `main`、全部 Git 标签和当前最新 Release 的准确附件集合，并执行严格匿名验证。
- 只有 GitHub 与 Gitee 的 `main`、历史标签、最新 Release 版本号、附件名称和附件大小完全一致，而且每个 Gitee 附件都可匿名读取，才能把发布标记为完成。
- 不批量迁移启用 Gitee 镜像之前的历史 Release 附件；已经同步到 Gitee 的历史 Release 和附件默认永久保留。只允许同步脚本自动清理当前最新 Gitee Release 中 GitHub 不存在的多余附件。若 1 GiB 配额阻塞正式最新版，只有仓库所有者针对精确 Release ID、标签和释放字节数明确确认后，才能例外清理历史 Gitee Release；对应 GitHub Release 与两端 Git 标签必须保留，且清理证据必须写入版本验收记录。

### v0.3.89 当前交接

- Windows、Linux、macOS 和 Skill 统一版本 `0.3.89`，主仓库标签 `v0.3.89`，源码提交 `f45eb4bec69536c93b9e00d70153ac6e5b44ce35`；三平台安装包必须由相应原生系统构建。
- V3 固件为 `0.3.71`，包含充电会话去重、大电池动画和 Agent 静置睡眠策略；上位机新增默认开启、断电保留的 Agent 深睡开关。功能源码已在开发版本标识 `0.3.70` 下完成 V3 `1C9E` app-only 实机验证；不得将旧包版本回读冒充 `0.3.71` 新包实机证据。
- macOS 使用 Apple Silicon arm64、ad-hoc 签名、未公证预览 DMG；Developer ID、公证、stapling、Gatekeeper 和 Intel 兼容性未声称。D4 已停止维护。
- 六个正式资产为 Windows EXE、Linux DEB、macOS 未公证预览 DMG、V3 固件 ZIP、Skill ZIP 和唯一 `latest.json`。必须通过 GitHub/Gitee 同步、哈希与匿名附件验证后才标记发布完成。

### 修改与验证

- 文档同步工具或结构变更后，运行文档检查、完整单元测试和 `git diff --check`。
- 发布同步规则或脚本变更后，额外运行 PowerShell AST 语法检查和 `uv run --no-project python scripts/gitee_release_sync.py verify`。
- 只暂存本轮相关文件，不使用 `git add -A`，不把令牌写入仓库、远端 URL、脚本或 `.env`。

## English rules

### Documentation must stay paired

- The repository has exactly two primary documentation entries: `README.md` in Chinese and `README.en.md` in English. They must use the same ordered `<!-- section:... -->` IDs and corresponding tree navigation.
- Canonical project documents live under `docs/zh-CN/` and `docs/en/`. Skill technical references live under `skills/ai-coding-handle/references/zh-CN/` and `skills/ai-coding-handle/references/en/`. Each pair of trees must contain identical relative Markdown paths and section IDs.
- Every human-readable documentation change must update its other-language counterpart in the same change and commit. Never add a single-language document or section.
- Legacy public paths are generated compatibility pages managed by `scripts/sync_docs.py`; do not edit their bodies directly.
- After documentation changes, run:

  ```powershell
  uv run --no-project python scripts/sync_docs.py
  uv run --no-project python scripts/sync_docs.py --check
  uv run --no-project python -m unittest discover -s tests -v
  ```

### Dual-platform publication is mandatory

- GitHub is the official build and primary release source. Gitee is the China-accessible fallback. Every formal version must be published on both platforms.
- After the GitHub Release is complete, run the repository-owned `scripts/sync-github-to-gitee.ps1`. It must synchronize `main`, every Git tag, and the exact latest Release asset set, then perform strict anonymous verification.
- Publication is complete only when GitHub and Gitee have identical `main`, historical tags, latest Release versions, asset names, and asset sizes, and every Gitee asset is anonymously readable.
- Do not bulk-migrate Release assets from before the Gitee mirror was enabled. Preserve every synchronized historical Gitee Release and attachment by default. The synchronizer may automatically remove only extra assets from the current latest Gitee Release. If the 1 GiB quota blocks the formal latest version, historical Gitee Releases may be removed only as an exception after the repository owner explicitly confirms the exact Release IDs, tags, and bytes to free. The matching GitHub Releases and Git tags on both remotes must remain intact, and the cleanup evidence must be recorded in the version verification record.

### Current v0.3.89 handoff

- Windows, Linux, macOS, and the Skill use version `0.3.89`, main-repository tag `v0.3.89`, and source commit `f45eb4bec69536c93b9e00d70153ac6e5b44ce35`. Each installer must be built on its native target OS.
- V3 firmware `0.3.71` adds charging-session deduplication, a large battery animation, and Agent inactivity sleep policy. The desktop adds a persistent Agent deep-sleep setting enabled by default. Feature source was validated by app-only flashing V3 `1C9E` under development label `0.3.70`; this is not a `0.3.71` package version-readback claim.
- macOS is Apple Silicon arm64, ad-hoc signed, and an unnotarized preview. Developer ID, notarization, stapling, Gatekeeper, and Intel compatibility are not claimed. D4 remains unmaintained.
- The six formal assets are the Windows EXE, Linux DEB, macOS unnotarized preview DMG, V3 firmware ZIP, Skill ZIP, and one `latest.json`. Publication is complete only after GitHub/Gitee synchronization, hash checks, and anonymous asset verification.

### Changes and validation

- After documentation tooling or structure changes, run documentation validation, the complete unit-test suite, and `git diff --check`.
- After release synchronization rules or scripts change, also run PowerShell AST syntax checks and `uv run --no-project python scripts/gitee_release_sync.py verify`.
- Stage only files related to the current change. Do not use `git add -A`, and never write tokens into the repository, remote URLs, scripts, or `.env`.
