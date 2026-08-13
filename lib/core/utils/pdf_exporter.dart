/// 社交教练 · 完整知识体系导出服务
///
/// 从 assets 加载预制的 PDF / Markdown 文件并分享，无需运行时渲染。
library pdf_exporter;

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../shared/widgets/app_toast.dart';

class PdfExporter {
  PdfExporter._();

  /// assets 中预制文件路径
  static const _pdfPath = 'assets/pdf/社交教练_完整知识手册.pdf';
  static const _mdPath = 'assets/markdown/社交教练_完整知识手册.md';

  /// 导出入口：弹出选择对话框，选择 PDF 或 Markdown
  static Future<void> export(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '导出知识手册',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '选择导出格式，可通过系统分享保存到文件或发送',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            // PDF 选项
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf, color: Colors.red),
              ),
              title: const Text('PDF 格式',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('适合阅读、打印、分享'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.of(ctx).pop();
                _shareAssetFile(context, _pdfPath, 'pdf');
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            // Markdown 选项
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description, color: Colors.blue),
              ),
              title: const Text('Markdown 格式',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('适合编辑、导入其他 AI 对话使用'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.of(ctx).pop();
                _shareAssetFile(context, _mdPath, 'md');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// 从 assets 加载文件并调用系统分享
  static Future<void> _shareAssetFile(
    BuildContext context,
    String assetPath,
    String ext,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    AppToast.showLoading(context, '正在准备文件…',
        duration: const Duration(seconds: 1));

    try {
      // 1. 从 assets 加载字节
      final ByteData assetData = await rootBundle.load(assetPath);
      final Uint8List bytes = assetData.buffer.asUint8List();
      if (bytes.isEmpty) throw Exception('文件为空');

      // 2. 写入临时文件
      final dir = await getTemporaryDirectory();
      final filename = assetPath.split('/').last;
      final filePath = '${dir.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      final mb = (bytes.length / 1024 / 1024).toStringAsFixed(1);
      final mimeType = ext == 'pdf' ? 'application/pdf' : 'text/markdown';

      // 3. 调用系统分享面板
      await Share.shareXFiles(
        [XFile(filePath, mimeType: mimeType)],
        text: '《社交教练 · 完整知识指导手册》（${ext.toUpperCase()} · $mb MB）',
      );
    } catch (e) {
      debugPrint('[PdfExporter] 导出失败：$e');
      // ignore: use_build_context_synchronously
      AppToast.showSnackBar(messenger, '导出失败：${e.runtimeType}',
          isError: true);
    }
  }
}
