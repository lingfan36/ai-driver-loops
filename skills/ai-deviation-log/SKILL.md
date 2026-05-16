---
name: ai-deviation-log
description: 记录"识破 AI 输出错误"的实例,积累个人 AI 失效模式手册。两个模式 —— (1) 快捕:用户在做别的事时,一句话快速入笔,绝不打断 flow;(2) 批处理:用户专门说"整理失效日志"时,逐条把 inbox 里的条目过一遍。触发词:"记一笔"、"/log-deviation"、"AI 错了"、"整理失效日志"、"/ai-deviation-log"。这是 ai-driver-loops 训练框架的回路 A 工具。
---

# AI 失效日志(回路 A)

**核心铁律**:用户随时可能在排查问题/写代码/调研中,**捕获不能打断他的 flow**。这条规则压过其他一切。

## 数据位置

数据文件路径由环境变量 `AI_LOOPS_DATA` 决定,默认 `~/ai-loops-data/`。

完整路径:`$AI_LOOPS_DATA/ai-deviation-log.md`

如果文件不存在,首次写入前要创建,并写入下方"初始模板"。

### 初始模板(首次创建用)
```markdown
# AI 失效日志

> 回路 A 数据文件。框架见 https://github.com/lingfan36/ai-driver-loops

## 统计
- 正式条目数: 0
- Inbox 待处理: 0

## Inbox(待处理)
_暂无_

## 日志条目
_等待第一条_
```

---

## 判断模式

| 用户表达 | 模式 |
|---|---|
| 给了一句话描述错误 / 在做别的事中插一句 | **Mode 1: 快捕** |
| 明确说"整理 / 处理 / 过一遍 inbox / 看看 inbox" | **Mode 2: 批处理** |
| 既没描述也没说处理 + inbox 非空 | 反问一句 "快捕新的 / 处理 inbox?" |

---

## Mode 1: 快捕(默认 / in-flow)

**绝不打断用户**。流程:

1. **抽取**(自己脑子里,不用工具):
   - 用户那一句话里包含什么:错在哪 / 我怎么发现的 / 可能的归类
   - 从**最近对话**找出 AI 出错的那段输出,截成 ≤200 字片段
2. **立即用 Agent 工具 spawn 后台 subagent**,参数:
   - `subagent_type: "general-purpose"`
   - `run_in_background: true`
   - `description: "写入失效日志"`
   - `prompt:` 包含 ① 用户一句话 ② AI 输出片段 ③ 自动归类(若有) ④ 写入指令(见下)
3. **主线程返回一行**:`✓ 已入 inbox(第 N 笔待处理)`,然后**立即回到用户原来在做的事**
4. 后台完成通知到达时,**只回应一行**:`✓ 已落盘`,不展开

### 关键禁令(违反就是 skill 失败)

- ❌ 在主线程问用户任何问题
- ❌ 复述/展开/分析用户的内容
- ❌ 在主线程读 `ai-deviation-log.md`
- ❌ 写出"接下来我会..."、"这条很有价值..."这类填充话
- ❌ 让这一笔打断当前正在做的事(bug 排查、代码修改、讨论...)

### 给后台 subagent 的 prompt 模板

```
追加一条 AI 失效日志到 $AI_LOOPS_DATA/ai-deviation-log.md 的 ## Inbox 区段。
路径解析:$env:AI_LOOPS_DATA 优先,否则 ~/ai-loops-data/。文件不存在则按初始模板创建。

数据:
- 用户一句话: <user oneliner>
- AI 出错的输出片段: <snippet ≤200 chars>
- 推测归类: <category or "未定">
- 时间: <YYYY-MM-DD HH:MM>

操作:
1. Read 该文件,定位 `## Inbox(待处理)` 区段
2. 按以下格式 append 一条:

   ### [inbox-N] <YYYY-MM-DD HH:MM> | <用户一句话标题>
   - **AI 给的方案**: <snippet>
   - **错在哪**: <从用户一句话提取,提取不到写 "TODO">
   - **我怎么发现的**: <从用户一句话提取,提取不到写 "TODO">
   - **失效归类**: `<category 或 待定>`

3. 更新顶部"统计"区的"Inbox 待处理"计数 +1
4. 返回一行: "✓ 入 inbox 完毕,当前 N 笔待处理"

不要修改任何已有条目。不要扩展或重写任何内容。
```

---

## Mode 2: 批处理(用户主动 trigger)

用户已退出 flow,**可以慢、可以仔细**。

1. Read `$AI_LOOPS_DATA/ai-deviation-log.md`,聚焦 `## Inbox` 区段
2. 给用户一个总览:"共 N 笔待处理。开始过第 1 笔?"
3. **逐条过**,每条:
   - 展示当前 4 个字段(高亮 TODO 项)
   - 问用户:"补一下「我怎么发现的」?其他要不要改?"
   - 用户确认后,把这条从 Inbox **移到** `## 日志条目` 区段,正式编号
   - 应用 SKILL 末尾的"反馈"逻辑(里程碑/同类高频提醒)
4. 全部处理完:
   - 清空 Inbox 区段(或留 "_暂无_")
   - 重算并更新顶部"统计"

---

## 失效类别(快捕时用于自动归类,批处理时供用户选)

`幻觉` / `边界条件` / `上下文丢失` / `乐观估计` / `路径依赖` / `过度抽象` / `表面合理` / `工具误用` / `规模误判`

用户自定义的新类别采纳后,登记到日志末尾"扩展类别"区。

---

## 反馈逻辑(只在 Mode 2 末尾跑)

- 总条目数到 10 / 30 / 50 / 100 → 提示里程碑
- 最近 5 条里 ≥ 3 条同类 → 提示"这个类别最近高频,值得专门看一下规律"
- 累计 ≥ 30 条 → 提示"可以生成 `$AI_LOOPS_DATA/ai-failure-modes.md` 归纳页"

## 路径

- 数据文件: `$AI_LOOPS_DATA/ai-deviation-log.md`(默认 `~/ai-loops-data/ai-deviation-log.md`)
- 归纳输出: `$AI_LOOPS_DATA/ai-failure-modes.md`
- 训练框架: https://github.com/lingfan36/ai-driver-loops
