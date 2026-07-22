# GitHub 主发布与 Gitee 国内备用

本仓库采用以下发布关系：

- GitHub 是正式主发布源。
- Gitee 同步 `main`、Git 标签和最新 Release 的全部附件，作为国内网络备用源。
- AutoClipboard 应优先访问 GitHub；GitHub 元数据或附件下载失败时，再自动尝试 Gitee。

Gitee 公开仓库：<https://gitee.com/shan-yujun/Communist-Manifesto-Releases>

## 本机凭据

这台 Windows 发布机使用两种互相独立的凭据：

1. `C:\Users\admin\.ssh\id_ed25519_gitee_release`：只负责 Git 代码和标签推送。
2. Windows Git Credential Manager 中的 `gitee.com` 私人令牌：负责创建仓库、管理 SSH 公钥、创建 Release 和上传附件。

私人令牌不得写入仓库、脚本、`.env` 或 Git 远端 URL。同步脚本会优先读取临时环境变量 `GITEE_TOKEN`，否则通过 `git credential fill` 从 Windows 凭据管理器读取。

## 日常同步

在 GitHub Release 已经发布完成后，从本仓库根目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync-github-to-gitee.ps1
```

脚本依次执行：

1. 检查中英文 README 是否同步。
2. 将 `main` 推送到 GitHub。
3. 将 `main` 和标签推送到 Gitee。
4. 读取 GitHub 最新 Release。
5. 在 Gitee 创建或更新同名 Release，并同步全部附件。
6. 以匿名方式验证 Gitee Release 和附件是否可以公开读取。

如果 GitHub Release 中同名附件被重新上传，使用：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync-github-to-gitee.ps1 -ReplaceExistingAssets
```

只有在确定 Gitee 最新 Release 中的多余附件应被删除时，才增加 `-PruneExtraAssets`。

## 单独验证

```powershell
uv run --no-project python scripts\gitee_release_sync.py verify
```

该命令不需要私人令牌，可用于确认国内用户是否能够匿名读取最新版本和附件下载地址。
