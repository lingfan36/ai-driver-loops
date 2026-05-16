# Hooks

## c-loop-reminder.ps1

软提示 hook — Claude Code 答完一个实质性回复时,1/4 概率在终端尾部显示回路 C 的找茬提醒。

### 平台支持

- ✅ **Windows + PowerShell 7+ (`pwsh`)**:开箱即用
- ⚠️ **macOS / Linux**:需要把脚本翻译成 bash 或 Python(欢迎 PR)

### 安装(Windows)

#### 1. 复制脚本

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\hooks" | Out-Null
Copy-Item c-loop-reminder.ps1 "$env:USERPROFILE\.claude\hooks\"
```

#### 2. 注册到 Claude Code

编辑 `~/.claude/settings.json`,在顶层 JSON 加入或合并:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "pwsh -NoProfile -ExecutionPolicy Bypass -File \"<HOME>/.claude/hooks/c-loop-reminder.ps1\""
          }
        ]
      }
    ]
  }
}
```

把 `<HOME>` 改成你的真实 home 路径,例如 `C:/Users/yourname`。

#### 3. 启用

```powershell
[Environment]::SetEnvironmentVariable("AI_TRAINING_LOOP", "1", "User")
```

(重启 Claude Code 后生效)

### 调参

如果觉得太频繁/太稀疏,改脚本里的:

```powershell
if ((Get-Random -Minimum 0 -Maximum 4) -ne 0) { exit 0 }
```

`Maximum 4` = 1/4 概率。`8` = 1/8,`2` = 1/2。

### 关闭

```powershell
# 永久
[Environment]::SetEnvironmentVariable("AI_TRAINING_LOOP", $null, "User")

# 仅本会话
$env:AI_TRAINING_LOOP = ""
```

### 显示的提示

```
💭 [Loop C] Find 3 potential problems in this answer before accepting.
   Did you predict the answer first (Loop B)?
   Caught a mistake → say "记一笔" (or "log AI error")
   Mute today → $env:AI_TRAINING_LOOP=""
```

不阻塞,不影响 Claude 的回答。

### 触发条件(全部满足才显示)

1. `$env:AI_TRAINING_LOOP -eq "1"`
2. Claude 的最近回复是"实质性"(字数 > 500 / 含代码块 / 含编号步骤)
3. 不是嵌套 Stop(`stop_hook_active != true`)
4. 随机采样命中(默认 1/4)

任一不满足 → 静默退出,你看不到任何输出。
