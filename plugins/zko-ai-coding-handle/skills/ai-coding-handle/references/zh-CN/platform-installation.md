<!-- section:s001 -->
# 平台安装

Bootstrap 脚本始终从以下地址读取元数据：

`https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest/download/latest.json`

脚本只接受 `github.com/Lijinzh/Communist-Manifesto-Releases/releases/.../download/...` 下的 HTTPS 附件，并在安装前验证声明的字节大小和 SHA-256。经过明确授权的软件安装或 Hook 配置 bootstrap 可以通过网络访问该元数据和选定安装包。本地元数据文件只能与 dry-run 一起使用，用于离线验证；通用 Agent 的离线 dry-run 仍会验证附件，但不会探测或修改已安装应用。

在真实安装、升级或 Hook 配置前，解释选定的平台安装包并取得一次明确的软件确认。该确认只覆盖软件和 Hook 事务，绝不覆盖固件刷写。

Bootstrap 结果文件使用稳定状态：验证 dry-run 为 `verified`；原生 Hook 安装和 doctor 完成后为 `ready`；通用 Agent 仍需要经过验证的生命周期 Hook，或 Codex 仍需要用户批准 Hook 时为 `configuration_required`；拒绝或未完成操作为 `failed`。`configuration_required` 会刻意使用 `success: false`，但 bootstrap 进程仍可能返回零，使调用 Agent 可以继续配置而不会误认为 Bridge 已经 ready。

真实安装或配置尝试后，读取结果 JSON 并保存其中的绝对 `executable`。之后所有 Maintenance 和 Agent Bridge 命令都必须调用该准确路径，不能假设 `auto-clipboard` 位于 `PATH`。Dry-run 的 `verified` 结果可能不包含 executable，因为它没有安装任何内容。

<!-- section:s002 -->
## Windows

运行 `scripts/bootstrap-autoclipboard.ps1`。它选择 `app.windows`，要求 `.exe`，并使用静默参数运行 Inno Setup 安装器。参数为 `-DryRun`、`-MetadataFile`、`-Agent auto|codex|claude|generic` 和 `-ResultFile`。

<!-- section:s003 -->
## Linux

运行 `scripts/bootstrap-autoclipboard.sh`。它选择 `app.linux`，要求 `.deb`，优先使用 `apt-get`/`apt` 安装，并以 `dpkg` 为后备。参数为 `--dry-run`、`--metadata-file`、`--agent auto|codex|claude|generic` 和 `--result-file`。

<!-- section:s004 -->
## macOS

POSIX bootstrap 选择 `app.macos`，要求 `.dmg`，并使用 `hdiutil` 挂载。它先把 `AutoClipboard.app` 复制到 `~/Applications` 目标旁的唯一暂存 bundle，在接触现有目标前验证暂存可执行文件。目标已存在时，bootstrap 将其重命名为唯一备份，再把暂存目录重命名为目标。只有可执行文件发现、版本验证和 Agent Bridge 配置全部完成后才删除备份。事务中任何失败都会删除新目标、恢复备份并清理暂存，因此 `ditto` 不会把新文件合并到现有 bundle。

决定是否下载前，两种脚本都会读取最新元数据中选定平台附件的版本，并使用经过验证的 SemVer 语法与 doctor 的 `app_version` 比较；允许前导 `v`。只有已安装版本更旧时才安装或升级；相同或更新版本跳过下载。元数据或版本缺失、格式错误时封闭失败，不进行猜测，也不会静默保留过期安装。第一次 doctor 是核心预检：`hook_executable_available`、`platform_poll_supported` 和 `state_directory_writable` 必须通过；缺失或过期的 Hook 检查可以失败，因为原生安装预计会修复它们。Codex 和 Claude 随后使用原生安装；空的 `changes` 表示没有检测到原生 Agent，因此不能进入 `ready`。

最终 doctor 是严格检查。唯一非致命例外是 Codex 的核心和 Hook 配置检查均通过，`hook_trust_probe_available`、`hook_trust_metadata_complete` 和 `hook_runtime_enabled` 为真，而且唯一失败项是 `hook_trust_granted`。此时 bootstrap 返回 `configuration_required`，要求用户在 Codex 内批准 AutoClipboard Hook 后重新运行 doctor。其他所有最终 doctor 失败都保持致命。

通用 Agent 同样需要核心预检，但绝不使用原生安装。Bootstrap 返回 `configuration_required`，让调用 Agent 配置已验证的 `emit` 协议；缺少原生 Hook 配置不会阻止该结果。
