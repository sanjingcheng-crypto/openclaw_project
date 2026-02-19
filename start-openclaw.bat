@echo off
title OpenClaw Starter
setlocal

REM 使用你的配置文件
set OPENCLAW_CONFIG_PATH=D:\Jim\openclawd\openclaw.json

REM 进入 OpenClaw 仓库
cd /d D:\Jim\openclawd\temp_repo

echo ==========================================
echo 启动 OpenClaw Gateway...
echo 配置文件: %OPENCLAW_CONFIG_PATH%
echo 端口     : 59999
echo Token    : 123456
echo ==========================================
echo.

REM 在新窗口中启动 Gateway，便于查看日志
start "OpenClaw Gateway" cmd /k ^
"set OPENCLAW_CONFIG_PATH=%OPENCLAW_CONFIG_PATH% && node openclaw.mjs gateway --allow-unconfigured --ws-log compact --verbose"

REM 等待几秒，给 Gateway 启动时间
echo 正在等待 Gateway 启动...
ping 127.0.0.1 -n 8 >nul

REM 目标地址
set URL=http://127.0.0.1:59999/?token=123456

REM 优先尝试常见 Chrome 路径
if exist "C:\Program Files\Google\Chrome\Application\chrome.exe" (
  start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" "%URL%"
  goto :EOF
)

if exist "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" (
  start "" "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" "%URL%"
  goto :EOF
)

REM 如果没找到 Chrome，就用系统默认浏览器打开
start "" "%URL%"

:EOF
endlocal
exit