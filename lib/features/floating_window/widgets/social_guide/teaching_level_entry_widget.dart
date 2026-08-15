/// 教学关卡入口 Widget
///
/// 展示关卡列表、进度条、勋章，作为教学系统的入口页。
library teaching_level_entry_widget;

import 'package:flutter/material.dart';
import 'teaching_level_system.dart';
import 'teaching_dialogue_widget.dart';
import 'social_knowledge_base.dart';
import 'quick_practice_widget.dart';

class TeachingLevelEntryWidget extends StatefulWidget {
  final String contactId;
  final String contactName;
  final String contactGender;

  const TeachingLevelEntryWidget({
    super.key,
    required this.contactId,
    required this.contactName,
    this.contactGender = '未设置',
  });

  @override
  State<TeachingLevelEntryWidget> createState() =>
      _TeachingLevelEntryWidgetState();
}

class _TeachingLevelEntryWidgetState extends State<TeachingLevelEntryWidget> {
  final _progressManager = TeachingProgressManager();
  int _subPage = 0; // 0=关卡列表, 1=知识词典, 2=快速练习
  TeachingMode _selectedMode = TeachingMode.general;

  @override
  void initState() {
    super.initState();
    _progressManager.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _progressManager.dispose();
    super.dispose();
  }

  void _startLevel(TeachingLevel level) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeachingDialogueWidget(
          level: level,
          contactName: widget.contactName,
          contactGender: widget.contactGender,
          mode: _selectedMode,
          onComplete: (totalScore, passed) {
            if (passed) {
              _progressManager.completeLevel(level.level, totalScore);
            } else {
              _progressManager.recordAttempt(level.level);
            }
          },
        ),
      ),
    );
  }

  int get _highestUnlocked {
    for (int i = 10; i >= 1; i--) {
      if (_progressManager.isUnlocked(i)) return i;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final levels = LevelRegistry.allLevels;
    final totalProgress = _progressManager.overallProgress;
    final highestUnlocked = _highestUnlocked;

    return Column(
      children: [
        // 顶部概览
        _buildOverview(cs, totalProgress, highestUnlocked),
        // 模式选择器
        _buildModeSelector(cs),
        // 子导航：关卡 / 知识词典
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _buildSubNavButton('闯关', 0, cs),
              _buildSubNavButton('知识词典', 1, cs),
              _buildSubNavButton('快速练习', 2, cs),
            ],
          ),
        ),
        // 内容
        Expanded(
          child: _subPage == 0
              ? _buildLevelList(cs, levels)
              : _subPage == 1
                  ? const SocialKnowledgeBaseWidget()
                  : const QuickPracticeWidget(),
        ),
      ],
    );
  }

  Widget _buildSubNavButton(String label, int index, ColorScheme cs) {
    final selected = _subPage == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _subPage = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverview(ColorScheme cs, double progress, int highestUnlocked) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primaryContainer, cs.primaryContainer.withValues(alpha: 0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    'Lv$highestUnlocked',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.primary),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '社交教学系统',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '初级 1-3 关 · 中级 4-6 关 · 高级 7-9 关 · 毕业第 10 关',
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: cs.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: cs.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: TeachingMode.values.map((mode) {
            final selected = _selectedMode == mode;
            return GestureDetector(
              onTap: () => setState(() => _selectedMode = mode),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? cs.primary.withValues(alpha: 0.12)
                      : cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? cs.primary.withValues(alpha: 0.5)
                        : cs.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      mode.icon,
                      size: 15,
                      color: selected ? cs.primary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      mode.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected ? cs.primary : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLevelList(ColorScheme cs, List<TeachingLevel> levels) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: levels.length,
      itemBuilder: (_, i) {
        final level = levels[i];
        final isUnlocked = _progressManager.isUnlocked(level.level);
        final isCompleted = _progressManager.isCompleted(level.level);
        final progress = isCompleted ? 1.0 : 0.0;

        return _buildLevelCard(cs, level, i, isUnlocked, isCompleted, progress);
      },
    );
  }

  Widget _buildLevelCard(
    ColorScheme cs, TeachingLevel level, int index,
    bool isUnlocked, bool isCompleted, double progress,
  ) {
    final tierLabel = switch (level.tier) {
      LevelTier.beginner => '初级',
      LevelTier.intermediate => '中级',
      LevelTier.advanced => '高级',
      LevelTier.graduation => '毕业',
      LevelTier.master => '宗师',
    };
    final tierColor = switch (level.tier) {
      LevelTier.beginner => Colors.green,
      LevelTier.intermediate => Colors.blue,
      LevelTier.advanced => Colors.purple,
      LevelTier.graduation => Colors.amber.shade700,
      LevelTier.master => Colors.deepOrange,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: isUnlocked ? 0.25 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? tierColor.withValues(alpha: 0.4) : cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isUnlocked ? () => _startLevel(level) : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 等级图标
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? tierColor.withValues(alpha: 0.15)
                        : isUnlocked
                            ? tierColor.withValues(alpha: 0.08)
                            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    border: Border.all(
                      color: isCompleted
                          ? tierColor
                          : isUnlocked
                              ? tierColor.withValues(alpha: 0.5)
                              : cs.outlineVariant.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(Icons.emoji_events_rounded, size: 20, color: tierColor)
                        : isUnlocked
                            ? Text(
                                '${level.level}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: tierColor,
                                ),
                              )
                            : Icon(Icons.lock_outline_rounded, size: 18, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                  ),
                ),
                const SizedBox(width: 12),
                // 关卡信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: tierColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tierLabel,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: tierColor),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              level.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isUnlocked ? cs.onSurface : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level.subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                      if (_selectedMode != TeachingMode.general && isUnlocked) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(_selectedMode.icon, size: 11, color: cs.primary.withValues(alpha: 0.7)),
                            const SizedBox(width: 3),
                            Text(
                              '${_selectedMode.label}模式',
                              style: TextStyle(
                                fontSize: 10,
                                color: cs.primary.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isUnlocked && !isCompleted) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 3,
                            backgroundColor: tierColor.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 状态图标
                if (isCompleted)
                  Icon(Icons.check_circle_rounded, size: 22, color: tierColor)
                else if (isUnlocked)
                  Icon(Icons.chevron_right_rounded, size: 22, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
