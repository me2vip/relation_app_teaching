/// 知识点练习页：基于单个知识点的情景对话练习
library knowledge_practice_page;

import 'dart:math';
import 'package:flutter/material.dart';

import 'teaching_level_system.dart';
import 'knowledge_extensions.dart';

/// 练习模式：自由练习 / 分步指导
enum _PracticeMode { free, guided }

class KnowledgePracticePage extends StatefulWidget {
  final SocialKnowledgeEntry entry;
  final KnowledgeExtensionBundle bundle;

  const KnowledgePracticePage({
    super.key,
    required this.entry,
    required this.bundle,
  });

  @override
  State<KnowledgePracticePage> createState() => _KnowledgePracticePageState();
}

class _KnowledgePracticePageState extends State<KnowledgePracticePage> {
  late final List<KnowledgePractice> _practices;
  int _currentIndex = 0;

  // 模式选择
  _PracticeMode? _selectedMode;

  // 分步指导状态
  int _currentStep = 0;
  bool _guideCompleted = false;
  KnowledgeStepGuide? _activeGuide;

  // 练习状态
  bool _inProgress = false;
  bool _finished = false;
  int _turn = 0;
  final int _maxTurns = 3;
  double _score = 0;
  String? _lastFeedback;
  final List<_PracticeMsg> _messages = [];
  final _inputController = TextEditingController();
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _practices = widget.bundle.practices;
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  // ===================== 启动一个练习场景 =====================
  void _startPractice(int index) {
    final p = _practices[index];
    setState(() {
      _currentIndex = index;
      _inProgress = true;
      _finished = false;
      _turn = 0;
      _score = 0;
      _messages.clear();
      _messages.add(_PracticeMsg(content: p.openingMessage, isUser: false));
    });
  }

  void _exitPractice() {
    setState(() {
      _inProgress = false;
      _finished = false;
      _messages.clear();
      _inputController.clear();
    });
  }

  // ===================== 提交回复 =====================
  void _submitReply() {
    final text = _inputController.text.trim();
    if (text.isEmpty || _finished) return;
    _inputController.clear();

    final p = _practices[_currentIndex];
    double turnScore = _calculateScore(text, p.goodKeywords);
    _score += turnScore;

    String feedback;
    if (turnScore >= 8) {
      feedback = '很好！熟练运用了关键词，表达自然且有效。';
    } else if (turnScore >= 5) {
      feedback = '不错，但可以更好。尝试更自然地融入关键词。';
    } else {
      feedback = '需要改进。请参考下方示范话术，理解为什么要这么说。';
    }

    setState(() {
      _messages.add(_PracticeMsg(content: text, isUser: true));
      _turn++;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (_turn >= _maxTurns) {
        setState(() {
          _finished = true;
          _lastFeedback = feedback;
        });
      } else {
        final reply = _generateNpcReply(turnScore);
        setState(() {
          _messages.add(_PracticeMsg(content: reply, isUser: false));
        });
      }
    });
  }

  double _calculateScore(String text, List<String> keywords) {
    double score = 3.0;
    for (final kw in keywords) {
      if (text.contains(kw)) score += 1.5;
    }
    if (text.length > 10) score += 1.0;
    if (text.length > 30) score += 1.0;
    if (text.contains('?') || text.contains('？')) score += 0.5;
    return score.clamp(0, 10);
  }

  String _generateNpcReply(double score) {
    if (score >= 8) {
      final replies = [
        '嗯，你说得挺有道理的。继续说？',
        '哈哈对，我也是这么想的。那你呢？',
        '这个角度不错，我没想过。再聊聊？',
      ];
      return replies[_random.nextInt(replies.length)];
    } else if (score >= 5) {
      final replies = [
        '嗯……算是吧。不过我还有点不同看法。',
        '也算有道理。你具体是怎么想的？',
        '嗯，你说的我懂了，但我不完全同意。',
      ];
      return replies[_random.nextInt(replies.length)];
    } else {
      final replies = [
        '……我不太理解你的意思。',
        '嗯。（简短回复，气氛有点冷）',
        '可能吧。不过我们好像不在一个频道上。',
      ];
      return replies[_random.nextInt(replies.length)];
    }
  }

