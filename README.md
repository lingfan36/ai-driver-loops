# ai-driver-loops

> Claude Code skills and hook for training the muscle to **steer AI**, not be steered by it.
>
> 训练"驾驭 AI"能力的 Claude Code 工具集 — 当 AI 跑偏时,第一时间察觉、定位、纠偏。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skills%20%2B%20hooks-orange)](https://claude.com/claude-code)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/lingfan36/ai-driver-loops/issues)

---

## What's inside

| Tool | Type | Loop | Purpose |
|---|---|---|---|
| `ai-deviation-log` | Skill | A | Log AI failure instances — dual mode: quick-capture during flow, batch-process after |
| `deep-domain-sprint` | Skill | D | 4-stage state machine for deep domain study, blocks shortcuts |
| `c-loop-reminder.ps1` | Hook | C | Soft `Stop`-event nudge (sampled 1/4) to scrutinize AI output |

Loop B (predict-before-reveal) is **intentionally not tooled** — see [training framework](docs/training-framework.md#loop-b--predict-before-reveal-daily-mental-habit) for why.

**📖 Full theory + design rationale**: [docs/training-framework.md](docs/training-framework.md)

---

## Install

### Option 1 — One-click (recommended)

Paste the prompt below into your AI CLI. It will clone the repo and install everything.

<details open>
<summary><b>For Claude Code (full install)</b></summary>

```
Install ai-driver-loops for me:

1. git clone https://github.com/lingfan36/ai-driver-loops.git /tmp/ai-driver-loops
   (if exists, git pull)

2. Copy both skill directories to ~/.claude/skills/:
   - /tmp/ai-driver-loops/skills/ai-deviation-log
   - /tmp/ai-driver-loops/skills/deep-domain-sprint
   (Windows: %USERPROFILE%\.claude\skills\)

3. Ask me whether to enable the Loop C hook reminder (Windows + pwsh only).
   If yes:
   - Copy /tmp/ai-driver-loops/hooks/c-loop-reminder.ps1 to ~/.claude/hooks/
   - Merge this into ~/.claude/settings.json (top-level):
     {"hooks":{"Stop":[{"matcher":"","hooks":[{"type":"command","command":"pwsh -NoProfile -ExecutionPolicy Bypass -File \"<HOME>/.claude/hooks/c-loop-reminder.ps1\""}]}]}}
   - Tell me to set AI_TRAINING_LOOP=1 to actually trigger it.

4. Ask about data directory: default ~/ai-loops-data/. If I want to customize,
   set AI_LOOPS_DATA env var. Skills auto-create on first write.

5. Report: paths installed, hook status, verification steps.

Reference: https://github.com/lingfan36/ai-driver-loops
```

</details>

<details>
<summary><b>For other AI CLIs (Cursor / Codex / Aider / Gemini)</b></summary>

```
Adapt ai-driver-loops to my current AI CLI:

1. git clone https://github.com/lingfan36/ai-driver-loops.git
2. Read README.md and skills/*/SKILL.md to understand the four loops (A/B/C/D).
3. Translate the rules into this tool's native config:
   - Cursor: .cursorrules or project rules
   - Codex CLI: ~/.codex/instructions.md or equivalent
   - Aider: .aider.conf.yml or system message
   - Gemini CLI: analogous mechanism
4. Create ~/ai-loops-data/ (or my chosen path) for the Loop A log.
5. Report: which mechanism, install path, how to trigger.
```

PRs upstreaming community adapters are welcome.

</details>

### Option 2 — Manual

```bash
git clone https://github.com/lingfan36/ai-driver-loops.git
cd ai-driver-loops
```

**Skills** (Claude Code, all platforms):

```bash
# macOS / Linux
cp -r skills/ai-deviation-log skills/deep-domain-sprint ~/.claude/skills/

# Windows PowerShell
Copy-Item -Recurse skills\ai-deviation-log,skills\deep-domain-sprint "$env:USERPROFILE\.claude\skills\"
```

**Hook** (Windows + PowerShell 7+, optional): see [hooks/README.md](hooks/README.md) for the `settings.json` snippet and env-var toggle.

---

## Usage

### Loop A — Log a deviation (quick capture)

During an active task, drop a one-liner:

```
> 记一笔: AI 漏了 token 校验,Set 之后没 if get == token
✓ 已入 inbox(第 1 笔待处理)
```

No 4-field interview, no context pollution — back to work in 3 seconds.

Later, batch-process the inbox:

```
> 整理失效日志
共 3 笔待处理。开始过第 1 笔?
```

### Loop D — Start a deep domain sprint

```
> 开始深度冲刺
What's the domain for this sprint?
> token bucket rate limiting
What does "good enough" look like, in one verifiable sentence?
> Can hand-draw the implementation and explain concurrency edge cases.
✓ Sprint created. Entering D-1 Socratic.
What do you think happens when a sudden burst exceeds the bucket capacity?
```

The 4 stages run in order. Skipping is blocked. Sprint state persists across sessions — say `继续冲刺` to resume.

### Loop C — Hook reminder

After Claude finishes a substantive response, ~25% of the time you'll see:

```
💭 [Loop C] Find 3 potential problems in this answer before accepting.
   Did you predict the answer first (Loop B)?
   Caught a mistake → say "记一笔" (or "log AI error")
   Mute today → $env:AI_TRAINING_LOOP=""
```

Non-blocking. Adjustable frequency in the script (see [hooks/README.md](hooks/README.md)).

---

## Configuration

| Env var | Default | Purpose |
|---|---|---|
| `AI_LOOPS_DATA` | `~/ai-loops-data` | Where the deviation log and sprint workspaces live |
| `AI_TRAINING_LOOP` | *(unset)* | Set to `1` to enable the Loop C hook reminder |

Set persistently on Windows:

```powershell
[Environment]::SetEnvironmentVariable("AI_LOOPS_DATA", "D:/knowledge/ai-loops", "User")
[Environment]::SetEnvironmentVariable("AI_TRAINING_LOOP", "1", "User")
```

On macOS / Linux, add to your shell profile (`.zshrc`, `.bashrc`):

```bash
export AI_LOOPS_DATA="$HOME/knowledge/ai-loops"
export AI_TRAINING_LOOP=1
```

---

## Repository layout

```
ai-driver-loops/
├── README.md                       # this file
├── LICENSE                         # MIT
├── docs/
│   └── training-framework.md       # theory: why loops A/B/C/D, KPIs, design rationale
├── skills/
│   ├── ai-deviation-log/           # Loop A
│   └── deep-domain-sprint/         # Loop D
└── hooks/
    ├── README.md                   # hook setup details
    └── c-loop-reminder.ps1         # Loop C
```

Runtime data (not in the repo):

```
$AI_LOOPS_DATA/                     # default: ~/ai-loops-data/
├── ai-deviation-log.md             # Loop A entries
└── sprints/
    └── <topic>-<YYYYMMDD>/         # one directory per Loop D sprint
        ├── meta.md
        ├── 01-socratic-log.md
        ├── 02-sources.md
        ├── 03-artifact.md
        └── 04-grill-log.md
```

---

## Documentation

- **[docs/training-framework.md](docs/training-framework.md)** — the full A/B/C/D theory, KPIs, and design rationale (why each loop is tooled the way it is, including why B is *not* tooled)
- **[hooks/README.md](hooks/README.md)** — hook installation, frequency tuning, platform notes
- **[skills/ai-deviation-log/SKILL.md](skills/ai-deviation-log/SKILL.md)** — Loop A skill internals
- **[skills/deep-domain-sprint/SKILL.md](skills/deep-domain-sprint/SKILL.md)** — Loop D skill internals

---

## Contributing

Issues and PRs welcome at [github.com/lingfan36/ai-driver-loops/issues](https://github.com/lingfan36/ai-driver-loops/issues).

High-value contributions:

- **macOS / Linux port of the hook** (`bash` or Python equivalent of `c-loop-reminder.ps1`)
- **Adapters for non-Claude CLIs** — Cursor rules, Aider config, Codex instructions, etc.
- **Failure-mode taxonomy expansions** based on real-world `ai-deviation-log` usage

---

## License

[MIT](LICENSE)
