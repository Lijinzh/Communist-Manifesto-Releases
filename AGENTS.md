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
- 不批量迁移启用 Gitee 镜像之前的历史 Release 附件；已经同步到 Gitee 的历史 Release 和附件永久保留。只允许清理当前最新 Gitee Release 中 GitHub 不存在的多余附件。

### v0.3.76 当前交接

- Windows、Linux、macOS 和 Skill 使用主仓库标签 `v0.3.76`，桌面源码提交为 `c15d0c11b47f738cfa8e03024af2e52abb41354e`；三个安装包均在对应原生系统构建并完成下载端哈希复核。
- V3 `0.3.68` 固件基于主仓库提交 `88f55b4b05d7bc6af4af2a5fc1c1ddf23cf03057`，包大小 602,440 字节，SHA-256 `8d02fc673aba92499ad39729fe10fd133ffe58ab054a022b5c23117fa4abef7e`。
- 固件已在 Linux `/dev/ttyACM1`、设备序列号 `A1EA` 上完成 validated app-only 烧录，只写 `0x10000` 应用区；串口完整 smoke 通过，30 秒 BLE/IMU 收到 565 帧，平均 18.83 Hz，无序号缺口、重复或重置嫌疑。
- D4 已停止维护；macOS 使用 Apple Silicon arm64、ad-hoc 签名、未经 Apple 公证的预览 DMG，并随 `latest.json` 正式分发。不得声称 Developer ID、公证、stapling、Gatekeeper 或 Intel 兼容性通过。
- 正式附件集合固定为 Windows EXE、Linux DEB、macOS 未公证预览 DMG、V3 `0.3.68` 固件 ZIP、Skill ZIP 和 `latest.json`。`latest.json` 为 2,865 字节，SHA-256 `239b53c3704788928a652c4ff168c09cde5242d9c9c076365d5cf197e0421204`；发布后必须执行 GitHub/Gitee 双平台同步和匿名附件验证。

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
- Do not bulk-migrate Release assets from before the Gitee mirror was enabled. Preserve every historical Gitee Release and attachment already synchronized. Extra-asset cleanup is allowed only on the current latest Gitee Release.

### Current v0.3.76 handoff

- Windows, Linux, macOS, and the Skill use main-repository tag `v0.3.76` at desktop source commit `c15d0c11b47f738cfa8e03024af2e52abb41354e`. Each native installer was built on its target OS and re-hashed after collection.
- V3 firmware `0.3.68` is based on main-repository commit `88f55b4b05d7bc6af4af2a5fc1c1ddf23cf03057`. The package is 602,440 bytes with SHA-256 `8d02fc673aba92499ad39729fe10fd133ffe58ab054a022b5c23117fa4abef7e`.
- It completed a validated app-only flash on Linux `/dev/ttyACM1`, device serial `A1EA`, writing only the application region at `0x10000`. The complete serial smoke passed, and a 30-second BLE/IMU live smoke received 565 frames at 18.83 Hz with no sequence gaps, duplicates, or reset suspicions.
- D4 is no longer maintained. macOS uses an Apple Silicon arm64, ad-hoc-signed, unnotarized preview DMG and is included in `latest.json`; do not claim Developer ID signing, notarization, stapling, Gatekeeper approval, or Intel compatibility.
- The formal asset set is the Windows EXE, Linux DEB, macOS unnotarized preview DMG, V3 `0.3.68` firmware ZIP, Skill ZIP, and `latest.json`. `latest.json` is 2,865 bytes with SHA-256 `239b53c3704788928a652c4ff168c09cde5242d9c9c076365d5cf197e0421204`. GitHub/Gitee synchronization and anonymous asset verification remain mandatory after publication.

### Changes and validation

- After documentation tooling or structure changes, run documentation validation, the complete unit-test suite, and `git diff --check`.
- After release synchronization rules or scripts change, also run PowerShell AST syntax checks and `uv run --no-project python scripts/gitee_release_sync.py verify`.
- Stage only files related to the current change. Do not use `git add -A`, and never write tokens into the repository, remote URLs, scripts, or `.env`.