  // ===================== 主构建 =====================
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget body;
    if (_selectedMode == null) {
      body = _buildModeSelector(cs);
    } else if (_selectedMode == _PracticeMode.free) {
      body = _inProgress ? _buildPracticeView(cs) : _buildScenarioPicker(cs);
    } else {
      // 分步指导模式
      if (_activeGuide == null) {
        body = _buildGuidePicker(cs);
      } else {
        body = _buildGuideView(cs);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.entry.title} · 情景练习'),
        centerTitle: true,
        leading: _selectedMode != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _handleBack,
              )
            : null,
      ),
      body: SafeArea(child: body),
    );
  }

  // ===================== 返回处理 =====================
  void _handleBack() {
    if (_selectedMode == _PracticeMode.free) {
      if (_inProgress) {
        _exitPractice();
      } else {
        setState(() => _selectedMode = null);
      }
    } else if (_selectedMode == _PracticeMode.guided) {
      if (_activeGuide != null) {
        setState(() {
          _activeGuide = null;
          _currentStep = 0;
          _guideCompleted = false;
        });
      } else {
        setState(() => _selectedMode = null);
      }
    }
  }

  // ===================== 场景选择页 =====================
  Widget _buildScenarioPicker(ColorScheme cs) {
    if (_practices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('该知识点暂无练习题', style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.tips_and_updates_rounded, size: 22, color: Colors.green.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '基于该知识点选择一个场景，进行 3 轮模拟对话练习，即时获得评分与示范话术。',
                    style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _practices.length,
            itemBuilder: (ctx, i) {
              final p = _practices[i];
              return _buildScenarioCard(cs, p, i);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScenarioCard(ColorScheme cs, KnowledgePractice p, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startPractice(index),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flash_on_rounded, size: 18, color: Colors.green),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '场景 ${index + 1}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          Text(
                            p.contactPersona,
                            style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.play_arrow_rounded, color: cs.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  p.scenario,
                  style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== 进行中练习视图 =====================
  Widget _buildPracticeView(ColorScheme cs) {
    final p = _practices[_currentIndex];
    final avgScore = _score / _maxTurns;

    return Column(
      children: [
        // 场景信息栏
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
            border: Border(bottom: BorderSide(color: cs.outlineVariant)),
          ),
          child: Row(
            children: [
              const Icon(Icons.flash_on_rounded, size: 18, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '场景 ${_currentIndex + 1}：${p.contactPersona}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '轮次 $_turn/$_maxTurns',
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (!_finished)
                TextButton(
                  onPressed: _exitPractice,
                  child: const Text('退出', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
        // 场景描述（仅前两轮可见）
        if (_turn <= 1)
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p.scenario,
                    style: TextStyle(fontSize: 11, color: cs.onSurface, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        // 对话区
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) => _buildMsgBubble(cs, _messages[i]),
          ),
        ),
        // 底部：结果 / 输入
        if (_finished)
          _buildResultPanel(cs, p, avgScore)
        else
          _buildInputBar(cs),
      ],
    );
  }

  Widget _buildMsgBubble(ColorScheme cs, _PracticeMsg msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: msg.isUser
              ? cs.primary.withValues(alpha: 0.12)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg.content,
          style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.45),
        ),
      ),
    );
  }

  Widget _buildInputBar(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              onSubmitted: (_) => _submitReply(),
              decoration: InputDecoration(
                hintText: '输入你的回复...',
                hintStyle: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.38)),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                isDense: true,
              ),
              style: TextStyle(fontSize: 13, color: cs.onSurface),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _submitReply,
            icon: const Icon(Icons.send_rounded, size: 18),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildResultPanel(ColorScheme cs, KnowledgePractice p, double avgScore) {
    final isGood = avgScore >= 7;
    final isPass = avgScore >= 5;
    final resultColor = isGood ? Colors.green : (isPass ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: resultColor.withValues(alpha: 0.08),
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGood ? Icons.celebration_rounded : (isPass ? Icons.thumb_up_rounded : Icons.refresh_rounded),
                size: 24,
                color: resultColor,
              ),
              const SizedBox(width: 8),
              Text(
                '平均分 ${avgScore.toStringAsFixed(1)}/10',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: resultColor.shade700,
                ),
              ),
              const Spacer(),
              Text(
                isGood ? '表现优秀！' : (isPass ? '还不错' : '继续练习'),
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_lastFeedback != null) ...[
            Text(
              '点评：$_lastFeedback',
              style: TextStyle(fontSize: 12, color: cs.onSurface),
            ),
            const SizedBox(height: 8),
          ],
          // 参考话术
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, size: 14, color: cs.tertiary),
                    const SizedBox(width: 4),
                    Text(
                      '参考话术',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.tertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  p.referenceReply,
                  style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 练习提示
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.tips_and_updates_rounded, size: 14, color: Colors.green.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    p.tip,
                    style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _startPractice(_currentIndex),
                  icon: const Icon(Icons.replay_rounded, size: 16),
                  label: const Text('再练一次'),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _exitPractice,
                  icon: const Icon(Icons.list_rounded, size: 16),
                  label: const Text('换个场景'),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== 模式选择页 =====================
  Widget _buildModeSelector(ColorScheme cs) {
    final hasGuides = widget.bundle.stepGuides.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 顶部介绍
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.school_rounded, size: 26, color: cs.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '选择练习方式',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '根据你的熟练程度，选择自由练习或分步指导。',
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 自由练习
          _buildModeCard(
            cs,
            icon: Icons.chat_rounded,
            iconColor: Colors.green,
            title: '自由练习',
            subtitle: '选择场景进行 3 轮模拟对话，即时评分与示范话术',
            badge: '推荐',
            onTap: () => setState(() => _selectedMode = _PracticeMode.free),
          ),
          const SizedBox(height: 12),
          // 分步指导
          _buildModeCard(
            cs,
            icon: Icons.list_alt_rounded,
            iconColor: Colors.blue,
            title: '分步指导',
            subtitle: hasGuides
                ? '按步骤学习话术与要点，循序渐进掌握技巧'
                : '暂无分步指导内容',
            badge: hasGuides ? '${widget.bundle.stepGuides.length} 个指导' : null,
            enabled: hasGuides,
            onTap: () => setState(() => _selectedMode = _PracticeMode.guided),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(
    ColorScheme cs, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badge,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? cs.surfaceContainerHighest.withValues(alpha: 0.25)
            : cs.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? iconColor.withValues(alpha: 0.35)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: enabled ? cs.onSurface : cs.onSurfaceVariant,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: iconColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: iconColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.4),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: enabled
                      ? cs.onSurfaceVariant
                      : cs.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== 分步指导选择页 =====================
  Widget _buildGuidePicker(ColorScheme cs) {
    final guides = widget.bundle.stepGuides;
    if (guides.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text('暂无分步指导', style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.list_alt_rounded, size: 22, color: Colors.blue.shade700),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '选择一个指导主题，按步骤学习完整的对话技巧。每一步包含指导说明、示范话术与注意事项。',
                    style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: guides.length,
            itemBuilder: (ctx, i) {
              final g = guides[i];
              return _buildGuideCard(cs, g, i);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCard(ColorScheme cs, KnowledgeStepGuide g, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _activeGuide = g;
              _currentStep = 0;
              _guideCompleted = false;
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0x272196F3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.list_alt_rounded, size: 18, color: Colors.blue),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '指导 ${index + 1}',
                            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                          ),
                          Text(
                            g.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${g.steps.length} 步',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  g.scenario,
                  style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      '开始学习',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== 分步指导视图 =====================
  Widget _buildGuideView(ColorScheme cs) {
    final guide = _activeGuide!;
    if (_guideCompleted) {
      return _buildGuideSummary(cs, guide);
    }

    final step = guide.steps[_currentStep];
    final totalSteps = guide.steps.length;
    final isLastStep = _currentStep == totalSteps - 1;
    final progress = totalSteps == 0 ? 0.0 : (_currentStep + 1) / totalSteps;

    return Column(
      children: [
        // 顶部标题 + 进度
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
            border: Border(bottom: BorderSide(color: cs.outlineVariant)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.list_alt_rounded, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      guide.title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${_currentStep + 1} / $totalSteps',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: cs.outlineVariant.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                ),
              ),
            ],
          ),
        ),
        // 步骤内容（可滚动）
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 场景描述（仅第一步展示）
                if (_currentStep == 0) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            guide.scenario,
                            style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // 步骤编号 + 标题
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_currentStep + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // 指导说明
                _buildSectionLabel(cs, Icons.menu_book_rounded, '指导说明', Colors.blue.shade700),
                const SizedBox(height: 6),
                Text(
                  step.instruction,
                  style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.55),
                ),
                const SizedBox(height: 14),
                // 示范话术
                _buildSectionLabel(cs, Icons.record_voice_over_rounded, '示范话术', Colors.amber.shade800),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote_rounded, size: 18, color: Colors.amber.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step.example,
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface,
                            height: 1.55,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 注意事项
                if (step.tip.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildSectionLabel(cs, Icons.warning_amber_rounded, '注意事项', Colors.orange.shade700),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.tips_and_updates_rounded, size: 18, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.tip,
                            style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // 关键词
                if (step.keywords.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildSectionLabel(cs, Icons.tag_rounded, '关键词', Colors.teal.shade700),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: step.keywords.map((kw) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          kw,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.teal.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        // 底部导航按钮
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _currentStep--),
                    icon: const Icon(Icons.keyboard_arrow_left_rounded, size: 18),
                    label: const Text('上一步'),
                    style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      if (isLastStep) {
                        _guideCompleted = true;
                      } else {
                        _currentStep++;
                      }
                    });
                  },
                  icon: Icon(
                    isLastStep ? Icons.done_all_rounded : Icons.keyboard_arrow_right_rounded,
                    size: 18,
                  ),
                  label: Text(isLastStep ? '完成' : '下一步'),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(ColorScheme cs, IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  // ===================== 分步指导完成总结 =====================
  Widget _buildGuideSummary(ColorScheme cs, KnowledgeStepGuide guide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 完成卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 32, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '已完成全部步骤',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${guide.title} · 共 ${guide.steps.length} 步',
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 场景回顾
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    guide.scenario,
                    style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          // 步骤回顾标题
          Text(
            '步骤回顾',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          // 步骤总结列表
          ...guide.steps.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '步骤 ${i + 1}：${s.title}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.instruction,
                    style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.5),
                  ),
                  if (s.example.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.format_quote_rounded, size: 14, color: Colors.amber.shade800),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s.example,
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface,
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentStep = 0;
                      _guideCompleted = false;
                    });
                  },
                  icon: const Icon(Icons.replay_rounded, size: 16),
                  label: const Text('重新学习'),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _activeGuide = null;
                      _currentStep = 0;
                      _guideCompleted = false;
                    });
                  },
                  icon: const Icon(Icons.list_alt_rounded, size: 16),
                  label: const Text('换个指导'),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PracticeMsg {
  final String content;
  final bool isUser;
  _PracticeMsg({required this.content, required this.isUser});
}
