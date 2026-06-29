$ErrorActionPreference = "Stop"

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Assert-True {
  param(
    [bool] $Condition,
    [string] $Message
  )

  if (-not $Condition) {
    throw $Message
  }
}

function Assert-Contains {
  param(
    [string] $Path,
    [string] $Pattern
  )

  $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
  Assert-True ($content.Contains($Pattern)) "$Path missing pattern: $Pattern"
}

$skillPath = Join-Path $root "SKILL.md"
$readmePath = Join-Path $root "README.md"

Assert-Contains $skillPath "name: kdskill"
Assert-Contains $skillPath "/kdskill"
Assert-Contains $skillPath "kd skill"
Assert-Contains $skillPath ".kdskill-state.md"
Assert-Contains $skillPath ".distill-state.md"
Assert-Contains $readmePath "~/.claude/skills/kdskill/"
Assert-Contains $readmePath "/kdskill"

$referencedFiles = @(
  "知识博主-单条视频蒸馏模板.md",
  "知识博主-批量蒸馏开工指南.md",
  "知识博主-钩子金句资产提取指南.md",
  "知识博主-综合汇总-第一阶段.md",
  "知识博主-综合汇总-第二阶段.md",
  "知识博主-综合汇总-第三阶段.md"
)

foreach ($relativePath in $referencedFiles) {
  $path = Join-Path $root $relativePath
  Assert-True (Test-Path -LiteralPath $path) "missing referenced workflow file: $relativePath"
}

$workDir = Join-Path ([System.IO.Path]::GetTempPath()) ("kdskill-smoke-" + [System.Guid]::NewGuid().ToString("N"))

try {
  $sourceDir = Join-Path $workDir "目标博主\00原文件\01测试"
  New-Item -ItemType Directory -Path $sourceDir | Out-Null

  $srtPath = Join-Path $sourceDir "测试视频.srt"
  $srt = @"
1
00:00:00,000 --> 00:00:02,000
这是一个用于验证 kdskill 输入路径的测试字幕。

2
00:00:02,000 --> 00:00:04,000
这里模拟知识博主视频中的一个方法论观点。
"@
  Set-Content -LiteralPath $srtPath -Value $srt -Encoding UTF8

  $statePath = Join-Path $workDir ".kdskill-state.md"
  $state = @"
# kdskill state

- 当前步骤：1
- 输入目录：$sourceDir
- 输出目录：待生成
- 最近更新：smoke test
"@
  Set-Content -LiteralPath $statePath -Value $state -Encoding UTF8

  Assert-True (Test-Path -LiteralPath $srtPath) "smoke SRT was not created"
  Assert-True (Test-Path -LiteralPath $statePath) "smoke state file was not created"
  Assert-Contains $srtPath "00:00:00,000 --> 00:00:02,000"
  Assert-Contains $statePath "kdskill state"
  Assert-Contains $statePath "当前步骤"
}
finally {
  if (Test-Path -LiteralPath $workDir) {
    Remove-Item -LiteralPath $workDir -Recurse -Force
  }
}

Write-Output "validate-kdskill-smoke: PASS"

