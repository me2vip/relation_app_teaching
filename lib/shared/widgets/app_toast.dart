// 轻提示组件（适配层）
//
// 源项目 `teaching_dialogue_widget.dart` 调用 `AppToast.info(...)` 展示提示。
// 此处提供同名 API 的轻量适配实现，借助 Material `SnackBar` 完成展示，
// 不引入源项目复杂的 Toast 视图体系。

import 'package:flutter/material.dart';

/// 提示类型（仅保留与教学模块相关的枚举值，保持 API 形状一致）
enum AppToastType { info, tip, success, warning, error }

/// 提示动作（占位实现，教学模块未使用具体动作）
class AppToastAction {
  final String label;
  final VoidCallback? onPressed;

  const AppToastAction({required this.label, this.onPressed});
}

/// 轻提示
class AppToast {
  const AppToast();

  static SnackBarAction? _convertAction(AppToastAction? action) {
    if (action == null || action.onPressed == null) return null;
    return SnackBarAction(label: action.label, onPressed: action.onPressed!);
  }

  /// 信息提示
  static void info(
    BuildContext context,
    String message, {
    String? title,
    AppToastAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      showSnackBar(messenger, message, action: _convertAction(action), duration: duration);
    }
  }

  /// 小贴士提示
  static void tip(
    BuildContext context,
    String message, {
    String? title,
    AppToastAction? action,
    Duration duration = const Duration(seconds: 5),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      showSnackBar(messenger, message, action: _convertAction(action), duration: duration);
    }
  }

  /// "正在生成/加载"类提示（较长时长）
  static void showLoading(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      showSnackBar(messenger, '⏳ $message', duration: duration);
    }
  }

  /// 通用 SnackBar 入口：允许从非 BuildContext 的位置（如已保存的 ScaffoldMessengerState）
  /// 展示提示，并可自定义成功色/错误色/动作按钮。
  static void showSnackBar(
    ScaffoldMessengerState messenger,
    String message, {
    SnackBarAction? action,
    Color? color,
    bool isError = false,
    Duration duration = const Duration(seconds: 4),
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? const Color(0xFFC84848)
              : color,
          action: action,
        ),
      );
  }
}
