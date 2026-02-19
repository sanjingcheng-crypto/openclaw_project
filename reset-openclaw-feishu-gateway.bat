@echo off
title OpenClaw Feishu Gateway Reset

echo ==========================================
echo 1. 结束所有 node.exe 进程...
echo ==========================================
taskkill /F /IM node.exe >nul 2>&1

echo 完成: 所有 node.exe（如存在）已尝试结束。
echo.

echo ==========================================
echo 2. 清理 gateway 状态目录...
echo    目标: C:\Users\Administrator\.openclaw\gateway
echo ==========================================
if exist "C:\Users\Administrator\.openclaw\gateway" (
  rmdir /S /Q "C:\Users\Administrator\.openclaw\gateway"
  echo 已删除 gateway 状态目录。
) else (
  echo 未找到 gateway 目录，跳过删除。
)
echo.

echo ==========================================
echo 3. 设置 OPENCLAW_CONFIG_PATH 环境变量...
echo    D:\Jim\openclawd\openclaw.json
echo ==========================================
set "OPENCLAW_CONFIG_PATH=D:\Jim\openclawd\openclaw.json"
echo 当前 OPENCLAW_CONFIG_PATH=%OPENCLAW_CONFIG_PATH%
echo.

echo ==========================================
echo 4. 从源码启动 OpenClaw Gateway (Feishu)...
echo    工作目录: D:\Jim\openclawd\temp_repo
echo ==========================================
cd /d D:\Jim\openclawd\temp_repo

echo 即将执行:
echo   node .\openclaw.mjs gateway --allow-unconfigured
echo.
node .\openclaw.mjs gateway --allow-unconfigured

echo.
echo Gateway 进程已退出。按任意键关闭窗口...
pause >nul

