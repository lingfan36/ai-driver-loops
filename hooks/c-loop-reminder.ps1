# c-loop-reminder.ps1
# Soft reminder for AI training Loop C (强制找茬).
# Fires on Claude Code Stop event. Detects substantive responses, samples 1-in-4.
# Toggle: set $env:AI_TRAINING_LOOP = "1" to enable. Unset/empty to disable.
#
# Part of ai-driver-loops: https://github.com/lingfan36/ai-driver-loops

$ErrorActionPreference = 'SilentlyContinue'

# 1. Toggle check — disabled by default
if ($env:AI_TRAINING_LOOP -ne "1") { exit 0 }

# 2. Read event JSON from stdin (Claude Code hook protocol)
$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

try {
    $event = $raw | ConvertFrom-Json
} catch {
    exit 0
}

# Avoid firing in nested stop loops
if ($event.stop_hook_active -eq $true) { exit 0 }

# 3. Pull last assistant text from the session transcript
$transcriptPath = $event.transcript_path
if (-not $transcriptPath -or -not (Test-Path -LiteralPath $transcriptPath)) { exit 0 }

$lines = Get-Content -LiteralPath $transcriptPath -Tail 100
if (-not $lines) { exit 0 }

[array]::Reverse($lines)

$lastAssistantText = ''
foreach ($line in $lines) {
    try {
        $msg = $line | ConvertFrom-Json
    } catch { continue }

    $role = $null
    if ($msg.type) { $role = $msg.type }
    elseif ($msg.role) { $role = $msg.role }
    elseif ($msg.message.role) { $role = $msg.message.role }

    if ($role -ne 'assistant') { continue }

    $content = $msg.message.content
    if (-not $content) { $content = $msg.content }
    if (-not $content) { continue }

    if ($content -is [string]) {
        $lastAssistantText = $content
        break
    }

    if ($content -is [System.Collections.IEnumerable]) {
        $textParts = @()
        foreach ($block in $content) {
            if ($block.type -eq 'text' -and $block.text) {
                $textParts += $block.text
            }
        }
        if ($textParts.Count -gt 0) {
            $lastAssistantText = ($textParts -join "`n")
            break
        }
    }
}

if ([string]::IsNullOrWhiteSpace($lastAssistantText)) { exit 0 }

# 4. Substantive heuristic — avoid firing on short chitchat
$isSubstantive = $false
if ($lastAssistantText.Length -gt 500) { $isSubstantive = $true }
if ($lastAssistantText -match '```') { $isSubstantive = $true }
if ($lastAssistantText -match '(?m)^\s*\d+\.\s') { $isSubstantive = $true }

if (-not $isSubstantive) { exit 0 }

# 5. Sampling — 1 in 4 substantive responses
# Adjust this number to tune frequency (higher = rarer)
if ((Get-Random -Minimum 0 -Maximum 4) -ne 0) { exit 0 }

# 6. Print soft reminder to stderr (terminal-visible, doesn't affect Claude)
$reminder = @"

💭 [Loop C] Find 3 potential problems in this answer before accepting.
   Did you predict the answer first (Loop B)?
   Caught a mistake → say "记一笔" (or "log AI error")
   Mute today → `$env:AI_TRAINING_LOOP=""

"@

[Console]::Error.WriteLine($reminder)
exit 0
