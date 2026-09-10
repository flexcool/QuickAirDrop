# QuickAirDrop

一个轻量级 macOS 菜单栏工具：拖拽文件即可触发 AirDrop 发送，同时支持一键运行常用脚本。

## 功能特性

- **拖拽即传** - 选中文件拖到菜单栏图标，选择「发送到 AirDrop」自动发送
- **拖拽动作选择** - 拖拽后可选：发送到 AirDrop / 运行脚本 / 用默认应用打开
- **快捷启动** - 收藏常用脚本（.py / .js / .sh / .command / .swift 等），菜单栏一键运行
- **选择文件** - 通过菜单选择本地文件发送
- **剪贴板发送** - 快速发送剪贴板中的文件
- **全局快捷键** - 可自定义快捷键，一键呼出菜单并开启/关闭防锁屏
- **防锁屏** - 防止长时间无操作时屏幕自动锁屏
- **开机启动** - 支持设置开机自启动
- **发送历史** - 记录所有 AirDrop 发送记录
- **文件过滤** - 支持按文件类型过滤

## 系统要求

- macOS 13.0 (Ventura) 或更高版本
- Wi-Fi 和蓝牙已开启（AirDrop 所需）

## 安装方式

### 方式一：下载 Release

1. 前往 [Releases](https://github.com/flexcool/QuickAirDrop/releases) 页面
2. 下载最新的 `QuickAirDrop.zip`
3. 解压后将 `QuickAirDrop.app` 拖入 Applications 文件夹
4. 首次打开需要在 系统设置 > 隐私与安全性 中允许运行

### 方式二：从源码构建

```bash
# 克隆仓库
git clone https://github.com/flexcool/QuickAirDrop.git
cd QuickAirDrop

# 安装 XcodeGen
brew install xcodegen

# 生成 Xcode 项目
xcodegen generate

# 打开项目
open QuickAirDrop.xcodeproj
```

## 使用方法

1. 启动 QuickAirDrop，菜单栏会出现图标
2. **拖拽文件** - 选中文件拖到菜单栏图标，弹出动作菜单：发送到 AirDrop / 运行脚本 / 用默认应用打开
3. **点击图标** - 打开弹窗菜单，可选择文件、发送剪贴板或运行收藏的脚本
4. **设置** - 在弹窗中点击"设置"配置各项功能

## 设置

点击菜单栏图标，选择"设置"：

| 选项 | 说明 |
|------|------|
| 开机自启动 | 登录时自动启动 |
| 显示通知 | AirDrop 完成/失败时通知 |
| 允许所有文件类型 | 禁用文件类型过滤 |
| 全局快捷键 | 自定义快捷键，呼出菜单并切换防锁屏（默认 ⌘⇧A） |
| 防锁屏 | 防止长时间无操作时屏幕自动锁屏 |
| 快捷启动 | 收藏脚本，菜单栏一键运行（.py/.js/.sh/.command/.swift 等） |

## 技术架构

- **语言**: Swift 5.9
- **UI 框架**: AppKit + SwiftUI
- **菜单栏**: NSPopover + NSStatusItem
- **拖拽支持**: NSPanel 透明覆盖窗口
- **AirDrop**: NSSharingService API
- **开机启动**: SMAppService (macOS 13+)
- **项目管理**: XcodeGen
- **CI/CD**: GitHub Actions

## 开发

### 项目结构

```
QuickAirDrop/
├── .github/workflows/    # GitHub Actions
├── Project.yml           # XcodeGen 配置
├── QuickAirDrop/
│   ├── Sources/
│   │   ├── App/          # 应用入口 (main.swift, AppDelegate)
│   │   ├── StatusBar/    # 状态栏管理 (StatusBarController, DragOverlayWindow)
│   │   ├── AirDrop/      # AirDrop 核心 (AirDropManager, AirDropDelegate)
│   │   ├── Features/     # 功能模块 (LaunchAtLogin, AirDropHistory, HotKeyManager, LockScreenManager, QuickLaunchManager)
│   │   ├── UI/           # 界面 (PopoverView, SettingsView, HistoryView, HotKeyRecorderView)
│   │   └── Utilities/    # 工具类 (FileValidator, NotificationManager)
│   └── Resources/        # 资源文件
└── Generated/            # 生成的文件
```

### 构建

```bash
# 安装依赖
brew install xcodegen

# 生成项目
xcodegen generate

# 构建
xcodebuild build -scheme QuickAirDrop -configuration Release CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License - 详见 [LICENSE](LICENSE)
