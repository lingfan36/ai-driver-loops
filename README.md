# ai-driver-loops

> **A training framework for AI-native developers**: build the skill to steer AI instead of being steered by it.
>
> 一套 Claude Code 的 skills + hook,用来训练"驾驭 AI"的能力 — 不是脱离 AI 自己写,而是当 AI 跑偏时第一时间察觉、定位、纠偏。

---

## 为什么需要这个

如果你是一名常年用 AI 协作开发的工程师/PM,你大概有过这种感受:

- 客观上你产出在涨,主观上像在原地踏步
- AI 出方案你能用,但**"我到底学到了什么"** 说不清
- 想"驾驭" AI,但不知道怎么练这个肌肉
- 焦虑感来源是:**进步信号被 AI 吃掉了**

这是 AI-mediated development 的结构性副作用。整个行业现在都在踩这个坑。

**北极星定义**(你要练的能力):

> 当 AI 跑偏时,**第一时间察觉、定位、纠偏**。
> 自动驾驶是它的,方向盘是你的。

---

## 这个能力由 4 层构成

| 层 | 内容 |
|---|---|
| 1 | **领域先验** — 你脑子里"对的样子"长什么样,判断跑偏的基准 |
| 2 | **AI 失效模式直觉** — 知道 AI 在哪类问题、用什么方式偏 |
| 3 | **关键阅读速度** — 30 秒扫出问题点,而不是逐行复核 |
| 4 | **精准纠偏能力** — 一句话拉回,而不是推倒重写 |

绝大多数人卡在第 1、2 层。3、4 层只是熟练度。

---

## 四个训练回路

### 🟢 回路 A:AI 失效日志(日常)

每次识破 AI 一个错,30 秒记一条(场景 / 错在哪 / 我怎么发现的 / 归类)。
**积满 30 条 = 一份只属于你的 AI 失效模式手册**,而且能直接看到"上周没识破的这周识破了"的进步信号。

→ 工具:**`ai-deviation-log` skill**(双模式 — 快捕不打断 flow + 批处理)

### 🟢 回路 B:预判再揭晓(日常,纯心智)

AI 出方案前,先用一句话预测"它会怎么做、会在 X 翻车"。再看实际输出。命中率走高 = 直觉对齐真实世界。

→ **不工具化**(刻意保留为主动习惯,工具化反而失真)

### 🟢 回路 C:强制找茬 + 软提醒(日常)

拿一份"看着没问题"的 AI 输出,**强迫自己挑出 3 个问题**,哪怕硬挑。训练主动审视的肌肉 — 大多数人栽就栽在"看着对就过了"。

→ 工具:**`c-loop-reminder.ps1` hook**(在 Claude Code 答完实质性回复时,1/4 概率柔提示)

### 🟢 回路 D:深度领域冲刺(每两周一次)

选一个领域,4 阶段不跳步:**苏格拉底学习 → 非 AI 源 cross-check → 必有产物 → 反向 grill**。
用 AI 用得深,而不是绕开 AI。

→ 工具:**`deep-domain-sprint` skill**(状态机,逼你不跳步)

---

## 进步 KPI(周记)

| 指标 | 目标方向 |
|---|---|
| 抓到 AI 错误数 | 稳步涨 |
| 抓到时机(输出前 / 中 / 后) | 越来越靠前 |
| 第一版 prompt 直接可用比例 | 涨 |
| "无 AI 也懂"的新概念数 | 每周 ≥ 2 |

这是"你在握 AI 方向盘"的客观证据,比凭感觉判断准得多。

---

## 🚀 一键安装(让 AI 给你装)

复制下面整段提示词,**粘贴给你的 AI CLI(Claude Code / Codex / Cursor Agent / Aider 等)**,它会自动完成全部安装。

<details open>
<summary><b>给 Claude Code(完整安装,含 hook)</b></summary>

