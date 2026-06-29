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

function Assert-File {
  param([string] $RelativePath)
  $path = Join-Path $root $RelativePath
  Assert-True (Test-Path -LiteralPath $path) "missing file: $RelativePath"
}

function Assert-Contains {
  param(
    [string] $RelativePath,
    [string] $Pattern
  )

  $path = Join-Path $root $RelativePath
  $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  Assert-True ($content.Contains($Pattern)) "$RelativePath missing pattern: $Pattern"
}

function Assert-NotContains {
  param(
    [string] $RelativePath,
    [string] $Pattern
  )

  $path = Join-Path $root $RelativePath
  $content = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  Assert-True (-not $content.Contains($Pattern)) "$RelativePath should not contain pattern: $Pattern"
}

Assert-File "README.md"
Assert-File "README-使用说明.md"
Assert-File "SKILL.md"
Assert-File "CLAUDE.md"
Assert-File "LICENSE"
Assert-File "知识博主-单条视频蒸馏模板.md"
Assert-File "知识博主-批量蒸馏开工指南.md"
Assert-File "知识博主-钩子金句资产提取指南.md"
Assert-File "知识博主-内容蒸馏与视频拆解-提示词库.md"
Assert-File "知识博主-综合汇总-第一阶段.md"
Assert-File "知识博主-综合汇总-第二阶段.md"
Assert-File "知识博主-综合汇总-第三阶段.md"

Assert-Contains "README.md" "知识博主蒸馏工具包"
Assert-Contains "README.md" "/kdskill"
Assert-Contains "README.md" "SRT 字幕"
Assert-Contains "README.md" "钩子金句资产库"
Assert-Contains "SKILL.md" "name: kdskill"
Assert-Contains "SKILL.md" "Trigger: kdskill, kd skill"
Assert-Contains "SKILL.md" ".kdskill-state.md"
Assert-Contains "SKILL.md" "蒸馏"
Assert-Contains "知识博主-单条视频蒸馏模板.md" "道法术"
Assert-Contains "知识博主-钩子金句资产提取指南.md" "hooks.jsonl"
Assert-Contains "知识博主-钩子金句资产提取指南.md" "golden_lines.jsonl"
Assert-NotContains "README.md" "/distill"
Assert-NotContains "README.md" "skills/distill"
Assert-NotContains "SKILL.md" "name: distill"

$insideGitWorktree = $false
try {
  $insideGitWorktree = ((git -C $root rev-parse --is-inside-work-tree 2>$null) -eq "true")
}
catch {
  $insideGitWorktree = $false
}

if (-not $insideGitWorktree) {
  $gitDir = Join-Path $root ".git"
  Assert-True (-not (Test-Path -LiteralPath $gitDir)) "copied project should not include .git directory"
}

Write-Output "validate-distill-method: PASS"

