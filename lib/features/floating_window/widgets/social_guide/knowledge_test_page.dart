/// 知识点测试页：选择题 / 多选题 / 判断题
library knowledge_test_page;

import 'package:flutter/material.dart';

import 'teaching_level_system.dart';
import 'knowledge_extensions.dart';

class KnowledgeTestPage extends StatefulWidget {
  final SocialKnowledgeEntry entry;
  final KnowledgeExtensionBundle bundle;

  const KnowledgeTestPage({
    super.key,
    required this.entry,
    required this.bundle,
  });

  @override
  State<KnowledgeTestPage> createState() => _KnowledgeTestPageState();
}

class _KnowledgeTestPageState extends State<KnowledgeTestPage> {
  late final List<KnowledgeQuestion> _questions;
  late final List<Set<int>> _selected;  // 每题用户选择的选项索引
  int _cursor = 0;                      // 当前题目
  bool _submitted = false;              // 已交卷

  @override
  void initState() {
    super.initState();
    _questions = widget.bundle.questions;
    _selected = List.generate(_questions.length, (_) => {});
  }

  // ===================== 状态查询 =====================
  bool get _allAnswered => _selected.every((s) => s.isNotEmpty);
  int get _correctCount {
    int n = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_isCorrect(i)) n++;
    }
    return n;
  }
  bool _isCorrect(int i) {
    final q = _questions[i];
    final s = _selected[i];
    if (s.length != q.correctIndices.length) return false;
    for (final ci in q.correctIndices) {
      if (!s.contains(ci)) return false;
    }
    return true;
  }

  // ===================== 选择动作 =====================
  void _toggleOption(int optionIndex) {
    if (_submitted) return;
    final q = _questions[_cursor];
    setState(() {
      if (q.type == QuestionType.singleChoice || q.type == QuestionType.trueFalse) {
        _selected[_cursor] = {optionIndex};
      } else {
        // 多选
        final set = Set<int>.from(_selected[_cursor]);
        if (set.contains(optionIndex)) {
          set.remove(optionIndex);
        } else {
          set.add(optionIndex);
        }
        _selected[_cursor] = set;
      }
    });
  }

  void _submit() {
    if (!_allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先完成所有题目')),
      );
      return;
    }
    setState(() => _submitted = true);
  }

  void _reset() {
    setState(() {
      _cursor = 0;
      _submitted = false;
      for (int i = 0; i < _selected.length; i++) _selected[i].clear();
    });
  }

  // ===================== 主构建 =====================
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.entry.title} · 知识测试'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _questions.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_empty_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text('该知识点暂无测试题', style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
                  ],
                ),
              )
            : Column(
                children: [
                  // 进度 / 结果头部
                  _buildHeader(cs),
                  // 题目区
                  Expanded(child: _buildQuestionArea(cs)),
                  // 导航
                  if (!_submitted) _buildNavFooter(cs),
                ],
              ),
      ),
    );
  }

  // ===================== 头部：进度 / 得分 =====================
  Widget _buildHeader(ColorScheme cs) {
    if (_submitted) {
      final rate = _correctCount / _questions.length;
      final good = rate >= 0.8;
      final pass = rate >= 0.6;
      final color = good ? Colors.green : (pass ? Colors.orange : Colors.red);
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(
                  '$_correctCount/${_questions.length}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    good ? '全部掌握，恭喜！' : (pass ? '基础掌握，还需加固' : '请重新学习知识点'),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color.shade700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '正确率 ${(rate * 100).toInt()}%',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: rate,
                      minHeight: 5,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _reset,
              icon: const Icon(Icons.replay_rounded, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // 未提交：进度条 + 题号指示
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Text(
                '${_cursor + 1}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: cs.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '共 ${_questions.length} 题，已完成 ${_selected.where((s) => s.isNotEmpty).length} 题',
                  style: TextStyle(fontSize: 12, color: cs.onSurface, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_cursor + 1) / _questions.length,
                    minHeight: 4,
                    backgroundColor: cs.primary.withValues(alpha: 0.12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== 题目区 =====================
  Widget _buildQuestionArea(ColorScheme cs) {
    if (_submitted) return _buildResultList(cs);
    return _buildSingleQuestion(cs);
  }

  Widget _buildSingleQuestion(ColorScheme cs) {
    final q = _questions[_cursor];
    final typeLabel = switch (q.type) {
      QuestionType.singleChoice => '单选题',
      QuestionType.multipleChoice => '多选题',
      QuestionType.trueFalse => '判断题',
    };
    final typeColor = switch (q.type) {
      QuestionType.singleChoice => Colors.blue,
      QuestionType.multipleChoice => Colors.deepPurple,
      QuestionType.trueFalse => Colors.teal,
    };
    final diffColor = q.difficulty == 1 ? Colors.green : (q.difficulty == 2 ? Colors.orange : Colors.red);
    final diffLabel = ['简单', '中等', '困难'][q.difficulty - 1];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  typeLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: typeColor),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: diffColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  diffLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: diffColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            q.question,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface, height: 1.5),
          ),
          const SizedBox(height: 16),
          ...List.generate(q.options.length, (i) => _buildOptionTile(cs, q, i)),
        ],
      ),
    );
  }

  Widget _buildOptionTile(ColorScheme cs, KnowledgeQuestion q, int i) {
    final selected = _selected[_cursor].contains(i);
    final optLetter = String.fromCharCode(65 + i); // A/B/C/D

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleOption(i),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected
                  ? cs.primary.withValues(alpha: 0.12)
                  : cs.surfaceContainerHighest.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? cs.primary.withValues(alpha: 0.5) : cs.outlineVariant.withValues(alpha: 0.3),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? cs.primary : cs.surfaceContainerHighest.withValues(alpha: 0.6),
                  ),
                  child: Center(
                    child: selected
                        ? Icon(Icons.check_rounded, size: 16, color: cs.onPrimary)
                        : Text(
                            optLetter,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      q.options[i],
                      style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.45),
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

  // ===================== 结果列表 =====================
  Widget _buildResultList(ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: _questions.length,
      itemBuilder: (ctx, i) {
        final q = _questions[i];
        final correct = _isCorrect(i);
        final color = correct ? Colors.green : Colors.red;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '第 ${i + 1} 题 ${correct ? '回答正确' : '回答错误'}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  q.question,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface, height: 1.45),
                ),
                const SizedBox(height: 10),
                ...List.generate(q.options.length, (oi) {
                  final isUserSel = _selected[i].contains(oi);
                  final isCorrectOpt = q.correctIndices.contains(oi);
                  Color bg = cs.surfaceContainerHighest.withValues(alpha: 0.3);
                  Color? borderColor;
                  IconData? trailingIcon;
                  Color? trailingColor;

                  if (isCorrectOpt) {
                    bg = Colors.green.withValues(alpha: 0.12);
                    borderColor = Colors.green.withValues(alpha: 0.4);
                    trailingIcon = Icons.check_rounded;
                    trailingColor = Colors.green;
                  } else if (isUserSel && !isCorrectOpt) {
                    bg = Colors.red.withValues(alpha: 0.1);
                    borderColor = Colors.red.withValues(alpha: 0.4);
                    trailingIcon = Icons.close_rounded;
                    trailingColor = Colors.red;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                      border: borderColor != null ? Border.all(color: borderColor) : null,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${String.fromCharCode(65 + oi)}. ',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
                        ),
                        Expanded(
                          child: Text(
                            q.options[oi],
                            style: TextStyle(fontSize: 12, color: cs.onSurface),
                          ),
                        ),
                        if (trailingIcon != null)
                          Icon(trailingIcon, size: 16, color: trailingColor),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.auto_stories_rounded, size: 16, color: cs.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '解析：${q.explanation}',
                          style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===================== 底部导航 =====================
  Widget _buildNavFooter(ColorScheme cs) {
    final isFirst = _cursor == 0;
    final isLast = _cursor == _questions.length - 1;
    final sel = _selected[_cursor];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            TextButton.icon(
              onPressed: isFirst ? null : () => setState(() => _cursor--),
              icon: const Icon(Icons.chevron_left_rounded, size: 18),
              label: const Text('上一题'),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
            const Spacer(),
            Text(
              sel.isEmpty ? '请选择答案' : '已选择 ${sel.length} 项',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
            const Spacer(),
            if (!isLast)
              FilledButton.icon(
                onPressed: sel.isEmpty
                    ? null
                    : () => setState(() => _cursor++),
                icon: const Text('下一题'),
                label: const Icon(Icons.chevron_right_rounded, size: 18),
                style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
              )
            else
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('提交'),
                style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
          ],
        ),
      ),
    );
  }
}
