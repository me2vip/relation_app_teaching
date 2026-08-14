// 教学关卡独立 App 入口
//
// 从 relation_app 抽取的"教学关卡"模块（位于
// lib/features/floating_window/widgets/social_guide/）原样保留，未做任何内容修改。
// 本文件为适配层，负责：
// 1. 提供应用级 MaterialApp 与 Material 3 主题；
// 2. 通过 [ChangeNotifierProvider] 注入 [AppStyleNotifier]，满足教学对话界面
//    `context.watch<AppStyleNotifier>()` 的依赖；
// 3. 承载 [TeachingLevelEntryWidget] 作为首页。
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_style_system.dart';
import 'core/utils/app_version_info.dart';
import 'core/utils/pdf_exporter.dart';
import 'core/widgets/update_dialog.dart';
import 'features/floating_window/widgets/social_guide/teaching_level_entry_widget.dart';

void main() {
  runApp(const TeachingApp());
}

class TeachingApp extends StatelessWidget {
  const TeachingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppStyleNotifier>(
      create: (_) => AppStyleNotifier(),
      child: MaterialApp(
        title: '社交教练',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5B8DEF),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const TeachingHomePage(),
      ),
    );
  }
}

class TeachingHomePage extends StatelessWidget {
  const TeachingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社交教学关卡'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: '检查更新',
            icon: const Icon(Icons.system_update_rounded),
            onPressed: () => UpdateDialog.show(context),
          ),
          IconButton(
            tooltip: '导出知识手册',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => PdfExporter.export(context),
          ),
          IconButton(
            tooltip: '关于',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showAboutDialog(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: const SafeArea(
        child: TeachingLevelEntryWidget(
          contactId: 'demo',
          contactName: '练习对象',
          contactGender: '未设置',
        ),
      ),
    );
  }

  /// 关于页面：版本号从 pubspec.yaml 动态读取（通过 package_info_plus）
  /// 改版本只需改 pubspec.yaml 的 version 字段，所有地方自动同步。
  static Future<void> _showAboutDialog(BuildContext context) async {
    final AppVersionInfo info = await AppVersionInfo.load();

    if (!context.mounted) return;

    showAboutDialog(
      context: context,
      applicationName: info.appName,
      applicationVersion: info.display,
      applicationLegalese: '© 2026 ${info.appName}',
      applicationIcon: const FlutterLogo(size: 48),
      children: [
        const SizedBox(height: 16),
        const Text(
          '社交技能分级教学与模拟对话练习 App',
          style: TextStyle(fontSize: 13),
        ),
        // 构建号辅助说明（小字灰色，版本+6 这种格式）
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '构建号 ${info.buildNumber} · ${info.full}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.person_outline_rounded, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text('作者：zw',
                style: TextStyle(fontSize: 13, color: Colors.grey[800])),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text('QQ：3125075915',
                style: TextStyle(fontSize: 13, color: Colors.grey[800])),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 4),
        // 应用内检查更新入口：调用 GitHub Release API
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              UpdateDialog.show(context);
            },
            icon: const Icon(Icons.system_update_alt_rounded, size: 18),
            label: const Text('检查更新'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }
}
