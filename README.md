# QuickAirDrop

一个轻量级 macOS 菜单栏工具，支持将文件拖拽到状态栏图标后自动触发 AirDrop 分享。

## 功能特性

- **拖拽即传** - 选中文件拖拽到菜单栏图标，自动启动 AirDrop
- **全局快捷键** - 按下 `⌃⌥⌘A` 快速触发 AirDrop
- **开机启动** - 支持设置开机自启动
- **发送历史** - 记录所有 AirDrop 发送记录
- **最近设备** - 记住常用 AirDrop 目标设备
- **剪贴板监听** - 可选监听剪贴板，发现文件自动提示
- **文件过滤** - 支持按文件类型过滤

## 系统要求

- macOS 13.0 (Ventura) 或更高版本
- Wi-Fi 和蓝牙已开启（AirDrop 所需）

## 安装方式

### 方式一：下载 Release

1. 前往 [Releases](https://github.com/jaryi/QuickAirDrop/releases) 页面
2. 下载最新的 `QuickAirDrop.zip`
3. 解压后将 `QuickAirDrop.app` 拖入 Applications 文件夹
4. 首次打开需要在 系统设置 > 隐私与安全性 中允许运行

### 方式二：从源码构建

```bash
# 克隆仓库
git clone https://github.com/jaryi/QuickAirDrop.git
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
2. **拖拽文件** - 选中文件拖拽到菜单栏图标
3. **右键菜单** - 点击图标打开菜单，可访问设置和历史
4. **快捷键** - 按 `⌃⌥⌘A` 快速触发（可在设置中修改）

## 设置

右键点击菜单栏图标，选择"设置"：

| 选项 | 说明 |
|------|------|
| 开机自启动 | 登录时自动启动 |
| 剪贴板监听 | 监听剪贴板中的文件 |
| 显示通知 | AirDrop 完成/失败时通知 |
| 允许所有文件类型 | 禁用文件类型过滤 |
| 全局快捷键 | 自定义快捷键 |

## 技术架构

- **语言**: Swift 5.9
- **UI 框架**: AppKit + SwiftUI (设置界面)
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
│   │   ├── App/          # 应用入口
│   │   ├── StatusBar/    # 状态栏管理
│   │   ├── AirDrop/      # AirDrop 核心
│   │   ├── Features/     # 功能模块
│   │   ├── UI/           # 界面
│   │   └── Utilities/    # 工具类
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
xcodebuild build -scheme QuickAirDrop -configuration Release
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License - 详见 [LICENSE](LICENSE)
