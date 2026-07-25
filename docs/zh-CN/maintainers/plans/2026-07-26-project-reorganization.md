# 项目整理实施计划

> **供代理执行：** 必须使用 `superpowers:executing-plans` 逐项执行本计划。所有步骤使用复选框跟踪。

**目标：** 在保留公开文档路径和必要内容的前提下，建立两个主要 README、两棵中英文文档树、双语 Skill 参考树、统一检查机制，并修复 GitHub/Gitee 发布镜像。

**架构：** 规范文档进入 `docs/zh-CN` 与 `docs/en`，旧路径由 `scripts/sync_docs.py` 生成兼容页。文档检查、Release 对比和匿名附件验证都由可单元测试的 Python 函数完成，PowerShell 只负责发布编排。

**技术栈：** Python 3 标准库、PowerShell、Git、GitHub/Gitee HTTP API、GitHub Actions、Markdown。

---

### 任务 1：建立文档同步检查器

**文件：**
- 新建：`scripts/sync_docs.py`
- 新建：`tests/test_sync_docs.py`

- [ ] 编写失败测试，覆盖两棵文档树路径不一致、章节 ID 不一致、兼容页渲染和失效本地链接。
- [ ] 运行 `uv run --no-project python -m unittest tests.test_sync_docs -v`，确认因模块不存在而失败。
- [ ] 实现 `markdown_paths()`、`section_ids()`、`render_redirect()`、`validate_pair_trees()`、`validate_local_links()` 和 `sync(check)`。
- [ ] 再次运行测试，预期全部通过。
- [ ] 运行 `git diff --check`。
- [ ] 仅暂存本任务文件并提交：`test: add bilingual documentation validation`。

关键接口：

```python
def markdown_paths(root: Path) -> set[Path]: ...
def section_ids(path: Path) -> tuple[str, ...]: ...
def render_redirect(language: str, target: str, title: str) -> str: ...
def validate_pair_trees(left: Path, right: Path) -> list[str]: ...
def validate_local_links(paths: Iterable[Path]) -> list[str]: ...
def sync(check: bool) -> int: ...
```

### 任务 2：迁移项目文档并生成兼容页

**文件：**
- 迁移：`docs/user-guide.zh-CN.md` → `docs/zh-CN/user-guide.md`
- 迁移：`docs/user-guide.en.md` → `docs/en/user-guide.md`
- 迁移：`docs/software-interface-manual/README.md` → `docs/zh-CN/software-interface-manual.md`
- 迁移：`docs/software-interface-manual/README.en.md` → `docs/en/software-interface-manual.md`
- 迁移：`docs/agent-signal-setup.md` → `docs/zh-CN/agent-signal-setup.md`
- 新建：`docs/en/agent-signal-setup.md`
- 迁移：`docs/ch343-driver-installation.zh-CN.md` → `docs/zh-CN/maintainers/ch343-driver-installation.md`
- 迁移：`docs/ch343-driver-installation.md` → `docs/en/maintainers/ch343-driver-installation.md`
- 迁移：`docs/gitee-publishing.md` → `docs/zh-CN/maintainers/gitee-publishing.md`
- 新建：`docs/en/maintainers/gitee-publishing.md`
- 修改：所有规范文档，加入稳定 `<!-- section:id -->` 标记并修正相对链接
- 修改：`scripts/sync_docs.py` 的兼容路径映射

- [ ] 使用 `git mv` 完成已有正文迁移，保留历史。
- [ ] 补齐 Agent 状态和 Gitee 发布文档的英文对应版本。
- [ ] 为每对文档加入相同顺序的章节 ID。
- [ ] 配置所有旧公开路径的兼容页，包括三个 `.bilingual.md` 路径。
- [ ] 运行 `uv run --no-project python scripts/sync_docs.py` 生成兼容页。
- [ ] 运行 `uv run --no-project python scripts/sync_docs.py --check`，预期通过。
- [ ] 运行 `git diff --check` 并检查删除内容都已迁移。
- [ ] 提交：`docs: organize mirrored documentation trees`。

### 任务 3：迁移并翻译 Skill 技术参考

**文件：**
- 迁移：`skills/ai-coding-handle/references/*.md` → `skills/ai-coding-handle/references/en/*.md`
- 新建：`skills/ai-coding-handle/references/zh-CN/*.md`
- 修改：`skills/ai-coding-handle/SKILL.md`
- 修改：`scripts/sync_docs.py` 的 Skill 兼容路径映射

