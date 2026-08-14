/// 应用内更新对话框
///
/// 调用 [AppUpdateService.checkForUpdate] 检查 GitHub Release，
/// 有新版本时弹出此对话框，用户确认后流式下载 APK 并调起系统安装器。
library update_dialog;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../utils/app_update_service.dart';

/// 更新对话框状态
enum _UpdateState { idle, downloading, installing, done, error }

class UpdateDialog {
  UpdateDialog._();

  /// 入口：检查更新 → 弹对话框（含进度）
  ///
  /// 调用方式：`UpdateDialog.show(context);`
  /// 流程：检查 → 有新版本则弹窗 → 用户点"立即下载" → 下载 → 调起系统安装器
  static Future<void> show(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CheckingDialog(),
    );
  }
}

// ============================================================================
// 检查中
// ============================================================================

class _CheckingDialog extends StatefulWidget {
  const _CheckingDialog();

  @override
  State<_CheckingDialog> createState() => _CheckingDialogState();
}

class _CheckingDialogState extends State<_CheckingDialog> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final outcome = await AppUpdateService.checkForUpdate();
    if (!mounted) return;
    Navigator.of(context).pop(); // 关闭检查中对话框
    if (!mounted) return;
    switch (outcome.result) {
      case UpdateCheckResult.hasUpdate:
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _UpdateContentDialog(
            release: outcome.releaseInfo!,
            currentVersion: outcome.currentVersion,
          ),
        );
        break;
      case UpdateCheckResult.upToDate:
        _toast('当前已是最新版（v${outcome.currentVersion}）');
        break;
      case UpdateCheckResult.noAsset:
        _toast('检测到新版本 ${outcome.releaseInfo?.version}，但暂未上传 APK，'
            '请稍后再试或在浏览器打开 Release 页面下载');
        break;
      case UpdateCheckResult.error:
        _toast('检查更新失败：${outcome.errorMessage}');
        break;
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在检查更新...', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 更新内容对话框（含下载进度）
// ============================================================================

class _UpdateContentDialog extends StatefulWidget {
  final GithubReleaseInfo release;
  final String currentVersion;

  const _UpdateContentDialog({
    required this.release,
    required this.currentVersion,
  });

  @override
  State<_UpdateContentDialog> createState() => _UpdateContentDialogState();
}

class _UpdateContentDialogState extends State<_UpdateContentDialog> {
  _UpdateState _state = _UpdateState.idle;
  double _progress = 0; // 0~1
  String _errorMsg = '';

  /// 流式下载 APK
  Future<void> _startDownload() async {
    setState(() {
      _state = _UpdateState.downloading;
      _progress = 0;
      _errorMsg = '';
    });
    try {
      final file = await AppUpdateService.downloadApk(
        widget.release,
        onProgress: (received, total) {
          if (total <= 0) return;
          setState(() => _progress = received / total);
        },
      );
      if (!mounted) return;
      setState(() => _state = _UpdateState.installing);
      // 调起系统安装器
      final result = await AppUpdateService.installApk(file);
      // 用户从安装器返回后（不论是否安装成功），关闭对话框
      if (!mounted) return;
      setState(() => _state = _UpdateState.done);
      if (result.message.isNotEmpty) {
        _toast('已下载完成。${result.message}');
      }
      // 关闭对话框
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _UpdateState.error;
        _errorMsg = e.toString();
      });
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  String get _progressText {
    final pct = (_progress * 100).toStringAsFixed(0);
    final totalMB = widget.release.apkSizeMB;
    return '$pct% / $totalMB MB';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 标题
              Row(
                children: [
                  Icon(Icons.system_update_rounded, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '发现新版本 v${widget.release.version}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '当前版本 v${widget.currentVersion} → 新版本 v${widget.release.version}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              const Divider(height: 20),

              // 发行说明
              Flexible(
                child: SingleChildScrollView(
                  child: widget.release.releaseNotes.trim().isEmpty
                      ? Text(
                          '暂无发行说明',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600]),
                        )
                      : MarkdownBody(
                          data: widget.release.releaseNotes,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(fontSize: 13),
                            h2: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            h3: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // 下载进度 / 状态
              if (_state == _UpdateState.downloading)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(value: _progress),
                    const SizedBox(height: 6),
                    Text(
                      _progressText,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                )
              else if (_state == _UpdateState.installing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('正在调起系统安装器...',
                        style: TextStyle(fontSize: 13)),
                  ],
                )
              else if (_state == _UpdateState.error)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.errorContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '下载失败：$_errorMsg',
                    style: TextStyle(fontSize: 12, color: cs.onErrorContainer),
                  ),
                ),

              const SizedBox(height: 16),

              // 按钮
              if (_state == _UpdateState.idle)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('稍后再说'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _startDownload,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('立即更新'),
                    ),
                  ],
                )
              else if (_state == _UpdateState.error)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _startDownload,
                      child: const Text('重试'),
                    ),
                  ],
                )
              else if (_state == _UpdateState.downloading ||
                  _state == _UpdateState.installing)
                // 下载/安装中：禁用关闭按钮，避免误操作
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
