/// 知识点练习页：基于单个知识点的情景对话练习
library knowledge_practice_page;

import 'dart:math';
import 'package:flutter/material.dart';

import 'teaching_level_system.dart';
import 'knowledge_extensions.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.entry.title} · 情景练习'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _inProgress
            ? _buildPracticeView(cs)
            : _buildScenarioPicker(cs),
      ),
    );
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
}

class _PracticeMsg {
  final String content;
  final bool isUser;
  _PracticeMsg({required this.content, required this.isUser});
}
