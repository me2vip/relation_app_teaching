/// 逐步模拟教学 Widget
///
/// 关卡制教学对话界面。系统扮演对话对象，用户逐轮回复，
/// 每轮给出即时反馈（话术点评 + 改进建议 + 参考话术）。
library teaching_dialogue_widget;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_style_system.dart';
import '../../../../shared/widgets/app_widgets.dart';
import 'teaching_level_system.dart';

// ============================================================================
// 教学对话 Widget
// ============================================================================

class TeachingDialogueWidget extends StatefulWidget {
  final TeachingLevel level;
  final String contactName;
  final String contactGender;
  final TeachingMode mode;
  final void Function(double totalScore, bool passed)? onComplete;
  final VoidCallback? onRetry;
  final VoidCallback? onShowDemonstration;

  const TeachingDialogueWidget({
    super.key,
    required this.level,
    required this.contactName,
    required this.contactGender,
    this.mode = TeachingMode.general,
    this.onComplete,
    this.onRetry,
    this.onShowDemonstration,
  });

  @override
  State<TeachingDialogueWidget> createState() => _TeachingDialogueWidgetState();
}

class _TeachingDialogueWidgetState extends State<TeachingDialogueWidget> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _listKey = GlobalKey<AnimatedListState>();
  final List<TeachingMessage> _messages = [];
  int _turnCount = 0;
  bool _isSimulating = false;
  bool _hasEnded = false;
  double _totalScore = 0;
  final _random = Random();

  // 测试题状态
  bool _showQuiz = false;
  int _quizIndex = 0;
  int? _selectedAnswer;
  int _quizCorrectCount = 0;
  bool _quizFinished = false;

  TeachingLevel get _level => widget.level;

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startLevel() {
    final greeting = _generateOpeningMessage();
    _messages.add(TeachingMessage(
      isUser: false,
      content: greeting,
      timestamp: DateTime.now(),
    ));
    _turnCount = 0;
    _totalScore = 0;
    _hasEnded = false;
  }

  String _generateOpeningMessage() {
    // 优先使用模式专属开场白
    final modeContent = ModeContentRegistry.getContent(widget.mode, _level.level);
    if (modeContent != null) return modeContent.openingMessage;

    final levelNum = _level.level;
    switch (levelNum) {
      case 1:
        return '（对方注意到你走过来，微笑着点了点头）嗨，今天人真多啊。';
      case 2:
        return '（对方微笑着回应）你好！我是做市场策划的，你呢？';
      case 3:
        return '（对方喝了一口饮料，表情变得认真）你知道吗，最近我们部门那个新项目真的让我挺有感触的——一开始大家都觉得不行，但最后居然成了。';
      case 4:
        return '（沉默了两秒，对方看了看四周）所以...你平时周末一般喜欢做些什么？';
      case 5:
        return '（对方叹了口气，语气低沉）有时候我真的不知道自己在坚持什么。上个月的项目被毙了，团队里也有人走了，感觉所有努力都白费了。';
      case 6:
        return '（对方交叉双臂，语气变得坚定）我明白你的想法，但我觉得我们应该先把预算砍掉一半，把核心功能做好——做太多反而哪个都做不精。';
      case 7:
        return '（对方放松地靠在椅背上，微笑着）跟你说实话，其实我一直想做一些跟现在完全不一样的事。只是...不太确定从哪开始。';
      case 8:
        return '（对方略显犹豫地笑了笑）展览啊...说实话我对当代艺术一窍不通，去了会不会完全看不懂？';
      case 9:
        return '（隔了几天的第一条消息）嗯。';
      case 10:
        return '（朋友聚会上，音乐声和笑声交织）嘿！你是小林的大学同学对吧？我是她同事，之前好像在公司年会上见过你。';
      default:
        return '你好，很高兴认识你。';
    }
  }

  void _onSendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSimulating || _hasEnded) return;
    _inputController.clear();

    // 添加用户消息
    final userMsg = TeachingMessage(
      isUser: true,
      content: text,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _turnCount++;

    // 即时评分
    final score = _evaluateMessage(text);
    final feedback = _generateFeedback(text, score);
    final reference = _generateReferenceReply();

    // 更新用户消息的评分信息
    _messages[_messages.length - 1] = TeachingMessage(
      isUser: true,
      content: text,
      feedback: feedback,
      referenceReply: reference,
      score: score,
      timestamp: userMsg.timestamp,
    );

    _totalScore += score;

    setState(() {});
    _scrollToBottom();

    // 检查是否结束
    if (_turnCount >= _level.maxTurns) {
      _hasEnded = true;
      final passed = _totalScore >= _level.passThreshold;
      setState(() {});
      widget.onComplete?.call(_totalScore, passed);
      return;
    }

    // 模拟对方回复
    _isSimulating = true;
    setState(() {});

    Future.delayed(Duration(milliseconds: 800 + _random.nextInt(700)), () {
      if (!mounted) return;
      final reply = _generateReply(text);
      _messages.add(TeachingMessage(
        isUser: false,
        content: reply,
        timestamp: DateTime.now(),
      ));
      _isSimulating = false;
      setState(() {});
      _scrollToBottom();
    });
  }

  double _evaluateMessage(String text) {
    double base = 5.0;
    final len = text.trim().length;

    // 过长或过短
    if (len < 5) base -= 2;
    if (len < 10) base -= 1;
    if (len > 200) base -= 0.5;

    // 关键词检测
    final lower = text.toLowerCase();
    final goodKeywords = _getGoodKeywords();
    final badKeywords = _getBadKeywords();

    for (final kw in goodKeywords) {
      if (lower.contains(kw)) base += 0.5;
    }
    for (final kw in badKeywords) {
      if (lower.contains(kw)) base -= 1.0;
    }

    // 问句加分（开放式>封闭式）
    if (text.contains('？') || text.contains('?')) {
      if (text.contains('怎么') || text.contains('为什么') || text.contains('什么')) {
        base += 1.0;
      } else {
        base += 0.5;
      }
    }

    // 情绪词加分
    final emotionWords = ['感觉', '觉得', '听起来', '看起来', '理解', '明白', '懂'];
    int emotionCount = 0;
    for (final w in emotionWords) {
      if (text.contains(w)) emotionCount++;
    }
    base += emotionCount * 0.3;

    return base.clamp(1.0, 10.0);
  }

  List<String> _getGoodKeywords() {
    // 优先使用模式专属关键词
    final modeContent = ModeContentRegistry.getContent(widget.mode, _level.level);
    if (modeContent != null) return modeContent.goodKeywords;

    switch (_level.level) {
      case 1: return ['今天', '活动', '分享', '你觉得', '有意思', '有趣'];
      case 2: return ['做', '喜欢', '最近', '研究', '关注', '好奇'];
      case 3: return ['然后呢', '感受', '那时候', '后来', '厉害', '了不起'];
      case 4: return ['说到', '对了', '这让我', '你也', '试过'];
      case 5: return ['不容易', '辛苦', '理解', '如果是我', '坚持', '佩服'];
      case 6: return ['理解', '担心', '共同', '方案', '试试', '你觉得'];
      case 7: return ['其实', '梦想', '如果', '真的', '重要', '想过'];
      case 8: return ['一起', '试试', '有趣', '体验', '我觉得', '简单'];
      case 9: return ['抱歉', '不对', '我错', '以后', '弥补', '机会'];
      case 10: return ['你好', '认识', '有意思', '聊聊', '理解', '抱歉', '一起'];
      default: return [];
    }
  }

  List<String> _getBadKeywords() {
    return ['随便', '不知道', '没意思', '无聊', '关我什么事', '哦', '呵呵', '你管呢'];
  }

  String _generateFeedback(String text, double score) {
    if (score >= 8.5) {
      return '做得很好！表达自然流畅，既有开放性又展现了真诚。继续这个状态！';
    } else if (score >= 7) {
      return '不错！方向是对的。可以考虑加入更多共情表达（如"我能理解"、"听起来"等）让对话更有温度。';
    } else if (score >= 5.5) {
      return '还可以，但有些地方可以优化：试着用更开放的方式回应，给对方更多接话的空间。避免过于简短的回复。';
    } else if (score >= 3.5) {
      return '需要改进。当前的回复可能让对方感到被堵死或不被重视。尝试：①表达你对对方的关注 ②用问句邀请对方继续分享。';
    } else {
      return '这轮互动效果不理想。请避免敷衍、冷淡或攻击性的表达。试着回到本轮教学目标，重新思考你真正想传达的是什么。';
    }
  }

  String _generateReferenceReply() {
    // 优先使用模式专属参考话术
    final modeContent = ModeContentRegistry.getContent(widget.mode, _level.level);
    if (modeContent != null) return modeContent.referenceReply;

    switch (_level.level) {
      case 1:
        return '嗨！确实，今天这个活动的氛围挺好的。你也是被朋友拉来的还是自己感兴趣的？';
      case 2:
        return '我是做产品设计的——最近在研究一些有趣的人机交互方向。说起来，你做市场策划应该经常跟不同的人打交道吧？';
      case 3:
        return '从被质疑到最终成功，这个过程听起来挺燃的。当时最难的部分是什么？你们是怎么撑过来的？';
      case 4:
        return '（微笑）周末的话，我最近迷上了城市徒步——不设具体目的地，就走到哪算哪，总能发现一些平时注意不到的小店。你呢？';
      case 5:
        return '听起来这段时间确实不容易。项目被毙、团队有人离开，换谁都会觉得打击很大。但你能坚持到现在，本身就说明了很多。';
      case 6:
        return '我理解你的担心，把预算集中到核心功能上确实更稳妥。不过我在想，有没有一个折中方案——比如先把核心功能做到极致，再把预算省下来做一两个能让人眼前一亮的差异化特性？';
      case 7:
        return '（认真地）我懂那种感觉——心里有个声音告诉你现在不是终点，但又不确定下一步该往哪走。如果完全抛开顾虑，你最想尝试的是什么方向？';
      case 8:
        return '完全不用担心！其实当代艺术最有意思的地方恰恰是——没有标准答案。我可以陪你先去看两个最有趣的作品，如果觉得无聊我们随时可以走。而且我知道附近有家超棒的咖啡馆，看完可以去坐坐。';
      case 9:
        return '我知道这次是我做错了，没有弄清楚情况就先做了决定。我不该让你感到被忽视。以后做类似决定之前，我一定会先跟你商量。如果可以的话，我想找个时间好好聊聊，把我该弥补的都补上。';
      case 10:
        return '没错！年会那次你好像还抽到了一个蓝牙音箱对吧（笑）。说起来，小林总说你是你们部门的"救火队长"——什么项目到你手里都能搞定。我特别好奇你是怎么做到的？';
      default:
        return '说得真好，你能详细说说吗？';
    }
  }

  String _generateReply(String userText) {
    final mood = _level.initialMood + (_totalScore / _level.maxTurns - 5) * 0.2;
    final lower = userText.toLowerCase();

    // 根据用户内容动态生成回应
    if (mood > 0.5) {
      // 对方情绪好
      final replies = [
        '（眼睛亮了起来）真的吗？我也觉得！',
        '（笑着点头）你说得太对了，我以前都没从这个角度想过。',
        '（身体微微前倾，看起来被你的话题吸引住了）这个事情有意思，你再多说说？',
      ];
      return replies[_random.nextInt(replies.length)];
    } else if (mood < -0.3) {
      // 对方情绪差
      final replies = [
        '（微微皱眉，看起来不太确定）嗯...我可能需要再想想。',
        '（语气平淡）好吧，我知道了。',
        '（轻轻叹了口气，没有立即回应）',
      ];
      return replies[_random.nextInt(replies.length)];
    } else {
      // 中性地继续对话
      if (lower.contains('？') || lower.contains('?')) {
        final replies = [
          '（思考了一下）这个问题挺好的...我觉得可能是（停顿）跟环境有关吧。你怎么看？',
          '（认真地点头）说实话，我之前确实没认真想过。让我想想...',
          '（被问得有点开心）你问得挺深的。其实我觉得...',
        ];
        return replies[_random.nextInt(replies.length)];
      } else {
        final replies = [
          '（若有所思地点点头）嗯，我明白你的意思。',
          '（微笑着）你说的有道理。对了，你有没有类似的经历？',
          '（似乎被触动了）这样说起来...其实我也有过类似的感受。',
        ];
        return replies[_random.nextInt(replies.length)];
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showDemonstration() {
    widget.onShowDemonstration?.call();
    final cs = Theme.of(context).colorScheme;
    final modeContent = ModeContentRegistry.getContent(widget.mode, _level.level);
    final knowledgePoints = _level.knowledgeCards
        .asMap()
        .entries
        .map((e) => '💡 ${e.key + 1}. ${e.value.title}\n   ${e.value.content.replaceAll('\n', '\n   ')}')
        .join('\n\n');
    final demoReply = modeContent?.referenceReply ?? _generateReferenceReply();
    final opening = modeContent?.openingMessage ?? _generateOpeningMessage();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary.withValues(alpha: 0.12),
                    ),
                    child: Icon(Icons.auto_awesome_rounded, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'L${_level.level} · ${_level.title}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        if (widget.mode != TeachingMode.general)
                          Text(
                            '${widget.mode.label}模式 · 示范对话',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildSection(cs, '🎯 教学目标', _level.teachingGoal),
              const SizedBox(height: 14),
              _buildSection(cs, '🎬 场景设定', modeContent?.scenarioDescription ?? _level.scenarioDescription),
              if (modeContent != null) ...[
                const SizedBox(height: 14),
                _buildSection(cs, '👤 对方画像', modeContent.contactPersona),
                const SizedBox(height: 14),
                _buildSection(cs, '💭 情绪状态', modeContent.contactMood),
              ],
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primaryContainer.withValues(alpha: 0.5), cs.primaryContainer.withValues(alpha: 0.15)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.play_circle_fill_rounded, size: 18, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          '示范对话（共 2 轮）',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildChatBubble(cs, false, opening),
                    const SizedBox(height: 10),
                    _buildChatBubble(cs, true, demoReply),
                    const SizedBox(height: 10),
                    _buildChatBubble(cs, false, _generateReply(demoReply)),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildSection(cs, '📚 核心技巧要点', knowledgePoints),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(ColorScheme cs, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.55,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubble(ColorScheme cs, bool isUser, String text) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isUser) ...[
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.secondary.withValues(alpha: 0.2),
            ),
            child: Icon(Icons.person_outline_rounded, size: 14, color: cs.secondary),
          ),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isUser
                  ? cs.primary
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isUser ? const Radius.circular(12) : const Radius.circular(3),
                bottomRight: isUser ? const Radius.circular(3) : const Radius.circular(12),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: isUser ? cs.onPrimary : cs.onSurface,
              ),
            ),
          ),
        ),
        if (isUser) ...[
          const SizedBox(width: 6),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primary.withValues(alpha: 0.2),
            ),
            child: Icon(Icons.tag_faces_outlined, size: 14, color: cs.primary),
          ),
        ],
      ],
    );
  }

  void _retryLevel() {
    _messages.clear();
    _turnCount = 0;
    _totalScore = 0;
    _hasEnded = false;
    _isSimulating = false;
    _inputController.clear();
    _startLevel();
    setState(() {});
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPassed = _totalScore >= _level.passThreshold;
    final progressPercent = (_turnCount / _level.maxTurns).clamp(0.0, 1.0);
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    // 读取当前风格配置，应用与伴窗一致的 scaffoldBg→surfaceColor 渐变背景
    final styleNotifier = context.watch<AppStyleNotifier>();
    final styleConfig = styleNotifier.config;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      body: Material(
        type: MaterialType.transparency,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                styleConfig.scaffoldBg,
                Color.lerp(styleConfig.scaffoldBg, styleConfig.surfaceColor, 0.45)!,
                styleConfig.surfaceColor,
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // 顶部信息栏
                  _buildHeader(cs, progressPercent, isPassed),
                  // 对话列表
                  Expanded(
                    child: _messages.isEmpty
                        ? _buildEmptyState(cs)
                        : ListView.builder(
                            key: _listKey,
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemCount: _messages.length,
                            itemBuilder: (ctx, i) {
                              final msg = _messages[i];
                              return _buildMessageBubble(msg, cs);
                            },
                          ),
                  ),
                  // 底部输入区 / 结束区
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.only(
                      bottom: viewInsets > 0 ? 0 : 8,
                    ),
                    child: _hasEnded
                        ? _buildEndPanel(cs, isPassed)
                        : _buildInputBar(cs),
                  ),
                ],
              ),
              // 知识测试题面板
              if (_showQuiz)
                Positioned.fill(child: _buildQuizPanel(cs)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs, double progressPercent, bool isPassed) {
    return SafeArea(
      bottom: false,
      child: Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_level.icon, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _level.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _level.teachingGoal,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.6),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _showDemonstration,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_rounded, size: 13, color: cs.onTertiaryContainer),
                      const SizedBox(width: 3),
                      Text(
                        '示范',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '目标 ${_level.passThreshold.toInt()}分',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 进度条
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 8,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _totalScore >= _level.passThreshold ? Colors.green : cs.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '第 $_turnCount / ${_level.maxTurns} 轮',
                style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.55)),
              ),
              const Spacer(),
              Text(
                '累计 ${_totalScore.toStringAsFixed(0)} 分',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _totalScore >= _level.passThreshold
                      ? Colors.green.shade600
                      : cs.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_level.icon, size: 48, color: cs.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              _level.scenarioDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                _retryLevel();
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text('开始练习'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(TeachingMessage msg, ColorScheme cs) {
    final hasFeedback = msg.isUser && msg.feedback != null && _hasEnded;
    // 解析旁白（括号内动作描写）与对话内容
    final narration = _extractNarration(msg.content);
    final dialogue = _extractDialogue(msg.content);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment:
            msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // 消息气泡
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: msg.isUser
                  ? cs.primaryContainer
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(msg.isUser ? 16 : 0),
                bottomRight: Radius.circular(msg.isUser ? 0 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!msg.isUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      widget.contactName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                  ),
                // 旁白（动作描述）
                if (narration != null) ...[
                  Text(
                    narration,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: cs.onSurface.withValues(alpha: 0.50),
                      height: 1.4,
                    ),
                  ),
                  if (dialogue != null) const SizedBox(height: 6),
                ],
                // 对话正文
                if (dialogue != null)
                  Text(
                    dialogue,
                    style: TextStyle(
                      fontSize: 14,
                      color: msg.isUser
                          ? cs.onPrimaryContainer
                          : cs.onSurface,
                      height: 1.5,
                    ),
                  )
                else if (narration == null)
                  Text(
                    msg.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: msg.isUser
                          ? cs.onPrimaryContainer
                          : cs.onSurface,
                      height: 1.5,
                    ),
                  ),
              ],
            ),
          ),
          // 即时反馈（仅在结束时显示）
          if (hasFeedback) ...[
            const SizedBox(height: 4),
            _buildFeedbackCard(msg, cs),
          ],
        ],
      ),
    );
  }

  /// 提取括号内的旁白/动作描写，返回 null 表示无旁白
  String? _extractNarration(String content) {
    final match = RegExp(r'^（(.+?)）').firstMatch(content.trim());
    return match != null ? '（${match.group(1)}）' : null;
  }

  /// 提取去旁白后的对话正文
  String? _extractDialogue(String content) {
    final trimmed = content.trim();
    final match = RegExp(r'^（.+?）\s*(.*)$', dotAll: true).firstMatch(trimmed);
    if (match != null) {
      final after = match.group(1)?.trim();
      return (after != null && after.isNotEmpty) ? after : null;
    }
    return null; // 无旁白时返回 null，由外层走原逻辑
  }

  Widget _buildFeedbackCard(TeachingMessage msg, ColorScheme cs) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: msg.score! >= 7
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: msg.score! >= 7
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                msg.score! >= 7 ? Icons.check_circle_outline : Icons.tips_and_updates,
                size: 14,
                color: msg.score! >= 7 ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                '得分 ${msg.score!.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: msg.score! >= 7 ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            msg.feedback!,
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant, height: 1.3),
          ),
          if (msg.referenceReply != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '参考话术：',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    msg.referenceReply!,
                    style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEndPanel(ColorScheme cs, bool isPassed) {
    // 获取本关关联的知识点
    final modeContent = ModeContentRegistry.getContent(widget.mode, _level.level);
    final relatedIds = modeContent?.relatedKnowledgeIds ?? const <String>[];
    final relatedKnowledge = relatedIds
        .map((id) => SocialKnowledgeBase.getById(id))
        .whereType<SocialKnowledgeEntry>()
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPassed
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.orange.withValues(alpha: 0.08),
        border: Border(
          top: BorderSide(color: cs.outlineVariant),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPassed ? Icons.celebration_rounded : Icons.replay_rounded,
                size: 24,
                color: isPassed ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isPassed ? '恭喜通关！' : '未达过关线，再试一次？',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isPassed ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
              ),
              Text(
                '${_totalScore.toStringAsFixed(0)} / ${_level.passThreshold.toInt()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),

          // 相关知识点区域
          if (relatedKnowledge.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 16, color: cs.primary),
                      const SizedBox(width: 6),
                      Text(
                        '本关知识点（${relatedKnowledge.length}）',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: relatedKnowledge.map((k) {
                      return InkWell(
                        onTap: () => _showKnowledgeDetail(cs, k),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                k.title.length > 16 ? '${k.title.substring(0, 16)}…' : k.title,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: cs.primary,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '点击标签查看知识详情，掌握理论再练习',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _retryLevel,
                  icon: const Icon(Icons.replay_rounded, size: 16),
                  label: const Text('重试本关'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showDemonstration,
                  icon: const Icon(Icons.visibility_rounded, size: 16),
                  label: const Text('查看示范'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _startQuiz,
                  icon: const Icon(Icons.quiz_rounded, size: 16),
                  label: const Text('知识测试'),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 显示知识详情弹窗
  void _showKnowledgeDetail(ColorScheme cs, SocialKnowledgeEntry entry) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_rounded, size: 20, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              // 分类标签
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Expanded(
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: entry.tags.take(3).map((t) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cs.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '#$t',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(height: 20, thickness: 0.5),
              // 内容（可滚动）
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildMarkdownContent(entry.content, cs),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarkdownContent(String content, ColorScheme cs) {
    // 简易Markdown支持（同knowledge_base中的渲染逻辑）
    final lines = content.split('\n');
    final children = <Widget>[];
    for (final line in lines) {
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }
      if (line.startsWith('### ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            line.substring(4),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ));
      } else if (line.startsWith('## ')) {
        children.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            line.substring(3),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: cs.primary,
            ),
          ),
        ));
      } else if (line.startsWith('**') && line.endsWith('**')) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            line.substring(2, line.length - 2),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              height: 1.6,
            ),
          ),
        ));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 7, left: 4, right: 8),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(child: Text(
                line.substring(2),
                style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.6),
              )),
            ],
          ),
        ));
      } else if (line.contains('**')) {
        // 行内粗体
        final spans = <TextSpan>[];
        final parts = line.split('**');
        for (int i = 0; i < parts.length; i++) {
          final isBold = i % 2 == 1;
          spans.add(TextSpan(
            text: parts[i],
            style: TextStyle(
              fontSize: 13,
              height: 1.65,
              color: cs.onSurface,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w400,
            ),
          ));
        }
        children.add(RichText(text: TextSpan(children: spans)));
      } else {
        children.add(Text(
          line,
          style: TextStyle(
            fontSize: 13,
            color: cs.onSurface,
            height: 1.65,
          ),
        ));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  // ========================================================================
  // 知识测试题系统
  // ========================================================================

  void _startQuiz() {
    final quiz = QuizRegistry.getQuiz(_level.level, widget.mode);
    if (quiz == null || quiz.isEmpty) {
      AppToast.info(context, '本关暂无测试题', duration: const Duration(seconds: 2));
      return;
    }
    setState(() {
      _showQuiz = true;
      _quizIndex = 0;
      _selectedAnswer = null;
      _quizCorrectCount = 0;
      _quizFinished = false;
    });
  }

  void _answerQuestion(int index, List<QuizQuestion> quiz) {
    setState(() => _selectedAnswer = index);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_selectedAnswer == quiz[_quizIndex].correctIndex) {
        _quizCorrectCount++;
      }
      if (_quizIndex < quiz.length - 1) {
        setState(() {
          _quizIndex++;
          _selectedAnswer = null;
        });
      } else {
        setState(() => _quizFinished = true);
      }
    });
  }

  void _closeQuiz() {
    setState(() {
      _showQuiz = false;
      _quizIndex = 0;
      _selectedAnswer = null;
      _quizCorrectCount = 0;
      _quizFinished = false;
    });
  }

  Widget _buildQuizPanel(ColorScheme cs) {
    final quiz = QuizRegistry.getQuiz(_level.level, widget.mode) ?? [];
    if (quiz.isEmpty) return const SizedBox.shrink();

    final question = quiz[_quizIndex];
    final isAnswered = _selectedAnswer != null;
    final isCorrect = isAnswered && _selectedAnswer == question.correctIndex;

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _quizFinished
              ? _buildQuizResult(cs, quiz.length)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 进度
                    Row(
                      children: [
                        Icon(Icons.quiz_rounded, size: 18, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          '知识测试 ${_quizIndex + 1}/${quiz.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: _closeQuiz,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    // 题干
                    Text(
                      question.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 选项
                    ...List.generate(question.options.length, (i) {
                      final option = question.options[i];
                      final isSelected = _selectedAnswer == i;
                      final isCorrectOption = i == question.correctIndex;

                      Color? bgColor;
                      Color? borderColor;
                      Color? textColor;
                      IconData? trailingIcon;

                      if (isAnswered) {
                        if (isCorrectOption) {
                          bgColor = Colors.green.withValues(alpha: 0.12);
                          borderColor = Colors.green;
                          textColor = Colors.green.shade700;
                          trailingIcon = Icons.check_circle_rounded;
                        } else if (isSelected) {
                          bgColor = Colors.red.withValues(alpha: 0.12);
                          borderColor = Colors.red;
                          textColor = Colors.red.shade700;
                          trailingIcon = Icons.cancel_rounded;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: isAnswered ? null : () => _answerQuestion(i, quiz),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: bgColor ?? cs.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: borderColor ?? cs.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected || (isAnswered && isCorrectOption)
                                          ? (isCorrectOption ? Colors.green : Colors.red)
                                          : cs.outlineVariant,
                                    ),
                                    color: isSelected || (isAnswered && isCorrectOption)
                                        ? (isCorrectOption ? Colors.green : Colors.red)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + i),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected || (isAnswered && isCorrectOption)
                                            ? Colors.white
                                            : cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textColor ?? cs.onSurface,
                                    ),
                                  ),
                                ),
                                if (trailingIcon != null)
                                  Icon(trailingIcon, size: 18, color: textColor),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    // 解析
                    if (isAnswered) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (isCorrect ? Colors.green : Colors.orange).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle_outline : Icons.lightbulb_outline,
                              size: 16,
                              color: isCorrect ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                question.explanation,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: 0.8),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildQuizResult(ColorScheme cs, int total) {
    final ratio = _quizCorrectCount / total;
    final isAllCorrect = _quizCorrectCount == total;
    final isPass = ratio >= 0.6;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isAllCorrect ? Icons.emoji_events_rounded : (isPass ? Icons.thumb_up_rounded : Icons.refresh_rounded),
          size: 48,
          color: isAllCorrect ? Colors.amber : (isPass ? Colors.green : Colors.orange),
        ),
        const SizedBox(height: 12),
        Text(
          '$_quizCorrectCount / $total',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isAllCorrect ? Colors.amber.shade700 : (isPass ? Colors.green : Colors.orange),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isAllCorrect ? '全部正确！知识掌握牢固' : (isPass ? '不错！继续巩固' : '还需加强，建议复习'),
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _closeQuiz,
            child: const Text('完成测试'),
          ),
        ),
      ],
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
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
              controller: _inputController,
              enabled: !_isSimulating,
              cursorColor: cs.primary,
              decoration: InputDecoration(
                hintText: _isSimulating ? '对方正在输入...' : '输入你的回复...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: cs.onSurface.withValues(alpha: 0.38),
                ),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
              style: TextStyle(fontSize: 14, color: cs.onSurface),
              onSubmitted: (_) => _onSendMessage(),
              maxLines: null,
              textInputAction: TextInputAction.send,
            ),
          ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSimulating
                ? SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  )
                : IconButton.filled(
                    onPressed: _onSendMessage,
                    icon: const Icon(Icons.send_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
