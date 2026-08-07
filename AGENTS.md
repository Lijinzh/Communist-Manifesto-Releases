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

### v0.3.65 当前交接

- `v0.3.65` 的源码基线固定为主仓库提交 `88caff478679922819d234a86974abc33d2e880a`。
- Linux amd64 DEB、V3 固件候选包和 Skill ZIP 可以进入 GitHub 草稿 Release；草稿不得包含最终 `latest.json`，不得发布为 latest，也不得提前同步成 Gitee 正式 Release。
- Windows 发布端已从上述源码提交生成并上传 `AutoClipboardSetup-0.3.65.exe`（50,924,814 字节，SHA-256 `11444f40c6fd727606de40cf7a45a6e0728345b0d658d6e28d9519e0103bfbdc`）；macOS 发布端仍待补签名、公证并 stapling 的 `AutoClipboard-0.3.65-macOS.dmg`。
- V3 候选包已通过构建和包校验，但两次 live 预检均因 `/dev/ttyACM0`、`/dev/ttyACM1` 固件身份读取超时而在写入前停止。正式发布前必须补齐唯一 V3 的 app-only 烧录、串口身份和 BLE 验证。
- 全部附件到齐后只生成一次最终 `latest.json`，再发布 GitHub Release、执行 Gitee 同步和匿名附件验证。

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

### Current v0.3.65 handoff

- The `v0.3.65` source baseline is fixed at main-repository commit `88caff478679922819d234a86974abc33d2e880a`.
- The Linux amd64 DEB, V3 firmware candidate, and Skill ZIP may be staged in a GitHub draft Release. The draft must not contain the final `latest.json`, become latest, or be mirrored as a formal Gitee Release.
- The Windows publisher has built and uploaded `AutoClipboardSetup-0.3.65.exe` from the exact source commit above (50,924,814 bytes, SHA-256 `11444f40c6fd727606de40cf7a45a6e0728345b0d658d6e28d9519e0103bfbdc`); the macOS publisher must still add a signed, notarized, and stapled `AutoClipboard-0.3.65-macOS.dmg`.
- The V3 candidate passed build and package validation, but two live preflights stopped before writing because firmware identity timed out on `/dev/ttyACM0` and `/dev/ttyACM1`. A unique V3 app-only flash, serial identity check, and BLE verification remain mandatory before formal publication.
- Generate the final `latest.json` exactly once after every asset arrives, then publish GitHub, synchronize Gitee, and run anonymous asset verification.

### Changes and validation

- After documentation tooling or structure changes, run documentation validation, the complete unit-test suite, and `git diff --check`.
- After release synchronization rules or scripts change, also run PowerShell AST syntax checks and `uv run --no-project python scripts/gitee_release_sync.py verify`.
- Stage only files related to the current change. Do not use `git add -A`, and never write tokens into the repository, remote URLs, scripts, or `.env`.
