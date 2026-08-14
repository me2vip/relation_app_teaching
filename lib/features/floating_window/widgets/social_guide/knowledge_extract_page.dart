/// 知识点提炼页：核心要点卡片视图 + 记忆模式
library knowledge_extract_page;

import 'package:flutter/material.dart';

import 'teaching_level_system.dart';
import 'knowledge_extensions.dart';

class KnowledgeExtractPage extends StatefulWidget {
  final SocialKnowledgeEntry entry;
  final KnowledgeExtensionBundle bundle;

  const KnowledgeExtractPage({
    super.key,
    required this.entry,
    required this.bundle,
  });

  @override
  State<KnowledgeExtractPage> createState() => _KnowledgeExtractPageState();
}

class _KnowledgeExtractPageState extends State<KnowledgeExtractPage> {
  // 是否开启"记忆模式"（先隐藏内容，点击再显示）
  bool _memoryMode = false;
  final Set<int> _revealed = {};

  Color _importanceColor(String importance) {
    switch (importance) {
      case '核心': return Colors.red;
      case '重要': return Colors.orange;
      case '了解': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _importanceIcon(String importance) {
    switch (importance) {
      case '核心': return Icons.new_releases_rounded;
      case '重要': return Icons.label_important_rounded;
      case '了解': return Icons.lightbulb_outline_rounded;
      default: return Icons.circle_rounded;
    }
  }

  void _toggleMemoryMode() {
    setState(() {
      _memoryMode = !_memoryMode;
      _revealed.clear();
    });
  }

  void _toggleReveal(int i) {
    setState(() {
      if (_revealed.contains(i)) {
        _revealed.remove(i);
      } else {
        _revealed.add(i);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final keyPoints = widget.bundle.keyPoints;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.entry.title} · 要点提炼'),
        centerTitle: true,
        actions: [
          if (keyPoints.isNotEmpty)
            IconButton(
              tooltip: _memoryMode ? '关闭记忆模式' : '开启记忆模式',
              icon: Icon(
                _memoryMode ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: _memoryMode ? cs.primary : null,
              ),
              onPressed: _toggleMemoryMode,
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: keyPoints.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_motion_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text(
                      '暂未提炼核心要点',
                      style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  // 概览条
                  _buildOverview(cs, keyPoints),
                  // 记忆模式提示
                  if (_memoryMode)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.psychology_rounded, size: 18, color: Colors.amber.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '记忆模式：先思考答案，再点击卡片查看核心内容',
                                style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // 要点卡片列表
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: keyPoints.length,
                      itemBuilder: (ctx, i) => _buildPointCard(cs, keyPoints[i], i),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ===================== 概览条 =====================
  Widget _buildOverview(ColorScheme cs, List<KnowledgeKeyPoint> points) {
    int core = 0, important = 0, info = 0;
    for (final p in points) {
      switch (p.importance) {
        case '核心': core++; break;
        case '重要': important++; break;
        default: info++;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer.withValues(alpha: 0.6), cs.primaryContainer.withValues(alpha: 0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.15),
            ),
            child: Icon(Icons.lightbulb_rounded, size: 22, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '共提炼 ${points.length} 个核心要点',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (core > 0) ...[
                      _tag(cs, '核心 $core', Colors.red),
                      const SizedBox(width: 6),
                    ],
                    if (important > 0) ...[
                      _tag(cs, '重要 $important', Colors.orange),
                      const SizedBox(width: 6),
                    ],
                    if (info > 0)
                      _tag(cs, '了解 $info', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(ColorScheme cs, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  // ===================== 单个要点卡片 =====================
  Widget _buildPointCard(ColorScheme cs, KnowledgeKeyPoint p, int index) {
    final impColor = _importanceColor(p.importance);
    final hidden = _memoryMode && !_revealed.contains(index);
    final iconData = p.icon ?? Icons.lightbulb_outline_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _memoryMode ? () => _toggleReveal(index) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: impColor.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: impColor.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // 卡片头部
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: impColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: impColor.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(iconData, size: 18, color: impColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${index + 1}  ${p.title}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  _importanceIcon(p.importance),
                                  size: 12,
                                  color: impColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  p.importance,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: impColor,
                                  ),
                                ),
                                if (_memoryMode) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    size: 12,
                                    color: cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    hidden ? '点击查看' : '再次隐藏',
                                    style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 卡片内容
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: hidden
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 24, 14, 24),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 18, color: cs.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          '点击卡片查看要点内容',
                          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                    child: Text(
                      p.content,
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onSurface,
                        height: 1.65,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
