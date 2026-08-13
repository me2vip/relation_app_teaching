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
import 'core/utils/pdf_exporter.dart';
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
            tooltip: '导出完整知识手册 PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => PdfExporter.export(context),
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
}
