<#
.SYNOPSIS
    OpenClaw 配置自动同步到 GitHub 脚本
.DESCRIPTION
    将 workspace 聊天记录备份并推送到 GitHub 仓库
#>

# 设置错误处理
$ErrorActionPreference = "Stop"

# 定义路径
$SourceDir = "C:\Users\Administrator\.openclaw\workspace"
$BackupDir = "D:\Jim\openclawd\backup\workspace"
$RepoDir = "D:\Jim\openclawd"

Write-Host "🚀 开始 OpenClaw 配置同步..." -ForegroundColor Cyan

# 1. 创建备份目录（如果不存在）
if (-not (Test-Path -Path $BackupDir)) {
    Write-Host "📁 创建备份目录: $BackupDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
}

# 2. 使用 robocopy 同步数据
Write-Host "📂 正在同步 workspace 数据..." -ForegroundColor Yellow
$robocopyArgs = @(
    '"$SourceDir"',
    '"$BackupDir"',
    "/MIR",  # 镜像同步（删除目标中源没有的文件）
    "/R:3",  # 重试 3 次
    "/W:5",  # 每次重试间隔 5 秒
    "/NDL",  # 不显示目录列表
    "/NFL",  # 不显示文件列表
    "/NJH",  # 不显示作业头
    "/NJS"   # 不显示作业摘要
)

$robocopyCmd = "robocopy `"$SourceDir`" `"$BackupDir`" /MIR /R:3 /W:5 /NDL /NFL"
$robocopyResult = Invoke-Expression $robocopyCmd
$exitCode = $LASTEXITCODE

# robocopy 退出码 0-7 都表示成功（0=无变化，1=文件复制成功，2=额外文件被删除等）
if ($exitCode -gt 7) {
    Write-Host "❌ Robocopy 同步失败，退出码: $exitCode" -ForegroundColor Red
    exit 1
}

Write-Host "✅ 数据同步完成" -ForegroundColor Green

# 切换到仓库目录
Set-Location -Path $RepoDir

# 3. 检查是否是 git 仓库
if (-not (Test-Path -Path ".git")) {
    Write-Host "❌ 当前目录不是 Git 仓库，请先执行 git init" -ForegroundColor Red
    exit 1
}

# 4. 添加所有更改
Write-Host "📤 正在添加文件到 Git..." -ForegroundColor Yellow
git add .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ git add 失败" -ForegroundColor Red
    exit 1
}

# 5. 检查是否有更改需要提交
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "ℹ️ 没有新的更改需要提交" -ForegroundColor Cyan
    exit 0
}

# 6. 提交更改（带动态时间戳）
$commitMessage = "Auto-sync backup: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "📝 正在提交: $commitMessage" -ForegroundColor Yellow
git commit -m "$commitMessage"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ git commit 失败" -ForegroundColor Red
    exit 1
}

# 7. 推送到远程仓库
Write-Host "🚀 正在推送到 GitHub..." -ForegroundColor Yellow
git push origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 推送到 GitHub 失败" -ForegroundColor Red
    Write-Host "💡 请检查远程仓库配置" -ForegroundColor Yellow
    Write-Host "   仓库地址: https://github.com/sanjingcheng-crypto/openclaw_project" -ForegroundColor Yellow
    Write-Host "" -ForegroundColor White
    Write-Host "🔧 可能的解决方案:" -ForegroundColor Cyan
    Write-Host "   1. 添加远程仓库: git remote add origin https://github.com/sanjingcheng-crypto/openclaw_project.git" -ForegroundColor White
    Write-Host "   2. 检查网络连接" -ForegroundColor White
    Write-Host "   3. 检查 GitHub 认证权限" -ForegroundColor White
    exit 1
}

# 8. 成功反馈
Write-Host "" -ForegroundColor White
Write-Host "✅ 备份已成功同步至 GitHub" -ForegroundColor Green
Write-Host "   时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
