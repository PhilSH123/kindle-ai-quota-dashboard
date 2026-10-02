# PhilSH123 的 Kindle 仪表盘

本分支面向 Kindle Paperwhite 3（固件 5.12.2）的原生浏览器试用。上游 KPM 全屏包只验证过 `kindlehf` 和 `kindlepw2`，不能直接安装到 PW3。先通过浏览器验证页面，暂不修改 Kindle 系统。

## 显示内容

- Codex：从本机 Codex CLI 读取订阅额度。
- DeepSeek：用本机 API Key 查询 API 余额。
- GLM Coding Plan：用本机 Coding Plan Key 查询套餐额度。
- 石家庄天气：Open-Meteo 免费 API，每次采集前更新。
- 每日一语：每日轮换一条古诗词，不消耗 AI 额度。

GitHub Pages 上的数据公开可读，包括额度百分比、余额、更新时间和城市。密钥只保存在本机，不进入 Git 仓库或 Pages。

## 首次准备（Windows）

1. 安装 Node.js 18 或更高版本、Git，并登录本机 Codex CLI。
2. 在 PowerShell 中进入本仓库，运行 `powershell -ExecutionPolicy Bypass -File scripts/setup-secrets.ps1`，在本机提示符输入 DeepSeek 和 GLM Coding Plan 密钥。不要在聊天或 GitHub 页面粘贴密钥。
3. 运行 `powershell -ExecutionPolicy Bypass -File scripts/run-dashboard.ps1`。检查 `state/data.json` 中的 `codex`、`deepseek`、`glm`、`weather` 都为 `ok: true`。`state/` 和 `config/` 被 Git 忽略。
4. 运行 `npm run serve`，在电脑浏览器打开 `http://127.0.0.1:8787` 预览。

## 发布到 GitHub Pages

先确认预览内容可以公开。运行 `powershell -ExecutionPolicy Bypass -File scripts/run-dashboard.ps1 -Publish`，会把构建页面推送到此仓库的 `gh-pages` 分支。随后在 GitHub 仓库 **Settings → Pages** 中选择 **Deploy from a branch → gh-pages → /(root)**。预期地址为 `https://philsh123.github.io/kindle-ai-quota-dashboard/`。

在 Kindle 上连接 Wi‑Fi，并用“体验版浏览器”打开该地址。原生浏览器能否完整显示必须在实体设备上验证；它可能自动息屏，也不会显示由越狱启动器提供的电量。

## 自动更新

首次手动发布成功后，运行 `powershell -ExecutionPolicy Bypass -File scripts/register-task.ps1`。Windows 登录期间每 10 分钟采集并发布一次。电脑关闭、未登录 Windows、网络中断或账户失效时，网页会显示旧值或离线状态。重复运行注册脚本会更新同名任务。

## 依据

- GLM 查询接口及认证方式：[智谱官方用量插件](https://github.com/zai-org/zai-coding-plugins/blob/main/plugins/glm-plan-usage/skills/usage-query-skill/scripts/query-usage.mjs)
- 天气数据：[Open-Meteo](https://open-meteo.com/en/docs)
- 设备兼容范围：[上游兼容性说明](https://github.com/softmutiny/kindle-ai-quota-dashboard/blob/main/docs/compatibility.md)
