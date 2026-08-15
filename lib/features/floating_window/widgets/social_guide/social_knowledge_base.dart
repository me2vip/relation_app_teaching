/// 社交知识词典 Widget
///
/// 系统化整理社交知识点（按关卡分类），提供浏览和搜索入口。
/// 支持展开查看知识点详情，无需跳转子页面。
library social_knowledge_base_widget;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'teaching_level_system.dart';
import 'knowledge_extensions.dart';
import 'knowledge_practice_page.dart';
import 'knowledge_test_page.dart';
import 'knowledge_extract_page.dart';
import 'knowledge_detail_page.dart';

// 知识词典三种显示方式
enum _KnowledgeDisplayMode { list, mindmap, tree }

// 导图/树 用的层级分组辅助类
class _KnowledgeSubGroup {
  final String category;
  final List<SocialKnowledgeEntry> entries;
  _KnowledgeSubGroup(this.category, this.entries);
  int get count => entries.length;
}

class _KnowledgeMajorGroup {
  final KnowledgeMajorCategory major;
  final List<_KnowledgeSubGroup> subs;
  _KnowledgeMajorGroup(this.major, this.subs);
  int get count => subs.fold(0, (s, g) => s + g.count);
}

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
  KnowledgeMajorCategory? _selectedMajor; // 大分类筛选（null=全部）
  String? _selectedCategory;              // 子分类筛选
  int? _selectedLevel;
  TargetAudience? _selectedAudience; // 性别适用对象筛选：all/male/female
  String _searchQuery = '';
  _KnowledgeDisplayMode _mode = _KnowledgeDisplayMode.list;
  final _searchController = TextEditingController();
  final Set<String> _expandedIds = {};

  /// 当前可选的子分类列表（根据大分类联动）
  List<String> get _visibleSubCategories {
    if (_selectedMajor == null) {
      return SocialKnowledgeBase.categories;
    }
    return SocialKnowledgeBase.subCategoriesOf(_selectedMajor!);
  }

  List<SocialKnowledgeEntry> get _filteredEntries {
    var entries = SocialKnowledgeBase.entries;
    // 大分类筛选
    if (_selectedMajor != null) {
      entries = entries.where((e) => e.majorCategory == _selectedMajor).toList();
    }
    if (_selectedCategory != null) {
      entries = entries.where((e) => e.category == _selectedCategory).toList();
    }
    if (_selectedLevel != null) {
      entries = entries.where((e) => e.relatedLevel == _selectedLevel).toList();
    }
    // 性别适用对象筛选（默认 null=全部；选了 male/female 时，同时保留 TargetAudience.all 通用内容，
    // 但专属内容（male/female）权重更靠前——按"专属优先"排序）
    if (_selectedAudience != null && _selectedAudience != TargetAudience.all) {
      final target = _selectedAudience!;
      entries = entries.where((e) =>
        e.targetAudience == TargetAudience.all || e.targetAudience == target
      ).toList();
      // 把目标受众的专属内容排在前面
      entries.sort((a, b) {
        final weightA = a.targetAudience == target ? 0 : 1;
        final weightB = b.targetAudience == target ? 0 : 1;
        return weightA.compareTo(weightB);
      });
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
        // 显示方式切换：列表 / 导图 / 树
        _buildModeSwitch(cs),
        // 大分类筛选（顶层导航）
        _buildMajorCategoryFilter(cs),
        // 子分类筛选（联动大分类）
        _buildCategoryFilter(cs),
        // 性别适用对象筛选
        _buildAudienceFilter(cs),
        // 内容区（按显示方式切换）
        Expanded(
          child: switch (_mode) {
            _KnowledgeDisplayMode.list => _buildEntryList(cs),
            _KnowledgeDisplayMode.mindmap => _buildMindMap(cs),
            _KnowledgeDisplayMode.tree => _buildTree(cs),
          },
        ),
      ],
    );
  }

  Widget _buildMajorCategoryFilter(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: SizedBox(
        height: 32,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildMajorChip(null, '全部', null, cs),
            const SizedBox(width: 6),
            ...SocialKnowledgeBase.majorCategories.map((m) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _buildMajorChip(m, m.label, m.emoji, cs),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMajorChip(
      KnowledgeMajorCategory? major, String label, String? emoji, ColorScheme cs) {
    final selected = _selectedMajor == major;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMajor = major;
          // 切换大分类后，重置子分类（避免选了一个不属于当前大分类的子分类）
          if (_selectedCategory != null &&
              major != null &&
              !SocialKnowledgeBase.subCategoriesOf(major)
                  .contains(_selectedCategory)) {
            _selectedCategory = null;
          }
          _selectedLevel = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: 0.92)
              : cs.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(18),
          border: selected ? null : Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceFilter(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: SizedBox(
        height: 32,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildAudienceChip(null, '全部', Icons.group_rounded, cs),
            const SizedBox(width: 6),
            ...TargetAudience.values.map((a) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _buildAudienceChip(a, a.label, a.icon, cs),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceChip(TargetAudience? value, String label, IconData icon, ColorScheme cs) {
    final selected = _selectedAudience == value;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedAudience = _selectedAudience == value ? null : value;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? cs.secondary : cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? cs.onSecondary : cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? cs.onSecondary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
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
    final subs = _visibleSubCategories;
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildFilterChip(
              '全部子分类',
              _selectedCategory == null && _selectedLevel == null, () {
            setState(() {
              _selectedCategory = null;
              _selectedLevel = null;
            });
          }, cs),
          const SizedBox(width: 6),
          ...subs.map((cat) {
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
    final ext = KnowledgeExtensionRegistry.getBundle(entry.id);
    final hasPractice = ext.practices.isNotEmpty;
    final hasTest = ext.questions.isNotEmpty;
    final hasExtract = ext.keyPoints.isNotEmpty;
    final isExpanded = _expandedIds.contains(entry.id);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isExpanded
              ? catColor.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          // ========== 收起状态：标题行 ==========
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedIds.remove(entry.id);
                } else {
                  _expandedIds.add(entry.id);
                }
              });
            },
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
                        // 标题 + 右侧适用对象徽章
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                entry.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // 适用对象：男生/女生 专属徽章
                            if (entry.targetAudience != TargetAudience.all)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: _audienceBadge(entry.targetAudience, cs),
                              ),
                          ],
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
                        const SizedBox(height: 6),
                        // 内容预览（收起时）
                        if (!isExpanded)
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
                        // 功能入口徽章（始终显示）
                        if (!isExpanded) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _featureBadge(
                                icon: Icons.school_rounded,
                                label: '指导',
                                count: ext.stepGuides.length,
                                activeColor: Colors.blue,
                                active: ext.stepGuides.isNotEmpty,
                                cs: cs,
                              ),
                              const SizedBox(width: 6),
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  // 展开/收起箭头
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: isExpanded ? catColor : cs.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ========== 展开状态：详情内容 ==========
          if (isExpanded)
            _buildExpandedContent(entry, ext, cs, catColor, hasLevel, level),
        ],
      ),
    );
  }

  // ===================== 展开后的内容区 =====================
  Widget _buildExpandedContent(
    SocialKnowledgeEntry entry,
    KnowledgeExtensionBundle ext,
    ColorScheme cs,
    Color catColor,
    bool hasLevel,
    TeachingLevel? level,
  ) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分割线
            Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 10),

            // 1) 完整内容
            _buildSectionTitle('完整内容', Icons.menu_book_rounded, cs.primary, cs),
            const SizedBox(height: 6),
            MarkdownBody(
              data: entry.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(fontSize: 12.5, color: cs.onSurface, height: 1.6),
                h1: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface),
                h2: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface),
                h3: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
                h4: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
                strong: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
                em: TextStyle(fontStyle: FontStyle.italic, color: cs.onSurface),
                code: TextStyle(
                  fontSize: 11.5,
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
              ),
            ),

            // 2) 知识点提炼
            if (ext.keyPoints.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildSectionTitle('核心要点', Icons.lightbulb_rounded, catColor, cs),
              const SizedBox(height: 6),
              ...ext.keyPoints.map((kp) => _buildKeyPointItem(kp, cs, catColor)),
            ],

            // 3) 四个功能入口按钮（两行）
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.school_rounded,
                    label: '分步指导',
                    subLabel: ext.stepGuides.isEmpty ? '暂无' : '${ext.stepGuides.length} 个指导',
                    color: Colors.blue,
                    enabled: ext.stepGuides.isNotEmpty,
                    onTap: () => _goToPractice(entry, ext),
                    cs: cs,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.flash_on_rounded,
                    label: '情景练习',
                    subLabel: ext.practices.isEmpty ? '暂无' : '${ext.practices.length} 个场景',
                    color: Colors.green,
                    enabled: ext.practices.isNotEmpty,
                    onTap: () => _goToPractice(entry, ext),
                    cs: cs,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.quiz_rounded,
                    label: '知识测试',
                    subLabel: ext.questions.isEmpty ? '暂无' : '${ext.questions.length} 道题',
                    color: Colors.orange,
                    enabled: ext.questions.isNotEmpty,
                    onTap: () => _goToTest(entry, ext),
                    cs: cs,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.auto_stories_rounded,
                    label: '要点提炼',
                    subLabel: '${ext.keyPoints.length} 个要点',
                    color: catColor,
                    enabled: true,
                    onTap: () => _goToExtract(entry, ext),
                    cs: cs,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color, ColorScheme cs) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyPointItem(KnowledgeKeyPoint kp, ColorScheme cs, Color catColor) {
    final importanceColor = kp.importance == '核心'
        ? Colors.red.shade400
        : kp.importance == '重要'
            ? Colors.orange.shade400
            : cs.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: catColor.withValues(alpha: 0.4), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (kp.icon != null) ...[
                Icon(kp.icon, size: 15, color: catColor),
                const SizedBox(width: 5),
              ],
              Expanded(
                child: Text(
                  kp.title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: importanceColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  kp.importance,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: importanceColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            kp.content,
            style: TextStyle(
              fontSize: 11.5,
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String subLabel,
    required Color color,
    required bool enabled,
    required VoidCallback onTap,
    required ColorScheme cs,
  }) {
    final actualColor = enabled ? color : cs.onSurfaceVariant.withValues(alpha: 0.4);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: actualColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: actualColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 17, color: actualColor),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: actualColor,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 9.5,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== 跳转动作 =====================
  void _goToPractice(SocialKnowledgeEntry entry, KnowledgeExtensionBundle bundle) {
    if (bundle.practices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该知识点暂无情景练习')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KnowledgePracticePage(entry: entry, bundle: bundle),
      ),
    );
  }

  void _goToTest(SocialKnowledgeEntry entry, KnowledgeExtensionBundle bundle) {
    if (bundle.questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该知识点暂无测试题')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KnowledgeTestPage(entry: entry, bundle: bundle),
      ),
    );
  }

  void _goToExtract(SocialKnowledgeEntry entry, KnowledgeExtensionBundle bundle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KnowledgeExtractPage(entry: entry, bundle: bundle),
      ),
    );
  }

  // ===================== 辅助组件 =====================
  Widget _audienceBadge(TargetAudience a, ColorScheme cs) {
    final Color bg = a == TargetAudience.male
        ? Colors.blue.withValues(alpha: 0.1)
        : Colors.pink.withValues(alpha: 0.12);
    final Color fg = a == TargetAudience.male ? Colors.blue.shade700 : Colors.pink.shade700;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(a.icon, size: 11, color: fg),
          const SizedBox(width: 2),
          Text(
            a.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
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

  // ===================== 显示方式：列表 / 导图 / 树 =====================

  /// 把当前筛选结果按「大分类 → 子分类」分组，供导图与树使用
  List<_KnowledgeMajorGroup> get _hierarchy {
    final entries = _filteredEntries;
    final byMajor = <KnowledgeMajorCategory, Map<String, List<SocialKnowledgeEntry>>>{};
    for (final e in entries) {
      byMajor
          .putIfAbsent(e.majorCategory, () => <String, List<SocialKnowledgeEntry>>{})
          .putIfAbsent(e.category, () => <SocialKnowledgeEntry>[])
          .add(e);
    }
    final result = <_KnowledgeMajorGroup>[];
    for (final major in SocialKnowledgeBase.majorCategories) {
      final subsMap = byMajor[major];
      if (subsMap == null || subsMap.isEmpty) continue;
      final subs = <_KnowledgeSubGroup>[];
      for (final cat in SocialKnowledgeBase.categories) {
        final list = subsMap[cat];
        if (list == null || list.isEmpty) continue;
        subs.add(_KnowledgeSubGroup(cat, list));
      }
      if (subs.isNotEmpty) result.add(_KnowledgeMajorGroup(major, subs));
    }
    return result;
  }

  Widget _buildModeSwitch(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _modeButton(_KnowledgeDisplayMode.list, Icons.view_agenda_rounded, '列表', cs),
          _modeButton(_KnowledgeDisplayMode.mindmap, Icons.bubble_chart_rounded, '导图', cs),
          _modeButton(_KnowledgeDisplayMode.tree, Icons.account_tree_rounded, '树形', cs),
        ],
      ),
    );
  }

  Widget _modeButton(_KnowledgeDisplayMode mode, IconData icon, String label, ColorScheme cs) {
    final selected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: selected ? cs.onPrimary : cs.onSurfaceVariant),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(ColorScheme cs) {
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

  // ---------------------- 树形视图 ----------------------
  Widget _buildTree(ColorScheme cs) {
    final groups = _hierarchy;
    if (groups.isEmpty) return _emptyState(cs);
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (ctx, i) => _buildTreeMajor(groups[i], cs),
    );
  }

  Widget _buildTreeMajor(_KnowledgeMajorGroup g, ColorScheme cs) {
    final catColor = _getCategoryColor(g.subs.first.entries.first.category, cs);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(g.major.emoji, style: const TextStyle(fontSize: 18))),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(g.major.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${g.count}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: catColor)),
            ),
          ],
        ),
        children: g.subs.map((s) => _buildTreeSub(s, cs)).toList(),
      ),
    );
  }

  Widget _buildTreeSub(_KnowledgeSubGroup s, ColorScheme cs) {
    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: const EdgeInsets.only(left: 20, right: 8),
      leading: Icon(Icons.folder_outlined, size: 18, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
      title: Text(s.category, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
      children: s.entries.map((e) => _buildTreeLeaf(e, cs)).toList(),
    );
  }

  Widget _buildTreeLeaf(SocialKnowledgeEntry e, ColorScheme cs) {
    final catColor = _getCategoryColor(e.category, cs);
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 44, right: 12),
      leading: Icon(_getCategoryIcon(e.category), size: 18, color: catColor),
      title: Text(e.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500)),
      subtitle: e.tags.isNotEmpty
          ? Text('#${e.tags.first}', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant.withValues(alpha: 0.7)))
          : null,
      trailing: e.targetAudience != TargetAudience.all
          ? _audienceBadge(e.targetAudience, cs)
          : Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
      onTap: () => _jumpToDetail(e),
    );
  }

  // ---------------------- 知识导图视图 ----------------------
  Widget _buildMindMap(ColorScheme cs) {
    final groups = _hierarchy;
    if (groups.isEmpty) return _emptyState(cs);
    final total = _filteredEntries.length;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Center(child: _mindCenterNode(total, cs)),
        const SizedBox(height: 6),
        ...groups.map((g) => _buildMindMajorBranch(g, cs)),
      ],
    );
  }

  Widget _mindCenterNode(int total, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: cs.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('社交知识词典', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: cs.onPrimary)),
          const SizedBox(height: 2),
          Text('$total 个知识点', style: TextStyle(fontSize: 11, color: cs.onPrimary.withValues(alpha: 0.85))),
        ],
      ),
    );
  }

  Widget _buildMindMajorBranch(_KnowledgeMajorGroup g, ColorScheme cs) {
    final catColor = _getCategoryColor(g.subs.first.entries.first.category, cs);
    return Container(
      margin: const EdgeInsets.only(top: 4, left: 6, right: 6),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: catColor.withValues(alpha: 0.3), width: 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 连接桩：横线 + 圆点
          Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(width: 14, height: 2, color: catColor.withValues(alpha: 0.3)),
                  Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: catColor)),
                ],
              ),
            ],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mindMajorHeader(g, catColor, cs),
                const SizedBox(height: 8),
                ...g.subs.map((s) => _mindSubBlock(s, cs)),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mindMajorHeader(_KnowledgeMajorGroup g, Color catColor, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: catColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: catColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(g.major.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(child: Text(g.major.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: catColor))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: catColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Text('${g.count}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: catColor)),
          ),
        ],
      ),
    );
  }

  Widget _mindSubBlock(_KnowledgeSubGroup s, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 5),
            child: Row(
              children: [
                Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: cs.onSurfaceVariant.withValues(alpha: 0.5))),
                const SizedBox(width: 6),
                Text(s.category, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: s.entries.map((e) => _mindEntryChip(e, cs)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _mindEntryChip(SocialKnowledgeEntry e, ColorScheme cs) {
    final catColor = _getCategoryColor(e.category, cs);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _jumpToDetail(e),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: catColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getCategoryIcon(e.category), size: 12, color: catColor),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  e.title,
                  style: TextStyle(fontSize: 11.5, color: cs.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (e.targetAudience != TargetAudience.all) ...[
                const SizedBox(width: 3),
                _audienceBadge(e.targetAudience, cs),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------- 跳转执行 ----------------------
  void _jumpToDetail(SocialKnowledgeEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => KnowledgeDetailPage(entry: entry)),
    );
  }
}
