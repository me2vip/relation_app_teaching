// 应用风格系统（适配层）
//
// 本项目从 relation_app 抽取"教学关卡"模块，原样保留了
// `teaching_dialogue_widget.dart` 中对 `AppStyleNotifier` / `AppStyleConfig`
// 的引用。此处提供等价的适配实现，使教学模块无需修改即可在该独立 App 中运行。
//
// 与源项目差异：仅保留教学对话界面所使用的字段（scaffoldBg / surfaceColor），
// 风格固定为默认浅色，未携带多套预设与持久化逻辑。

import 'package:flutter/material.dart';

/// 应用风格配置（适配子集）
class AppStyleConfig {
  /// 页面 Scaffold 背景
  final Color scaffoldBg;

  /// 卡片 / 表面背景
  final Color surfaceColor;

  const AppStyleConfig({
    required this.scaffoldBg,
    required this.surfaceColor,
  });

  /// 默认浅色风格
  static const AppStyleConfig defaultApp = AppStyleConfig(
    scaffoldBg: Color(0xFFF8F9FC),
    surfaceColor: Colors.white,
  );
}

/// 风格状态管理（适配层）
///
/// 教学对话界面通过 `context.watch<AppStyleNotifier>()` 读取当前风格配置，
/// 此处提供一个常驻返回默认风格的轻量实现，保持 API 一致。
class AppStyleNotifier extends ChangeNotifier {
  AppStyleNotifier() : _config = AppStyleConfig.defaultApp;

  final AppStyleConfig _config;

  /// 当前风格配置
  AppStyleConfig get config => _config;
}
