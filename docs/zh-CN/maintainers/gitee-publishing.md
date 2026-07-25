<!-- section:s001 -->
# GitHub 主发布与 Gitee 国内备用

本仓库采用以下发布关系：

- GitHub 是正式主发布源。
- Gitee 同步 `main`、Git 标签和最新 Release 的全部附件，作为国内网络备用源。
- 不批量迁移启用 Gitee 镜像之前的全部 GitHub 历史 Release；从启用镜像开始，同步到 Gitee 的每个新 Release 都继续保留。
- AutoClipboard 应优先访问 GitHub；GitHub 元数据或附件下载失败时，再自动尝试 Gitee。

Gitee 公开仓库：<https://gitee.com/shan-yujun/Communist-Manifesto-Releases>

<!-- section:s002 -->
## 本机凭据

这台 Windows 发布机使用两种互相独立的凭据：

1. `C:\Users\admin\.ssh\id_ed25519_gitee_release`：只负责 Git 代码和标签推送。
2. Windows Git Credential Manager 中的 `gitee.com` 私人令牌：负责创建仓库、管理 SSH 公钥、创建 Release 和上传附件。

私人令牌不得写入仓库、脚本、`.env` 或 Git 远端 URL。同步脚本会优先读取临时环境变量 `GITEE_TOKEN`，否则通过 `git credential fill` 从 Windows 凭据管理器读取。

<!-- section:s003 -->
## 日常同步

在 GitHub Release 已经发布完成后，从本仓库根目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync-github-to-gitee.ps1
```

脚本依次执行：

1. 检查中英文规范文档树、章节 ID、兼容页和本地链接是否同步。
2. 将 `main` 推送到 GitHub。
3. 将 `main` 和标签推送到 Gitee。
4. 读取 GitHub 最新 Release。
5. 在 Gitee 创建或更新同名 Release，并把附件集合精确同步为 GitHub 最新 Release。
6. 以匿名方式验证两个平台的 `main`、标签、Release 标签、附件名称、附件大小和每个 Gitee 下载地址。

如果 GitHub Release 中同名附件被重新上传，使用：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync-github-to-gitee.ps1 -ReplaceExistingAssets
```

正式同步默认删除当前最新 Gitee Release 中 GitHub 不存在的多余附件，但绝不删除历史 Gitee Release 或历史附件。

<!-- section:s004 -->
## 单独验证

```powershell
uv run --no-project python scripts\gitee_release_sync.py verify
```

该命令不需要私人令牌。它会精确比较 GitHub 与 Gitee 的 `main`、全部标签、最新 Release 和附件元数据，并逐个验证 Gitee 附件可以匿名读取。任何差异都会返回非零退出码。