```
请帮我安装 ai-driver-loops(Claude Code 的 AI 驾驭训练工具),步骤:

1. 克隆仓库:git clone https://github.com/lingfan36/ai-driver-loops.git /tmp/ai-driver-loops
   (如果存在则 git pull)

2. 复制两个 skill 到全局 skills 目录:
   - /tmp/ai-driver-loops/skills/ai-deviation-log → ~/.claude/skills/ai-deviation-log
   - /tmp/ai-driver-loops/skills/deep-domain-sprint → ~/.claude/skills/deep-domain-sprint
   Windows 路径为 %USERPROFILE%\.claude\skills\

3. 询问我是否要启用回路 C 的 hook 软提醒(每答完实质性内容 1/4 概率提示挑错)。
   若启用:
   - 复制 /tmp/ai-driver-loops/hooks/c-loop-reminder.ps1 到 ~/.claude/hooks/
   - 在 ~/.claude/settings.json 顶层合并(已存在 hooks 则 merge):
     {
       "hooks": {
         "Stop": [{
           "matcher": "",
           "hooks": [{
             "type": "command",
             "command": "pwsh -NoProfile -ExecutionPolicy Bypass -File \"<HOME>/.claude/hooks/c-loop-reminder.ps1\""
           }]
         }]
       }
     }
     (<HOME> 替换为我的实际 home 绝对路径)
   - 提示我:重启 Claude Code,设置环境变量 AI_TRAINING_LOOP=1 才会真触发

4. 询问数据目录:默认 ~/ai-loops-data/。若我想自定义,设置 AI_LOOPS_DATA 环境变量。
   不需要先创建,skills 首次写入时会自建。

5. 安装完毕后报告:
   - 装到了哪些路径
   - hook 装没装
   - 验证方式:重启后说"记一笔: 测试"应该触发 /ai-deviation-log

仓库说明:https://github.com/lingfan36/ai-driver-loops
```

</details>

<details>
<summary><b>给其他 AI CLI(Codex / Cursor Agent / Aider / Gemini CLI 等)</b></summary>

skills + hook 是 Claude Code 特有机制,其他 CLI 暂无对应加载点。但你仍然可以用本仓库的**理念**和**数据格式**——把训练框架(A/B/C/D)做成你工具里的等价物:

```
请帮我适配 ai-driver-loops 到当前 AI CLI:

1. 克隆 https://github.com/lingfan36/ai-driver-loops.git
2. 阅读 README.md 和 skills/*/SKILL.md,理解四个回路(A/B/C/D)的意图
3. 把这些规则转化成当前工具支持的形式:
   - Cursor: 写入 .cursorrules 或项目 rules
   - Codex CLI: 写入 ~/.codex/instructions.md 或对应配置
   - Aider: 写入 .aider.conf.yml 或 system message
   - Gemini CLI: 类比处理
4. 创建数据目录 ~/ai-loops-data/(或我指定的位置)用于回路 A 的失效日志
5. 报告:适配到了哪种机制、装在哪、怎么触发

社区适配版欢迎 PR 回上游仓库。
```

</details>

---

## 手动安装

如果你想自己操作(或上面的一键不工作),走这套:

### 1. 克隆仓库

```bash
git clone https://github.com/lingfan36/ai-driver-loops.git
cd ai-driver-loops
```

### 2. 安装 skills 到 Claude Code

复制(或软链接)两个 skill 目录到 Claude Code 的全局 skills 目录:

**Windows (PowerShell):**
```powershell
Copy-Item -Recurse skills\ai-deviation-log "$env:USERPROFILE\.claude\skills\"
Copy-Item -Recurse skills\deep-domain-sprint "$env:USERPROFILE\.claude\skills\"
```

**macOS / Linux:**
```bash
cp -r skills/ai-deviation-log ~/.claude/skills/
cp -r skills/deep-domain-sprint ~/.claude/skills/
```

### 3. 安装 hook(回路 C 提醒,可选)

**仅 Windows / PowerShell 7+** (其他平台见 [hooks/README.md](hooks/README.md)):

```powershell
# 复制脚本
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\hooks" | Out-Null
Copy-Item hooks\c-loop-reminder.ps1 "$env:USERPROFILE\.claude\hooks\"
```

然后在 `~/.claude/settings.json` 的 `hooks` 区添加:

```json
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
```

把 `<HOME>` 替换为你的实际 home 路径(Windows 例:`C:/Users/yourname`)。

启用:
```powershell
[Environment]::SetEnvironmentVariable("AI_TRAINING_LOOP", "1", "User")
```

关闭:
```powershell
[Environment]::SetEnvironmentVariable("AI_TRAINING_LOOP", $null, "User")
```

