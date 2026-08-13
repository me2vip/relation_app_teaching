/// 社交知识词典 Widget
///
/// 系统化整理社交知识点（按关卡分类），提供浏览和搜索入口。
/// 包含：原则、技巧、常见误区、案例。
library social_knowledge_base_widget;

import 'package:flutter/material.dart';
import 'teaching_level_system.dart';
import 'knowledge_extensions.dart';
import 'knowledge_detail_page.dart';

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

  void _openDetail(SocialKnowledgeEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KnowledgeDetailPage(entry: entry),
      ),
    );
  }

  Widget _buildEntryCard(SocialKnowledgeEntry entry, ColorScheme cs) {
    final hasLevel = entry.relatedLevel > 0 && entry.relatedLevel <= 10;
    final level = hasLevel ? LevelRegistry.getLevel(entry.relatedLevel) : null;
    final catColor = _getCategoryColor(entry.category, cs);
    final ext = KnowledgeExtensionRegistry.getBundle(entry.id);
    final hasPractice = ext.practices.isNotEmpty;
    final hasTest = ext.questions.isNotEmpty;
    final hasExtract = ext.keyPoints.isNotEmpty;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(entry),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧分类图标
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(entry.category),
                    size: 20,
                    color: catColor,
                  ),
                ),
                const SizedBox(width: 12),
                // 中间文字区
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // 标签行
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: [
                          if (hasLevel)
                            _miniChip(
                              'Lv${entry.relatedLevel} ${level!.title}',
                              cs.primary.withValues(alpha: 0.1),
                              cs.primary,
                            )
                          else
                            _miniChip(
                              entry.category,
                              catColor.withValues(alpha: 0.1),
                              catColor,
                            ),
                          ...entry.tags.take(2).map(
                            (tag) => _miniChip(
                              '#$tag',
                              cs.surfaceContainerHighest.withValues(alpha: 0.6),
                              cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 内容预览
                      Text(
                        _preview(entry.content),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 三个功能入口徽章
                      Row(
                        children: [
                          _featureBadge(
                            icon: Icons.flash_on_rounded,
                            label: '练习',
                            count: ext.practices.length,
                            activeColor: Colors.green,
                            active: hasPractice,
                            cs: cs,
                          ),
                          const SizedBox(width: 6),
                          _featureBadge(
                            icon: Icons.quiz_rounded,
                            label: '测试',
                            count: ext.questions.length,
                            activeColor: Colors.orange,
                            active: hasTest,
                            cs: cs,
                          ),
                          const SizedBox(width: 6),
                          _featureBadge(
                            icon: Icons.lightbulb_rounded,
                            label: '提炼',
                            count: ext.keyPoints.length,
                            activeColor: catColor,
                            active: hasExtract,
                            cs: cs,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                // 右箭头
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _featureBadge({
    required IconData icon,
    required String label,
    required int count,
    required Color activeColor,
    required bool active,
    required ColorScheme cs,
  }) {
    final color = active ? activeColor : cs.onSurfaceVariant.withValues(alpha: 0.5);
    final bg = active ? activeColor.withValues(alpha: 0.1) : cs.surfaceContainerHighest.withValues(alpha: 0.5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: active ? 0.35 : 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            count > 0 ? '×$count' : '—',
            style: TextStyle(
              fontSize: 9.5,
              color: color.withValues(alpha: active ? 1 : 0.6),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _preview(String content) {
    var text = content
        .replaceAll('\n', ' ')
        .replaceAll('【', ' ')
        .replaceAll('】', ' ')
        .replaceAll(RegExp(r'#+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.length > 60) text = '${text.substring(0, 60)}...';
    return text;
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
