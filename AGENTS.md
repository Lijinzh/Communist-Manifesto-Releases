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

### v0.3.66 当前交接

- `v0.3.66` 的源码基线固定为主仓库提交 `315d670d97a645d3f7a0ac1115af106c8a538583`。
- 本版本经所有者明确批准先正式发布 Windows x64、V3 固件和 Skill；Linux DEB 由专用 Linux 构建机后续补充，macOS 正式 DMG 由合作伙伴后续编译补充，当前 `latest.json` 不得包含 `app.linux` 或 `app.macos`。
- Windows EXE 为 50,598,899 字节，SHA-256 `95112d5b9c0330694728b9214743a57871458de5ede45ea6c065b35b4fa5a28e`。D4 已停止维护，本版本不发布新 D4 固件，当前 `latest.json` 不得包含 `firmware.d4`。
- V3 最终包大小 601,742 字节，SHA-256 `882dabee1b6c63d31d40168864f7c0399156ece27aded9a65fe67330f058cca1`，已在 Windows `COM7`、设备序列号 `1C9E` 上完成 validated app-only 烧录，只写 `0x10000` 应用区；串口身份/版本确认、状态命令及 BLE/IMU 30 秒 live smoke 通过，收到 458 帧，平均 15.3 Hz。
- 当前正式附件集合固定为 Windows EXE、V3 固件 ZIP、Skill ZIP 和 `latest.json`。发布后必须执行 GitHub/Gitee 双平台同步和匿名附件验证。

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

### Current v0.3.66 handoff

- The `v0.3.66` source baseline is fixed at main-repository commit `315d670d97a645d3f7a0ac1115af106c8a538583`.
- The owner explicitly approved formal publication of Windows x64, V3 firmware, and the Skill first. A dedicated Linux builder will add the DEB later, and a partner will add the formal macOS DMG later; the current `latest.json` must not contain `app.linux` or `app.macos`.
- The Windows EXE is 50,598,899 bytes with SHA-256 `95112d5b9c0330694728b9214743a57871458de5ede45ea6c065b35b4fa5a28e`. D4 is no longer maintained, so this release has no new D4 firmware and the current `latest.json` must not contain `firmware.d4`.
- The final V3 package is 601,742 bytes with SHA-256 `882dabee1b6c63d31d40168864f7c0399156ece27aded9a65fe67330f058cca1`. It completed a validated app-only flash on Windows `COM7`, device serial `1C9E`, writing only the application region at `0x10000`. Serial identity/version readback, status commands, and a 30-second BLE/IMU live smoke passed with 458 frames at 15.3 Hz.
- The formal asset set is fixed to the Windows EXE, V3 firmware ZIP, Skill ZIP, and `latest.json`. After publication, GitHub/Gitee synchronization and anonymous asset verification remain mandatory.

### Changes and validation

- After documentation tooling or structure changes, run documentation validation, the complete unit-test suite, and `git diff --check`.
- After release synchronization rules or scripts change, also run PowerShell AST syntax checks and `uv run --no-project python scripts/gitee_release_sync.py verify`.
- Stage only files related to the current change. Do not use `git add -A`, and never write tokens into the repository, remote URLs, scripts, or `.env`.
