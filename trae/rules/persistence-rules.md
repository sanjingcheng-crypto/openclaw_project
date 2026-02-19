🛠️ 工具安装与持久化规则 (Trae Persistence Rules)
===============================================

A. 全局环境预设 (Global Environment)
-----------------------------------

在执行任何安装前，Trae 必须确保基础环境符合以下要求：

- 镜像源：必须锁定国内镜像  
  - `https://registry.npmmirror.com`
- 网络参数：所有安装指令必须附加 `--no-proxy` 参数。
- 管理权限：若遇到 `EACCES` 或 `permission denied` 报错，立即停止并提醒用户：  
  > 检测到权限不足，请开启管理员权限 (Administrator Privileges) 后重试。

B. 核心方案：pnpm 寻址存储（最推荐）
------------------------------------

为了实现“一次下载，处处复用”，Trae 应优先引导用户使用 pnpm：

1. 全局安装 pnpm（若本地未安装）：

   ```bash
   npm install -g pnpm --registry=https://registry.npmmirror.com --no-proxy
   ```

2. 依赖安装逻辑：

   - 使用 `pnpm install` 代替 `npm install`。
   - pnpm 会自动利用本地 `~/.pnpm-store`（全局存储），新项目安装时通过硬链接完成复用，无需重复下载。

C. 备选方案：全局链接 (Installation Priority)
--------------------------------------------

若用户坚持使用 npm 或特定工具需要全局运行，Trae 必须按此顺序操作：

1. 检查全局是否已安装目标包：

   ```bash
   npm list -g <package-name>
   ```

2. 如未安装，全局安装该包：

   ```bash
   npm install -g <package-name> --registry=https://registry.npmmirror.com --no-proxy
   ```

3. 在当前项目中通过全局链接引用：

   ```bash
   npm link <package-name>
   ```

   要求：通过软链接引用全局包，禁止在本地 `node_modules` 中重复完整下载相同依赖。

D. 自动化配置指令
-----------------

当 Trae 初始化一个新工程时，应主动询问或执行以下配置，以确保 pnpm 指向国内源：

```bash
pnpm config set registry https://registry.npmmirror.com
```

"如果项目没有 pnpm，优先使用 npx pnpm install 并带上 --registry=https://registry.npmmirror.com --no-proxy --ignore-scripts 以确保极速且安全的初始化。"

E. 特殊依赖处理 (GitHub Dependencies)

当遇到指向 github.com 或 codeload.github.com 的依赖安装失败时，Trae 应意识到 --no-proxy 可能导致连接重置。

策略：优先检查 pnpm-store 是否已有缓存；若无，询问用户是否允许通过代理下载该特定包，安装成功后立即恢复 --no-proxy 环境。

F. OpenClaw 飞书连接故障标准修复流程 (SOP)
-----------------------------------------

当用户反馈“飞书没反应”“长连接断开”“配置不生效”时，Trae 必须优先按以下顺序执行：

1. 彻底清场（杀进程）

   ```powershell
   taskkill /F /IM node.exe
   ```

   要求：确保所有遗留的 Node 网关进程被杀掉，避免端口占用或旧版本逻辑残留。

2. 清理网关缓存状态

   ```powershell
   Remove-Item -Recurse -Force "C:\Users\Administrator\.openclaw\gateway"
   ```

   要求：清理残留的 gateway 状态文件，避免旧状态干扰新配置（如端口锁文件、上次运行的快照等）。

3. 显式指定配置路径启动

   ```powershell
   $env:OPENCLAW_CONFIG_PATH = "D:\Jim\openclawd\openclaw.json"
   ```

   要求：任何后续与 OpenClaw 相关的启动命令（尤其是 gateway）都在当前会话中显式带上该环境变量，确保使用的是用户指定的配置文件，而不是全局默认 profile。

4. 源码优先启动 Gateway

   ```powershell
   cd D:\Jim\openclawd\temp_repo
   node .\openclaw.mjs gateway
   ```

   要求：优先从源码仓库启动网关，保证运行的是当前 temp_repo 中的最新代码逻辑，而不是全局安装的旧版 openclaw（如 C:\Users\Administrator\AppData\Roaming\npm\node_modules\openclaw）。如需调试 Feishu 行为，所有变更应先在 temp_repo 中修改并通过此命令启动验证。

G. Trae 自动执行原则 (能自己做就不要让用户做)
---------------------------------------------

在具备足够权限且不会破坏用户环境安全的前提下，Trae 在执行任何“可自动化”的操作时，必须遵守以下原则：

- 若步骤是“在某目录新建/修改/删除文件”“写入脚本内容”“更新配置文本”等，且 Trae 在当前仓库有写权限，则应直接使用编辑工具在本地完成，不再提示用户手动复制、粘贴或新建文件。
- 只有当操作超出 Trae 能力范围（例如需要在图形界面中点击、涉及物理设备、或用户需在外部系统中登录授权）时，才应把具体步骤交给用户，并尽量给出最简洁的一步到位指令。
- 对于重复性较高的运维/调试流程（如本文件中定义的 OpenClaw 飞书连接故障 SOP），若可以通过脚本或配置自动化（例如 .bat/.ps1/.sh 脚本），Trae 应优先主动创建或更新这些脚本，而非让用户根据说明手工操作。
