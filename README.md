# 灵感闪记 (FlashIdea)

快速捕捉、转瞬即逝的灵感。

## 功能特点

- **灵感记录** - 快速记录文字和图片灵感
- **智能分类** - 9种预设分类 + 自定义分类
- **选题管理** - 将灵感发展为选题，跟踪进度
- **拍摄跟踪** - 记录选题的拍摄状态
- **本地存储** - 数据保存在本地，支持离线使用

## 界面预览

- 首页：醒目的流动记录按钮 + 灵感列表
- 灵感列表：支持搜索和分类筛选
- 选题管理：跟踪选题状态和拍摄进度
- 分类管理：自定义灵感分类

## 技术栈

- **Flutter** - 跨平台UI框架
- **Provider** - 状态管理
- **Hive** - 本地数据存储
- **image_picker** - 图片选择

## 运行项目

```bash
# 克隆项目
git clone https://github.com/compassionater/flash-idea.git

# 进入目录
cd flash-idea

# 安装依赖
flutter pub get

# 运行项目
flutter run
```

## 构建 APK

```bash
# Debug 版本
flutter build apk --debug

# Release 版本
flutter build apk --release
```

APK 文件位于：`build/app/outputs/flutter-apk/`

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── idea.dart            # 灵感
│   ├── project.dart         # 选题
│   └── category.dart        # 分类
├── providers/               # 状态管理
├── screens/                 # 页面
├── services/                # 服务
├── theme/                   # 主题
└── widgets/                 # 组件
```

## 许可证

MIT License
