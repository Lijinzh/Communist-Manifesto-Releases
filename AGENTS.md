# 发布仓库项目规则

## 双平台发布是强制要求

- GitHub 是正式构建和主发布源，Gitee 是中国大陆网络备用发布源。任何正式版本必须同时在 GitHub 和 Gitee 完成发布，不能只完成其中一个平台。
- GitHub Release 构建完成后，统一运行 `git sync-release-mirrors`。该命令必须同步 `main`、Git 标签和当前最新 Release 的全部附件，并验证 Gitee 匿名访问。
- 只有 GitHub 最新 Release 与 Gitee 最新 Release 的版本号、附件名称和附件大小一致，并且 Gitee 附件可公开读取，才能把发布标记为完成。任意一步失败都必须报告发布未完成。

## 不批量迁移旧历史，保留已同步版本

- 不批量回填或搬运启用 Gitee 镜像之前的全部 GitHub 历史 Release 附件。
- 从启用镜像开始，每次同步到 Gitee 的新 Release 都必须永久保留；后续发布不得自动删除旧的 Gitee Release 或其附件。
- `main` 和历史 Git 标签始终同步并保留，用于代码与版本追溯。

## 修改与验证

- README 的事实来源是 `docs/README.bilingual.md`；修改后运行 `uv run --no-project python scripts/sync_readmes.py` 和 `uv run --no-project python scripts/sync_readmes.py --check`。
- 发布同步规则或脚本变更后，至少运行 PowerShell 语法检查、`git diff --check` 和 `uv run --no-project python scripts/gitee_release_sync.py verify`。
- 只暂存本轮相关文件，不使用 `git add -A`，不把令牌写入仓库、远端 URL、脚本或 `.env`。