- [ ] 将五份现有英文参考用 `git mv` 移入 `references/en/`。
- [ ] 创建同名中文参考，保持命令、状态码、JSON 字段和安全边界不变。
- [ ] 为每对参考加入相同章节 ID。
- [ ] 更新 `SKILL.md`，明确默认读取英文树，中文会话可读取中文树。
- [ ] 生成原 `references/*.md` 兼容页。
- [ ] 运行文档测试和 `sync_docs.py --check`。
- [ ] 提交：`docs: add mirrored skill reference trees`。

### 任务 4：整理主 README、规则、CI 和图片

**文件：**
- 修改：`README.md`
- 修改：`README.en.md`
- 修改：`AGENTS.md`
- 修改：`.github/workflows/readme-sync.yml`
- 修改：`scripts/build_software_interface_manual_assets.py`
- 删除：`scripts/sync_readmes.py`
- 迁移：`docs/software-interface-manual/assets/*` → `docs/assets/software-interface-manual/*`
- 删除：确认重复或无引用的完整截图中间产物

- [ ] 在两个根 README 中建立对应的树状文档导航，并把重复细节缩为摘要链接。
- [ ] 将 `AGENTS.md` 改为中英文规则，强制所有文档同轮双语修改和检查。
- [ ] 扩大 CI 路径触发范围，运行单元测试、文档检查和 PowerShell 语法检查。
- [ ] 修改图片构建脚本，直接读取共享完整截图，只生成被引用的裁剪和编号图。
- [ ] 迁移软件手册图片并更新两种语言的引用。
- [ ] 删除 SHA-256 完全重复文件及未引用中间产物。
- [ ] 删除旧 README 生成器，统一使用 `sync_docs.py`。
- [ ] 运行测试、文档检查、图片引用扫描和 `git diff --check`。
- [ ] 提交：`refactor: clarify repository documentation structure`。

### 任务 5：以测试驱动修复 Release 验证

**文件：**
- 修改：`scripts/gitee_release_sync.py`
- 修改：`scripts/sync-github-to-gitee.ps1`
- 新建：`tests/test_gitee_release_sync.py`
- 修改：`docs/zh-CN/maintainers/gitee-publishing.md`
- 修改：`docs/en/maintainers/gitee-publishing.md`

- [ ] 编写失败测试，覆盖标签不同、缺少附件、多余附件、大小不同和完全一致。
- [ ] 运行 `uv run --no-project python -m unittest tests.test_gitee_release_sync -v`，确认新比较函数不存在。
- [ ] 实现纯函数 `release_asset_map()` 和 `compare_release_mirrors()`。
- [ ] 扩展 `verify_public_mirror()`：读取 GitHub 最新 Release、Gitee 最新 Release，精确比较附件并匿名读取每个 Gitee 下载 URL。
- [ ] 增加 GitHub/Gitee `main` 和标签引用比较。
- [ ] 让正式同步默认删除当前最新 Gitee Release 的多余附件，但不删除历史 Release。
- [ ] 更新 PowerShell 编排和双语维护文档。
- [ ] 运行单元测试、PowerShell AST 语法检查、文档检查和 `git diff --check`。
- [ ] 提交：`fix: verify exact GitHub and Gitee release parity`。

关键比较接口：

```python
def release_asset_map(release: dict[str, object]) -> dict[str, int]: ...
def compare_release_mirrors(
    github_tag: str,
    github_assets: dict[str, int],
    gitee_tag: str,
    gitee_assets: dict[str, int],
) -> list[str]: ...
```

### 任务 6：完成验证、推送和线上修复

**文件：**
- 修改：仅在验证发现遗漏时修改本轮相关文件

- [ ] 运行 `uv run --no-project python -m unittest discover -s tests -v`。
- [ ] 运行 `uv run --no-project python scripts/sync_docs.py --check`。
- [ ] 对全部 PowerShell 文件运行 AST 语法检查。
- [ ] 运行 `git diff --check` 和 `git status --short`。
- [ ] 推送 `main` 到 GitHub。
- [ ] 配置或核对 Gitee SSH 远端，推送 `main` 和全部标签。
- [ ] 运行正式镜像同步，修复 `v0.3.51` 缺少和错误的附件。
- [ ] 运行严格匿名验证，确认两个平台标签均为 `v0.3.51`、附件均为 8 个且名称和大小逐项一致。
- [ ] 最后运行 `git status --short --branch`，确认工作区干净且两个远端代码引用一致。