### 4. 配置数据目录

skills 会在你的 home 下创建一个 `ai-loops-data/` 目录(也可以通过 `AI_LOOPS_DATA` 环境变量自定义):

```powershell
# 自定义(可选)
[Environment]::SetEnvironmentVariable("AI_LOOPS_DATA", "D:/my-knowledge/ai-loops", "User")
```

默认会用 `~/ai-loops-data/`。

---

## 使用

### 回路 A:记一笔 AI 失效

排查中突然发现 AI 漏写了 token 校验:

```
你: 记一笔: AI 漏了 token 校验,我看到 Set 后没 if get == token 就觉得不对
Claude: ✓ 已入 inbox(第 1 笔待处理)
```

主线程不读文件、不问你 4 个字段、不打断 flow。**3 秒回到原本在做的事**。

等空闲了,批处理:

```
你: 整理失效日志
Claude: 共 3 笔待处理。开始过第 1 笔?
        [展示当前字段,问 TODO 项要不要补]
```

### 回路 C:hook 提示

Claude 答完一个长方案后,**约 1/4 概率**终端尾部多一行:

```
💭 [回路 C] 挑这版方案的 3 个潜在问题再接受;刚才有没有先做 B 预判?
   抓到错 → 说"记一笔"      关闭今日提示 → $env:AI_TRAINING_LOOP=""
```

不阻塞,可随时关。

### 回路 D:深度冲刺

```
你: 开始深度冲刺
Claude: 这次冲刺的领域是?
你: 限流
Claude: 太大了。具体到哪个子问题?token bucket?leaky bucket?滑动窗口?
你: token bucket
Claude: 学到什么程度算够?用一句可判定的话写出来。
你: 能徒手画出实现并解释并发场景下的边界
Claude: ✓ Sprint 已建立。进入 D-1 苏格拉底学习。
        你猜 token bucket 怎么处理"短时间高并发突刺"?
```

整个 4 阶段全程,**禁止跳步**(D-2 想跳过会被拒)、**禁止糊弄**(D-3 想用 AI 整段代码当产物会被拒)。

---

## 文件结构

```
ai-driver-loops/
├── README.md
├── LICENSE
├── skills/
│   ├── ai-deviation-log/
│   │   ├── SKILL.md
│   │   └── template.md
│   └── deep-domain-sprint/
│       └── SKILL.md
└── hooks/
    ├── README.md
    └── c-loop-reminder.ps1
```

数据(运行时生成,不在仓库内):

```
$AI_LOOPS_DATA/                 (默认 ~/ai-loops-data/)
├── ai-deviation-log.md         # 回路 A 数据
├── sprints/                    # 回路 D 每次冲刺一个目录
│   └── <topic>-<YYYYMMDD>/
│       ├── meta.md
│       ├── 01-socratic-log.md
│       ├── 02-sources.md
│       ├── 03-artifact.md
│       └── 04-grill-log.md
└── ai-failure-modes.md         # 回路 A 积满 30 条后归纳产物
```

---

## 核心原则

> **全程 AI 在场,但你的脑子始终在驾驶位。**

- 不绕开 AI(那是反工具化)
- 也不被 AI 喂着走(那是更高级的刷短视频)
- "用 AI 用得深 / 用得对"才是路径

---

## 设计上的取舍(为什么是这样)

- **A 用双模 skill**:排查 flow 神圣不可侵犯,捕获必须 3 秒内完成。质量字段(尤其"我怎么发现的")事后批处理补,不让后台 agent 编。
- **B 不工具化**:B 的本质是"在看到 AI 答案**之前**预判",任何 hook 都来不及。强行工具化会变成事后诸葛,失去训练价值。
- **C 用 hook 而不是 skill**:C 是软提醒,主动调用 skill 反而太重。采样 1/4 防止训练成空气。
- **D 用状态机 skill**:固定 4 阶段流程,skill 强约束防跳步。这是仪式,工具化反而强化仪式感。

---

## 反馈 / 贡献

- 在 [issues](https://github.com/lingfan36/ai-driver-loops/issues) 反馈使用问题
- PR 欢迎 — 尤其是 macOS/Linux 版本的 hook

---

## License

MIT
