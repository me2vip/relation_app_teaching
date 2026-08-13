# 社交教练

社交技能分级教学与模拟对话练习 App —— 从陌生破冰到深度连接，10 级闯关 + 10 大关系模式 + 完整知识词典 + 跨 AI 提示词体系。

## 功能

- **10 级分级教学关卡**：初次问候 → 自我介绍 → 倾听技巧 → 话题延展 → 情绪共鸣 → 冲突化解 → 深度连接 → 影响力沟通 → 关系修复 → 毕业考核
- **10 大关系模式**：通用 / 追女生 / 追男生 / 维系关系 / 职场社交 / 群体社交 / 家庭沟通 / 陌生人破冰 / 跨圈层社交 / 网络社交，每种模式为每个关卡提供定制化场景
- **48 条知识词典**：覆盖 17 大分类（破冰、倾听、情绪共鸣、肢体语言、社交媒体情报等）
- **26 个快速练习场景**：按难度分级（简单/中等/困难），碎片化练习
- **导出知识手册**：支持导出 PDF 和 Markdown，可在其他对话 AI 中直接使用内置提示词进行练习和考核
- **关于页面**：作者信息

## 截图

<p align="center">
  <img src="screenshots/home_screen.png" alt="首页-关卡列表" width="200"/>
  <img src="screenshots/knowledge_list.png" alt="知识词典列表" width="200"/>
  <img src="screenshots/knowledge_detail.png" alt="知识词典详情" width="200"/>
</p>

<p align="center">
  <img src="screenshots/dialogue_practice.png" alt="对话练习界面" width="200"/>
  <img src="screenshots/quick_practice.png" alt="快速练习界面" width="200"/>
</p>

## 技术栈

- Flutter / Dart
- Material 3
- Provider 状态管理
- share_plus（系统分享）
- path_provider（文件存储）

## 开始使用

```bash
flutter pub get
flutter run
```

构建发布版：

```bash
flutter build apk --release
```

## 项目结构

```
lib/
├── main.dart                          # 应用入口
├── core/
│   ├── theme/                         # 主题
│   └── utils/
│       └── pdf_exporter.dart          # 导出服务（PDF / Markdown）
├── shared/
│   └── widgets/
│       └── app_toast.dart             # 轻提示组件
└── features/
    └── floating_window/widgets/social_guide/
        ├── teaching_level_system.dart       # 关卡+知识词典+模式定义
        ├── teaching_level_entry_widget.dart  # 关卡入口
        ├── quick_practice_widget.dart        # 快速练习
        └── social_knowledge_base.dart        # 知识词典浏览
```

## 导出文件

应用内置完整知识手册，支持两种格式导出：

- **PDF**（`assets/pdf/社交教练_完整知识手册.pdf`）：适合阅读、打印、分享
- **Markdown**（`assets/markdown/社交教练_完整知识手册.md`）：适合编辑、导入其他 AI 对话使用

手册包含 7 大部分：通用系统提示词、10 级关卡详解、10 大关系模式、48 条知识词典、26 个练习场景、评分规则、7 个快速提示词模板。

## 作者

- 作者：zw
- QQ：3125075915

## License

© 2026 社交教练
