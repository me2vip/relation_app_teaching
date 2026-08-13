/// 知识点详情页：展示完整内容 + 练习/测试/提炼入口
library knowledge_detail_page;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'teaching_level_system.dart';
import 'knowledge_extensions.dart';
import 'knowledge_practice_page.dart';
import 'knowledge_test_page.dart';
import 'knowledge_extract_page.dart';

class KnowledgeDetailPage extends StatefulWidget {
  final SocialKnowledgeEntry entry;

  const KnowledgeDetailPage({
    super.key,
    required this.entry,
  });

  @override
  State<KnowledgeDetailPage> createState() => _KnowledgeDetailPageState();
}

class _KnowledgeDetailPageState extends State<KnowledgeDetailPage> {
  late KnowledgeExtensionBundle _bundle;
  bool _loadingExtension = true;

  @override
  void initState() {
    super.initState();
    _bundle = KnowledgeExtensionRegistry.getBundle(widget.entry.id);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _loadingExtension = false);
    });
  }

  // ===================== 颜色 / 图标辅助 =====================
  Color _getCategoryColor(String category, ColorScheme cs) {
    switch (category) {
      case '破冰与开场': return Colors.blue;
      case '自我介绍': return Colors.indigo;
      case '倾听技巧': return Colors.teal;
      case '话题管理': return Colors.amber.shade700;
      case '情绪共鸣': return Colors.pink;
      case '冲突化解': return Colors.orange;
      case '深度连接': return Colors.purple;
      case '影响力沟通': return Colors.red;
      case '关系修复': return Colors.brown;
      case '肢体语言与微表情': return Colors.cyan;
      case '社交媒体情报': return Colors.deepOrange;
      case '日常相处': return Colors.green;
      case '打闹与互动': return Colors.deepPurple;
      case '关系维护': return Colors.blueGrey;
      case '关系分层与识人': return Colors.red.shade700;
      case '社交对象分类': return Colors.indigo.shade400;
      case '群体社交': return Colors.deepPurple.shade600;
      default: return cs.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '破冰与开场': return Icons.ac_unit_rounded;
      case '自我介绍': return Icons.person_rounded;
      case '倾听技巧': return Icons.hearing_rounded;
      case '话题管理': return Icons.forum_rounded;
      case '情绪共鸣': return Icons.psychology_rounded;
      case '冲突化解': return Icons.shield_rounded;
      case '深度连接': return Icons.connect_without_contact_rounded;
      case '影响力沟通': return Icons.trending_up_rounded;
      case '关系修复': return Icons.favorite_rounded;
      case '肢体语言与微表情': return Icons.accessibility_new_rounded;
      case '社交媒体情报': return Icons.phone_android_rounded;
      case '日常相处': return Icons.coffee_rounded;
      case '打闹与互动': return Icons.sports_kabaddi_rounded;
      case '关系维护': return Icons.handshake_rounded;
      case '关系分层与识人': return Icons.people_outline_rounded;
      case '社交对象分类': return Icons.diversity_3_rounded;
      case '群体社交': return Icons.groups_rounded;
      default: return Icons.menu_book_rounded;
    }
  }

  // ===================== 跳转动作 =====================
  void _goToPractice() {
    if (_bundle.practices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该知识点暂无情景练习')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KnowledgePracticePage(
          entry: widget.entry,
          bundle: _bundle,
        ),
      ),
    );
  }

  void _goToTest() {
    if (_bundle.questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该知识点暂无测试题')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KnowledgeTestPage(
          entry: widget.entry,
          bundle: _bundle,
        ),
      ),
    );
  }

  void _goToExtract() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KnowledgeExtractPage(
          entry: widget.entry,
          bundle: _bundle,
        ),
      ),
    );
  }

  // ===================== 主构建 =====================
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final catColor = _getCategoryColor(widget.entry.category, cs);
    final hasLevel = widget.entry.relatedLevel > 0 && widget.entry.relatedLevel <= 10;
    final level = hasLevel ? LevelRegistry.getLevel(widget.entry.relatedLevel) : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.entry.title),
        centerTitle: true,
        actions: [
          if (KnowledgeExtensionRegistry.hasBundle(widget.entry.id))
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.verified_rounded,
                color: catColor,
                size: 20,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部信息卡片
            _buildHeaderCard(cs, catColor, hasLevel, level),
            const SizedBox(height: 10),
            // 三个功能入口卡片区
            _buildActionRow(cs, catColor),
            const SizedBox(height: 8),
            // 正文内容
            Expanded(
              child: _buildContentArea(cs),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== 头部信息卡片 =====================
  Widget _buildHeaderCard(ColorScheme cs, Color catColor, bool hasLevel, TeachingLevel? level) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            catColor.withValues(alpha: 0.15),
            catColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: catColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(widget.entry.category),
              size: 26,
              color: catColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.entry.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.entry.category,
                        style: TextStyle(
                          fontSize: 10,
                          color: catColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (hasLevel)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '关联 Lv${widget.entry.relatedLevel} ${level!.title}',
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ...widget.entry.tags.take(3).map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 三个入口卡片 =====================
  Widget _buildActionRow(ColorScheme cs, Color catColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              cs: cs,
              icon: Icons.flash_on_rounded,
              label: '情景练习',
              subLabel: _loadingExtension
                  ? '...'
                  : _bundle.practices.isEmpty
                      ? '暂无'
                      : '${_bundle.practices.length} 个场景',
              color: Colors.green,
              onTap: _goToPractice,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionCard(
              cs: cs,
              icon: Icons.quiz_rounded,
              label: '知识测试',
              subLabel: _loadingExtension
                  ? '...'
                  : _bundle.questions.isEmpty
                      ? '暂无'
                      : '${_bundle.questions.length} 道题',
              color: Colors.orange,
              onTap: _goToTest,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildActionCard(
              cs: cs,
              icon: Icons.lightbulb_rounded,
              label: '要点提炼',
              subLabel: _loadingExtension
                  ? '...'
                  : '${_bundle.keyPoints.length} 个要点',
              color: catColor,
              onTap: _goToExtract,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required ColorScheme cs,
    required IconData icon,
    required String label,
    required String subLabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 10,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== 正文内容 =====================
  Widget _buildContentArea(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_rounded, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                '完整内容',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: MarkdownBody(
                data: widget.entry.content,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.7),
                  h1: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface),
                  h2: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface),
                  h3: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface),
                  h4: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
                  strong: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
                  em: TextStyle(fontStyle: FontStyle.italic, color: cs.onSurface),
                  code: TextStyle(
                    fontSize: 12,
                    backgroundColor: cs.surfaceContainerHighest,
                    color: cs.primary,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: cs.primary.withValues(alpha: 0.3), width: 3),
                    ),
                  ),
                  blockquotePadding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
                  horizontalRuleDecoration: BoxDecoration(
                    border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
