<!-- section:s001 -->
# 贡献与验证

贡献流程的目标是保留用户数据、限制改动范围，并让每个结论都能追溯到测试或实机证据。

<!-- section:s002 -->
## 开始前

1. 阅读目标仓库的 `AGENTS.md`、规格和当前发布交接。
2. 运行 `git status --short --branch`，识别已有修改和未跟踪文件。
3. 抓取远端并检查分叉；不要覆盖用户修改或强制推送。
4. 为任务写清楚验收条件，以及是否需要硬件、浏览器或平台原生构建机。

<!-- section:s003 -->
## 修改文档

- 根入口只使用 `README.md` 与 `README.en.md`。
- 规范文档位于 `docs/zh-CN/` 与 `docs/en/`，相对 Markdown 路径必须一致。
- 每对页面使用相同顺序的 `<!-- section:... -->` ID。
- 兼容跳转页由 `scripts/sync_docs.py` 生成，不直接编辑正文。
- 修改后运行：

```powershell
uv run --no-project python scripts/sync_docs.py
uv run --no-project python scripts/sync_docs.py --check
uv run --no-project python -m unittest discover -s tests -v
git diff --check
```

<!-- section:s004 -->
## 修改 AutoClipboard 或固件

- 使用主仓库的 `uv --project AutoClipboard` 环境。
- 运行与改动相关的单元、契约、smoke 和编译检查。
- 固件代码变化在硬件可用且身份唯一时，需要构建 V3、生成并校验 app-only 包、validated 烧录、串口读回和 BLE/IMU live smoke。
- 不用 PlatformIO upload 绕过包校验，不写 bootloader/partitions，不擦除 NVS/SPIFFS。

<!-- section:s005 -->
## 修改官网

- 保持 Gitee 国内主下载与 GitHub 备用下载都指向准确的版本化附件。
- 更新页面时同步更新自动化测试和缓存版本参数。
- 至少验证桌面和移动视口、控制台、主要导航、一个真实交互以及线上缓存刷新后的页面。
- 截图、测试脚本和临时报告不默认提交进仓库。

<!-- section:s006 -->
## 提交与发布

1. 只暂存本轮相关文件，不使用 `git add -A`。
2. 查看 staged diff 和 `git diff --check`。
3. 创建描述范围明确的提交。
4. 普通同步使用 fast-forward 和非强制推送。
5. 正式 Release 完成后运行 `git sync-release-mirrors`，验证 GitHub/Gitee main、标签、附件和匿名下载。

<!-- section:s007 -->
## 证据语言

- `implemented`：源码实现存在。
- `fixture`：使用受控测试数据通过。
- `full-download`：完整公开资产下载与校验通过。
- `physical-live`：真实设备或真实平台交互通过。

不要用较低等级证据声称较高等级结论，也不要把一个操作系统的结果扩展到其他系统。
