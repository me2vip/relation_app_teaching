/// 社交知识词典 Widget
///
/// 系统化整理社交知识点（按关卡分类），提供浏览和搜索入口。
/// 包含：原则、技巧、常见误区、案例。
library social_knowledge_base_widget;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'teaching_level_system.dart';

// ============================================================================
// 社交知识词典浏览 Widget
// ============================================================================

class SocialKnowledgeBaseWidget extends StatefulWidget {
  const SocialKnowledgeBaseWidget({super.key});

  @override
  State<SocialKnowledgeBaseWidget> createState() =>
      _SocialKnowledgeBaseWidgetState();
}

class _SocialKnowledgeBaseWidgetState extends State<SocialKnowledgeBaseWidget> {
  String? _selectedCategory;
  int? _selectedLevel;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<SocialKnowledgeEntry> get _filteredEntries {
    var entries = SocialKnowledgeBase.entries;
    if (_selectedCategory != null) {
      entries = entries.where((e) => e.category == _selectedCategory).toList();
    }
    if (_selectedLevel != null) {
      entries = entries.where((e) => e.relatedLevel == _selectedLevel).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      entries = entries.where((e) {
        return e.title.toLowerCase().contains(query) ||
            e.tags.any((t) => t.toLowerCase().contains(query)) ||
            e.content.toLowerCase().contains(query);
      }).toList();
    }
    return entries;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 搜索栏
        _buildSearchBar(cs),
        // 分类筛选
        _buildCategoryFilter(cs),
        // 内容列表
        Expanded(child: _buildEntryList(cs)),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索知识点...',
          hintStyle: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: cs.onSurfaceVariant),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        style: TextStyle(fontSize: 14, color: cs.onSurface),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildCategoryFilter(ColorScheme cs) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildFilterChip('全部', _selectedCategory == null && _selectedLevel == null, () {
            setState(() {
              _selectedCategory = null;
              _selectedLevel = null;
            });
          }, cs),
          const SizedBox(width: 6),
          ...SocialKnowledgeBase.categories.map((cat) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _buildFilterChip(cat, _selectedCategory == cat, () {
                setState(() {
                  _selectedCategory = _selectedCategory == cat ? null : cat;
                  _selectedLevel = null;
                });
              }, cs),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap, ColorScheme cs) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildEntryList(ColorScheme cs) {
    final entries = _filteredEntries;

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_rounded, size: 48, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty ? '未找到匹配的知识点' : '选择分类浏览知识点',
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _buildEntryCard(entries[i], cs),
    );
  }

  Widget _buildEntryCard(SocialKnowledgeEntry entry, ColorScheme cs) {
    final hasLevel = entry.relatedLevel > 0 && entry.relatedLevel <= 10;
    final level = hasLevel ? LevelRegistry.getLevel(entry.relatedLevel) : null;
    final catColor = _getCategoryColor(entry.category, cs);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(entry.category),
            size: 18,
            color: catColor,
          ),
        ),
        title: Text(
          entry.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            if (hasLevel) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Lv${entry.relatedLevel} ${level!.title}',
                  style: TextStyle(fontSize: 10, color: cs.primary),
                ),
              ),
              const SizedBox(width: 6),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  entry.category,
                  style: TextStyle(fontSize: 10, color: catColor, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 6),
            ],
            ...entry.tags.take(2).map((tag) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                '#$tag',
                style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
              ),
            )),
          ],
        ),
        children: [
          const Divider(),
          _buildMarkdownContent(entry.content, cs),
        ],
      ),
    );
  }

  Widget _buildMarkdownContent(String content, ColorScheme cs) {
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          fontSize: 13,
          color: cs.onSurface,
          height: 1.65,
        ),
        h1: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        h2: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        h3: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
        h4: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
        strong: TextStyle(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        em: TextStyle(
          fontStyle: FontStyle.italic,
          color: cs.onSurface,
        ),
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
        tableHead: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        ),
        tableBody: TextStyle(
          fontSize: 13,
          color: cs.onSurface,
        ),
        tableBorder: TableBorder(
          horizontalInside: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        a: TextStyle(
          color: cs.primary,
          decoration: TextDecoration.underline,
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          // 可以使用 url_launcher 打开链接
        }
      },
    );
  }

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
}
