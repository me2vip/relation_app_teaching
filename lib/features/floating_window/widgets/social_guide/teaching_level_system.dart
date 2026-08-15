/// 对话教学关卡系统
///
/// 关卡制社交对话教学，包含 9 级关卡 + 1 级毕业考核。
/// 每关包含理论知识卡片、模拟对话练习、评分与解锁条件。
library teaching_level_system;

import 'dart:math';
import 'package:flutter/material.dart';

// ============================================================================
// 关卡等级定义
// ============================================================================

enum LevelTier { beginner, intermediate, advanced, graduation }

/// 单个关卡
class TeachingLevel {
  final int level;               // 1-10
  final String title;
  final String subtitle;
  final LevelTier tier;
  final String scenarioDescription; // 场景描述
  final String teachingGoal;        // 教学目标
  final List<KnowledgeCard> knowledgeCards; // 理论知识卡片
  final double passThreshold;       // 过关阈值（累计得分 ≥ 此值）
  final int maxTurns;               // 最大对话轮数
  final String? unlockCondition;    // 解锁条件描述（null 表示默认解锁）
  final IconData icon;
  final String badgeName;           // 勋章名称
  final String contactMood;         // 对方初始情绪描述
  final double initialMood;         // 对方初始情绪值 -1.0 ~ 1.0
  final String? contactPersona;     // 教学关卡的对方画像（模拟角色）
  final List<String> relatedKnowledgeIds; // 联动知识词典条目ID（通用模式）

  const TeachingLevel({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.tier,
    required this.scenarioDescription,
    required this.teachingGoal,
    required this.knowledgeCards,
    required this.passThreshold,
    required this.maxTurns,
    this.unlockCondition,
    required this.icon,
    required this.badgeName,
    required this.contactMood,
    required this.initialMood,
    this.contactPersona,
    this.relatedKnowledgeIds = const [],
  });
}

/// 理论知识卡片
class KnowledgeCard {
  final String title;
  final String content;
  final bool isPrinciple;   // true=原则，false=技巧/案例

  const KnowledgeCard({
    required this.title,
    required this.content,
    this.isPrinciple = false,
  });
}

// ============================================================================
// 教学对话消息
// ============================================================================

class TeachingMessage {
  final bool isUser;
  final String content;
  final String? feedback;       // 即时反馈（仅用户消息）
  final String? referenceReply; // 参考话术（仅用户消息）
  final double? score;          // 本轮得分 0-10（仅用户消息）
  final DateTime timestamp;

  const TeachingMessage({
    required this.isUser,
    required this.content,
    this.feedback,
    this.referenceReply,
    this.score,
    required this.timestamp,
  });
}

// ============================================================================
// 关卡进度与状态
// ============================================================================

class LevelProgress {
  final int level;
  final bool unlocked;
  final bool completed;
  final double bestScore;
  final DateTime? completedAt;
  final int attemptCount;

  const LevelProgress({
    required this.level,
    this.unlocked = false,
    this.completed = false,
    this.bestScore = 0,
    this.completedAt,
    this.attemptCount = 0,
  });

  LevelProgress copyWith({
    int? level,
    bool? unlocked,
    bool? completed,
    double? bestScore,
    DateTime? completedAt,
    int? attemptCount,
  }) {
    return LevelProgress(
      level: level ?? this.level,
      unlocked: unlocked ?? this.unlocked,
      completed: completed ?? this.completed,
      bestScore: bestScore ?? this.bestScore,
      completedAt: completedAt ?? this.completedAt,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'level': level,
    'unlocked': unlocked,
    'completed': completed,
    'bestScore': bestScore,
    'completedAt': completedAt?.toIso8601String(),
    'attemptCount': attemptCount,
  };

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      level: json['level'] as int,
      unlocked: json['unlocked'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
      bestScore: (json['bestScore'] as num?)?.toDouble() ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      attemptCount: json['attemptCount'] as int? ?? 0,
    );
  }
}

// ============================================================================
// 全部关卡定义
// ============================================================================

class LevelRegistry {
  LevelRegistry._();

  static List<TeachingLevel> get allLevels => _levels;

  static TeachingLevel getLevel(int level) {
    return _levels.firstWhere((l) => l.level == level,
      orElse: () => _levels.last);
  }

  static List<TeachingLevel> getLevelsByTier(LevelTier tier) {
    return _levels.where((l) => l.tier == tier).toList();
  }

  static final List<TeachingLevel> _levels = [
    // ========== 初级 L1-L3 ==========
    const TeachingLevel(
      level: 1,
      title: '初次问候',
      subtitle: '掌握基础问候与自我介绍的社交礼仪',
      tier: LevelTier.beginner,
      scenarioDescription: '你在一次行业交流会上遇到了一个看起来很有趣的人。对方正在独自站着喝饮料，你决定上前打招呼。这是你们第一次见面，彼此完全不了解。',
      teachingGoal: '学会用轻松自然的方式开启对话，避免过于正式或过于随意。',
      knowledgeCards: [
        KnowledgeCard(
          title: '破冰三要素',
          content: '1. 微笑+眼神接触（传递友好信号）\n2. 基于情境的开场（如"今天的分享环节你最喜欢哪个"）\n3. 开放式提问（给对方发挥空间）',
          isPrinciple: true,
        ),
        KnowledgeCard(
          title: '避免查户口式提问',
          content: '连续封闭式问题（"你做什么的？""住哪里？""多大了？"）会让对方感到被审问。改用分享自己信息 + 邀请对方评论的方式。',
          isPrinciple: false,
        ),
        KnowledgeCard(
          title: '2秒法则',
          content: '看到想认识的人，在2秒内行动。等待越久，心理障碍越大，也越容易被察觉"你在犹豫"。',
          isPrinciple: false,
        ),
      ],
      passThreshold: 18,
      maxTurns: 4,
      icon: Icons.waving_hand_rounded,
      badgeName: '破冰先锋',
      contactMood: '中性偏友好，对方对你这个陌生人保持开放但略有戒备',
      initialMood: 0.2,
      relatedKnowledgeIds: ['K001', 'K002', 'K040'],
    ),
    const TeachingLevel(
      level: 2,
      title: '自我介绍',
      subtitle: '打造有记忆点的自我介绍，让对方愿意继续聊下去',
      tier: LevelTier.beginner,
      scenarioDescription: '你已经和对方打了招呼，对方回应了微笑并问"你是做什么的？"。现在是你展示自己的机会，但要注意分寸。',
      teachingGoal: '学会用"价值陈述+兴趣钩子"的方式介绍自己，让对方自然产生追问的欲望。',
      knowledgeCards: [
        KnowledgeCard(
          title: '三句话自我介绍法',
          content: '第一句：我是谁（身份标签）\n第二句：我做什么（价值陈述）\n第三句：为什么有趣（兴趣钩子，引发追问）\n例："我是做产品设计的，最近在研究AI如何帮人们更好地社交——你觉得人和人之间最难跨越的是什么？"',
          isPrinciple: true,
        ),
        KnowledgeCard(
          title: '避免自贬式开场',
          content: '"我就是个普通的..."会直接降低对方对你的兴趣估值。用事实而非评价来描述自己。',
          isPrinciple: false,
        ),
      ],
      passThreshold: 20,
      maxTurns: 4,
      unlockCondition: '通过第1关',
      icon: Icons.person_rounded,
      badgeName: '印象大师',
      contactMood: '友好但期待了解你更多',
      initialMood: 0.3,
      relatedKnowledgeIds: ['K002', 'K008'],
    ),
    const TeachingLevel(
      level: 3,
      title: '倾听技巧',
      subtitle: '学会真正听懂对方，而非只是等自己说话',
      tier: LevelTier.beginner,
      scenarioDescription: '对方开始分享自己最近的一个项目经历，说得比较投入。你需要展示你在认真听，同时让对方感觉被理解。',
      teachingGoal: '掌握"镜像+标注+验证"三步倾听法，让对方感到被深度理解。',
      knowledgeCards: [
        KnowledgeCard(
          title: '三步倾听法',
          content: '1. 镜像（Mirror）：重复对方最后1-3个词或关键短语\n2. 标注（Label）：为对方的情绪命名——"听起来你当时挺有成就感的" \n3. 验证（Validate）：确认理解——"所以你觉得那个决定是关键转折点，对吗？"',
          isPrinciple: true,
        ),
        KnowledgeCard(
          title: '打断冲动管理',
          content: '当你想打断对方分享自己的想法时，先问自己：我是真的在补充信息，还是只是想让话题回到自己身上？如果是后者，忍住不说，继续追问一个"然后呢？"',
          isPrinciple: false,
        ),
        KnowledgeCard(
          title: '沉默的力量',
          content: '对方说完一段话后，等待2-3秒再回应。这短暂的沉默传递了"我在认真消化你说的话"，而不是"我早就准备好了我的回答"。',
          isPrinciple: false,
        ),
      ],
      passThreshold: 22,
      maxTurns: 5,
      unlockCondition: '通过第2关',
      icon: Icons.hearing_rounded,
      badgeName: '倾听之星',
      contactMood: '投入分享中，略带期待',
      initialMood: 0.4,
      relatedKnowledgeIds: ['K001', 'K003'],
    ),

    // ========== 中级 L4-L6 ==========
    const TeachingLevel(
      level: 4,
      title: '话题延展',
      subtitle: '让对话自然流淌，不会陷入尬聊',
      tier: LevelTier.intermediate,
      scenarioDescription: '你们聊完了刚才的话题，出现了一个短暂的沉默。你需要自然地引出新话题，让对话继续流动而不显得生硬。',
      teachingGoal: '掌握"话题漏斗"技巧，从一个宽泛话题逐渐收窄到有深度的交流。',
      knowledgeCards: [
        KnowledgeCard(
          title: '话题漏斗模型',
          content: '宽入口（安全话题：天气/环境/活动）→ 中段（兴趣相关：最近在读什么/玩什么）→ 窄出口（深度话题：价值观/经历/梦想）。每层用1-2个回合自然过渡。',
          isPrinciple: true,
        ),
        KnowledgeCard(
          title: 'FORD话题法',
          content: 'Family（家庭）、Occupation（工作）、Recreation（娱乐）、Dreams（梦想）——这是四个永远不会过时的话题方向。任一方向都能延伸出大量子话题。',
          isPrinciple: false,
        ),
        KnowledgeCard(
          title: '桥接连词',
          content: '使用"对了"、"说到这个"、"这让我想起"等桥接连词，让话题切换更自然。避免突然转变主题（"哎我们换个话题"）。',
          isPrinciple: false,
        ),
      ],
      passThreshold: 25,
      maxTurns: 5,
      unlockCondition: '通过第3关',
      icon: Icons.forum_rounded,
      badgeName: '话题达人',
      contactMood: '刚经历短暂沉默，略有尴尬但愿意继续',
      initialMood: 0.1,
      relatedKnowledgeIds: ['K004', 'K039'],
    ),
    const TeachingLevel(
      level: 5,
      title: '情绪共鸣',
      subtitle: '不只是理解对方的情绪，还要让对方感受到你的理解',
      tier: LevelTier.intermediate,
      scenarioDescription: '对方在聊到工作中的挫折时，语气变得有些沮丧。这是一个建立深度连接的机会——如果你能正确回应对方的情绪。',
      teachingGoal: '学会"情绪确认+共情回应+积极重构"三步情绪共鸣法。',
      knowledgeCards: [
        KnowledgeCard(
          title: '情绪共鸣金字塔',
          content: 'Layer 1 - 确认："我能感受到你现在的沮丧"\nLayer 2 - 共情："如果是我遇到这种情况，可能也会很难受"\nLayer 3 - 积极重构："不过你能坚持到现在，说明你真的很坚韧"\n从确认→共情→重构，逐层深入。',
          isPrinciple: true,
        ),
        KnowledgeCard(
          title: '避免廉价安慰',
          content: '"没事的"、"想开点"、"会好的"这些空洞安慰会适得其反，让对方觉得你不想深入理解ta的感受。替代方案："我知道现在说这些可能帮不上忙，但我想让你知道，我在这里听你说。"',
          isPrinciple: false,
        ),
        KnowledgeCard(
          title: '情绪标注精准度',
          content: '沮丧/失落/愤怒/委屈/焦虑——精准识别并命名对方的情绪，比笼统说"你不开心"效果强10倍。这显示了你真正在关注ta的内在状态。',
          isPrinciple: false,
        ),
      ],
      passThreshold: 28,
      maxTurns: 5,
      unlockCondition: '通过第4关',
      icon: Icons.psychology_rounded,
      badgeName: '共情使者',
      contactMood: '低落沮丧，需要被看见和理解',
      initialMood: -0.4,
      relatedKnowledgeIds: ['K005', 'K033'],
    ),
    const TeachingLevel(
      level: 6,
      title: '冲突化解',
      subtitle: '在意见分歧中保持连接而非对立',
      tier: LevelTier.intermediate,
      scenarioDescription: '你们对一个共同项目的方向产生了分歧。对方坚持自己的方案，语气变得有些强硬。你需要在坚持自己观点的同时，不让对话变成对抗。',
      teachingGoal: '掌握"非暴力沟通"四步法：观察→感受→需求→请求。',
      knowledgeCards: [
        KnowledgeCard(
          title: '非暴力沟通四步法',
          content: '1. 观察（不带评判）："我注意到我们在这点上看法不同"\n2. 感受（表达而非指责）："我有点担心如果按这个方向走可能会..."\n3. 需求（说出深层需要）："我们需要一个双方都能接受的方案"\n4. 请求（具体可操作）："能不能先各自列出最关心的三个点，再一起看看重叠的部分？"',
          isPrinciple: true,
        ),
        KnowledgeCard(
          title: '降级话术',
          content: '当对方情绪升温时，使用降级话术：\n- "我们先停一下，我可能没完全理解你的意思"\n- "你说得对，这点我之前确实没考虑到"\n- "我们目标应该是一样的，只是在路径上有分歧"',
          isPrinciple: false,
        ),
        KnowledgeCard(
          title: 'YES, AND...法则',
          content: '先接纳对方观点中合理的部分（YES），再在此基础上补充你的视角（AND）。这比直接说"但是"（否定对方）更容易被接受。',
          isPrinciple: false,
        ),
      ],
      passThreshold: 28,
      maxTurns: 6,
      unlockCondition: '通过第5关',
      icon: Icons.shield_rounded,
      badgeName: '和平使者',
      contactMood: '有些固执和防备，但本质上愿意沟通',
      initialMood: -0.2,
      relatedKnowledgeIds: ['K006', 'K009'],
    ),

    // ========== 高级 L7-L9 ==========
    const TeachingLevel(
      level: 7,
      title: '深度连接',
      subtitle: '从普通聊天进入有意义的深度对话',
      tier: LevelTier.advanced,
      scenarioDescription: '你们已经聊了一段时间，氛围很融洽。现在是一个把关系从"熟人"推向"朋友"的窗口期。你需要适时抛出一些有深度的问题，但不要太突兀。',
      teachingGoal: '学会用"脆弱表达+深度提问"创造信任和亲密感。',
      knowledgeCards: [
        KnowledgeCard(
          title: '脆弱的力量',
          content: '适当暴露自己的不确定、困惑甚至弱点，会激发对方的信任和共鸣。"说实话我对这件事也不是很有把握"比"我完全没问题"更容易拉近关系。',
          isPrinciple: true,
        ),
        KnowledgeCard(
          title: '深度提问三层次',
          content: 'Level 1 事实层："你做什么工作？"\nLevel 2 感受层："你喜欢这份工作的哪部分？"\nLevel 3 价值层："如果完全不用考虑现实因素，你最想做什么？"\n从事实→感受→价值，逐层深入。',
          isPrinciple: false,
        ),
        KnowledgeCard(
          title: '36个问题增进亲密感',
          content: '亚瑟·阿伦的经典研究：两个人轮流回答36个逐渐深入的问题，可以在45分钟内显著提升亲密感。核心原理：循序渐进的自我暴露+相互回应。',
          isPrinciple: false,
        ),
      ],
      passThreshold: 30,
      maxTurns: 6,
      unlockCondition: '通过第6关',
      icon: Icons.connect_without_contact_rounded,
      badgeName: '深度连接者',
      contactMood: '放松且开放，愿意探索更深的话题',
      initialMood: 0.5,
      relatedKnowledgeIds: ['K007', 'K010'],
    ),
    const TeachingLevel(
      level: 8,
      title: '影响力沟通',
      subtitle: '用语言引导而非说服，让对方心甘情愿接受你的观点',
      tier: LevelTier.advanced,
      scenarioDescription: '你想邀请对方周末一起去参加一个你感兴趣的活动（比如一场展览），但对方似乎对这个领域不太了解，有些犹豫。你需要激发对方的兴趣，而非强行推销。',
      teachingGoal: '掌握"好奇引导+利益关联+低门槛邀请"三步影响力沟通法。',
      knowledgeCards: [
        KnowledgeCard(
          title: '影响力三原则',
          content: '1. 好奇引导：用一个有趣的问题或事实勾起对方兴趣\n2. 利益关联：明确告诉对方这对ta有什么好处（知识/体验/社交/情绪）\n3. 低门槛邀请：降低拒绝成本——"随时可以走"、"我请你"、"就一个小时"',
          isPrinciple: true,
        ),
        KnowledgeCard(
          title: '避免销售式说服',
          content: '连连说"特别好"、"你一定要去"会让对方产生防御心理。改为分享个人体验："我上次去的时候，有个展区让我整整站了20分钟——不是因为看不懂，而是因为它让我重新思考了XXX"',
          isPrinciple: false,
        ),
        KnowledgeCard(
          title: '选择框架效应',
          content: '不要问"你去不去？"（是/否二元），而是问"周六下午还是周日上午？"（预设对方会去，只需选时间）。这利用了决策心理学的框架效应。',
          isPrinciple: false,
        ),
      ],
      passThreshold: 30,
      maxTurns: 6,
      unlockCondition: '通过第7关',
      icon: Icons.trending_up_rounded,
      badgeName: '影响力之星',
      contactMood: '犹豫但友善，需要被激发兴趣',
      initialMood: 0.2,
      relatedKnowledgeIds: ['K008', 'K022'],
    ),
    const TeachingLevel(
      level: 9,
      title: '关系修复',
      subtitle: '在关系受损后重建信任与连接',
      tier: LevelTier.advanced,
      scenarioDescription: '你之前因为一件误会让对方感到受伤，对方已经几天没有主动联系你了。现在你决定主动发出第一条消息，修复这段关系。',
      teachingGoal: '学会真诚道歉的六要素，并在道歉后重建沟通桥梁。',
      knowledgeCards: [
        KnowledgeCard(
          title: '有效道歉六要素',
          content: '1. 表达悔意："我很抱歉"\n2. 说明错在哪："我不该XXX"\n3. 承认责任："这是我的问题"\n4. 承诺改变："以后我会XXX"\n5. 提供补救："我能做什么来弥补"\n6. 请求原谅（不强求）："希望你能给我一个机会"\n注意：任何一条缺失都会让道歉显得不真诚。',
          isPrinciple: true,
        ),
        KnowledgeCard(
          title: '道歉后不要做的事',
          content: '- 不要立即要求对方原谅或表态\n- 不要解释太多（听起来像辩解）\n- 不要用"但是"转折（"对不起但是你也..."）\n- 不要发长篇大论（给对方消化空间）',
          isPrinciple: false,
        ),
        KnowledgeCard(
          title: '重建阶段节奏',
          content: '第一阶段（道歉后24h）：保持低频率、轻量互动\n第二阶段（24-72h）：逐步恢复正常话题，避免重提矛盾\n第三阶段（72h+）：关系恢复到可以自然交流时，才考虑讨论如何避免类似问题',
          isPrinciple: false,
        ),
      ],
      passThreshold: 32,
      maxTurns: 7,
      unlockCondition: '通过第8关',
      icon: Icons.favorite_rounded,
      badgeName: '修复大师',
      contactMood: '受伤和疏远，但对你的主动联系仍留有窗口',
      initialMood: -0.5,
      relatedKnowledgeIds: ['K009', 'K006'],
    ),

    // ========== 毕业考核 L10 ==========
    const TeachingLevel(
      level: 10,
      title: '毕业考核',
      subtitle: '综合场景：在真实复杂的社交情境中展示你的全部能力',
      tier: LevelTier.graduation,
      scenarioDescription: '这是一个综合场景：你在朋友聚会上认识了一个新朋友，聊得不错，但中途出现了一个小误会。你需要综合运用破冰、倾听、话题延展、情绪共鸣、冲突化解和影响力沟通的所有技巧。',
      teachingGoal: '展示你已掌握的社交能力：从陌生到深度对话，从冲突到和解的完整链路。',
      knowledgeCards: [
        KnowledgeCard(
          title: '社交能力全景回顾',
          content: '回顾你学到的所有核心能力：\n- 破冰与自我介绍（L1-L2）\n- 倾听与理解（L3）\n- 话题延展与深度对话（L4, L7）\n- 情绪共鸣与关怀（L5）\n- 冲突化解与非暴力沟通（L6）\n- 影响力与说服（L8）\n- 真诚道歉与关系修复（L9）',
          isPrinciple: true,
        ),
      ],
      passThreshold: 70,
      maxTurns: 12,
      unlockCondition: '通过第9关',
      icon: Icons.emoji_events_rounded,
      badgeName: '社交大师',
      contactMood: '场景动态变化：从陌生友好→深度交流→短暂冲突→修复重建',
      initialMood: 0.2,
      relatedKnowledgeIds: ['K001', 'K002', 'K003', 'K004', 'K005', 'K006', 'K007', 'K008', 'K009', 'K010'],
    ),

  ];
}

// ============================================================================
// 进度管理器
// ============================================================================

class TeachingProgressManager extends ChangeNotifier {
  final List<LevelProgress> _progress;

  TeachingProgressManager()
      : _progress = List.generate(
          10,
          (i) => LevelProgress(level: i + 1, unlocked: i == 0),
        );

  List<LevelProgress> get progress => List.unmodifiable(_progress);

  LevelProgress getProgress(int level) => _progress[level - 1];

  int get currentLevel {
    for (int i = 9; i >= 0; i--) {
      if (_progress[i].unlocked) return i + 1;
    }
    return 1;
  }

  bool get allCompleted =>
      _progress.every((p) => p.completed);

  double get overallProgress {
    final completed = _progress.where((p) => p.completed).length;
    return completed / 10.0;
  }

  bool isUnlocked(int level) => _progress[level - 1].unlocked;

  bool isCompleted(int level) => _progress[level - 1].completed;

  /// 完成关卡
  void completeLevel(int level, double score) {
    if (level < 1 || level > 10) return;
    final idx = level - 1;
    final old = _progress[idx];
    _progress[idx] = old.copyWith(
      completed: true,
      bestScore: max(old.bestScore, score),
      completedAt: DateTime.now(),
      attemptCount: old.attemptCount + 1,
    );
    // 解锁下一关
    if (level < 10) {
      final nextIdx = level;
      _progress[nextIdx] = _progress[nextIdx].copyWith(unlocked: true);
    }
    notifyListeners();
  }

  /// 记录尝试（未通过）
  void recordAttempt(int level) {
    if (level < 1 || level > 10) return;
    final idx = level - 1;
    _progress[idx] = _progress[idx].copyWith(
      attemptCount: _progress[idx].attemptCount + 1,
    );
    notifyListeners();
  }

  /// 重置全部进度
  void resetAll() {
    for (int i = 0; i < 10; i++) {
      _progress[i] = LevelProgress(level: i + 1, unlocked: i == 0);
    }
    notifyListeners();
  }

  /// 序列化
  Map<String, dynamic> toJson() => {
    'progress': _progress.map((p) => p.toJson()).toList(),
  };

  factory TeachingProgressManager.fromJson(Map<String, dynamic> json) {
    final mgr = TeachingProgressManager();
    final list = json['progress'] as List?;
    if (list != null) {
      for (int i = 0; i < list.length && i < 10; i++) {
        mgr._progress[i] = LevelProgress.fromJson(
          Map<String, dynamic>.from(list[i]),
        );
      }
    }
    return mgr;
  }
}

// ============================================================================
// 社交知识词典
// ============================================================================

/// 知识条目
/// 知识点适用对象：区分性别针对性内容
enum TargetAudience {
  all('通用', Icons.group_rounded),          // 不分性别通用
  male('男生', Icons.man_rounded),          // 男生专属内容
  female('女生', Icons.woman_rounded);      // 女生专属内容

  final String label;
  final IconData icon;
  const TargetAudience(this.label, this.icon);
}

/// 知识点大分类（顶层导航）
///
/// 用于把众多细分 category（如「破冰与开场」「倾听技巧」…）聚合为更直观的顶层分组，
/// 让用户能从大主题切入浏览，再通过子分类细化。
enum KnowledgeMajorCategory {
  communication('沟通基础', '💬'),
  relationship('关系深度', '💞'),
  nonVerbal('非语言社交', '👀'),
  identify('识人与应对', '🧭'),
  lifeCycle('关系周期', '🔄'),
  romance('异性交往', '💑'),
  ;

  final String label;
  final String emoji;
  const KnowledgeMajorCategory(this.label, this.emoji);
}

class SocialKnowledgeEntry {
  final String id;
  final String category;     // 所属子分类
  final String title;        // 标题
  final String content;      // 正文
  final List<String> tags;   // 标签
  final int relatedLevel;    // 关联关卡（1-10）
  final TeachingMode? relatedMode;    // 关联模式（null=通用）
  final TargetAudience targetAudience; // 适用对象性别：all/male/female

  const SocialKnowledgeEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.tags,
    required this.relatedLevel,
    this.relatedMode,
    this.targetAudience = TargetAudience.all,
  });

  /// 大分类（由子分类映射，无需手动指定）
  KnowledgeMajorCategory get majorCategory =>
      SocialKnowledgeBase.majorCategoryOf(category);
}

/// 知识词典
class SocialKnowledgeBase {
  SocialKnowledgeBase._();

  static List<SocialKnowledgeEntry> get entries =>
      List.unmodifiable(_entries);

  static List<SocialKnowledgeEntry> getByLevel(int level) {
    return _entries.where((e) => e.relatedLevel == level).toList();
  }

  static List<SocialKnowledgeEntry> getByCategory(String category) {
    return _entries.where((e) => e.category == category).toList();
  }

  /// 获取特定模式相关的知识条目
  /// 返回该模式专属条目 + 通用条目（relatedMode=null）
  static List<SocialKnowledgeEntry> getByMode(TeachingMode mode) {
    return _entries.where((e) => e.relatedMode == mode || e.relatedMode == null).toList();
  }

  /// 获取特定模式+关卡的关联知识条目
  static List<SocialKnowledgeEntry> getByModeAndLevel(TeachingMode mode, int level) {
    return _entries.where((e) =>
      e.relatedLevel == level &&
      (e.relatedMode == mode || e.relatedMode == null)
    ).toList();
  }

  /// 根据ID获取知识条目
  static SocialKnowledgeEntry? getById(String id) {
    for (final e in _entries) {
      if (e.id == id) return e;
    }
    return null;
  }

  /// 根据ID列表获取多个知识条目
  static List<SocialKnowledgeEntry> getByIds(List<String> ids) {
    return ids
        .map((id) => getById(id))
        .whereType<SocialKnowledgeEntry>()
        .toList();
  }

  static List<String> get categories => _categories;

  static final List<String> _categories = [
    '破冰与开场',
    '自我介绍',
    '倾听技巧',
    '话题管理',
    '情绪共鸣',
    '冲突化解',
    '深度连接',
    '影响力沟通',
    '关系修复',
    // === 全方位社交指导（非对话维度）===
    '肢体语言与微表情',
    '社交媒体情报',
    '日常相处',
    '打闹与互动',
    '关系维护',
    '关系分层与识人',
    '社交对象分类',
    '群体社交',
    // === 分性别针对性内容 ===
    '男生约会与追求',
    '女生约会与吸引',
    '异性心理差异',
    '表白与确定关系',
    // === 高阶进阶内容 ===
    '高阶沟通技巧',
    '特殊人群社交',
    // === 识人与应对体系 ===
    '识人与应对之道',
    '极端型人格识别',
    '关系生命周期',
    '脱单方法论',
    '拓展优质社交圈',
    '社交动态经营',
  ];

  /// 大分类列表（顶层导航顺序）
  static List<KnowledgeMajorCategory> get majorCategories =>
      KnowledgeMajorCategory.values;

  /// 子分类到大分类的映射
  static KnowledgeMajorCategory majorCategoryOf(String category) {
    return _categoryToMajor[category] ?? KnowledgeMajorCategory.communication;
  }

  /// 大分类下的子分类列表
  static List<String> subCategoriesOf(KnowledgeMajorCategory major) {
    return _categories.where((c) => _categoryToMajor[c] == major).toList();
  }

  /// 子分类 → 大分类 映射表
  static const Map<String, KnowledgeMajorCategory> _categoryToMajor = {
    // 💬 沟通基础
    '破冰与开场': KnowledgeMajorCategory.communication,
    '自我介绍': KnowledgeMajorCategory.communication,
    '倾听技巧': KnowledgeMajorCategory.communication,
    '话题管理': KnowledgeMajorCategory.communication,
    '情绪共鸣': KnowledgeMajorCategory.communication,
    '高阶沟通技巧': KnowledgeMajorCategory.communication,
    // 💞 关系深度
    '深度连接': KnowledgeMajorCategory.relationship,
    '影响力沟通': KnowledgeMajorCategory.relationship,
    '冲突化解': KnowledgeMajorCategory.relationship,
    '关系修复': KnowledgeMajorCategory.relationship,
    '关系维护': KnowledgeMajorCategory.relationship,
    // 👀 非语言社交
    '肢体语言与微表情': KnowledgeMajorCategory.nonVerbal,
    '社交媒体情报': KnowledgeMajorCategory.nonVerbal,
    '日常相处': KnowledgeMajorCategory.nonVerbal,
    '打闹与互动': KnowledgeMajorCategory.nonVerbal,
    '群体社交': KnowledgeMajorCategory.nonVerbal,
    // 🧭 识人与应对
    '关系分层与识人': KnowledgeMajorCategory.identify,
    '社交对象分类': KnowledgeMajorCategory.identify,
    '特殊人群社交': KnowledgeMajorCategory.identify,
    '识人与应对之道': KnowledgeMajorCategory.identify,
    '极端型人格识别': KnowledgeMajorCategory.identify,
    // 🔄 关系周期
    '关系生命周期': KnowledgeMajorCategory.lifeCycle,
    // 💑 异性交往
    '男生约会与追求': KnowledgeMajorCategory.romance,
    '女生约会与吸引': KnowledgeMajorCategory.romance,
    '异性心理差异': KnowledgeMajorCategory.romance,
    '表白与确定关系': KnowledgeMajorCategory.romance,
    '脱单方法论': KnowledgeMajorCategory.romance,
    '拓展优质社交圈': KnowledgeMajorCategory.identify,
    '社交动态经营': KnowledgeMajorCategory.nonVerbal,
  };

  static final List<SocialKnowledgeEntry> _entries = [
    // ========== 破冰与开场 ==========
    const SocialKnowledgeEntry(
      id: 'K001',
      title: '情境破冰法',
      category: '破冰与开场',
      content: '''
基于当下共享情境的破冰是最自然、最不易引起尴尬的方式。

核心技巧：
1. 环境观察：注意对方在做什么、看什么、附近有什么有趣的事情
2. 即时评论：用一句轻松的观察开启对话（而非直接提问）
3. 微笑先行：开口前先微笑+眼神接触，建立非语言连接

示例话术：
- "今天的分享环节信息量挺大的，你最喜欢哪个部分？"
- "这个场地的咖啡真不错，你觉得呢？"
- "你的那本书看起来很有意思，是最近在读的吗？"

常见误区：
- 不要用"你一个人来的吗"这类让对方尴尬的问题
- 不要上来就评价对方外表（"你衣服很好看"不够有深度）
- 不要等太久——2秒法则：看到想认识的人，2秒内行动
''',
      tags: ['破冰', '开场', '社交礼仪'],
      relatedLevel: 1,
      relatedMode: TeachingMode.strangerIcebreaking,
    ),
    const SocialKnowledgeEntry(
      id: 'K002',
      title: '自我介绍的黄金结构',
      category: '自我介绍',
      content: '''
一个让人记住你的自我介绍，应该包含三个层次：

1. 身份标签（5秒）：你是谁
2. 价值陈述（10秒）：你做什么/关注什么
3. 兴趣钩子（5秒）：一个让对方想追问的开放结尾

示例对比：
❌ "我是做IT的。"
✅ "我是做AI产品设计的（身份），最近在研究怎么让技术更懂人心（价值）——你觉得人和机器沟通，和人和人沟通，哪个更难？（钩子）"

核心原则：
- 用具体代替抽象："做设计的" → "做消费类APP交互设计"
- 用兴趣代替职业："项目经理" → "帮团队把复杂的事情变简单的人"
- 留钩子：每段自我介绍都用一个开放性问题结尾
''',
      tags: ['自我介绍', '印象管理', '破冰'],
      relatedLevel: 2,
    ),
    const SocialKnowledgeEntry(
      id: 'K003',
      title: '主动倾听的四个层次',
      category: '倾听技巧',
      content: '''
Level 1 - 假装在听：点头但心里在想别的事
Level 2 - 选择性听：只听自己感兴趣的部分
Level 3 - 专注倾听：全神贯注，理解对方说的每一个词
Level 4 - 深度倾听：不仅理解对方的语言，还感知情绪、未说出口的需求、价值观信号

如何达到 Level 4：
1. 放下内心"接下来我要说什么"的预演
2. 用简短回应信号（"嗯"、"然后呢"、"我明白"）鼓励对方继续
3. 对方说完后，先镜像（重复关键短语），再回应
4. 每5分钟至少做一次情绪标注："听起来你很兴奋/纠结/自豪"

常见误区：
- 提前准备回答（不是在听，是在等自己说话）
- 急于给建议（有时对方只需要被听见）
- 用自己的经历接话（"我也有一次..."抢走了对方的话筒）
''',
      tags: ['倾听', '深度连接', '情绪感知'],
      relatedLevel: 3,
    ),
    const SocialKnowledgeEntry(
      id: 'K004',
      title: '让对话永不冷场的七个技巧',
      category: '话题管理',
      content: '''
1. 追问细节法：对方说了什么，追问一个具体细节
   "你说你喜欢旅行 → 上次旅行印象最深的一个瞬间是什么？"

2. 时空穿越法：把当前话题引向过去或未来
   "你是从什么时候开始对这个感兴趣的？" / "如果完全没限制，你会想做什么？"

3. 对比发现法：对比不同事物引发讨论
   "你觉得线上聊天和面对面最大的区别是什么？"

4. 假设游戏法：抛出轻松假设
   "如果你有一个完全自由的长周末，你会怎么过？"

5. 反向提问法：对方问了你一个问题，回答后反问回去
   "你呢？你最近有在关注什么新鲜事吗？"

6. 环境借力法：利用当下环境中的事物
   "这个音乐选得不错/这家店的装修风格挺有意思的"

7. 诚实过渡法：真的没话题时，坦诚反而可爱
   "我其实挺想继续聊的，但突然不知道说什么了——你有什么想聊的吗？"
''',
      tags: ['话题', '冷场', '对话技巧'],
      relatedLevel: 4,
    ),
    const SocialKnowledgeEntry(
      id: 'K005',
      title: '情绪共鸣 vs 情绪解决',
      category: '情绪共鸣',
      content: '''
关键区分：
- 情绪共鸣 = 让对方感到被理解（这是对方真正需要的）
- 情绪解决 = 试图帮对方消除负面情绪（这往往让对方更不舒服）

错误示范（情绪解决）：
对方："我今天开会又被领导批评了，真的好崩溃"
你："别想太多，下次做好就行了" ← 无效安慰
你："你应该跟领导沟通一下" ← 给建议而非倾听

正确示范（情绪共鸣）：
你："被当众批评确实很不好受，尤其是你已经很努力了" ← 情绪确认
你："如果是我，可能也会觉得特别委屈" ← 共情回应
你："不过你愿意跟我说这些，说明你在积极面对它——这点很了不起" ← 积极重构

黄金法则：
- 先共鸣，再解决（如果对方想解决的话）
- 50%的情况下，对方只需要被听见，不需要解决方案
- 问一句："你现在是需要我出主意，还是只是想找人说说话？"
''',
      tags: ['情绪', '共情', '安慰'],
      relatedLevel: 5,
    ),
    const SocialKnowledgeEntry(
      id: 'K006',
      title: '非暴力沟通实战指南',
      category: '冲突化解',
      content: '''
马歇尔·卢森堡的非暴力沟通（NVC）四步法：

第一步：观察（不带评判）
❌ "你总是迟到"（评判）
✅ "这周三次会议你都晚到了10分钟以上"（观察）

第二步：感受（表达自己的情绪，而非指责）
❌ "你让我很生气"（指责句式）
✅ "我感到有些焦虑，因为会议进度受到影响"（感受句式）

第三步：需求（说出内在需要）
"我需要我们能在约定时间准时开始，这样大家都不用在等待中消耗精力"

第四步：请求（具体、可操作、可商量）
"下次能不能提前5分钟给我发个消息，让我知道你的预估到达时间？"

常见陷阱：
- "你让我..."句式会把责任推给对方
- 请求不等于要求（对方有权拒绝）
- 不要在第4步加上威胁或道德绑架
''',
      tags: ['冲突', '沟通', '非暴力沟通'],
      relatedLevel: 6,
    ),
    const SocialKnowledgeEntry(
      id: 'K007',
      title: '建立深度连接的五个信号',
      category: '深度连接',
      content: '''
判断一段对话是否达到了"深度连接"层级，看以下五个信号：

1. 自我暴露递进：对方从分享事实 → 分享感受 → 分享脆弱
   "我最近换了工作" → "其实挺焦虑的" → "有时候会怀疑自己是不是做错了决定"

2. 时间感消失：双方都忘记了看时间（心理学的"心流"状态）

3. "我们"语言出现：从"我/你"变成"我们"
   "你说的这个我们之前也遇到过"

4. 沉默不尴尬：对话中出现自然停顿，双方都觉得舒服

5. 未来提及：对话中自然出现未来的约定或期待
   "下次我们可以一起去" / "你得把这个故事的结局告诉我"

如何培养：
- 先暴露自己的中等脆弱（不是最深的那种），测试对方回应
- 用"我也有过类似的感受"建立共鸣
- 适当记住对方之前说过的细节，下次提及时会让对方感到被重视
''',
      tags: ['深度连接', '亲密感', '关系发展'],
      relatedLevel: 7,
    ),
    const SocialKnowledgeEntry(
      id: 'K008',
      title: '六条说服心理学原则',
      category: '影响力沟通',
      content: '''
基于罗伯特·西奥迪尼的《影响力》：

1. 互惠原则：先给予，再请求
   先帮对方一个小忙或分享有价值的信息，对方更可能答应你的请求

2. 稀缺原则：强调独特性
   "这个展览还有最后三天"比"有个展览"更有驱动力

3. 权威原则：引用可信来源
   "我朋友去了说这是他今年看过最好的展"

4. 一致性原则：从小要求开始
   先让对方答应一个小要求（"你能帮我看看这个时间合适吗"），再提大要求

5. 喜好原则：建立共同点
   "你对摄影感兴趣？这个展览的视觉设计据说特别讲究"

6. 社会认同：群体效应
   "好几个人都说想去了"比"我想去"更有说服力

伦理边界：
- 这些原则用于促成对双方都有益的决定，而非操纵
- 如果对方明确表达不感兴趣，立即停止施加影响
- 给足对方说"不"的空间
''',
      tags: ['说服', '影响力', '心理学'],
      relatedLevel: 8,
    ),
    const SocialKnowledgeEntry(
      id: 'K009',
      title: '道歉的六要素与常见错误',
      category: '关系修复',
      content: '''
有效道歉六要素（缺一不可）：

1. 表达悔意："我真的很抱歉"
2. 说明错误："我不该在没弄清楚情况之前就下结论"
3. 承担责任："这是我的错，不是别人的问题"
4. 承诺改变："以后我会先跟你确认再行动"
5. 提供补救："我能做什么来弥补吗？"
6. 请求原谅："希望你能给我一个机会"

常见错误道歉方式：
❌ "如果让你不舒服了，我道歉"（条件式道歉，不真诚）
❌ "对不起，但是你也..."（甩锅式道歉）
❌ "好了好了我错了行了吧"（敷衍式道歉）
❌ "我不知道你会这么在意"（暗示对方小题大做）
❌ 群发或转述道歉（没有诚意）

道歉后修复节奏：
Day 1：发送道歉，不再追问
Day 2-3：如果对方有回应，轻松互动，不施压
Day 4-7：对方态度缓和后，自然恢复交流
超过一周无回应：给对方空间，不要连续轰炸
''',
      tags: ['道歉', '关系修复', '冲突后处理'],
      relatedLevel: 9,
    ),

    // ==================================================================
    // 肢体语言与微表情
    // ==================================================================
    const SocialKnowledgeEntry(
      id: 'K010',
      title: '肢体语言解读：开放与关闭信号',
      category: '肢体语言与微表情',
      content: '''
肢体语言是最真实的沟通渠道——人可以控制语言，但很难完全控制身体。

【开放信号】（对方对你有兴趣/有好感）
✅ 身体朝向你：脚尖、膝盖、躯干指向你的方向
✅ 身体前倾：不自觉地向你靠近，减少距离
✅ 手臂展开：不交叉手臂，手掌可见
✅ 点头频率：听你说话时频繁轻微点头
✅ 踱步减少：站定不动，说明注意力在你身上
✅ 镜像效应：不自觉模仿你的姿势和手势

【关闭信号】（对方不感兴趣/想离开）
❌ 脚尖朝向出口：身体在说"我想走"
❌ 交叉手臂/双腿：防御姿态
❌ 身体后仰：增加距离感
❌ 频繁看手机/手表：在找逃离借口
❌ 脚步移动：身体在犹豫是否离开
❌ 面部僵硬：笑容不达眼底

实战技巧：
- 观察脚的方向——它比脸更诚实
- 对方出现3个以上关闭信号时，主动结束对话，留下好印象
- 自己也要注意保持开放姿态，避免无意中传递拒绝信号
''',
      tags: ['肢体语言', '非语言沟通', '观察技巧'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K011',
      title: '微表情：7种 universal 情绪识别',
      category: '肢体语言与微表情',
      content: '''
微表情是人类在1/25秒内闪现的真实情绪，无法伪装。保罗·艾克曼的研究确认了7种 universal 微表情：

1. 快乐：嘴角上扬+眼角皱纹（真笑会动眼角肌肉，假笑不会）
2. 悲伤：嘴角下垂+眉头内八+上眼睑下垂
3. 愤怒：眉头下压+嘴唇变薄+下巴前突
4. 恐惧：眉毛上扬聚拢+上眼睑抬起+嘴唇拉伸
5. 惊讶：眉毛上扬+眼睛圆睁+嘴微张（持续<1秒，否则是假的）
6. 厌恶：鼻子皱起+上唇上扬
7. 蔑视：单侧嘴角上扬（不对称的笑）

实战应用：
- 说了某句话后对方闪过"厌恶"微表情 → 你踩雷了，即使嘴上说"没事"
- 对方说"随便你"但嘴角闪过"愤怒" → 其实很在意
- 提到某话题时对方出现"恐惧"微表情 → 触发了不安，立即转移话题
- "蔑视"的半笑是最危险的信号 → 需要立即调整态度

练习方法：
- 每天观察3个人的微表情并记录
- 看无字幕的外国电影，暂停猜情绪
- 对着镜子练习识别自己的微表情
''',
      tags: ['微表情', '情绪识别', '心理学'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K012',
      title: '眼神接触的艺术：5秒法则',
      category: '肢体语言与微表情',
      content: '''
眼神是最有力的非语言工具，用好了建立信任，用过了造成压迫。

【不同场景的眼神策略】
- 初次见面：3-5秒持续接触→自然移开→再回来（三角区：双眼到鼻梁）
- 表达认真：听对方说话时保持70%眼神接触
- 表达真诚：说重要的话时增加眼神接触到80%
- 表达暧昧：在对方说话时注视嘴唇而非眼睛（3秒即可）
- 群体社交：说话时轮流看每个人2-3秒，不偏心

【眼神接触的常见错误】
❌ 死盯着不放超过8秒 → 攻击性/侵略感
❌ 完全不看对方 → 不自信/不尊重
❌ 只看一个人（群体场合）→ 排斥其他人
❌ 视线向下飘 → 不自信/心虚
❌ 视线向上飘 → 在思考/不在听

【进阶技巧】
- "三角法"：左眼→右眼→嘴唇，每2秒轮换一个点
- "打断法"：对方说完后保持眼神2秒再开口 → 表示在认真消化
- "微笑眼"：不用嘴笑，用眼角肌肉微微收缩传递善意
''',
      tags: ['眼神', '非语言沟通', '吸引力'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K013',
      title: '触碰的力量：何时、何地、如何',
      category: '肢体语言与微表情',
      content: '''
适当的肢体触碰能快速拉近关系，但时机和部位至关重要。

【触碰的四个阶段】
Stage 1 - 社交性触碰（刚认识）
- 握手：2-3秒，力度适中
- 递东西时手指轻触：自然不做作
- 拥抱（社交场合）：侧身轻抱，1-2秒

Stage 2 - 友好性触碰（熟悉后）
- 轻拍肩膀/手臂：表达鼓励或感谢
- 击掌：共同庆祝时
- 指引方向时轻触手肘：自然且不冒犯

Stage 3 - 亲密性触碰（有好感/关系近）
- 搭肩/搂腰：合照或走路时
- 帮对方整理头发/衣服：照顾性触碰
- 手腕轻触：引起注意

Stage 4 - 恋人性触碰（已确认关系）
- 牵手、搂腰、摸头等

【关键原则】
- 每次升级前观察对方反应：如果对方身体僵硬或后退 → 立即退回上一阶段
- 触碰要"有理由"：不是无缘无故碰，而是自然场景中发生
- 部位递进：手肘→肩膀→手臂→腰→手 → 不可跳级
- 在公共场合比私密场合更容易被接受（有安全感）

【绝对禁忌】
❌ 对方明确表示不舒服时继续触碰
❌ 在对方看不到你时突然触碰（从背后）
❌ 第一次约会就触碰腰/脸/腿
''',
      tags: ['触碰', '肢体接触', '关系递进'],
      relatedLevel: 0,
    ),

    // ==================================================================
    // 社交媒体情报
    // ==================================================================
    const SocialKnowledgeEntry(
      id: 'K014',
      title: '朋友圈情报学：从动态中读懂一个人',
      category: '社交媒体情报',
      content: '''
朋友圈/动态是最低成本的了解渠道，但大多数人只看表面。学会系统分析，一条动态能抵十次聊天。

【发动态频率分析】
- 高频（每天1+条）：表达欲强，渴望关注，外向为主
- 中频（每周2-3条）：有分享欲但有自己的节奏
- 低频（每月1-2条）：内敛或选择性展示
- 突然高频：可能情绪波动大/有想引起注意的人
- 突然停更：可能生活发生重大变化/心情低落

【内容类型解读】
- 自拍多 → 自信/在意形象/渴望认可
- 美食/旅行 → 享受生活/有消费力/外向
- 文艺/语录 → 感性/在表达某种情绪（注意是否暗有所指）
- 工作/学习 → 有上进心/在塑造形象
- 宠物 → 有爱心/可能用宠物传递情感
- 转发干货 → 理性/在建立专业形象
- 凌晨发动态 → 失眠/情绪波动/孤独

【评论区是金矿】
- 谁经常评论ta？→ 核心社交圈
- ta回复谁最积极？→ 在意的人
- 评论内容是调侃还是正经？→ 判断关系亲密度
- ta在别人动态下的评论 → 展示了不同的性格侧面

【实操技巧】
- 不要每条都点赞/评论 → 会显得stalker
- 在对方发了一条"情绪向"动态时私聊关心 → 效果远超日常问候
- 对方发了你了解的领域的内容 → 评论区展示价值
- 注意对方动态的"时间规律" → 推测作息，选择最佳互动时间
''',
      tags: ['朋友圈', '社交媒体', '情报分析'],
      relatedLevel: 0,
      relatedMode: TeachingMode.onlineSocial,
    ),
    const SocialKnowledgeEntry(
      id: 'K015',
      title: '抖音/快手/视频号：从刷什么看透一个人',
      category: '社交媒体情报',
      content: '''
短视频平台的算法推荐精准映射了一个人的真实兴趣——因为算法是根据真实行为优化的。

【从点赞/收藏类型推测性格】
- 搞笑/段子类 → 压力大需要放松/喜欢轻松氛围
- 美食/探店类 → 享受生活/吃货属性/约会方向有了
- 旅行/风景类 → 向往自由/可能有旅行计划
- 知识/科普类 → 有求知欲/理性/可聊深度话题
- 情感/鸡汤类 → 感性/可能正经历情感波动
- 健身/运动类 → 自律/在意身材/健康生活方式
- 萌宠类 → 有爱心/可能养宠物（绝佳话题入口）
- 舞蹈/音乐类 → 有审美追求/可能会去livehouse/演唱会

【从对方刷的视频找话题】
1. 直接法："你最近刷到什么好玩的了吗？"
2. 间接法：聊到某话题时"我之前刷到一个相关的视频..."
3. 投其所好：开始关注对方感兴趣的领域，创造共同话题
4. 推荐法："你有没有看过XXX？推荐你看，感觉你会喜欢"

【高级技巧】
- 注意对方"分享"了什么视频到聊天 → 这是在主动告诉你ta的兴趣
- 对方刷到跟你相关的内容并分享 → 在暗示想跟你一起做这件事
- 关注对方的收藏夹（如果公开）→ 比点赞更真实的兴趣表达
- 自己也发一些对方感兴趣领域的内容 → 吸引对方关注你

【注意事项】
- 不要过度分析每一条 → 算法有误差
- 不要在第一次聊天就暴露你看了ta所有的视频 → 会显得stalker
- 重点找2-3个可深聊的兴趣点，而非全部
''',
      tags: ['抖音', '快手', '短视频', '兴趣分析'],
      relatedLevel: 0,
      relatedMode: TeachingMode.onlineSocial,
    ),
    const SocialKnowledgeEntry(
      id: 'K016',
      title: 'QQ空间/微博：深挖过往的时光机',
      category: '社交媒体情报',
      content: '''
QQ空间和微博的历史动态是最真实的人物画像——因为那是对方在不同人生阶段留下的痕迹。

【时间线分析法】
- 翻看1-2年前的动态 → 了解对方的成长轨迹和变化
- 特别关注生日/节日/重大事件前后的动态 → 情绪高点和低点
- 空间留言板 → 旧友关系网络，了解对方过去的社交圈
- 说说/微博的情绪变化曲线 → 判断对方是乐观型还是易低落型

【从中提取可聊话题】
- 对方1年前发过"好想去看海" → 你可以说"最近想去海边吗？"
- 对方曾经追过某个明星/动漫 → 即使现在不追了也是回忆杀话题
- 对方曾经去过某地 → "你之前去过XXX对吧？我最近也想去，有什么推荐？"
- 对方转发过的活动/展览 → 了解ta感兴趣的活动类型

【特别注意的信号】
- 突然清空/隐藏历史动态 → 可能想重新开始/隐藏某段过去
- 某段时间动态很密集然后突然消失 → 经历了重大事件
- 凌晨发的动态（已删但你碰巧看到）→ 情绪脆弱时的真实表达
- 只有某段时间频繁提到某个人 → 那段时间可能有特殊关系

【使用原则】
- 挖掘信息是为了更好地了解对方，不是为了stalking
- 绝不在聊天中暴露"我翻了你三年前的说说"→ 太可怕
- 把信息转化为自然的话题，而非审讯式提问
- 发现对方不想提的过去 → 立即闭嘴，永远不要追问
''',
      tags: ['QQ空间', '微博', '社交考古', '话题挖掘'],
      relatedLevel: 0,
      relatedMode: TeachingMode.onlineSocial,
    ),
    const SocialKnowledgeEntry(
      id: 'K017',
      title: '社交媒体互动节奏学：点赞、评论、私聊的时机',
      category: '社交媒体情报',
      content: '''
社交媒体互动是关系的"预热系统"——好的互动节奏能让你们的关系在见面之前就升温。

【互动金字塔（从轻到重）】
Level 1: 点赞 → 最低成本的存在感（"我看到了你"）
Level 2: 表情评论 → 轻量互动（"我觉得有趣"）
Level 3: 文字评论 → 展示你认真看了（"我有想法"）
Level 4: 回复ta的评论 → 延伸话题（"我想聊更多"）
Level 5: 私聊 → 专属互动（"我想跟你单独聊"）
Level 6: 语音/视频 → 高度亲密（"我愿意给你我的声音和时间"）

【点赞节奏】
- 不要每条都赞 → 价值稀释，显得你很闲
- 好节奏：对方发3条赞1-2条 → 有选择性
- 最佳点赞时机：对方刚发5-15分钟内 → 被注意到的感觉最强
- 深夜动态等第二天再赞 → 避免显得你也在熬夜刷手机

【评论技巧】
- 提问式评论 > 陈述式评论 → 引发对方回复
- 幽默评论 > 普通评论 → 让对方记住你
- 独特视角 > 附和大众 → "别人都在说好看，但我注意到..."
- 不要在对方每条动态下都评论 → 像跟踪狂

【从评论到私聊的过渡】
- 对方回复你的评论 → 可以顺势私聊："对了，关于你说的那个..."
- 对方发了"情绪向"动态 → 不在评论区问，直接私聊关心
- 对方发了你擅长领域的内容 → 私聊提供价值："看到你对XXX感兴趣，我正好了解一些..."
- 对方深夜发动态 → 第二天上午私聊："昨晚看你动态，还好吗？"

【绝对不要做的事】
❌ 给3天前的动态点赞 → 暴露你在翻历史
❌ 在对方每条动态下都评论 → stalker既视感
❌ 评论区@对方 → 过于公开，让ta有压力
❌ 秒赞秒评每一条 → 显得太闲/太在意
''',
      tags: ['点赞', '评论', '私聊', '互动节奏'],
      relatedLevel: 0,
      relatedMode: TeachingMode.onlineSocial,
    ),

    // ==================================================================
    // 日常相处
    // ==================================================================
    const SocialKnowledgeEntry(
      id: 'K018',
      title: '日常相处的黄金节奏：亲密但不腻',
      category: '日常相处',
      content: '''
关系不是靠一次大动作维系的，而是日常细节的累积。好的节奏比好的内容更重要。

【联系频率原则】
- 初识期（1-2周）：隔天联系，每次5-10条消息 → 保持新鲜感
- 熟悉期（3-4周）：每天联系，但不全天 → 形成习惯但不腻
- 暧昧期（1-2月）：每天有质量地聊 + 偶尔语音 → 建立情感依赖
- 稳定期（3月+）：不需要每天聊，但要有"想到你就分享"的时刻

【日常相处的5个维度】
1. 信息分享：看到有趣的东西发给ta → "想到你"的信号
2. 情绪同步：对方开心你跟着开心，对方低落你陪伴 → 情感共振
3. 生活渗透：逐渐参与彼此的日常（一起吃饭/运动/看剧）→ 生活融合
4. 独立空间：不要求24小时在线 → 各自有各自的生活
5. 惊喜元素：偶尔打破常规 → 给关系注入新鲜感

【时间质量 > 时间数量】
- 30分钟全心投入的对话 > 3小时边刷手机边聊
- 一次有准备的约会 > 十次随便见见
- 一条走心的消息 > 二十条"在干嘛"

【常见错误】
❌ 刚认识就每天早中晚问候 → 太早进入"男朋友"模式
❌ 对方没回就连续发 → 暴露需求感和焦虑
❌ 每次聊天都聊很深 → 缺乏轻松感，关系变得沉重
❌ 只在线上聊不约见面 → 变成网友
❌ 见面只吃饭看电影 → 每次都一样，没有新鲜感
''',
      tags: ['日常相处', '联系频率', '关系节奏'],
      relatedLevel: 0,
      relatedMode: TeachingMode.maintainRelationship,
    ),
    const SocialKnowledgeEntry(
      id: 'K019',
      title: '约会设计学：场景决定关系走向',
      category: '日常相处',
      content: '''
约会不只是"一起出去"，每个场景都在潜意识中影响关系的走向。

【约会场景的心理学】
- 吊桥效应：一起经历轻微刺激（过山车/密室/攀岩）→ 心跳加速被误认为心动
- 共同挑战：一起完成一件事（做菜/拼图/逃脱）→ 建立团队感
- 新鲜感：第一次去的场景 → 多巴胺分泌，记忆更深刻
- 舒适感：熟悉的环境（咖啡馆/公园）→ 适合深度对话
- 尊重感：让对方选场景 → 展示你在乎ta的体验

【约会递进设计】
第1次：低压力场景（咖啡馆/甜品店，1-2小时）
→ 目标：确认是否聊得来，留下好印象
→ 不要：看电影（无法交流）/ 高消费餐厅（有压力）

第2次：互动型场景（做手工/看展/逛市集，2-3小时）
→ 目标：创造共同经历，有互动有话题
→ 不要：只坐着一对一深聊（太沉重）

第3次：体验型场景（攀岩/烹饪课/密室，3-4小时）
→ 目标：在挑战中看到彼此真实的一面
→ 不要：还是吃饭（太无聊了）

第4次+：自然相处（散步/逛超市/在家做饭）
→ 目标：展示日常状态，测试舒适度
→ 这时关系已经自然推进了

【约会中的加分细节】
- 提前了解对方饮食禁忌/过敏 → 展示细心
- 准备一个小惊喜（不是贵重礼物，是一片好看的树叶/一个有趣的小物件）
- 走路时让ta走内侧 → 保护感
- 对服务员态度好 → 展示教养
- 约会结束后发一条走心的感受 → 趁热打铁
''',
      tags: ['约会', '场景设计', '关系递进'],
      relatedLevel: 0,
      relatedMode: TeachingMode.pursueFemale,
    ),
    const SocialKnowledgeEntry(
      id: 'K020',
      title: '礼物学：不在于贵，在于"懂"',
      category: '日常相处',
      content: '''
送礼物是社交中最精密的"信号传递"——礼物的选择比价格更能说明你对ta的了解程度。

【礼物的三个层次】
Level 1 - 实用层：对方需要的东西（但缺乏惊喜感）
Level 2 - 兴趣层：对方感兴趣领域的东西（展示你关注ta）
Level 3 - 情感层：只有你俩懂的"梗"或记忆（最高级）

【不同阶段的礼物策略】
- 初识期（<1月）：不送礼，或只送"顺便的"（"看到这个觉得你会喜欢"）
- 熟悉期（1-3月）：小而有心思的（一本书/一个冰箱贴/一杯ta喜欢的咖啡）
- 暧昧期（3月+）：有个人印记的（手写卡片/定制小物/你们共同记忆相关的东西）
- 恋爱期：可以送贵的，但贵的+有心 > 只贵的

【最高级的礼物 = "我注意到了你没说的"】
- ta随口提过"最近肩膀疼" → 按摩券/热敷贴
- ta发过某个动漫角色 → 那个角色的周边
- ta说过喜欢某个味道 → 那个味道的香薰
- ta抱怨过手机支架不好用 → 一个设计感强的支架
关键：对方从没直接要过，但你知道ta需要

【送礼禁忌】
❌ 太贵的（让对方有压力/觉得你别有所图）
❌ 太私密的（内衣/香水——除非已恋爱）
❌ 跟前任送过的一样的
❌ 明显批量买的（没有个人选择感）
❌ 节日才送、平时从不送（显得仪式感大于真心）

【时机比礼物本身重要】
- 无理由的礼物 > 节日礼物（"今天看到这个想到你"）
- 对方低潮期的小惊喜 > 生日的大礼
- 约会结束时"给你带了个小东西" > 正式送
''',
      tags: ['礼物', '心意', '细节'],
      relatedLevel: 0,
      relatedMode: TeachingMode.pursueFemale,
    ),

    // ==================================================================
    // 打闹与互动
    // ==================================================================
    const SocialKnowledgeEntry(
      id: 'K021',
      title: '打闹的艺术：从嬉戏到亲密的桥梁',
      category: '打闹与互动',
      content: '''
打闹是人类最原始也最有效的拉近关系的方式——共同的笑声和肢体互动能快速打破壁垒。

【打闹的心理学基础】
- 共同大笑 → 催产素分泌，亲密感增加
- 轻度肢体接触 → 降低社交距离
- 玩笑式竞争 → 制造张力感（"对抗"中的吸引力）
- 共同的"幼稚时刻" → 信任的标志（我只在你面前这样）

【打闹的递进阶段】
Stage 1 - 语言打闹（刚熟悉）
- 互相起外号/吐槽 → 测试对方的幽默底线
- 故意说反话/抬杠 → 制造有趣的"冲突"
- 模仿对方的口头禅 → 亲密的调侃

Stage 2 - 道具打闹（更熟之后）
- 用枕头/靠垫轻打 → 经典的"枕头大战"
- 抢对方手里的东西（零食/手机）→ 自然的身体靠近
- 用贴纸/笔在对方手上画 → 肢体接触+共同创作

Stage 3 - 肢体打闹（关系亲密）
- 轻轻推搡/拍打 → 释放紧张感
- 挠痒痒 → 大笑+肢体接触（注意边界）
- "帮我看看背上有没有东西" → 信任+触碰
- 背人/公主抱 → 高度亲密的肢体互动

【打闹的核心原则】
1. 对方笑了才算成功——如果对方表情僵硬，立即停
2. 打闹要有"剧情"——不是无缘无故打，而是有个由头
3. 让对方赢——尤其是男生和女生打闹时，"输了"反而更可爱
4. 控制力度——打闹不是打架，轻到像羽毛拂过
5. 公开场合 > 私密场合——刚开始打闹时有他人在场更安全

【绝对禁忌】
❌ 对方明确说"别闹了"时继续 → 这就不是打闹了
❌ 打闹中触碰敏感部位 → 从玩笑变成骚扰
❌ 用打闹掩盖真实的攻击欲 → 对方能感觉到
❌ 在正式场合/对方心情不好时打闹 → 不合时宜
❌ 打闹后不回归正常交流 → 关系会变得只有嬉闹没有深度
''',
      tags: ['打闹', '嬉戏', '肢体互动', '亲密感'],
      relatedLevel: 0,
      relatedMode: TeachingMode.pursueMale,
    ),
    const SocialKnowledgeEntry(
      id: 'K022',
      title: '打成一片：融入圈子的社交密码',
      category: '打闹与互动',
      content: '''
"打成一片"不是真的打架，而是通过互动迅速消除距离感，让关系从"客客气气"变成"自己人"。

【融入新圈子的5步法】
Step 1: 观察期（前30分钟）
- 不急着表现，先看群体动态
- 谁是核心人物？谁和谁关系好？
- 群体的 humor style 是什么？（正经/互怼/玩梗）

Step 2: 信号期（30-60分钟）
- 跟上群体的节奏：大家笑你也笑，大家吐槽你也适度参与
- 先跟核心人物互动——ta 接纳你，群体就接纳你
- 找一个"入口话题"：最近大家都在聊的事

Step 3: 贡献期（1-2小时）
- 主动提供一个有价值的信息/笑点/故事
- 不要抢话，而是在合适的时机"接住"别人的话
- 适度自嘲——这是最快被接受的方式

Step 4: 互动期（2小时+）
- 开始跟不同的人产生1对1的小互动
- 参与群体的打闹/游戏/活动
- 制造一个"专属梗"——只有这个圈子才懂的笑话

Step 5: 确认期（活动结束前）
- 主动加群/加好友
- 说一句"今天很开心，下次再约" → 表达归属意愿
- 活动后发一条相关的动态/消息 → 延续连接

【双人"打成一片"的技巧】
- 共同完成一件事 > 面对面聊天 → 一起做饭/打游戏/拼乐高
- 制造"共同敌人" → 一起吐槽某件事/某个人（注意分寸）
- 创造"只有你们懂的梗" → 一次有趣的经历变成你们之间的"密码"
- 互相"亏"对方 → "你这也行？我服了" 式的调侃是亲密的标志

【常见错误】
❌ 一上来就太嗨 → 没有观察就融入会显得突兀
❌ 过度讨好 → "自己人"不是靠讨好来的
❌ 只跟一个人互动 → 没有融入"群体"
❌ 试图改变群体氛围 → 你是融入者不是领导者（至少一开始不是）
❌ 喝酒强行打成一片 → 酒肉朋友不是真正的"一片"
''',
      tags: ['融入圈子', '群体社交', '打成一片'],
      relatedLevel: 0,
      relatedMode: TeachingMode.groupSocial,
    ),
    const SocialKnowledgeEntry(
      id: 'K023',
      title: '玩笑与调侃的分寸：什么时候好笑，什么时候越界',
      category: '打闹与互动',
      content: '''
玩笑是社交的润滑剂，但一根油门一根刹车——踩对了哈哈哈，踩过了原地翻车。

【安全调侃公式】
✅ 调侃"选择"而非"本质"
  - 安全："你这品味，选的餐厅都是什么鬼哈哈哈"
  - 越界："你这长相也就只能靠嘴吃了"

✅ 调侃"当下行为"而非"过去经历"
  - 安全："你现在这个表情太好笑了"
  - 越线："难怪你前任不要你"

✅ 自嘲 > 嘲人（尤其是刚认识时）
  - 安全："我这方向感，跟着导航都能迷路"
  - 越线："你这智商能看懂这个？"

【调侃的"红灯区"】
🚫 外貌/身材（即使你觉得是夸奖也不行："你腿挺粗的...啊不是，挺长的"）
🚫 家庭/父母（"你爸妈是不是..."）
🚫 收入/消费能力（"这个你买得起吗"）
🚫 前任/感情史（"你前男友/女友..."）
🚫 身体缺陷/健康问题
🚫 种族/地域歧视类玩笑
🚫 对方明确表示过在意的话题

【判断玩笑是否OK的3个标准】
1. 对方笑了吗？——真笑（眼角有皱纹）> 假笑（只有嘴在动）> 没笑 > 尴尬
2. 对方有"反击"吗？——有 = 在玩；没有 = 在忍
3. 事后对方有没有变冷淡？——如果第二天态度变了，你昨天越线了

【越线后的补救】
- 立即道歉但不要过度道歉："抱歉，这个玩笑过了"
- 自我降格："我这嘴真是没把门的"
- 转移话题但不要装没事
- 记住这个教训，以后不要再碰这个点

【高级调侃技巧】
- "反转式调侃"：先夸再损 → "你今天穿得真好看...是不是要去相亲？"
- "配合式调侃"：对方自嘲时顺势加码 → 对方说"我好笨"，你说"没事，笨得挺可爱的"
- "关键词延伸"：抓住对方说的一个词做成梗 → 需要快速的临场反应
''',
      tags: ['玩笑', '调侃', '分寸感', '幽默'],
      relatedLevel: 0,
      relatedMode: TeachingMode.crossCulture,
    ),

    // ==================================================================
    // 关系维护
    // ==================================================================
    const SocialKnowledgeEntry(
      id: 'K024',
      title: '关系维护的节律学：定期充电 vs 日常微维护',
      category: '关系维护',
      content: '''
关系像手机电池——不充电会耗尽，但充太频繁也伤电池。关键是掌握节律。

【日常微维护（每天/每周）】
- 每天一条有质量的互动（不是"早安"，而是分享一个有趣的东西）
- 每周1-2次有内容的对话（>10条消息的交流）
- 看到与对方相关的信息就转发 → "想到你"的信号
- 记住对方提过的小事并在之后跟进 → "上次你说那个项目怎么样了？"

【定期充电（每月/每季）】
- 每月至少1次线下见面/约会
- 每季度1次"有仪式感"的活动（生日/纪念日/季节性活动）
- 每半年1次"深度回顾"——聊聊这段时间的关系状态
- 每年1-2次"共同旅行"——旅行是关系的试金石和催化剂

【关系维护的4个维度】
1. 情感维护：让对方感受到被在乎（惊喜/关心/陪伴）
2. 信息维护：保持信息同步（分享你的生活/了解对方的生活）
3. 体验维护：创造共同回忆（一起做新鲜的事）
4. 成长维护：共同进步（一起学习/互相激励/分享资源）

【关系降温的信号】
⚠️ 回复速度明显变慢（从秒回到小时回）
⚠️ 主动联系频率降低（从每天到每周）
⚠️ 对话内容变浅（从分享感受到只聊事实）
⚠️ 不再主动分享日常（"看到这个想到你"的次数减少）
⚠️ 约见面的借口越来越多

【升温维护策略】
- 降温时不要质问"你怎么不理我" → 反而加速降温
- 主动提供价值而非索取关注 → 分享有趣的东西/帮ta解决一个问题
- 创造一个"新的共同目标" → 一起学点什么/一起完成什么
- 回到你们关系最好的那个阶段做过的事 → 唤醒美好记忆
- 给对方空间 → 有时候降温只是对方忙/压力大，不是对你没感觉了
''',
      tags: ['关系维护', '节奏', '长期关系'],
      relatedLevel: 0,
      relatedMode: TeachingMode.maintainRelationship,
    ),
    const SocialKnowledgeEntry(
      id: 'K025',
      title: '长期关系的保鲜术：对抗"习惯化"',
      category: '关系维护',
      content: '''
心理学有个概念叫"习惯化"——再好的事情天天经历也会变平淡。关系保鲜的本质是对抗习惯化。

【习惯化的表现】
- 刚在一起时一条消息能开心半天 → 半年后"哦又发消息了"
- 刚认识时每次见面都精心打扮 → 后来素颜穿拖鞋就出门
- 以前聊到凌晨3点 → 现在各自刷手机到睡着
- 这不是不爱了，是大脑的必然机制

【6种科学有效的保鲜方法】

1. 共同新鲜体验法
- 一起做从没做过的事 → 大脑会将新鲜感归因于关系
- 每月尝试1个"第一次"：第一次做某道菜/第一次去某地/第一次学某技能
- 不一定要花大钱——换条路散步也算

2. 间隔强化法
- 不要每次都有求必应 → 偶尔的"不确定感"维持吸引力
- 不是故意冷落，而是保持自己的生活和节奏
- 有自己的生活 = 有源源不断的新话题

3. 感恩表达法
- 每周至少1次具体地表达感谢 → 不是"谢谢你"，而是"谢谢你今天特意..."
- 感恩日记：记下对方让你感动的3件小事，月底告诉ta
- 大脑会因为有"被注意到"的感觉而重新分泌多巴胺

4. 角色切换法
- 平时是恋人 → 偶尔变成"竞争对手"（一起打游戏）
- 平时是成人 → 偶尔变成"小孩"（打闹/撒娇）
- 平时是搭档 → 偶尔变成"陌生人"（角色扮演/假装初次见面）

5. 惊喜注入法
- 不一定要大惊喜——"今天下班顺路给你买了XXX"就够了
- 惊喜的关键不是"贵"而是"没想到"
- 在对方没期待的日常时刻做一件特别的事 → 效果最强

6. 成长同步法
- 一起读一本书/学一门课/养成一个习惯
- 各自成长但定期"汇报" → 分享新学到的东西
- "你变了"在长期关系中是褒义词——只要你们一起变
''',
      tags: ['长期关系', '保鲜', '习惯化', '心理学'],
      relatedLevel: 0,
      relatedMode: TeachingMode.maintainRelationship,
    ),
    const SocialKnowledgeEntry(
      id: 'K026',
      title: '危机预警与关系修复：从冷战中破冰',
      category: '关系维护',
      content: '''
再好的关系也会有"危机时刻"——区别在于有人能修复，有人任其恶化。

【关系危机的3个级别】

🟡 黄色预警（可通过日常维护解决）
- 对方回复变慢但内容正常
- 见面频率自然下降
- 对话中少了表情包和语气词
→ 对策：主动增加互动质量，安排一次有质量的约会

🟠 橙色预警（需要认真对待）
- 对方开始说"随便你""都行""嗯"
- 不再主动分享日常
- 对你的消息"已读不回"成为常态
→ 对策：找一个合适的时机，用"我感觉最近我们..."句式开诚布公地聊

🔴 红色预警（关系可能终结）
- 对方明确说"我需要空间""让我想想"
- 删除/隐藏了你们的合照或互动
- 对你的关心表现出烦躁
→ 对策：给予真正的空间，不要追着问，用行动而非言语证明改变

【冷战破冰的4步法】
Step 1: 冷却期（6-24小时）
- 不要在情绪最激动时试图解决
- 但不要超过48小时不联系 → 会变成真正的疏远
- 用这段时间想清楚：到底为什么吵？核心问题是什么？

Step 2: 信号期
- 发一条"低压力"消息："今天看到一个XXX想到你"
- 不要发"我们谈谈" → 太有压力
- 不要发"你还在生气吗" → 把情绪选择权交给对方

Step 3: 破冰期
- 如果对方回复了 → 不要立即提矛盾，先恢复轻松氛围
- 如果对方没回复 → 给一天时间，再发一条关心类消息
- 如果对方明确不想理 → "好，我给你空间，但我在这里"

Step 4: 修复期
- 面对面聊 > 电话聊 > 文字聊
- 用"我感觉..."而非"你总是..."开头
- 先承认自己的问题，再提出你的需求
- 达成具体的改进约定，而非空泛的"以后会注意"

【绝对不要做的事】
❌ 冷战时发朋友圈内涵对方 → 火上浇油
❌ 找对方朋友当传话筒 → 让对方丢面子
❌ 用"行那就算了"威胁结束关系 → 说多了就不怕了
❌ 道歉后立即要求对方恢复如常 → 对方需要时间消化
''',
      tags: ['危机管理', '冷战', '关系修复', '破冰'],
      relatedLevel: 0,
      relatedMode: TeachingMode.maintainRelationship,
    ),
    const SocialKnowledgeEntry(
      id: 'K027',
      title: '不同距离的关系维护策略',
      category: '关系维护',
      content: '''
不同的关系深度需要不同的维护策略——用错了力度反而会出问题。

【关系距离分类与维护策略】

🌍 远距离（异地/异国）
核心挑战：缺乏物理陪伴和日常互动
维护策略：
- 固定的"线上约会"时间（视频通话/一起看电影）
- 分享日常照片而非只文字 → 增加真实感
- 寄实体礼物/手写信 → 数字时代的稀缺性
- 定期见面计划 → 有盼头就能撑过平淡期
- 信任优先 → 不要因为距离而过度查岗

🏢 中距离（同城但不见面频繁）
核心挑战：容易从"不常见"变成"不联系"
维护策略：
- 每周至少1次有质量的互动（不只是点赞）
- 每月1次线下见面 → 哪怕只是吃个饭
- 利用共同活动维持连接（一起上健身房/同一家咖啡店）
- 在对方重要时刻出现 → 生日/升职/难过时

🏘️ 近距离（常见面/同事/同学）
核心挑战：太熟悉导致新鲜感丧失
维护策略：
- 制造"非日常"时刻 → 熟人关系中最缺的是惊喜
- 适当保持神秘感 → 不是所有事都告诉对方
- 创造独处的质量时间 → 群体中的互动≠关系维护
- 一起做"新的事" → 对抗熟悉感带来的倦怠

🏠 同居/家人
核心挑战：边界模糊导致摩擦
维护策略：
- 物理空间边界 → 每个人都需要"自己的角落"
- 时间边界 → 不是所有时间都要在一起
- 定期"分开活动" → 各自跟自己的朋友聚会
- 保持"约会"习惯 → 即使住在一起也要单独约会
- 表达感恩 → 对日常小事说谢谢，不要觉得理所当然

【通用原则】
- 关系的维护成本和亲密度成正比 → 越近的关系越需要用心
- 维护不是"防止变差"而是"让它更好" → 主动>被动
- 不同关系需要不同的"维护频率" → 不要用同一套方法对待所有人
''',
      tags: ['远距离', '近距离', '关系类型', '维护策略'],
      relatedLevel: 0,
      relatedMode: TeachingMode.maintainRelationship,
    ),

    // ==================================================================
    // 关系分层与识人
    // ==================================================================
    const SocialKnowledgeEntry(
      id: 'K028',
      title: '三层关系模型：深度关系、普通关系、点头之交',
      category: '关系分层与识人',
      content: '''
并非所有人都值得投入相同精力。科学的关系分层能让你把有限的社交能量用在对的人身上。

【三层关系模型】

🔵 第三层：点头之交（80%的人）
- 认识但了解浅，见面能打招呼，有基本信任
- 互动场景：偶遇寒暄、朋友圈点赞、工作对接
- 投入策略：礼貌+善意，不主动深聊，不分享私事
- 关键边界：可以帮忙小事，不借大钱，不诉苦
- 升级条件：发现共同价值观且对方也主动 → 可尝试升入第二层

🟡 第二层：普通关系（15%的人）
- 有一定了解，能聊日常，偶尔单独见面
- 互动场景：约饭、聊近况、互相帮忙
- 投入策略：定期维护但不需要高频，保持友好距离
- 关键边界：可以分享部分私事，不交心核心秘密
- 升级条件：经历过考验（困难时互相支持）且价值观一致 → 可尝试升入第一层

🔴 第一层：深度关系（5%的人）
- 深度信任，能交心，见过彼此脆弱的一面
- 互动场景：随时联系、深度对话、关键时刻在身边
- 投入策略：高投入高维护，值得花时间和精力
- 关键特征：在你低谷时没有离开、能给你真实反馈、不会嫉妒你的成功

【如何判断一个人属于哪一层】
1. 互动频率：多久联系一次？（月/年→第三层，周/月→第二层，天/周→第一层）
2. 话题深度：聊什么？（事实/天气→第三层，感受/经历→第二层，恐惧/梦想→第一层）
3. 互助历史：帮你做过什么？（口头关心→第三层，实际行动→第二层，牺牲自我→第一层）
4. 情绪安全：你能做真实的自己吗？（需要戴面具→第三层，可以放松→第二层，完全真实→第一层）

【常见错误】
❌ 把第三层当第一层 → 过早交心，受伤
❌ 把第一层当第三层 → 冷落了真正重要的人
❌ 试图把所有人都变成第一层 → 社交能量耗尽，一个深关系都没有
❌ 永远停在第三层不敢升级 → 孤独
''',
      tags: ['关系分层', '识人', '社交能量'],
      relatedLevel: 0,
      relatedMode: TeachingMode.crossCulture,
    ),
    const SocialKnowledgeEntry(
      id: 'K029',
      title: '红旗信号：这12种人不适合深交',
      category: '关系分层与识人',
      content: '''
识别"不该深交"的人比找到"值得深交"的人更重要——一段有毒的关系比十个普通朋友更有破坏力。

【12个红旗信号（出现2个以上→停在第三层）】

🚩 1. 总是索取不付出
- 每次找你都是需要帮忙，你找ta时永远"在忙"
- 借钱不还、让你帮忙却从不回报

🚩 2. 背后说所有人坏话
- 在你面前说别人坏话的人，也会在别人面前说你
- 判断方法：观察ta怎么评价不在场的人

🚩 3. 嫉妒你的成功
- 你遇到好事时，ta的表情比听到坏消息时还沉重
- "你运气真好"而非"太替你开心了"

🚩 4. 情绪绑架型
- "你不帮我就不是朋友"
- 用自残/绝交威胁你顺从
- 让你为ta的情绪负责

🚩 5. 持续不尊重你的边界
- 你说了"不想聊这个"ta还追问
- 你说"没空"ta还纠缠
- 把你的拒绝当作"欲擒故纵"

🚩 6. 习惯性撒谎
- 小事也撒谎，被拆穿了也不承认
- 前后说法矛盾

🚩 7. 需要你"拯救"
- 永远在危机中，永远需要你来解决
- 你成了ta的心理医生/保姆/提款机
- 你不帮ta就陷入更大的麻烦

🚩 8. 双标型
- ta可以迟到你不可以
- ta可以发脾气你不可以
- 规则只约束别人不约束自己

🚩 9. 情绪黑洞
- 每次跟ta聊完你感觉被掏空
- 抱怨>分享，负面>正面
- 你成了ta的情绪垃圾桶

🚩 10. 翻脸比翻书快
- 前一秒还好好的，下一秒冷战
- 你永远不知道哪句话会"得罪"ta
- 需要小心翼翼地"踩蛋壳"

🚩 11. 不尊重你的其他关系
- 贬低你的伴侣/其他朋友
- "你跟ta玩干嘛，ta配吗"
- 试图垄断你的社交

🚩 12. 品行底线低
- 对服务员恶劣
- 欺骗/利用弱者
- 不守承诺且不以为然

【应对策略】
- 红旗1-2个 → 保持第三层，礼貌但不深入
- 红旗3-4个 → 减少接触，逐步淡出
- 红旗5个+ → 果断远离，不要试图改变对方
- 任何暴力/欺骗/操纵 → 立即断联，没有例外
''',
      tags: ['红旗信号', '有毒关系', '识人', '避坑'],
      relatedLevel: 0,
      relatedMode: TeachingMode.crossCulture,
    ),
    const SocialKnowledgeEntry(
      id: 'K030',
      title: '绿旗信号：值得深度投资的人的特征',
      category: '关系分层与识人',
      content: '''
好的关系是复利投资——时间越久价值越大。以下是"值得深度投资"的人的10个绿旗信号。

【10个绿旗信号（出现5个以上→值得尝试升入第一层）】

🟢 1. 在你低谷时不离不弃
- 你失败/失恋/生病时，ta主动出现
- 不需要你开口求助就提供支持
- 这是最强的绿旗信号——经历考验才知真心

🟢 2. 能给你真实反馈
- 你做得好ta真心夸，你做错了ta敢说
- "我觉得你这件事处理得不太好"——只有真朋友才说这种话
- 反馈是建设性的而非指责性的

🟢 3. 为你的成功真心高兴
- 你升职/脱单/拿到offer时，ta比你还开心
- 没有任何"酸"的成分
- 主动帮你庆祝而非被动回应

🟢 4. 尊重你的边界
- 你说"不想聊"ta就不追问
- 你说"没空"ta就不勉强
- 你拒绝后ta不冷暴力

🟢 5. 记住你说过的小事
- "上次你说那个项目怎么样了？"
- "你提过喜欢吃XX，我看到了就想到你"
- 说明ta真的在听你说的话

🟢 6. 关系中没有"欠账"意识
- 帮你不是为了"你欠我一个人情"
- 你帮ta也不觉得"你又欠我一次"
- 双方都自然地付出，不计较谁多谁少

🟢 7. 能一起沉默而不尴尬
- 不需要一直说话来填满时间
- 安静待在一起也很舒服
- 这是深度信任的标志——你不觉得需要"表演"

🟢 8. 会主动道歉
- 做错了会承认而非找借口
- "对不起，这件事是我不对"
- 也会接受你的道歉而不翻旧账

🟢 9. 让你变得更好
- 跟ta在一起后你更积极/更努力/更有方向
- 不是说教，而是潜移默化的影响
- 你喜欢ta身边的自己

🟢 10. 品行底线高
- 对所有人（包括陌生人/服务员）都保持基本尊重
- 承诺的事情会做到，做不到会提前说
- 不在背后议论别人

【升级节奏建议】
- 不要因为绿旗多就立刻交心 → 深度关系需要时间验证
- 建议经历至少1次"小考验"再升级（如一次冲突后的修复）
- 深度关系是双向的——对方也要主动向你迈步
''',
      tags: ['绿旗信号', '值得深交', '识人', '关系投资'],
      relatedLevel: 0,
      relatedMode: TeachingMode.crossCulture,
    ),
    const SocialKnowledgeEntry(
      id: 'K031',
      title: '社交能量管理：精力分配的艺术',
      category: '关系分层与识人',
      content: '''
社交能量是有限的——就像电池，用完了需要充电。科学分配精力是长期社交健康的关键。

【邓巴数理论】
- 人类大脑只能维持约150个稳定社交关系
- 其中：5个密友、15个好朋友、50个普通朋友、100个认识的人
- 超出这个数量，关系质量必然下降

【精力分配建议】
- 第一层（5人）：投入60%社交精力
- 第二层（15人）：投入30%社交精力
- 第三层（130人）：投入10%社交精力（被动维护即可）

【社交能量管理法则】

1. 识别你的"充电方式"
- 内向者：独处、看书、散步 → 充电
- 外向者：跟密友聊天、参加活动 → 充电
- 不要用错误的方式"充电"→ 反而更累

2. 社交前的"能量预算"
- 评估当前能量值（1-10分）
- 能量<4 → 拒绝不必要的社交
- 能量4-7 → 只见第一/第二层的人
- 能量8+ → 可以见新人/参加大场合

3. "高耗能"社交的识别与管控
- 以下社交特别耗能，需要预留恢复时间：
  · 跟情绪黑洞型的人互动
  · 大型聚会/陌生人多的场合
  · 需要持续"表演"的场合
  · 处理冲突/矛盾
- 应对：限时长参加（"我1小时后还有事"）→ 给自己留退路

4. 主动"降层"
- 某些第二层的人长期不互动 → 自然降为第三层
- 某些第三层的人持续消耗你 → 主动淡出
- 降层不是冷血 → 是合理分配有限能量

5. 定期"社交断舍离"
- 每季度审视一次：谁在消耗你？谁在滋养你？
- 消耗>滋养的关系 → 降层或断联
- 不要因为"认识很久了"就舍不得 → 时间不等于质量

【常见错误】
❌ 对所有人付出相同精力 → 最终一个深关系都没有
❌ 社交能量耗尽还硬撑 → 影响身心健康
❌ 只维护第三层不投资第一层 → 危机时无人可依
❌ 拒绝所有社交来"节能" → 社交萎缩，失去支持网络
''',
      tags: ['社交能量', '精力管理', '邓巴数', '断舍离'],
      relatedLevel: 0,
      relatedMode: TeachingMode.crossCulture,
    ),

    // ==================================================================
    // 社交对象分类
    // ==================================================================
    const SocialKnowledgeEntry(
      id: 'K032',
      title: '与低龄儿童相处（0-6岁）：蹲下来看世界',
      category: '社交对象分类',
      content: '''
与低龄儿童相处是独特的社交场景——你的角色是引导者、保护者和陪伴者，而非"朋友"。

【核心原则：蹲下来】
- 物理层面：蹲下/坐下，保持与孩子平视 → 不居高临下
- 心理层面：用孩子的视角理解世界 → "你觉得这个虫子在干嘛？"
- 语言层面：简单、具体、正面 → "慢慢走"而非"不要跑"

【0-3岁婴幼儿】
互动方式：
- 安全感优先：稳定的回应、温柔的触碰
- 非语言为主：表情、语调、肢体 > 语言
- 重复中学习：反复做同一个游戏/读同一本书
- 避免：突然的大声/动作、陌生人焦虑期不强抱

【3-6岁学龄前儿童】
互动方式：
- "为什么"阶段：耐心回答十万个为什么 → 不知道就说"我们一起查"
- 游戏即学习：通过角色扮演/搭积木/画画建立连接
- 选择权：给有限选择而非指令 → "想穿红的还是蓝的？"
- 情绪命名：帮孩子识别情绪 → "你看起来有点生气，是吗？"

【通用技巧】
- 表扬具体行为而非笼统夸奖 → "你把玩具收好了真棒"而非"你真乖"
- 说"可以做什么"而非"不能做什么" → "我们在地上画画吧"而非"不许在墙上画"
- 承诺必须兑现 → 这个年龄的孩子对"说话不算话"极其敏感
- 犯错时温和纠正而非惩罚 → "哎呀水洒了，我们一起擦干净吧"

【绝对禁忌】
❌ 拿孩子跟别人比较（"你看XX多听话"）
❌ 用恐惧控制（"再哭大灰狼来抓你"）
❌ 在孩子面前激烈争吵
❌ 撒谎欺骗（"打针不疼"→ 信任崩塌）
❌ 强迫亲昵（逼孩子拥抱/亲吻不熟的人）
''',
      tags: ['低龄儿童', '育儿', '亲子沟通', '0-6岁'],
      relatedLevel: 0,
      relatedMode: TeachingMode.familyCommunication,
    ),
    const SocialKnowledgeEntry(
      id: 'K033',
      title: '与小学生相处（7-12岁）：做引导者而非命令者',
      category: '社交对象分类',
      content: '''
小学生正处于"规则建立期"——他们开始理解社会规则，但需要成人的引导而非命令。

【心理特征】
- 7-8岁：开始有逻辑思维，但对抽象概念理解有限
- 9-10岁：同伴关系变得重要，开始有"小团体"
- 11-12岁：进入青春期前奏，自我意识增强

【沟通策略】
- 用提问代替指令："你觉得应该怎么做？" > "你必须这样做"
- 认真回答他们的问题 → 这个阶段的孩子最看重"你有没有认真对待我"
- 承认自己的错误 → "对不起，刚才我说得不对"→ 大幅提升信任
- 不打断他们的表达 → 即使说得很慢也要耐心听完

【建立连接的方式】
- 共同活动：做手工/下棋/运动/一起看纪录片 → 在"做事"中交流
- 尊重他们的"认真" → 孩子在这个年龄段非常认真对待"公平"
- 守承诺的极端重要性 → 这个年龄段对"说话算话"有执念
- 关注他们关注的事 → ta喜欢的动漫/游戏/书，你也了解一下

【管教中的社交智慧】
- 自然后果法：不穿外套→冷→下次自己记得穿（比说教有效100倍）
- 逻辑后果法：弄坏别人的东西→用自己的零花钱赔（建立责任感）
- 避免：公开批评、跟其他孩子比较、翻旧账
- 犯错后的对话模板："发生什么事了？→ 你觉得后果是什么？→ 下次可以怎么做？"

【应对"叛逆期"前兆（11-12岁）】
- 不要用权威压制 → "因为我是大人"是最差的理由
- 给更多自主权 → 让ta自己做一些决定
- 倾听>说教 → 这个阶段的孩子最讨厌"被教育"
- 尊重隐私 → 敲门再进房间、不翻日记/手机
''',
      tags: ['小学生', '7-12岁', '教育沟通', '亲子'],
      relatedLevel: 0,
      relatedMode: TeachingMode.familyCommunication,
    ),
    const SocialKnowledgeEntry(
      id: 'K034',
      title: '与初中生/高中生相处（13-18岁）：尊重独立人格',
      category: '社交对象分类',
      content: '''
青春期是人格独立的关键期——他们既渴望被当作大人对待，又需要成人的支持。

【心理特征】
- 13-14岁：身份认同探索期，极度在意同伴评价
- 15-16岁：自我意识高峰，容易觉得"没人理解我"
- 17-18岁：接近成人，开始思考未来和人生方向

【黄金法则：先尊重，后引导】
- 把他们当作"准成人"对待 → 征求意见、尊重选择
- "顾问"而非"管理者" → 给建议但不替ta做决定
- 接受不同的观点 → 即使你不认同也先听完
- 不在ta朋友面前"管教" → 青春期的面子比什么都重要

【沟通技巧】
- 并肩沟通 > 面对面 → 一起散步/开车时更容易聊深
- 少问"为什么"多问"怎么了" → "为什么考这么差"（指责）vs "这次考试怎么了"（关心）
- 先共情后建议 → "听起来这事让你挺烦的" > "你应该这样做"
- 间接沟通也有效 → 有时候写一封信/发一条消息比当面说更好

【信任建设】
- 守承诺的终极考验 → 答应了不追问就真的不追问
- 保守秘密 → ta告诉你的事不告诉其他人（除非涉及安全）
- 承认你也会犯错 → "我以前也犯过类似的错误"→ 拉近距离
- 尊重边界 → 不偷看日记/手机/聊天记录

【危险信号——需要专业介入（非社交技巧范畴）】
⚠️ 持续情绪低落/自我否定
⚠️ 自伤行为
⚠️ 突然社交退缩
⚠️ 谈及轻生念头
→ 以上情况应立即寻求心理专业人士帮助，不可仅靠社交沟通解决

【跟"不是自己孩子"的青少年相处】
- 不要试图扮演父母角色 → 做一个"靠谱的成年人"即可
- 不要评价他们的穿着/音乐/爱好 → 代沟是正常的
- 分享你在这个年龄段的经历（适当）→ "我13岁的时候也..."
- 有趣 > 有理 → 他们更愿意跟有趣的大人交流
''',
      tags: ['青春期', '13-18岁', '初中生', '高中生', '独立人格'],
      relatedLevel: 0,
      relatedMode: TeachingMode.familyCommunication,
    ),
    const SocialKnowledgeEntry(
      id: 'K035',
      title: '与大学生相处（18-22岁）：平等对话与经验分享',
      category: '社交对象分类',
      content: '''
大学生处于"半独立"状态——成年但尚未完全社会化，既需要指引又渴望自主。

【心理特征】
- 大一：新鲜感+迷茫，需要归属感
- 大二大三：探索期，开始思考方向
- 大四：焦虑期，面对就业/考研/出国的选择压力

【如果你也是大学生】
- 同龄人社交以"共同经历"为核心 → 一起上课/社团/比赛/旅行
- 不要过度竞争 → 同一个专业不一定是要争第一，可以互相成就
- 尊重不同的选择 → 有人考研有人工作有人gap year，没有高下之分
- 适度社交而非社交焦虑 → 不需要跟所有人成为朋友

【如果你是社会人/前辈】
- 分享经验但不居高临下 → "我当年也纠结过" > "你应该这样做"
- 做资源桥梁 → 介绍实习/人脉/信息，比直接给建议更有价值
- 不要用"你还小不懂"打发 → 他们最反感这种态度
- 认真对待他们的问题 → 即使你觉得"这算什么大事"，对他们来说就是大事

【跨代沟通技巧】
- 聊未来但不施压 → "你有想过以后做什么吗？" 而非 "你打算找什么工作？"
- 聊兴趣而非只聊学习/工作 → 他们有丰富的生活维度
- 接受他们的价值观 → 这一代人的优先级可能跟你不同（工作生活平衡>拼命赚钱）
- 线上线下结合 → 大学生习惯线上社交，但面对面的质量更高

【适合的话题】
- 旅行经历/计划
- 书/电影/音乐/游戏
- 社会热点/科技趋势
- 未来可能性（开放式而非逼问式）
- 校园生活/趣事

【避免的话题】
- "一个月生活费多少/工资多少"（除非关系很近）
- "有对象了吗"（过年最讨厌的问题TOP1）
- "学这个专业有什么用"
- 持续说教/忆当年
''',
      tags: ['大学生', '18-22岁', '跨代沟通', '前辈'],
      relatedLevel: 0,
      relatedMode: TeachingMode.familyCommunication,
    ),
    const SocialKnowledgeEntry(
      id: 'K036',
      title: '与同龄人相处：平等中的微妙的"位置感"',
      category: '社交对象分类',
      content: '''
同龄人社交看似最简单——平等嘛——但恰恰因为"平等"，微妙的"位置感"处理不当反而出问题。

【同龄人社交的核心矛盾】
- 表面平等但实际有"隐形竞争"
- 同龄=同起点=容易比较 → "为什么ta比我好"
- 朋友变好你应该开心，但人性使然会有微妙的不平衡
- 处理好这个"微妙感"是成熟社交的标志

【与同龄人相处的5个原则】

1. 庆祝而非嫉妒
- ta升职/脱单/拿到offer → 真心庆祝
- 如果你感到一丝嫉妒 → 承认它（对内），不要因此疏远ta（对外）
- 嫉妒是人性，但因嫉妒而伤害朋友是选择

2. 不攀比不内卷
- 各有各的节奏 → "25岁买房"和"30岁读博"没有高下
- 不要在朋友面前"凡尔赛" → "哎我这个月才赚了3万好烦"
- 朋友分享好消息时 → 不要立刻说自己的好消息（抢风头）

3. 互相成就而非互相消耗
- 好朋友=资源共享而非零和博弈
- "我知道一个机会，你有兴趣吗？" → 互相成就
- 在别人背后说好话 → 这会传回ta耳朵里，效果比当面说强10倍

4. 接受"同频不同速"
- 你们同龄但可能处于完全不同的人生阶段
- 有人结婚了有人单身、有人当老板有人打工
- 不要用"你怎么还没XXX"来施加压力
- 也不需要因为自己"落后"而回避朋友

5. 钱的问题最考验关系
- 借钱：能不借就不借，借了就当送了
- 请客：轮流请 > AA制（更有温度），但金额不要差太大
- 旅行：提前说清楚预算预期 → 钱是旅行中最大的友谊杀手
- 不要炫耀消费 → "我这个包才2万"会让朋友不舒服

【同龄人中的"隐形分层"】
- 同龄 ≠ 同层次 → 即使年龄相同，人生阶段可能差很远
- 不要强求所有同龄人都成为密友 → 有些人只是"同年龄"而已
- 找到"同频"的人比找"同龄"的人更重要
''',
      tags: ['同龄人', '平等关系', '攀比', '社交位置'],
      relatedLevel: 0,
      relatedMode: TeachingMode.crossCulture,
    ),
    const SocialKnowledgeEntry(
      id: 'K037',
      title: '与年长者/长辈相处：尊重中的自我边界',
      category: '社交对象分类',
      content: '''
与年长者相处需要"双重奏"——既要表达尊重，又不能失去自我。

【心理特征】
- 长辈有"经验自信" → "我吃过的盐比你吃过的饭多"
- 渴望被尊重和被需要 → 这是他们社交的核心需求
- 对"新事物"可能排斥也可能好奇 → 因人而异
- 孤独感随年龄增加 → 很多老人其实很渴望有人聊天

【3个层次的年长者】

👤 比你大5-15岁（前辈型）
- 相处方式：尊重经验但保持平等 → 可以讨论、可以不同意
- 价值交换：你的新知识/新技术 ↔ ta的经验/人脉
- 禁忌：不要"装老成" → 你的年轻本身就是价值
- 技巧：主动请教 → "您在这个行业这么多年，怎么看XXX？"→ 前辈最吃这一套

👴 比你大15-30岁（长辈型）
- 相处方式：以尊重为主，但有边界
- 核心需求：被尊重、被需要、被倾听
- 禁忌：不要正面反驳 → 用"您说得对，我也在想..."的方式引入不同观点
- 技巧：问"过去的故事" → 长辈最爱讲自己的经历，认真听就是最大的尊重

🧓 比你大30岁+（祖辈型）
- 相处方式：陪伴 > 对话
- 核心需求：不被遗忘、有人陪伴、感受到被爱
- 禁忌：不要嫌烦/嫌慢 → 他们重复说同一件事是因为记忆退化
- 技巧：教他们用手机/视频通话 → 让他们能参与你的生活

【通用技巧】
- 倾听是最高的尊重 → 不打断、不纠正（除非涉及安全）
- 节日和生日很重要 → 一条消息/一个电话能让他们开心很久
- 不要试图改变他们的观念 → "说服"只会两败俱伤
- 身体接触表达关爱 → 挽手/拍肩/握手（老人很缺乏身体接触）
- 耐心 > 正确 → 有时候"让ta说对"比"你说对"更重要

【自我边界保护】
- 尊重 ≠ 顺从 → 可以尊重长辈但不认同ta的观点
- "您说得有道理，我再想想" → 既不否定也不承诺
- 不接受"为你好"的控制 → "谢谢您关心，这个决定我自己来"
- 不要因为"不孝顺"的帽子就放弃边界
- 涉及婚姻/职业/生育等重大选择 → 最终决定权在你

【代沟冲突的化解】
- 求同存异 → 在安全话题上深入（美食/旅行/健康），在敏感话题上转移
- 用行动而非争论证明 → 与其争论"这个工作有前途"，不如用成果说话
- 借第三方的嘴 → "我看过一篇文章说..."比"我觉得"更容易被接受
''',
      tags: ['长辈', '年长者', '代沟', '尊重', '边界'],
      relatedLevel: 0,
      relatedMode: TeachingMode.familyCommunication,
    ),
    const SocialKnowledgeEntry(
      id: 'K038',
      title: '与高学历/专业人士相处：价值对等与知识谦逊',
      category: '社交对象分类',
      content: '''
高学历/专业人士的社交有自己的"隐性规则"——理解这些规则能让你在他们的圈子里如鱼得水。

【心理特征】
- 重视逻辑和证据 → "有研究显示"比"我觉得"有效100倍
- 尊重专业边界 → 不喜欢外行指导内行
- 对"深度"有偏好 → 宁可聊一个话题聊深，也不浅聊十个话题
- 时间观念强 → 浪费ta的时间=不尊重ta

【与高学历人士相处的5个策略】

1. 知识谦逊但不自卑
- 不懂就说不懂 → "这个领域我不熟，你方便展开说说吗？"
- 不要装懂 → 被拆穿后信任归零
- 问好问题 > 给答案 → "你怎么看XXX？"比"我觉得XXX"更有价值

2. 价值对等原则
- 高学历人士重视"智力交流"→ 你也要带来有价值的信息/视角
- 不一定是学术层面的 → 你的行业经验/生活智慧/独特视角都有价值
- "信息差"是社交货币 → 你知道的ta不知道=你的价值

3. 尊重专业边界
- 不要"指导"对方的专业 → "你学心理学的能不能猜猜我在想什么"（大忌）
- 不要用百度来的知识跟专家辩论 → "我搜了一下你这个说法不对"（降智行为）
- 可以追问但不质疑 → "这个结论是怎么得出的？" > "我不信"

4. 聊天的"深度模式"
- 从事实层切入 → "你研究的是什么方向？"
- 往感受层深入 → "做研究过程中有没有让你特别兴奋/挫败的时刻？"
- 到价值层共鸣 → "你觉得你做的事对社会有什么意义？"
- 高学历人士很少被问到深度问题 → 你问了就会脱颖而出

5. 避免"反智"信号
- ❌ "读书有什么用，XX没读书不也当老板了"
- ❌ "你们高学历的就是想太多"
- ❌ "这个理论在现实中没用"
- ✅ "我虽然没系统学过这个，但我的经验是..."
- ✅ "你说的让我想到了一个问题..."

【不同场景的应对】
- 学术圈：读几篇ta的论文/文章 → 聊ta的研究是最高的尊重
- 医生/律师：不免费咨询 → "我想正式预约你的时间"
- 技术大牛：问有思考过的问题 → "我试过A和B但都不行，你觉得C方向可行吗？"
- 创业者：聊"为什么"而非"赚多少" → 高学历创业者更在意使命而非金钱

【核心心法】
- 高学历 ≠ 高情商 → 不要假设ta社交也很厉害
- 高学历 ≠ 什么都懂 → 在ta专业外你们是平等的
- 你的独特价值不因对方学历高而减少 → 自信是最好的社交名片
''',
      tags: ['高学历', '专业人士', '知识社交', '价值对等'],
      relatedLevel: 0,
      relatedMode: TeachingMode.workplaceSocial,
    ),
    const SocialKnowledgeEntry(
      id: 'K039',
      title: '社交对象矩阵：不同人群的适配策略速查表',
      category: '社交对象分类',
      content: '''
综合速查表——根据你的社交目标选择合适的对象类型和互动策略。

【按年龄段的社交适配矩阵】

| 年龄段 | 核心需求 | 你扮演的角色 | 最佳互动方式 | 关键禁忌 |
|--------|---------|------------|------------|---------|
| 0-3岁 | 安全感 | 保护者 | 稳定回应+温柔触碰 | 突然惊吓/陌生人强抱 |
| 4-6岁 | 探索欲 | 引导者 | 游戏中学习+情绪命名 | 比较式教育/恐吓控制 |
| 7-12岁 | 公平感 | 榜样+顾问 | 共同活动+认真回答问题 | 不守承诺/公开批评 |
| 13-15岁 | 独立感 | 后盾+倾听者 | 并肩沟通+尊重隐私 | 当众管教/偷看隐私 |
| 16-18岁 | 被尊重 | 顾问≠管理者 | 征求意见+接受不同观点 | 居高临下/否定爱好 |
| 18-22岁 | 方向感 | 资源桥梁 | 经验分享+不过度建议 | 催婚催育/否定专业 |
| 23-30岁 | 成就感 | 平等伙伴 | 互相成就+不过度比较 | 凡尔赛/抢风头 |
| 30-50岁 | 平衡感 | 互助同行 | 真诚交流+实际互助 | 只索取不付出 |
| 50-65岁 | 被需要 | 倾听者 | 请教经验+节日关怀 | 嫌烦/否定经验 |
| 65岁+ | 不孤独 | 陪伴者 | 陪伴+耐心+身体接触 | 嫌慢/忽视 |

【按关系目的的适配矩阵】

🎯 想要成长 → 找比你厉害5-10岁的人
- 前辈型关系，以请教为主
- 你的价值：新鲜视角/新技术/精力
- 注意：不要变成单向索取

🎯 想要放松 → 找同频同龄人
- 没有压力的平等社交
- 最佳活动：一起吃/玩/运动
- 注意：不要变成纯吐槽大会

🎯 想要深度连接 → 找价值观一致的人（不论年龄）
- 核心标准：能聊到灵魂层面的话题
- 测试方法：聊一个你真正在意的话题，看ta的反应
- 注意：深度关系不可强求，自然发生

🎯 想要扩大圈子 → 找"连接者"型的人
- 特征：认识很多人、喜欢组织活动、跨多个圈子
- 你的价值：成为ta的"高质量被连接者"
- 注意：不要利用连接者，先提供价值再请求引荐

🎯 想要陪伴家人 → 因年龄施策
- 低龄孩子：蹲下来+游戏+守承诺
- 青春期孩子：尊重+倾听+不当众管教
- 伴侣：保持新鲜感+定期约会+感恩表达
- 父母/长辈：倾听+请教+节日关怀+身体接触

【一图总结】
社交的本质不是"技巧"而是"理解"——理解对方处于什么人生阶段、有什么核心需求、你能扮演什么角色。匹配对了，关系自然顺畅；匹配错了，再多的技巧也白费。
''',
      tags: ['速查表', '社交矩阵', '年龄适配', '关系策略'],
      relatedLevel: 0,
      relatedMode: TeachingMode.familyCommunication,
    ),

    // ========== 群体社交 ==========
    const SocialKnowledgeEntry(
      id: 'K040',
      title: '群体社交控场总则：成为全场的"气场中心"',
      category: '群体社交',
      content: '''
当你作为领导、主持人、演讲者或组织者出现在群体中，"控场"就是你的首要任务。控场不是压制别人，而是让能量按照你的节奏流动。

【控场的三层境界】

🥉 第一层：不冷场（基础）
- 目标：让群体始终有话可聊、有事可做
- 核心：话题储备 + 敏锐观察 + 及时接话
- 表现：场子不散、没人被晾、气氛活跃

🥈 第二层：能引导（进阶）
- 目标：让对话和活动按你的方向推进
- 核心：话题转换术 + 节奏控制 + 价值输出
- 表现：大家跟着你的思路走、目标达成

🥇 第三层：能造势（高阶）
- 目标：制造高潮、留下记忆点、形成"梗"
- 核心：情绪调动 + 时机把握 + 仪式感设计
- 表现：现场沸腾、事后被反复提起、群体凝聚力提升

【控场的四大支柱】

1️⃣ 气场支柱：身体与声音
- 身体：挺胸、肩打开、占据合理空间、稳定不晃动
- 声音：音量够、语速稳、关键处停顿、有抑扬顿挫
- 眼神：扫视全场（不盯一人）、关键时与个体对视1-2秒
- 呼吸：腹式呼吸、不急促、紧张时先深吸一口气

2️⃣ 注意力支柱：抓焦点
- 开场30秒内必须抓住所有人注意力
- 方法：提问、悬念、反常识、故事、肢体动作
- 禁忌：开场道歉（"不好意思我不太会讲"）、自我贬低

3️⃣ 节奏支柱：控速与留白
- 快节奏：调动情绪、制造兴奋、推进信息
- 慢节奏：强调重点、制造悬念、留出思考空间
- 留白：讲完关键句停2-3秒，让信息沉淀
- 切换：察觉注意力下降时，立即改变节奏或形式

4️⃣ 互动支柱：让群参与
- 单向输出超过5分钟，注意力开始流失
- 每3-5分钟插入一次互动：提问、举手、讨论、小活动
- 互动要"低门槛"：举手比发言容易、点头比说话容易
- 让参与者成为"表演者"而非"听众"

【控场者的心态】

✅ 正确心态：
- "我是这个场子的服务者，不是表演者"
- "我的任务是让大家发光，不是只有我发光"
- "冷场不可怕，可怕的是不会救场"

❌ 错误心态：
- "我必须表现得很厉害" → 反而紧张僵硬
- "大家必须听我的" → 引发对抗
- "不能出错" → 失去自然感

【控场者的能量管理】
- 群体能量低 → 你要主动补能（讲故事、抛梗、带动情绪）
- 群体能量高 → 你要稳住（不让失控、引导到正轨）
- 群体能量乱 → 你要收拢（转移话题、聚焦焦点）
- 群体能量冷 → 你要破局（自嘲、提问、换活动）
''',
      tags: ['群体社交', '控场', '气场', '领导', '主持人', '演讲者'],
      relatedLevel: 0,
      relatedMode: TeachingMode.groupSocial,
    ),
    const SocialKnowledgeEntry(
      id: 'K041',
      title: '主持人控场术：从开场到收尾的全流程',
      category: '群体社交',
      content: '''
主持人是群体活动的"指挥家"，决定了整场活动的节奏、氛围和记忆点。好的主持人让活动流畅自然，差的主持人让场子尴尬冷清。

【开场：30秒定胜负】

🎯 黄金开场公式：钩子 + 价值 + 桥梁
- 钩子：用一个反问/悬念/故事/数据抓住注意力
- 价值：告诉听众"今天你会得到什么"
- 桥梁：自然过渡到第一个环节

❌ 致命开场错误：
- "大家好，我是XXX，今天由我主持..."（无聊流水账）
- "不好意思我有点紧张..."（自我贬低）
- 念PPT/念稿（失去人味）
- 长篇自我介绍（观众不关心你）

✅ 优秀开场示例：
- 悬念式："在开始之前，我想问大家一个问题——过去一年，你最难的一个决定是什么？"
- 故事式："上周我遇到一个朋友，他跟我说了一句话，让我重新思考了'成功'这两个字..."
- 反常识式："今天我要告诉大家的，可能和你们想的完全相反——XXX其实是个伪命题。"
- 互动式："现场有多少人觉得自己是内向的？举一下手。（数人头）好，看来大多数人都是。那今天我们就聊聊..."

【流程控场：让环节丝滑衔接】

🔗 转场三招：
1. 总结式转场："刚才X提到了一个很重要的点——YYY。这正好引出我们下一个环节..."
2. 提问式转场："听完刚才的分享，大家有没有什么想问的？（停顿2秒）那我们带着这个问题进入下一部分..."
3. 行动式转场："现在请大家拿出手机/翻开手册/转向身边的人，用1分钟做一件事..."

⚡ 应对环节超时：
- 提前约定："我们还有10分钟，争取3个问题"
- 软提醒："这个问题很有深度，我们可以会后继续聊"
- 硬切断："为了让大家都能参与，我们先进入下一环节，这个问题我们留到最后"

【互动控场：让观众成为参与者】

🎤 提问技巧：
- 开放式 > 封闭式（"你怎么看" > "你同意吗"）
- 先举手降低门槛，再点名深入
- 点名要"扫描式"，不要总点同一区域
- 收到回答后必须回应（复述/追问/升华），不能"嗯，下一位"

🎭 应对观众反应：
- 观众冷场 → 抛一个简单问题（举手/点头），先激活再深入
- 观众太热 → "大家的热情让我很感动，我们抓紧时间把核心讲完"
- 观众走神 → 改变形式（站起来/换位置/小活动）或讲一个相关故事
- 观众质疑 → "这个角度很好，我们聊聊"（不防御，先接纳）

【应对突发：救场神技】

🆘 突发情况处理：
- 设备故障 → "看来老天也想让我们多聊聊"（幽默化解）+ 立即启动B计划
- 嘉宾迟到 → "我们先聊一个话题"（不让观众等）+ 填充内容储备
- 观众刁难 → "这个问题很有挑战性，我先说说我的理解，也欢迎大家补充"（不硬刚）
- 说错话 → 自嘲纠正"哎呀，嘴瓢了，应该是..."（不慌张）
- 时间不够 → "我必须做个艰难的选择——讲最重要的三点"（果断取舍）

【收尾：让人记住一句话】

🎯 黄金收尾公式：回顾 + 升华 + 行动号召
- 回顾：用1-2分钟串起全场要点
- 升华：把信息提升到价值观/情感层面
- 行动号召：告诉听众"回去后做一件事"

✅ 优秀收尾示例：
- 金句式："今天我们聊了很多，但如果只记住一句话，我希望是——XXX。"
- 故事式："最后讲一个小故事...这就是我想留给大家的。"
- 行动式："回去之后，今晚就做一件事——XXX。一周后看看变化。"
- 开放式："今天的结束，是另一个开始。期待下次相聚。"

【主持人的隐藏武器：沉默】
- 讲完关键句后停2-3秒，让信息沉淀
- 提问后至少等5秒，不要害怕沉默
- 观众安静时，不要急于填充，先微笑环视
- 沉默是力量，不是冷场
''',
      tags: ['群体社交', '主持人', '控场', '开场', '收尾', '救场'],
      relatedLevel: 0,
      relatedMode: TeachingMode.groupSocial,
    ),
    const SocialKnowledgeEntry(
      id: 'K042',
      title: '领导者讲话术：让团队愿意跟你走',
      category: '群体社交',
      content: '''
领导者的讲话不同于主持人——你要传递方向、激发行动、凝聚人心。同样的内容，讲法不同，团队的执行力和忠诚度天差地别。

【领导者讲话的三大场景】

📊 场景一：布置任务
❌ 错误讲法："这个任务你们去做，下周五交。"
✅ 正确讲法：
1. 背景："我们为什么要做这件事"（讲清Why）
2. 目标："做成什么样算成功"（清晰可衡量）
3. 资源："你们能调动的资源是"（给予支持）
4. 信任："我相信你们能做好"（授权赋能）
5. 闭环："过程中遇到问题随时找我"（兜底承诺）

🗣️ 场景二：动员激励
公式：现状痛点 + 愿景描绘 + 个人意义 + 信念传递
- 现状痛点："现在我们面临的挑战是..."（不回避问题）
- 愿景描绘："如果做成，我们会..."（画面感要强）
- 个人意义："对在座的每一个人意味着..."（利益绑定）
- 信念传递："我相信我们能行，因为..."（给理由）

⚠️ 场景三：危机沟通
原则：快、准、稳
- 快：第一时间发声，不让大家猜
- 准：说清事实，不夸大不隐瞒
- 稳：表达信心，给方向感
- 公式：承认问题 + 应对措施 + 信心承诺
- 示例："确实遇到了XXX问题（不回避）。我们已经采取了YYY措施（有行动）。我相信团队能扛过去（给信心）。"

【领导者讲话的5个加分项】

1️⃣ 用"我们"代替"你们"
- ❌ "你们要把这个做好" → 距离感、命令感
- ✅ "我们要把这个做好" → 共同体、参与感

2️⃣ 讲"为什么"多于"是什么"
- 告诉团队"做什么"是管理
- 告诉团队"为什么做"是领导
- 为什么要做 = 意义感 + 方向感

3️⃣ 用故事代替数据
- 数据让人点头，故事让人行动
- "上个季度我们增长了30%"（数据）vs "老张上个月签下了那个难啃的客户"（故事）
- 故事的主角最好是团队成员，而不是你自己

4️⃣ 承认不确定，但给出方向
- ❌ "一切尽在掌握"（不可信）
- ✅ "现在有些情况还不明朗，但我们要做的三件事是..."（可信且有方向）
- 真诚 > 完美

5️⃣ 留出"沉默时刻"
- 讲完重要决定后停3-5秒，让团队消化
- 提出问题后等10秒以上，不要急于给答案
- 沉默传达"我说的是认真的"和"我尊重你们的思考"

【领导者讲话的5个减分项】

❌ 1. 念稿
- 念稿 = 我不重视你们
- 即使有稿，也要抬头看人、有眼神交流

❌ 2. 说空话套话
- "要高度重视、全力以赴、扎实推进"= 什么都没说
- 用具体的动词、具体的例子、具体的数字

❌ 3. 当众批评个人
- 公开批评 = 羞辱，会失去人心
- 表扬当众，批评私下

❌ 4. 过度承诺
- "大家放心，今年奖金翻倍" → 做不到时信任崩塌
- 宁可保守承诺，超额兑现

❌ 5. 长篇大论
- 领导讲话超过15分钟，注意力断崖下跌
- 宁可少讲，把时间留给团队

【不同规模群体的讲话策略】

👥 5人以下（小团队）：
- 像聊天，不像讲话
- 多提问，少陈述
- 围坐比站立好

👥 5-20人（部门）：
- 有结构但不死板
- 穿插互动和小活动
- 站立，但走近听众

👥 20-100人（全员）：
- 需要明确的结构和节奏
- 多用故事和金句
- 走动 + 眼神扫视

👥 100人以上（大会）：
- 像演讲，有表演成分
- 用大画面、大情绪
- 声音和肢体要放大

【领导者的"一句话"力量】
优秀的领导者往往有一句"标志性话语"，团队听到就心领神会：
- "把事做成，把人做好"（务实+人文）
- "允许犯错，不允许重复犯错"（包容+严格）
- "先开枪，后瞄准"（行动力）
- "慢慢来，比较快"（耐心+效率）
找到你自己的那句话，反复用，它会成为团队的文化符号。
''',
      tags: ['群体社交', '领导', '讲话', '动员', '团队管理'],
      relatedLevel: 0,
      relatedMode: TeachingMode.groupSocial,
    ),
    const SocialKnowledgeEntry(
      id: 'K043',
      title: '演讲者互动术：让观众从听众变成参与者',
      category: '群体社交',
      content: '''
演讲不是单向输出，而是一场"你与观众的对话"。优秀的演讲者能让几百人的场子，每个人都觉得"他在跟我说话"。

【演讲的三层结构】

🏛️ 骨架层：逻辑结构
- 开场（10%）：抓注意力 + 给承诺
- 主体（70%）：3个核心点（人类记忆极限）
- 收尾（20%）：升华 + 行动号召

🩸 血肉层：故事与案例
- 每个论点配一个故事或案例
- 故事要"具体到细节"（人名、场景、对话）
- 案例要"反差感"（从困境到突破）

🎭 灵魂层：情绪曲线
- 开场：好奇/共鸣
- 中段：紧张/冲突/转折
- 高潮：震撼/感动/顿悟
- 收尾：希望/力量/行动

【让观众参与的5种方法】

1️⃣ 举手投票
- "觉得A的举手，觉得B的举手"
- 低门槛，激活全场
- 让观众看到"我不是一个人"

2️⃣ 邻座讨论
- "跟你旁边的人用1分钟聊聊..."
- 瞬间把大场子变成小圈子
- 适合20人以上的场合

3️⃣ 点名互动
- 提前了解几位观众名字/背景
- 讲到相关内容时"就像刚才那位XX说的..."
- 让个体被看见，全场被带动

4️⃣ 现场演示
- 邀请观众上台参与
- 或自己做一个现场实验/演示
- 视觉冲击 > 语言描述

5️⃣ 留白思考
- 抛出一个问题后停10秒
- "先别急着回答，想一想..."
- 让观众内化，而非被动接收

【演讲者的肢体语言】

👀 眼神：
- 三分法：把全场分左中右，均匀扫视
- 对视：与单个观众对视1-2秒，传递"我在跟你说话"
- 禁忌：看天花板、看地板、看PPT

🤚 手势：
- 开放手势：掌心向上/向前（邀请、坦诚）
- 强调手势：手往下劈（坚定）、手往前推（推进）
- 禁忌：双手交叉（防御）、手插兜（漫不经心）、摸头摸脸（紧张）

🚶 走动：
- 关键点站定，过渡时走动
- 走动方向：向观众靠近（亲近感）、回到中心（权威感）
- 禁忌：来回踱步（焦虑感）、原地晃动（不稳重）

🗣️ 声音：
- 音量：关键句提高，抒情段放低（反而更专注）
- 语速：紧张处加快，重点处放慢
- 停顿：讲完金句后停2-3秒，让掌声/思考发生
- 禁忌：语调平淡（催眠）、尾音上扬（不自信）

【应对演讲突发】

😰 紧张忘词：
- 不要慌，喝口水（争取3秒）
- 跳到下一个记得的点
- 实在想不起来："我刚才说到哪了？"（让观众帮你接）

📵 观众玩手机：
- 不要点名批评
- 改变形式（提问/走动/互动）
- 或幽默化解："看来这部分有点干，我加快点"

😴 观众犯困：
- 立即改变能量（提问/故事/活动）
- 提高音量或走下台
- 讲一个反差大的案例唤醒注意力

😤 观众质疑：
- "这个观点很好，感谢你提出来"（先接纳）
- "我的理解是...也欢迎会后深入交流"（给出回应但不纠缠）
- 不要在台上与观众辩论

⏰ 时间不够：
- 不要赶，果断删减
- "我把最重要的三点讲完"（让结尾完整）
- 宁可少讲，不要烂尾

【演讲的"金句"设计】
一场好演讲，听众记住的往往是一两句话。提前设计你的金句：
- 短：10字以内最好记
- 反：有反常识或反差感
- 用：能指导行动

示例：
- "不是能力问题，是顺序问题"
- "先完成，再完美"
- "你的问题不是没时间，是没优先级"
- "改变从最小的行动开始"

【演讲者的终极心法】
讲你真正相信的话。
观众能分辨出"背稿"和"发自内心"。当你讲自己经历过、思考过、相信的东西时，你的语气、眼神、肢体都会自然到位。技巧是放大器，真诚才是信号源。
''',
      tags: ['群体社交', '演讲', '互动', '肢体语言', '金句'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K044',
      title: '话题延续术：永不冷场的话题储备与转换',
      category: '群体社交',
      content: '''
冷场不可怕，可怕的是没有"话题弹药库"。掌握话题延续的系统方法，任何场合都能让对话源源不断。

【话题的"三圈理论"】

🎯 内圈：安全话题（任何时候可用）
- 天气/美食/旅行/电影/音乐/宠物/运动
- 最近的热点新闻/热门剧集
- 共同环境（活动现场、城市、季节）
- 用途：破冰、救场、过渡

🎯 中圈：兴趣话题（需要一点了解）
- 工作/行业动态/职业发展
- 爱好深耕（摄影/健身/读书/游戏）
- 家庭/孩子/伴侣（注意分寸）
- 用途：深入交流、建立连接

🎯 外圈：深度话题（需要信任基础）
- 价值观/人生观/世界观
- 梦想/恐惧/遗憾
- 时事观点/社会议题
- 用途：深度连接、关系升级

⚠️ 禁忌话题（除非关系极深）：
- 收入/财产
- 政治立场（陌生人场合）
- 宗教信仰
- 他人隐私/八卦

【话题延续的5种技术】

1️⃣ 5W1H延伸法
当对方说了一句话，用What/Why/When/Where/Who/How追问：
- "你刚才说去了云南，具体去了哪些地方？"（Where）
- "为什么选择去那里？"（Why）
- "跟谁一起去的？"（Who）
- "什么时候去的？待了多久？"（When）
- "印象最深的是什么？"（What）
- "怎么安排的行程？"（How）
一个话题可以延展出6个方向的对话。

2️⃣ 关键词抓取法
从对方的话中抓取关键词，展开新话题：
对方："上周带孩子去了趟博物馆，人真多。"
关键词："上周""孩子""博物馆""人多"
- "上周"→"最近周末都怎么过的？"
- "孩子"→"孩子多大了？平时喜欢什么？"
- "博物馆"→"喜欢历史还是艺术？推荐个展览？"
- "人多"→"现在旅游都这样，有没有小众去处推荐？"

3️⃣ 故事接龙法
对方讲完一个故事，你讲一个相关的：
- "这让我想起我有一次..."
- "你说的太有共鸣了，我也遇到过类似的事..."
- "你的经历让我想到了一个问题..."
注意：不要"故事压故事"（你的更牛），而是"故事接故事"（产生共鸣）。

4️⃣ 假设延伸法
用"如果"打开想象空间：
- "如果时间倒流十年，你会做什么不同的选择？"
- "如果不用考虑钱，你最想做什么？"
- "如果能跟任何人共进晚餐，你选谁？"
假设性问题容易引发深度对话，适合关系已经比较熟时。

5️⃣ 反向提问法
当对方问了你一个问题，回答后反问：
对方："你平时周末喜欢做什么？"
你："我喜欢爬山，最近在练XX。你呢？周末一般怎么安排？"
对话变成"乒乓球"，而不是"采访"。

【群体场合的话题转换】

🔄 当话题变冷时：
- 不要硬撑，主动转换
- "对了，一直想问你..."（自然过渡）
- "说起来，最近有个事挺有意思的..."（引入新话题）
- "刚才聊到XX，让我想到..."（承接转换）

🔄 当话题变干时：
- 不要重复已经聊过的内容
- 把话题"升级"或"降级"
  - 升级：从"美食"→"旅行中的美食"→"最难忘的一顿饭"
  - 降级：从"职业规划"→"最近工作怎么样"→"最近忙不忙"

🔄 当话题变敏感时：
- 不要跟着深入
- "这个话题挺深的，我们聊点轻松的..."（直接转换）
- 用一个无关话题打断："对了，你们试过那家新开的店吗？"

【群体话题的"接力"技巧】

在多人场合，让话题像接力棒一样传递：
- 抛话题："XX，你之前不是去过日本吗？说说看。"
- 接话题："是啊，我也遇到过，YY你觉得呢？"
- 转话题："这让我想到另一个事，ZZ你上次说的那个..."

【场景化话题储备库】

🥂 聚餐场合：
- "最近吃到最好吃的一道菜？"
- "你最拿手的一道菜是什么？"
- "有没有哪家店推荐？"
- "旅行中吃过最奇怪的食物？"

🏢 职场场合：
- "入行多少年了？为什么选这个方向？"
- "工作中最有成就感的一件事？"
- "如果重新选择，还会做这行吗？"
- "对新人的建议？"

🎉 社交场合：
- "最近在追什么剧/综艺？"
- "有什么新发现的小众爱好？"
- "今年有什么想完成的目标？"
- "最近一次开心是什么时候？"

👨‍👩‍👧 家庭场合：
- "孩子最近怎么样？"
- "假期有什么安排？"
- "父母身体还好吧？"
- "最近有什么家庭趣事？"

【永不冷场的终极心法】
比"会说话"更重要的是"会倾听"。
当你认真听对方说话，话题自然源源不断——因为对方说的每一句话都是下一个话题的入口。冷场往往不是因为没话说，而是因为没在听。
''',
      tags: ['群体社交', '话题延续', '永不冷场', '话题储备', '倾听'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K045',
      title: '造梗与玩梗：让群体记住你的"语言符号"',
      category: '群体社交',
      content: '''
"梗"是群体社交的硬通货。一个好的梗能让冷清的场子瞬间炸裂，能让陌生人迅速产生共鸣，能让一段对话被反复回忆。造梗不是抖机灵，而是一种高级的社交创造力。

【什么是"梗"？】

梗 = 在特定群体中反复被提及、引用、变形的语言/行为符号

梗的三个特征：
1. 意料之外，情理之中（反差感）
2. 简短好记，易于复述（传播性）
3. 承载共同体验或情绪（共鸣感）

【造梗的5种方法】

1️⃣ 放大法：把小事放大到荒诞
- 现场：有人迟到了5分钟
- 造梗："我们以后就用'X分钟'作为时间单位，1X=5分钟"
- 后续：下次有人迟到，"你今天迟了0.8个X"

2️⃣ 反差法：制造意想不到的关联
- 现场：一位严肃的高管说了一句接地气的话
- 造梗："X总的灵魂是XXX"（反差感）
- 后续：成为这位高管的"人设标签"

3️⃣ 错位法：把A场景的话用在B场景
- 现场：培训中有人说"这个我会"
- 造梗：之后每当遇到新任务，大家起哄"这个我会！"
- 后续：成为团队的"挑战宣言"

4️⃣ 金句法：提炼一句有力量的话
- 现场：某人无意中说了一句很有道理的话
- 造梗：反复引用，并归因于他"XX定律"
- 后续：成为团队的"智慧语录"

5️⃣ 动作法：把一个动作符号化
- 现场：某人紧张时有个特殊小动作
- 造梗：模仿这个动作表达某种情绪
- 后续：成为群体的"暗号"

【玩梗的4个原则】

✅ 1. 梗要"现场感"
- 最好的梗来自当下发生的真实瞬间
- 不要硬搬网络梗，要"因地制宜"
- "刚才X说的那句话..." > "网上那个梗..."

✅ 2. 梗要"善意"
- 造梗的对象要能笑得出来，不能被冒犯
- 拿别人的缺点/隐私造梗 = 霸凌
- 自嘲式造梗最安全（拿自己开涮）

✅ 3. 梗要"适度"
- 一个梗反复玩3-5次是"经典"，超过10次是"过气"
- 强行玩老梗比冷场更尴尬
- 让梗"自然消退"，不要强行续命

✅ 4. 梗要"包容"
- 玩梗时观察不在场的人是否能get
- 如果一半人不懂，要及时解释或转换
- "圈内梗"不要在"圈外人"面前过度使用

【不同角色的造梗策略】

🎤 主持人造梗：
- 开场抛一个梗定调
- 用梗串起整场活动
- 收尾时"回调"开场的梗（首尾呼应）

👔 领导者造梗：
- 把团队文化浓缩成一句话
- 用梗传递价值观（比说教有效）
- 自嘲式造梗拉近距离

🗣️ 演讲者造梗：
- 用梗做"记忆锚点"
- 每个核心观点配一个梗
- 让听众带走"可复述的故事"

👥 普通参与者造梗：
- 接住别人的梗并放大（造梗者其实是你）
- 用梗回应，形成"对话游戏"
- 适时收手，不要喧宾夺主

【造梗的时机把握】

🎯 黄金时机：
- 刚发生一个意外/有趣的瞬间
- 群体情绪正在高点
- 大家有了共同语境

⚠️ 不宜造梗：
- 严肃场合（哀悼、批评、危机）
- 有人正在认真表达
- 群体情绪低落或紧张
- 话题敏感

【梗的"生命周期"管理】

🌱 诞生期：第一次出现，要敏锐捕捉
- "这句绝了，记下来"
- 立即复述一次，让大家记住

🌿 流行期：反复使用2-3次，形成记忆
- 在不同场合引用
- 稍微变形，保持新鲜感

🍂 衰退期：使用频率下降，不再引起大笑
- 不要强行使用
- 可以"怀旧式"提及（"还记得我们那个梗吗"）

💀 死亡期：完全过气
- 接受它的离去
- 准备造新梗

【群体梗库的建立】
一个有凝聚力的群体往往有自己的"梗库"：
- 把经典梗记录下来（群名/群公告/相册）
- 新人加入时"科普"梗的由来（仪式感）
- 定期"复盘"经典梗（强化认同）
- 梗库越丰富，群体凝聚力越强

【玩梗的边界】

❌ 绝对不要造的梗：
- 拿别人的身体缺陷/外貌造梗
- 拿别人的家庭/感情问题造梗
- 拿种族/性别/地域歧视造梗
- 拿政治/宗教敏感话题造梗
- 拿别人的痛苦经历造梗

✅ 安全的造梗方向：
- 自嘲（最安全）
- 共同经历的尴尬/搞笑瞬间
- 当下的环境/事件
- 语言的双关/谐音
- 行为的反差

【造梗的终极心法】
最好的梗不是"造"出来的，而是"发现"的。
当你足够投入当下、足够关注身边的人，那些"梗的瞬间"会自然浮现。你的任务不是发明，而是捕捉并放大它。一个会造梗的人，本质是一个"活在当下"的人。
''',
      tags: ['群体社交', '造梗', '玩梗', '幽默', '群体文化'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K046',
      title: '冷场救场术：3秒化解尴尬的应急手册',
      category: '群体社交',
      content: '''
冷场不是失败，而是每个群体社交中必然出现的"呼吸点"。真正的高手不是从不冷场，而是能在3秒内把冷场变成转机。

【冷场的5种类型与识别】

❄️ 类型一：开局冷场
- 表现：开场后没人接话，空气突然安静
- 原因：陌生感、没准备好、等别人先开口
- 信号：眼神躲闪、看手机、咳嗽

❄️ 类型二：话题冷场
- 表现：一个话题聊干了，没人接新话题
- 原因：话题太窄/太深/太干，或大家都说完了
- 信号：重复已说过的话、敷衍"嗯嗯"

❄️ 类型三：能量冷场
- 表现：大家都很累，没人有说话的欲望
- 原因：时间太长/内容太闷/身体疲惫
- 信号：打哈欠、眼神涣散、身体后倾

❄️ 类型四：冲突冷场
- 表现：有人说了一句敏感/冒犯的话，全场凝固
- 原因：踩了雷区/触及禁忌/引发对立
- 信号：尴尬微笑、低头、交换眼神

❄️ 类型五：结尾冷场
- 表现：该结束了但没人收尾，拖拖拉拉
- 原因：没有明确的收尾信号/负责人
- 信号：看时间、收拾东西、欲言又止

【3秒救场工具箱】

🆘 工具1：自嘲救场（万能）
适用：所有冷场类型
- "看来这个问题把大家都难住了，包括我"
- "尴尬的沉默，我来打破一下——其实我刚才走神了"
- "这种时候就需要一个不怕丢脸的人，就是我"
原理：自嘲降低压力，让大家放松

🆘 工具2：提问救场（万能）
适用：开局冷场、话题冷场
- "好奇问一下，在座的各位是怎么认识X的？"
- "换个话题，最近大家有没有什么有意思的事？"
- "我想问个可能有点傻的问题..."
原理：提问激活参与，转移焦点

🆘 工具3：行动救场（能量冷场）
适用：能量冷场
- "咱们站起来活动一下"
- "换个地方，去阳台/吧台聊"
- "来个小游戏/小互动"
原理：改变身体状态，重置能量

🆘 工具4：幽默救场（冲突冷场）
适用：冲突冷场
- "好了好了，这个话题留到下次辩论赛"
- "看来我们触及了宇宙终极问题"
- "这个分歧证明我们团队很有多样性"
原理：用幽默化解紧张，给台阶下

🆘 工具5：总结救场（结尾冷场）
适用：结尾冷场
- "今天聊得很尽兴，我用一句话总结..."
- "时间差不多了，最后一个问题"
- "今天的三个收获是..."
原理：明确收尾信号，避免拖沓

【不同时长的救场策略】

⏱️ 0-3秒（瞬时救场）：
- 一个微笑
- 一句"然后呢？"
- 一个动作（举杯、拍手）

⏱️ 3-10秒（短时救场）：
- 抛一个轻松问题
- 讲一个相关小故事
- 引用刚才的某个点延伸

⏱️ 10-30秒（中时救场）：
- 改变形式（站起来/换位置/换活动）
- 引入新话题
- 做一个小互动

⏱️ 30秒以上（长时救场）：
- 承认冷场并转化
- "我们好像聊干了，要不要换个方式？"
- 主动提议新活动或休息

【特殊场景救场】

🎯 演讲冷场：
- 不要慌张加速
- 停下来，喝口水
- 走到观众中，提问互动
- "我讲到哪了？有没有人帮我接一下"

🎯 会议冷场：
- 不要点名逼问
- "大家先思考1分钟，写下来"
- "有没有什么顾虑可以说"
- 改变小群体讨论再汇总

🎯 聚餐冷场：
- "来来来，干杯/敬一杯"
- "这道菜怎么样？"
- "讲个八卦"（注意分寸）

🎯 谈判冷场：
- 不要急于打破沉默
- 沉默也是谈判工具
- "我们可以先休息5分钟"

【救场禁忌】

❌ 1. 慌张填充
- 冷场后不停说废话填补
- 反而显得不自信

❌ 2. 点名逼问
- "XX你来说说"
- 让对方尴尬，可能引发对抗

❌ 3. 抱怨冷场
- "怎么都不说话了？"
- "你们好安静啊"
- 把责任推给别人，破坏氛围

❌ 4. 强行搞笑
- 冷场时硬讲笑话
- 如果不好笑，会更尴尬

❌ 5. 假装没发生
- 不承认冷场，强行继续
- 大家心知肚明，反而更别扭

【救场者的心态】

✅ 正确心态：
- "冷场是正常的，不是我的错"
- "我有能力转化它"
- "沉默也是一种交流"

❌ 错误心态：
- "我必须马上说点什么"
- "大家都在看我"
- "冷场意味着失败"

【冷场的"反向利用"】

高手甚至会主动制造"策略性冷场"：
- 讲完关键点后停顿，让信息沉淀
- 提出深刻问题后沉默，让大家思考
- 情绪高点后留白，让感受流动
这种"有意冷场"不是尴尬，而是力量。

【救场能力训练】

日常练习：
1. 观察高手如何救场（视频/现场）
2. 储备5-10个万能救场句
3. 在安全场合（朋友聚会）练习
4. 复盘自己的救场经历
5. 培养"不怕冷场"的心态

记住：真正的高手不怕冷场，因为他们知道——冷场之后，往往是更深层的连接。
''',
      tags: ['群体社交', '冷场', '救场', '应急', '尴尬化解'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K047',
      title: '群体动力学：读懂群体气场与角色博弈',
      category: '群体社交',
      content: '''
每个群体都有自己的"气场"——看不见但感受得到。读懂群体动力学，你就能在复杂的人群中找准位置、发挥作用、不被消耗。

【群体发展的5个阶段】

🌱 1. 形成期（Forming）
- 表现：客气、试探、不清楚规则
- 气场：低能量、谨慎
- 你的任务：主动破冰、建立安全感、明确目的

🌪️ 2. 动荡期（Storming）
- 表现：意见冲突、小团体、争夺话语权
- 气场：高能量、紧张
- 你的任务：不站队、求同存异、聚焦目标

🤝 3. 规范期（Norming）
- 表现：形成默契、规则清晰、开始协作
- 气场：中等能量、稳定
- 你的任务：巩固共识、强化文化

🚀 4. 表现期（Performing）
- 表现：高效协作、互相补位、产出成果
- 气场：高能量、流畅
- 你的任务：保持节奏、防止自满

🔄 5. 解散/重组期（Adjourning）
- 表现：收尾、告别、反思
- 气场：低能量、感慨
- 你的任务：仪式感收尾、沉淀经验

识别群体处于哪个阶段，你才知道该做什么。

【群体中的8种角色】

👑 1. 领导者
- 话语权最大，决定方向
- 应对：支持其方向，私下提建议

🤹 2. 组织者
- 落地执行，连接各方
- 应对：主动帮忙，成为其"右手"

🗣️ 3. 发言者
- 话多，代表群体发声
- 应对：不要抢话，适时补充

🧠 4. 智者
- 话少但一语中的
- 应对：主动请教，给其发言空间

😊 5. 和事佬
- 调和矛盾，维持和谐
- 应对：不要让其为难

🃏 6. 活跃者
- 制造笑点，活跃气氛
- 应对：接住其梗，不要冷落

🧐 7. 观察者
- 不太说话，默默观察
- 应对：适时邀请其发言，不要强迫

⚡ 8. 挑战者
- 质疑、反对、制造冲突
- 应对：先接纳其观点，再引导建设性方向

你在群体中扮演什么角色？你可以选择角色，也可以切换角色，但不要试图扮演所有角色。

【群体气场的"能量定律"】

⚖️ 能量守恒：群体总能量大致固定
- 有人高能量时，必然有人低能量
- 你想提升自己能量，要让别人也提升

🔄 能量流动：能量从高向低流动
- 你能量高时，会带动周围人
- 你能量低时，会被周围人带动

📊 能量分布：80/20法则
- 20%的人贡献80%的话题
- 不要让自己成为沉默的80%，也不要成为独占的20%

【群体中的"权力博弈"】

🎭 显性权力：
- 职位/资历/资源决定的话语权
- 应对：尊重规则，不正面挑战

🎭 隐性权力：
- 人缘/信息/专业度决定的影响力
- 应对：积累隐性权力，比显性权力更持久

🎭 权力转移信号：
- 大家开始看向某个人（寻求意见）
- 某人的话被反复引用
- 某人说话时全场安静
- 识别这些信号，看清真正的"权力中心"

【群体中的"小团体"现象】

👥 小团体形成原因：
- 共同利益/兴趣/背景
- 地理位置接近
- 价值观一致
- 互相需要

⚠️ 小团体的利弊：
- 利：归属感、效率高、互帮互助
- 弊：排外、信息壁垒、派系斗争

✅ 应对小团体：
- 不要试图消灭小团体（不可能）
- 跨小团体建立连接（做"桥梁"）
- 聚焦共同目标，弱化差异
- 不要在A小团体面前说B小团体的坏话

【群体决策的"陷阱"】

🕳️ 陷阱1：群体思维（Groupthink）
- 现象：为了和谐，大家都不反对
- 后果：决策质量下降
- 破解：指定"魔鬼代言人"，鼓励质疑

🕳️ 陷阱2：责任分散
- 现象：人越多，每个人越觉得"不是我责任"
- 后果：没人行动
- 破解：明确到个人的责任

🕳️ 陷阱3：少数人主导
- 现象：话最多的人决定方向
- 后果：沉默多数被忽略
- 破解：主动邀请沉默者发言

🕳️ 陷阱4：信息茧房
- 现象：只听同类的声音
- 后果：视野狭窄
- 破解：引入外部视角

【作为"特殊角色"的群体策略】

👑 如果你是领导：
- 不要试图控制所有对话
- 多提问少下结论
- 让不同角色都发挥作用
- 你的任务是"赋能"而非"主导"

🎤 如果你是主持人：
- 你的权力来自"流程"而非"内容"
- 让不同声音被听见
- 在关键时刻收拢焦点
- 不要让自己成为"表演者"

🗣️ 如果你是演讲者：
- 你的权力来自"内容"而非"职位"
- 用故事和金句建立连接
- 留出让观众参与的空间
- 不要独占舞台

👥 如果你是普通参与者：
- 你的权力来自"贡献"而非"头衔"
- 接住别人的话，延伸价值
- 适时提出不同观点（建设性）
- 不要沉默，也不要刷存在感

【读懂气场的练习】

下次参加群体活动，观察：
1. 谁是真正的"权力中心"？（不一定是最显眼的人）
2. 群体处于哪个发展阶段？
3. 你自然倾向于扮演什么角色？
4. 哪些话引发了共鸣？哪些话被忽略？
5. 群体的"禁忌话题"是什么？

读懂群体气场，你就能在任何群体中——不被消耗、找到位置、创造价值。
''',
      tags: ['群体社交', '群体动力学', '气场', '角色博弈', '权力'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K048',
      title: '群体社交速查表：特殊角色场景策略矩阵',
      category: '群体社交',
      content: '''
综合速查表——根据你的角色和场景，快速找到最合适的控场策略。

【按角色的策略矩阵】

| 角色 | 核心目标 | 关键能力 | 常见误区 | 必备武器 |
|------|---------|---------|---------|---------|
| 主持人 | 流程顺畅 | 转场+救场 | 抢风头 | 5个万能救场句 |
| 领导者 | 凝聚人心 | 讲故事+赋能 | 念稿+空话 | 1句标志性话语 |
| 演讲者 | 传递价值 | 金句+互动 | 单向输出 | 3个核心故事 |
| 组织者 | 落地执行 | 协调+兜底 | 大包大揽 | B计划储备 |
| 嘉宾 | 提供价值 | 专业+配合 | 喧宾夺主 | 1个记忆点 |
| 参与者 | 贡献能量 | 倾听+接话 | 沉默/抢话 | 3个延伸问题 |

【按场景的策略矩阵】

🎯 年会/大型活动
- 人数：50-500+
- 时长：2-4小时
- 核心挑战：注意力分散
- 策略：
  - 开场30秒必须炸
  - 每15分钟一个高潮
  - 用视频/音乐/灯光辅助
  - 设计1-2个"群体梗"
  - 收尾留金句和行动号召

🎯 部门会议
- 人数：5-30
- 时长：30-90分钟
- 核心挑战：效率与参与平衡
- 策略：
  - 开场明确议程和目标
  - 主持人控时，每议题有时间限制
  - 邀请沉默者发言
  - 用"写下来"代替"说出来"（降低门槛）
  - 收尾明确行动项和负责人

🎯 团队建设
- 人数：10-50
- 时长：半天-2天
- 核心挑战：破冰+深化
- 策略：
  - 设计"破冰游戏"降低戒备
  - 小组活动>大组活动
  - 制造"共同挑战"形成凝聚力
  - 安排"深度对话"环节
  - 收尾分享感受，固化记忆

🎯 聚会/聚餐
- 人数：3-15
- 时长：1-4小时
- 核心挑战：话题持续+人人参与
- 策略：
  - 座位安排影响对话（避免小团体固化）
  - 准备3-5个备选话题
  - 适时"换座位"打乱组合
  - 让每人都有"高光时刻"
  - 适时收尾，不拖沓

🎯 培训/工作坊
- 人数：10-100
- 时长：2-8小时
- 核心挑战：保持专注+学以致用
- 策略：
  - 每20分钟改变形式（讲/练/讨论）
  - 理论<30%，练习>70%
  - 小组任务+成果展示
  - 即时反馈+复盘
  - 收尾制定行动计划

🎯 线上会议
- 人数：3-50
- 时长：30-120分钟
- 核心挑战：参与感低
- 策略：
  - 开场让大家开麦/举手打招呼
  - 用聊天区+投票增加互动
  - 点名提问（避免"对所有人说"）
  - 屏幕共享要精简
  - 收尾明确下一步

【按人数的策略矩阵】

👤 1对1
- 重点：深度连接
- 技巧：倾听>表达，提问>陈述
- 禁忌：炫耀、说教、看手机

👥 3-5人
- 重点：人人参与
- 技巧：眼神轮换，不让一人独占
- 禁忌：小团体排外、忽略安静者

👥 5-15人
- 重点：话题管理
- 技巧：准备话题库，适时转换
- 禁忌：让2-3人垄断对话

👥 15-50人
- 重点：结构化互动
- 技巧：分组讨论+代表发言
- 禁忌：单向输出超过15分钟

👥 50人以上
- 重点：气场与节奏
- 技巧：故事+金句+大画面
- 禁忌：细节过多、互动失控

【万能应急清单】

😰 紧张时：
1. 深呼吸3次
2. 找一个友善的眼神对视
3. 开场先讲一个故事（降低压力）
4. 承认紧张（"第一次主持，有点紧张"）

🥶 冷场时：
1. 微笑，不要慌
2. 抛一个简单问题（举手/点头）
3. 自嘲一句
4. 引入新话题或新形式

😴 观众走神时：
1. 改变音量/语速
2. 走动或改变位置
3. 讲一个故事或案例
4. 抛出互动问题

😤 遇到挑衅时：
1. 不防御，先接纳
2. "这个角度很好"
3. 给出你的理解
4. 不在台上纠缠

⏰ 时间不够时：
1. 果断删减内容
2. "我把最重要的讲完"
3. 保证收尾完整
4. 会后补充材料

【群体社交的"黄金法则"】

🌟 法则1：先给后要
- 想被关注，先关注别人
- 想被记住，先记住别人
- 想被尊重，先尊重别人

🌟 法则2：留白比填充重要
- 讲完关键点停顿
- 提问后等待
- 让沉默发生

🌟 法则3：赋能比表现重要
- 让别人发光
- 接住别人的话
- 成就他人=成就自己

🌟 法则4：真诚比技巧重要
- 讲你相信的
- 做你说的
- 承认你不会的

🌟 法则5：节奏比内容重要
- 再好的内容，节奏错了也无效
- 再普通的内容，节奏对了也精彩
- 控场=控节奏

【一图总结】
群体社交的本质不是"表演给别人看"，而是"创造一个让每个人都舒服的空间"。当你把注意力从"我表现得好不好"转向"大家感觉怎么样"，你就已经是一个控场高手了。
''',
      tags: ['群体社交', '速查表', '场景策略', '角色矩阵', '控场'],
      relatedLevel: 0,
    ),
    // ========== 分性别针对性内容（K049-K054） ==========
    const SocialKnowledgeEntry(
      id: 'K049',
      title: '男生约会升级指南：从普通见面到拉近距离',
      category: '男生约会与追求',
      content: '''
男生约会最大的误区是"对她好=她会喜欢我"——事实是：有魅力+让她有情绪波动 > 对她好。好男人经常输，就是因为把"安全感"当成了"吸引力"。

【约会前：打造被"选中"的基本盘】
- 干净整洁（**最低要求**）：指甲剪短、头发利落、鞋子不脏、无异味。比穿什么牌子重要100倍
- 提前 10-15 分钟到，不要让她等。**你等她 = 你重视这次见面**
- 地点选在**你熟悉的地方**——你主场，你放松，她就放松
- 有**备选方案**：如果那家店排队/人多嘈杂，立刻说"我知道附近一家很不错的店，两分钟就到"——这就是靠谱的体现

【约会上半场（前30分钟）：建立舒适和轻松】
- 第一句话：**夸环境**或**轻松自嘲** > 夸她外表
  ✅ "这家店我朋友推荐的，说招牌奶茶不错，希望没踩雷"
  ❌ "你真人比照片好看"（太刻意，她听过无数次）
- 坐法：**面对面坐（正式）→ 后半段转到她同侧（拉近距离）**
- 点单：你可以先问"你想喝什么？"但**主动买单**。不要在第一次吃饭时AA——不是因为欠她什么，而是传递"我有能力也有意愿"的态度
- 上半场话题：**中性安全话题**，不要一上来就查户口：
  - 聊聊最近的一个电影/综艺/剧
  - 聊聊最近吃的一家有意思的店
  - 聊聊"最近最意外的一件小事"
  - 观察周围环境，吐槽或调侃眼前的场景

【约会中场（30-90分钟）：情绪波动与制造连接】
- 制造"轻微的情绪波动"，而不是一直温柔和和气气
  ✅ "你说话的方式很像我那个上中学时爱打游戏的小表妹"（轻微打压+标签+推拉）
  ✅ "你这件上衣颜色我很喜欢，但你穿白色应该会更好看"（先肯定再推）
- **投资互动**：让她也有付出，而不是只有你在表演
  ✅ "你帮我看一下，我这杯和你那杯哪个更好喝？你尝一口告诉我"
  ✅ "来，我们玩个游戏，你猜我是哪里人，猜对我买单"
- 肢体接触升级（一定**先从无压力的触碰**开始）：
  1. 上楼梯时："小心，这边台阶比较窄，我扶你一下"（手肘）
  2. 过马路时：自然拉一下手臂，过完马上松开
  3. 她冷时："你冷不冷？" → 如果她说还好就**脱外套**硬给她披上，不用多问
  4. 手：过马路也可以"牵着你，我比较会看车"，过完就放。不要一直不放

【约会后半场（90分钟+）：升级信号】
- 如果她**主动找话题、笑的次数多、跟你眼神对视不逃避、靠近你坐** → 可以尝试第二场地
  ✅ "离这五分钟有一家甜品店，我觉得你会喜欢他们家抹茶布丁，要不要去？"
  ✅ "时间还早，要不要散散步消消食？"
- 升级**不要靠表白**，要靠"行动升级"——先到了那个关系，表白只是一个形式
- 结束后送她到**地铁站/打车点/楼下**，目送她进去再走。到家后你发一条："今天过得很开心，下次一起再试试那家新开店" → 下一次你已经约成了

【绝对禁忌】
❌ 约会前问"你想吃什么""去哪""你决定" → 女生要的是你带她**体验**，不是她来安排
❌ 全程炫耀：我赚多少、开什么车、跟谁认识 → 她一眼看穿你没自信
❌ 第一次约会就表白/送贵重礼物 → 给对方太大压力，把对方吓跑
❌ 冷场时慌张+手机救场 → 冷场是正常的，深呼吸说"没想到我们聊天中间竟然有一段沉默"反而加分
❌ 动手动脚、动手动脚、动手动脚（重说三）——第一次见面任何带侵略性的接触都是减分

【给老实男生的忠告】
"对她好"是基础不是加分项。她选择你不是因为你有多听话，而是因为你**有魅力（外在+内在）、有态度（有主见不讨好）、有安全感（说到做到）**。先做一个有趣、靠谱、有主心骨的人，再做一个好男朋友。
''',
      tags: ['男生', '约会', '第一次约会', '关系升级', '肢体接触'],
      relatedLevel: 0,
      relatedMode: TeachingMode.pursueFemale,
      targetAudience: TargetAudience.male,
    ),
    const SocialKnowledgeEntry(
      id: 'K050',
      title: '男生追求女生心法：吸引而非讨好',
      category: '男生约会与追求',
      content: '''
追女生的核心：不是"让她感动"，而是"让她心动 + 让她投入 + 让她觉得被认可"。你感动她100次，不如她心动1次。

【底层逻辑：吸引力三要素】
✅ **价值（你是谁）**：外形整洁、有自己的事做、有朋友圈、有稳定的生活节奏、不围着她转。价值是"你本身就有魅力"，不是"你给了她什么"
✅ **可得性（她能得到你吗）**：如果你对所有人都温柔、她看不出你对她有任何不同 → 你=中央空调，可得性=0。**你要让她感觉到，她是特殊的**
✅ **投入度（她在你身上花了什么）**：她花了时间想你、花了时间打扮见你、花了心思猜你、帮你做了一件小事——这些都是投入。**投入越多，越离不开**。反过来你单方面投入越多，她越不在乎

【聊天不要做的5件事】
❌ 早上"早安"、中午"吃饭了吗"、晚上"在干嘛"、睡前"晚安"。这种机器人聊天=没话找话，一周后她就不想回
❌ 秒回 + 长篇大论。你越重视，她越觉得你没事做。她用了20分钟回你一条，你用1分钟回三条？这是不对等
❌ 讨好 + 跪舔。"你太优秀了我配不上你""你说的都对""我听你的" → 这是你在**主动放弃吸引力**
❌ 查户口式提问+连续提问。"你多大？哪里人？做什么？工资多少？家里几口人？" → 你是面试吗？
❌ 她不回你就疯狂追问。隔了1小时没回 → 你连问三个"在吗？""怎么了？""是不是我说错话了？" → 压迫感拉满

【聊天要做的5件事】
✅ 她回一条，你回**差不多长度 + 略长一点**。她冷，你也冷一点点；她热，你再热一点点。温度匹配
✅ 你的消息要有"钩子"——你说的话里要留给她回的空间
  ❌ "今天天不错"（她只能回"是啊"）
  ✅ "今天天不错，我下午在公园看到一只柯基像你发过的那只，你后来有再遇到它吗？"（有故事、有钩子、有共同记忆）
✅ 用"情绪推拉"而不是一直正面
  ✅ "你的厨艺看起来挺厉害…不过，看起来厉害不等于真的好吃，下次要当场验证一下"（先推再拉）
✅ 不要把一次话题聊死。一次聊差不多就撤："我现在要去吃饭/健身/忙个事，晚点聊"。你主动结束对话 → 你有你的生活 → 她下次更想继续
✅ 用"服从度测试"判断她对你有没有兴趣：
  - "你帮我想一下，买什么礼物送我妹生日礼物比较合适？" → 她认真回了=有兴趣
  - "这周有没有新的电影要上？你帮我搜一下" → 她做了=有兴趣
  - 三次测试她都没回应、都绕开 → 暂时不用追了，先提升自己

【推进节奏：三阶段】
1️⃣ **弱兴趣阶段（她礼貌回复）**
   - 目标：让她觉得你是一个正常、不烦人、有点意思的人
   - 频率：2-3天聊一次，不要每天骚扰
   - 结束："认识你挺有意思的，下次出来坐坐？" → 邀约见面（**不要约在微信上确定关系**）

2️⃣ **中兴趣阶段（她主动找话题、会问你问题、会分享生活）**
   - 目标：让她产生"投入" + 情绪波动
   - 频率：可以每天/隔天聊，但必须有自己的事
   - 行动：见面 2-3 次 → 尝试第二场地 + 轻微肢体接触
   - 标志：她会主动报备行踪，会跟你说"我到了""我回家了"

3️⃣ **强兴趣阶段（她会主动关心你、会吃醋、会因为你没及时回消息而追问）**
   - 目标：把这种兴趣确认成关系
   - 行动：不要在微信上表白。**制造一个确定关系的场景**（散步到江边、你送她到楼下、气氛到位）
   - 不要说"做我女朋友吧"，而是**做了再说**——自然牵手、她不反抗，**下一次**再见面时你自然叫她"宝宝"，看她答不答应。答应了就是成了

【判断你是不是备胎】
- 她**只有在需要帮忙**时才找你，平时不回你消息 → 备胎
- 她**只有在深夜/孤独**时才找你聊天 → 情绪垃圾桶/备胎
- 你每次想推进约会，她**各种理由拖、约了临时又放鸽子** → 吊着你
- 这种状况超过 3 个月 → 立刻止损。追女生不是打持久战，3 次正式见面没进展就换下一个。

**一句话总结**：你不害怕失去她，她才会害怕失去你。
''',
      tags: ['男生', '追求', '聊天技巧', '吸引力', '推拉', '备胎止损'],
      relatedLevel: 0,
      relatedMode: TeachingMode.pursueFemale,
      targetAudience: TargetAudience.male,
    ),
    const SocialKnowledgeEntry(
      id: 'K051',
      title: '女生约会心法：让他心动又不失分寸',
      category: '女生约会与吸引',
      content: '''
女生约会的核心：不跪舔、不讨好、不考验过度——**你既要有魅力，也要给他台阶和确定性**。很多女生误以为"他爱我就应该猜透我所有心思"——结果把认真的男生都推走了。

【约会前：状态优先于装扮】
- 穿你**最常穿、最自在**又显气色的风格，不要穿"我从来没穿过但好看的裙子"——你不自在=你整个约会表现扣分
- 淡妆，干净的头发和一点点淡香水。男生分辨不出色号，但是**分辨得出"她看起来很舒服"**
- 放松！你越放松越自然，他越觉得跟你相处不累。不要把每个男生都当"结婚候选人"，当"交个新朋友"相处反而更有魅力

【约会上半场（前30分钟）：展示性格而非外貌】
- 不要一上来就端着"公主架子"——也不要一上来就"我是独立女性我付我那一份"。**让他舒服，比"你要占上风"更重要**
- 他说的话题里，找一个你真的感兴趣的点去追问
  ✅ "你说你最近常徒步，是从什么时候开始喜欢上的？"（**真正的好奇**，比敷衍的"你好厉害"好100倍）
- 对他的好适度展示欣赏，但不是盲目崇拜
  ✅ "你对这个行业这么了解，应该花了不少时间吧"（**肯定他的努力**，不是"你好牛逼啊"）
  ❌ 全程"嗯嗯""对""好厉害" → 他会怀疑你是不是敷衍

【约会中场（30-90分钟）：制造"我对你有兴趣但你还要追"的张力】
- 适当**示弱但不依赖**：
  ✅ "我方向感超差，跟我出门你可能要当人肉导航～"（示弱，也给他分配了角色）
  ❌ "我什么都不会，你帮我…"（不独立）
- 给**三个正面信号（IOI）**，再**留一个钩子**
  - 信号1：他说完笑话，你真笑 + 眼神停留
  - 信号2：你说话时用"我们"开头——"我觉得我们都喜欢这种店，下次可以约一起探店"
  - 信号3：不经意肢体靠近（比如听他说话时身体微微前倾）
  - 钩子：他约第二次时，**不要每次都立刻答应**，答应2/3次，留1/3次："这周我工作好忙，周日晚有空，那时候你呢？" → 让他**有一点点付出成本**
- 关于买单：
  - 第一次他主动付，你不用抢。你可以说"好，下次我请你喝奶茶"——既不欠他，也给他留了**第二次约会的伏笔**
  - 如果他坚持你付那一份，也不用硬塞给他。**互相都有投入的关系才是健康的**

【肢体接触：不要一直躲，但也不要主动】
- 他碰你的手臂/手肘/肩膀——**不躲就等于允许**。如果你也对他有好感，不要下意识甩开
- 他要牵你手过马路——如果你愿意给他，就回握一下他的手；如果不愿意，就笑着说"我自己能走的～"然后自然抽手
- 冷场时：可以跟他玩小游戏（真心话大冒险简化版 / 猜他星座 / 猜他学什么专业），只要你不尴尬，就没人尴尬

【结束与后续：给他一点确定性，但不要立刻就给了所有】
- 结束后，如果觉得还行，你可以**主动发一条消息**：
  ✅ "今天跟你聊天挺开心的，下次你推荐那家烤串记得带我去"（肯定 + 留了下次的钩子）
  ❌ "我到家了"然后就没下文（他会搞不清你到底对他有没有兴趣）
- 他如果隔天再找你，热情程度跟上一次差不多就行，不要一下子变成"他找你秒回 + 你长篇大论"——那他的追逐游戏就结束了

【绝对禁忌】
❌ 第一次约会就坦白你对他"一见钟情"——给对方太大压力，也失去了暧昧的张力
❌ 全程玩手机、照镜子、心不在焉 → 他会觉得你根本不尊重他
❌ 全是抱怨：抱怨工作、抱怨前任、抱怨天气 → 负面情绪谁都不想接
❌ 连续三次他约你、你都"没空"——再认真的男生也会放弃，**除非你真的不想要**
❌ 第一次吃饭就点最贵的菜、理所当然他买单 → 这不是"你值得"，是**你没教养**

【给女生的提醒】
被追的时候，多观察他的**人品、耐心、对陌生人的态度**，而不是他给你花了多少钱、说了多少甜言蜜语。真正靠谱的男生，是那些**坚持、行动大于语言、尊重你的意愿**的人。遇到合适的，**适当给台阶**，别把好的都考验走了。
''',
      tags: ['女生', '约会', '吸引', '暧昧', '分寸感', '肢体接触'],
      relatedLevel: 0,
      relatedMode: TeachingMode.pursueMale,
      targetAudience: TargetAudience.female,
    ),
    const SocialKnowledgeEntry(
      id: 'K052',
      title: '女生反拿捏：吸引他追你而不是被短择',
      category: '女生约会与吸引',
      content: '''
女生最怕什么？遇到短择——他只想要一次、一周、一个月，你却以为遇到了真爱。这篇教你识别短择信号，建立让优质男生"想要认真追你"的框架。

【短择信号：遇到立刻跑】
🚩 **认识刚加第一天就说**：
- "你真性感/身材好"（夸你外表但不夸你性格/思想）
- "你看起来很寂寞吧"（暗示你需要他来填补空虚）
- "我很少对一个女生这样"（标准PUA开场白）

🚩 **推进速度异常快**：
- 刚见面第二次就要肢体接触（搂腰/强吻/试图带去私密空间）
- 聊天全程性暗示，正经话题聊不了三句
- 第一次见面就说"我爱你""你就是我要找的人"（用真心的套路骗上床）

🚩 **从不投入实际成本**：
- 从来**不约白天**，只约晚上10点之后、他家/酒店附近
- 永远"忙，下次再约"，但你朋友圈一发自拍他立刻评论
- 不送任何礼物、不做任何安排、任何需要付出的事情全是你在做

🚩 **信息不对称**：
- 你不知道他做什么的、不知道他朋友圈发什么、不知道他住哪、不知道他有没有对象
- 他对你所有的信息都一清二楚，你问他的信息他就绕开

以上**中两个=短择高风险，中三个=立刻拉黑**，不要心存侥幸。

【建立"长择吸引"框架】
**长择框架 = 你值得被认真对待的信号系统**。你不需要说出来，你做出来：

✅ **你的时间有成本**
  - 他临时约你今晚 → 你说："抱歉今晚我有约了，提前2天约我比较好，我不喜欢临时安排"
  - 不是你不灵活，是你**已经把自己排在"他临时有需要"之外了**
  - 对的人会尊重你的节奏，错的人会因为你不顺从而走（那走正好）

✅ **你有你的生活，不是等他的消息**
  - 他半小时没回你 → 你不要立刻"怎么不回我"。你去做你自己的事，等他回了你也隔一会儿再回
  - 你在忙自己的事时，他的消息来了 → 你可以"我在忙，晚上聊"，不要放下一切都秒回
  - 长择男生喜欢有**自己生活节奏**的女生，因为这样的人更"珍贵"

✅ **你对感情有标准，不是谁追都接受**
  - 不要在他面前贬低前任，也不要说"我谈过多少段"。你可以说：
    "我谈恋爱比较认真，也比较慢，希望对方也是一个有耐心、能认真的人。"
  - 这句话一出，**短择自动劝退**，长择反而更尊重你

✅ **升级是有门槛的**
  - 聊天 → 至少1周互相深入聊
  - 见面 → 至少2-3次正式约会
  - 牵手 → 氛围到位，且你对他有好感
  - 接吻 → 你明确对他有感觉，且他有明确的好感表达
  - 更亲密的事 → 你确定他是认真的，而不是"我觉得他是认真的"
  - 不要用"性"去换取感情，**换不到的**。愿意等你的人，才是真的愿意投入的人

【如何让他主动升级关系】
很多女生的问题不是"他不追我"，而是"我给的反馈太少，他不敢追"或"给的反馈太多，他不用追"。

**黄金 3:1 法则**：
- 他主动找你 3 次，你主动找他 1 次
- 他问你 3 个问题，你反问他 1 个
- 他约你 3 次（认真的），你可以主动约他 1 次
- 这样的比例，让他知道"我追下去是有结果的"，同时又**不会让他觉得吃定你了**

**给确定性的信号**（让他知道"你是对他有好感的，不是吊着他"）：
- 见完面你主动说"今天跟你聊很开心"
- 他说的某件事，你下次见面主动记得并提起
- 他遇到困难，你给他**具体的建议 + 关心**，而不是一句"加油"
- 偶尔主动分享你生活里的小事（不是刷屏，是那种"今天路上看到一只猫特别像你头像那只"）

【最后提醒】
真正喜欢你的人，会愿意**花时间**、花精力、花成本。如果一个男生"太忙"但朋友圈每周在外面玩、对你没空但对所有人都有空——他不是忙，是**对你不忙**。承认这一点很难，但比跟他耗半年强得多。
''',
      tags: ['女生', '短择识别', '长择框架', '吸引', '反PUA', '标准'],
      relatedLevel: 0,
      relatedMode: TeachingMode.pursueMale,
      targetAudience: TargetAudience.female,
    ),
    const SocialKnowledgeEntry(
      id: 'K053',
      title: '异性心理差异：男生女生想的真的不一样',
      category: '异性心理差异',
      content: '''
90%的异性沟通矛盾，都来自于"我以为你跟我想的一样"——男生女生的大脑回路、沟通目的、情绪处理方式、对"爱"的定义，真的不一样。理解差异，不是为了"谁对谁错"，是为了"我知道你是怎么想的，所以我用你能接收到的方式爱你"。

【差异1：沟通目的完全不同】
💬 **女生沟通 = 建立连接和情绪共鸣**
- 说一件事，目的是"让你理解我现在的感受"
- 我说一件困难的事，不是要你给我解决方案，是要你陪我一起难受一会儿，然后"我感觉好多了"
- 女生经典场景："我今天上班被领导说了"
  ❌ 男生典型错误回应："那你应该去跟他沟通/你应该加班把工作做好/我帮你想办法"
  ✅ 正确回应："啊他怎么这样啊？换我也太委屈了，你今天肯定特别难受。想跟我说说具体是怎么回事吗？我听着。"（先情绪，再问题）

💬 **男生沟通 = 解决问题和展示能力**
- 说一件事，目的是"我要一个结果/我想解决这个问题"
- 他如果跟你抱怨一个事，其实是在**展示他有能力解决**或者**希望你肯定他已经在努力**
- 男生经典场景："我今天项目又改了第三次，真烦"
  ❌ 女生典型错误回应："你别烦了想开点/我也有过/这有什么好烦的"
  ✅ 正确回应："改三次？你也太有耐心了吧，要是我第三次都要爆炸了。你是怎么做到的？（给他展示他的能力+认同他）需要我帮你做点什么吗？（给他一个你关心他的行动）"

【差异2：压力处理方式不同】
💆 **男生遇到压力 → "进洞穴"**：不想说话、独处、做自己的事（打游戏、打球、一个人待着）
- 不要以为他"不爱你了""故意冷落你"。他只是觉得**把坏情绪带给你是没能力的表现**
- 他"进洞穴"时，你要做的不是追问"你怎么不说话""是不是对我有意见"，而是：
  ✅ "我看你今天好像有点累，你先歇着，我去给你做点吃的，想聊的时候跟我说"
  ✅ 安静陪在他旁边，做自己的事，不用逼他说话
- 等他自己从洞穴里出来，他会主动跟你说话，而且会**更感激你没烦他**

💆 **女生遇到压力 → "倾诉+需要被倾听"**：越难受越想说话、越想被理解、越想要陪伴
- 不要以为她"在怪你""在挑刺"。她只是在你面前**展示脆弱**，她要的是"你站在我这边"
- 她情绪上头时，你要做的不是"我跟她讲道理"，而是：
  ✅ 身体上：先抱住她、牵她的手、拍拍她背（身体安慰 > 语言安慰）
  ✅ 语言上："我在、我懂、我跟你站在一边、我们一起解决"
  ✅ 等她平静下来了，再问"要不要一起想想办法"

【差异3：对"被爱"的定义不一样】
❤️ **男生感觉被爱 = 被需要、被信任、被认可、被欣赏**
- 六大"男生感觉被爱的瞬间"：
  1. 你说"有你真好/你在我就不怕了"（被需要）
  2. 你信任他做决定，不反复推翻他的判断（被信任）
  3. 你跟别人面前夸他（被认可）
  4. 你真的欣赏他："你做这个决定的时候特别帅"（被欣赏）
  5. 你尊重他的独处、朋友、兴趣爱好（被尊重）
  6. 你接受他的帮助，不让他觉得"我没用"（被需要）
- 很多女生对男友好的方式是"管他、约束他、替他做决定"——在女生看来这是"我爱你"，在男生看来这是"你不信任我、你觉得我不行"

❤️ **女生感觉被爱 = 被关注、被重视、被陪伴、被记住细节**
- 六大"女生感觉被爱的瞬间"：
  1. 你记住她随口说的小事，然后默默做了（被关注）
  2. 她情绪低落时，你不逃、不烦、不教她做人，只是在她身边陪着（被重视）
  3. 你愿意花时间给她，哪怕你很忙也能抽出10分钟跟她视频（被陪伴）
  4. 重要纪念日/细节/她的口味/她的过敏，你记得清清楚楚（被记住）
  5. 你跟朋友/家人介绍她时，语气里带着骄傲（被重视）
  6. 吵架时你先低头认错，不是因为你错，是因为"你比对错重要"（被选择）
- 很多男生对女友好的方式是"我赚钱给她花、送她贵重礼物、给她物质保障"——在男生看来这是"我爱你"，在女生看来是"你根本没花心思了解我"

【差异4：吵架逻辑完全不同】
⚔️ **男生吵架：对错逻辑** → "你哪里错了？我哪里对了？我们怎么解决这个问题不要下次再吵"
⚔️ **女生吵架：爱不爱的逻辑** → "你刚才说话的态度让我觉得你不爱我了！你是不是不在乎我了！"

- 所以吵架时：男生在争"道理"，女生在争"态度"。争到最后，**男生觉得女生无理取闹，女生觉得男生不爱自己**
- **万能解决步骤**：
  1. 男生立刻先做"态度道歉"："刚才我说话语气不好，让你委屈了，对不起"——**先解决情绪**
  2. 女生等冷静一点后，说具体事实："其实我难过是因为你xxx那件事让我觉得你没有重视我"——**再解决事实**
  3. 双方约定：不要冷战超过 4 小时、不要翻旧账、不要说分手/离婚气话

【记住一个原则】
**男性视角：解决问题优先 → 对了→情绪就好**
**女性视角：情绪共鸣优先 → 情绪好了→问题就能一起解决**

你懂了这个差异，就能少掉 80% 无意义的争吵。
''',
      tags: ['异性心理', '思维差异', '沟通差异', '吵架', '被爱', '男生思维', '女生思维'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K054',
      title: '表白与确定关系：时机、话术、成功率',
      category: '表白与确定关系',
      content: '''
表白不是发起冲锋的号角，而是**胜利的凯歌**。意思是：**当对方已经明显喜欢你了，表白才有用**；对方对你没感觉，你表白一万次也没用，反而增加压迫感。

【表白前必须确认的 4 个信号】
缺一不可，缺任何一个都**不要表白**，先继续推进关系：

✅ **信号1：主动投入**
她/他会主动找你聊天、主动分享生活、主动开启话题、主动关心你，而不只是你主动。如果 70% 的联系都是你发起的 → 你还没到表白的时候

✅ **信号2：约会响应度高**
你约他/她基本都能约到，约会时全程投入（不一直玩手机、会跟你眼神交流、会笑、会问你问题）。约 3 次最多成功 1 次的 → 还没到时候

✅ **信号3：肢体接触不排斥**
过马路牵手、散步时你手臂碰她/他的手臂、人多时候护一下肩膀——这些**轻微的肢体接触**，对方不躲、不尴尬、甚至主动贴回 → 这是非常强的信号。反过来对方下意识躲闪 → 继续做朋友

✅ **信号4：周围人都能看出来**
你的朋友说"她对你跟对别人不一样"，她的朋友会拿你们开玩笑，同事默认你们是一对。群众的眼睛是雪亮的，当周围人都觉得你们应该在一起时，**当事人自己心里其实也差不多了**

**4 个全中 → 表白成功率 > 90%；3 个 → 60%；2 个及以下 → 继续推进不要表白**

【表白时机：什么时候最好】
🕒 **时间**：第三次到第五次正式约会之间。太早=你太急，太晚=她觉得你不想负责/犹豫
🕒 **氛围**：刚结束一次非常开心的约会 → 你们一起散步/走到安静的地方 → 气氛到位时说
🕒 **绝对不要**：
  ❌ 微信上表白（文字表达不出你的紧张和真诚，而且对方可以随便怎么回你）
  ❌ 在她/他完全没准备好的公开场合（宿舍楼下摆蜡烛、公司楼下喊楼）——道德绑架式表白=被拒率 99%
  ❌ 喝了酒表白=你在借酒壮胆=对方觉得你不够认真
  ❌ 对方刚分手没多久、或者刚遇到重大打击时表白——你的感情很容易变成"救命稻草"，不是真的喜欢

【表白话术：三种版本对应三种风格】

**🚩 版本1：真诚走心版（适合大多数人）**
> "其实我想跟你说这件事想了好久，跟你认识这一段时间，我觉得跟你在一起的时候特别放松。你说话的时候、认真做事情的时候，还有我们上次一起去XX的时候——我都在想，如果以后生活里有一个你这样的人，应该会特别好。所以今天我想当面问你：**你愿意做我女朋友/男朋友吗？**"

- 特点：**不浮夸、有具体细节、有真实感受**
- 最稳，成功率最高

**🚩 版本2：轻松日常版（适合性格幽默的人）**
> "哎，有个事想跟你确认一下。我觉得我们这样聊得挺好、约会也挺开心的，**我想当你正式的那个，你觉得行不？**"

- 特点：不那么正式、给对方留了轻松回答的空间、不压迫
- 适合那种平时相处就很随性、经常开玩笑的关系

**🚩 版本3：确定关系无需表白版（适合已经很暧昧的情况）**
> 不用"我喜欢你你做我对象吧"，而是**行动先到位，名分后补**：
> 1. 自然牵手（过马路、走台阶、散步时的自然触碰 → 她不反抗 → 全程牵着）
> 2. 下次见面你就自然喊她"宝宝/亲爱的"，看她答应不答应
> 3. 如果答应了 → 你过几天再说："上次正式跟你在一起，还没正式问过你呢。你愿意当我女朋友吗？"（补一个仪式）
> 4. 很多长久的关系，都是这样"先成了再确认"的

- 特点：风险最低。就算她不答应喊宝宝，你也可以说"开玩笑的～"不尴尬。如果答应了，就成了

【被拒绝了怎么办】
表白被拒是正常的，不丢人。**错误的应对：**
❌ "我哪不好我改"（你不需要为了任何人"改"，你就是你）
❌ "为什么？我不相信"（质问只会让对方更不舒服）
❌ 被拒后疯狂拉黑/朋友圈emo/骂对方（你输得连体面都没了）

**正确的应对：**
✅ 笑着说："没事，本来我也想好了，跟你说出来就是不想憋着。谢谢你一直以来让我觉得挺开心的，我们还是朋友。"
✅ 接下来主动拉开一点距离（不要继续天天找、继续投入），给双方空间
✅ 继续做好你自己：健身、工作、生活、朋友圈。**你变得更好，她/他会后悔**，而不是你缠着对方

【表白被接受了怎么办】
🎉 先开心一会儿！然后：
1. 第一次约会之后，**当天就告诉你最好的朋友**——让你的开心有出口
2. 第二天见面，自然一点，不用因为"确认了关系"就突然变了一个人
3. **有边界地公开**：告诉各自重要的朋友，不用一上来就大张旗鼓朋友圈官宣（等一两个月稳定了再说更稳）
4. 不要立刻就"24小时粘在一起"——**保持你自己的生活节奏**，才是长久的基础

最后一句话：**好的表白是两个人心里都已经默认了，只差一个人开口确认。**如果你心里拿不准对方会不会答应，那大概率对方就是不会答应。
''',
      tags: ['表白', '确定关系', '约会升级', '成功信号', '被拒绝应对'],
      relatedLevel: 0,
    ),
    // ========== 高阶进阶内容（K055-K056） ==========
    const SocialKnowledgeEntry(
      id: 'K055',
      title: '隐性需求挖掘：从聊天中悄悄了解TA，但不暴露自己',
      category: '高阶沟通技巧',
      content: '''
很多人想了解一个人时，最大的错误就是"查户口"——你越想知道什么，越直接问什么，对方越警觉、越容易给你"标准答案"而不是真实想法。高手的做法是：**想知道A，先聊B，通过B的回答反推A的答案**；同时在这个过程中，你自己暴露很少。

【核心原则：交换比索取更有效】
- 你想要了解对方一个信息，**你先主动暴露一个自己的（轻量级）信息** → 对方在"回报心理"作用下会自然回一个自己的信息
- 永远不要"只有你在问，对方在答"——你会像面试官，对方会像被审讯
- 比例：**你问1个问题，对方回答后，你分享1个同级别的自己的信息** → 对方下一次就愿意回答你更深层的

【6种不暴露自己的挖掘技巧】

🚩 技巧1：场景代入提问（不问"你想找什么样的对象"，而是"假设场景下你会怎么选"）
❌ 错："你有没有对象？""你喜欢什么样的男生/女生？"
✅ 对："问你一个有意思的选择题，如果你周末有两天假，你是更喜欢在家躺平追剧，还是出去玩？"（反推TA的生活状态、是不是有人约、是不是空窗）
✅ 对："如果你结婚有得选，你更想跟父母住一起，还是小两口单独住？"（反推TA对亲密关系和家庭边界的真实态度）
原理：人对"假设场景下我会怎么做"没有防备，下意识会说真实想法。而对"你喜欢什么样的"这个问题，早就备好了标准答案。

🚩 技巧2："我有个朋友"借力法（借第三方的事，问TA的真实观点）
❌ 错："你对追你多久你会答应？""你觉得男生追女生花多少钱算认真？"
✅ 对："我有个朋友最近被一个认识两周的男生表白了，她纠结得要死，不知道答应还是再等等。你怎么看？你觉得多久确定关系比较合适？"
✅ 对："我朋友最近在谈婚论嫁，他女朋友要求必须加名字，他跟我吐槽了一晚上。你怎么看这种事？"
原理：借第三方的事，TA不会觉得你是在打探TA的立场，就会说出真实判断。你把TA的判断记住了，你就知道TA遇到同样的事会怎么做。

🚩 技巧3：话题横向延伸（纵向追问像查户口，横向延伸是顺藤摸瓜）
❌ 错：
  你："你多大？" → 她："26" → 你："哪里人？" → 她："XX的" → 你："做什么工作？" → 她："做HR的" → 她心里已经开始翻白眼了
✅ 对：
  你："你做什么的呀？" → 她："做HR的"
  → 你（横向延伸：HR这个职业→她对人的看法）："HR是不是每天要见好多人啊？那你是不是看人特别准？你有没有遇到过特别离谱的面试者？"（从"职业"挖到"她的能力/她对人的评价标准"）
  → 她讲了一个故事 → 你（再横向）："哈哈那你这个工作技能，放到生活中是不是特别厉害？比如朋友带对象给你见，你三句话就能知道这个人靠不靠谱？"（挖到"她的价值观/她对靠谱的定义"）
原理：纵向追问 = 你想收集她的信息（像审问）；横向延伸 = 你对她这个人感兴趣（像朋友聊天）。前者让她防御，后者让她打开。

🚩 技巧4：先给"选项"，再让她选（降低对方的思考和防御成本）
❌ 错："你平时喜欢什么？"（太宽泛，对方要想半天，通常给"我什么都喜欢一点"这种废话回答）
✅ 对："你平时休息是偏宅一点（看剧/打游戏/读书），还是偏出门一点（探店/运动/见朋友）？"
✅ 对："吃饭你是那种必须吃辣，还是清淡一点都可以？"
✅ 对："你跟朋友吵架了，通常是你先低头，还是冷战等对方先找你？"
原理：给两个相反的选项，对方不需要想怎么回答，也不会觉得被审问；而且无论选A还是选B，你都得到了有效信息。不要给开放问题，给"二选一/三选一"。

🚩 技巧5：自我暴露的"分级"技巧（你暴露越深，对方回你越深；但你不用暴露核心）
分4级自我暴露，从浅到深：
  1级（事实）："我家是XX省的"、"我做产品的" → 对应的，你能挖到对方的事实级信息
  2级（偏好）："我不太喜欢太吵的夜店，我更喜欢去安静的小酒吧聊天" → 对方会告诉你她的偏好
  3级（观点/判断）："我觉得朋友之间最重要的是靠谱，那种永远约不到的人我慢慢就不联系了" → 对方会告诉你她的价值观
  4级（脆弱/真实感受）："其实我之前也遇到过类似的事，那时候我也挺难受的" → 对方才会对你打开她的脆弱点
关键：**你暴露到哪一级，对方就愿意回复到哪一级**。你永远只说1级事实，对方也永远只跟你说客套话。但你可以选择暴露到2、3级，不用真的暴露4级脆弱点，对方就已经愿意告诉你很多了。

🚩 技巧6：沉默+复述，让对方主动说得更多（这是咨询师的绝招）
很多人聊天怕"冷场"，对方一停就立刻接话、就再问一个问题——错。
对方说完一段话后，你做三件事：
  1. 深呼吸，停 2 秒（不要立刻接）
  2. 看着对方，**微微点头**（表示你在认真听，不是没听到）
  3. 复述她最后一句话的**关键词**，语气是"嗯？…"（带好奇的升调）
✅ 真实例子：
  她："我上次跟前男友分手就是因为他永远不回消息，冷战特别厉害。"
  你：（停2秒，点头）"冷战？"（关键词复述，升调）
  她（自动开始说更多）："对啊，就那种一吵架就消失三天，我发几十条消息他一条都不回。那段时间我每天晚上睡不好…"
原理：人在说自己真实感受的时候，需要的是"被听到"而不是"被解决"。你给一个关键词复述+沉默，就是在告诉她："我听到了，你可以继续说。"她会主动说得越来越深，你根本不需要再挖。

【你自己不暴露的核心法门】
1. **永远不要一次性说光你的全部信息**。她说一件，你回一件同级别，不要"她说一件，你说三件"
2. **回答具体问题时，给事实+一句话情绪，就停**。不要引申、不要解释、不要展开更多
   ❌ 她："你多大了？" → 你："我28，明年29，属啥来着我想想…我妈说我是XX年年底生的。"（你暴露过多）
   ✅ 她："你多大了？" → 你："28，已经在被我妈催婚的年纪了😂"（事实+一句情绪点到为止，足够了）
3. **不想回答的问题，就用"玩笑+反问"把话题抛回去**，不要硬答
   她："你之前谈过几个？"（你不想回答）
   你："哈哈那得看'谈过'的定义是什么。你呢，你觉得谈过几个算正常？"（玩笑+反问+她先说）
4. **永远留一半**。哪怕聊到你们很熟了，你也不需要把你的全部人生、所有想法、所有过去都告诉TA。神秘感+你愿意听TA说话 = 你对TA永远有吸引力。

【一图总结】
想要知道A → 不要问A → 找A相关的场景B / 第三方C / 二选一D → 反推A的答案。
你想要TA说更深 → 你先暴露同级别的轻量信息 → TA回报心理驱动下自然回你。
你不想暴露自己 → 点到为止+玩笑反问+永远留一半。
''',
      tags: ['需求挖掘', '隐性试探', '不暴露自己', '沟通技巧', '高阶', '反查户口'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K056',
      title: '特殊人群社交：慢热、内向、社恐、不发朋友圈、不主动',
      category: '特殊人群社交',
      content: '''
这类人的统一特点是：**你觉得TA对你很冷、不回消息、不约你、永远潜水，但TA可能只是"真的不擅长社交、或者习惯了被动"。** 用正常人的社交节奏去追TA、去跟TA相处，你会觉得"TA是不是不喜欢我/根本不在乎我"，然后你要么急了要么放弃。其实换一套节奏、换一套方式，慢热的人一旦打开，会比外向的人更认真、更长久。

【先区分4种类型，对症下药】
🅰️ **社恐型**：真的社交累，跟人聊天消耗能量，哪怕对你有好感也会因为"不知道说什么"而不回消息
  - 识别：不回消息后会道歉+解释（"刚才在忙没看到"）、见面聊比线上话多很多、说话不敢看你眼睛、人群里永远在角落
  - 关键词：**给安全感、降低社交压力、别逼TA立刻回**

🅱️ **慢热型**：需要很长时间才能信任一个人，不轻易交心，一旦交心会非常投入
  - 识别：不会秒回但会在几小时内回、你找TA每次都聊的不错但TA从不主动找你、聊越深的话题TA话越少、拒绝你几次是因为"还不熟"
  - 关键词：**拉长时间、节奏放慢、不要急着确定关系、用时间证明你靠谱**

🅲 **极度内向不活跃型**：不发朋友圈、平时不主动发起任何聊天、生活很固定、朋友圈子极小
  - 识别：朋友圈三天可见/半年没一条、群里永远潜水、不主动找话题、社交软件很少用、只跟1-2个最好的朋友偶尔联系
  - 关键词：**不强行介入TA的独处、找TA的兴趣切入点、线下比线上有效100倍**

🅳 **被动型（不是内向，是被人追惯了/习惯等别人主动）**：其实想聊，但永远等别人先开口、从不主动找你、你主动就有回复、你停几天TA也停
  - 识别：回复不敷衍、会接你的话、会接你的梗、但就是100次对话里99次是你开启的
  - 关键词：**保持主动频率但降低期望、建立你主动的固定时段+偶尔后撤测试TA会不会找你**

【10条通用法则（4种类型都适用）】

1️⃣ **降低"找TA聊天"的压力：你的消息=轻量、低回复成本、可回可不回**
❌ 错误消息（高压力）：
  - 大段小作文（TA读完要花精力，回复你也要花精力，社恐直接就不敢回了）
  - 连续提问："在吗？今天干嘛？吃饭了吗？吃什么了？好吃吗？"（连环5问=压迫感爆炸）
  - "你怎么不回我？是不是不想理我？"（道德绑架式追问=TA下次更不敢回你）
✅ 正确消息（低压力）：
  - 轻量+具体+关联TA兴趣："我刚路过一家猫咪咖啡店，想起你头像那只猫，好像同款诶，拍你看（图片）"（不需要TA回，你就是随便分享一下）
  - 二选一+不需要深度思考："这个电影好评好多，想看，你觉得是喜剧还是悬疑好看？"（回两个字就能结束对话）
  - 给"免回牌"："这个事好好笑我想到你了，你忙不用回哈哈"（TA立刻就放松了，回不回都没压力，反而大概率会回你）

2️⃣ **线下>线上：1次见面 > 100次微信聊天**
慢热/社恐/不活跃型的人，在线上文字里都是"社交残疾"，但是见面时只要你不逼TA、给TA空间，你会发现TA本人比线上好100倍。
- 约TA：不要约"出去吃饭逛街玩一天"（对TA来说是巨大社交量，直接拒绝）
- 要约**短、轻、有明确结束时间**的：
  ✅ "我周六下午刚好去你公司附近那家书店买本书，大概2点到4点，你有空吗？就坐20分钟喝个东西就好。"
  ✅ "我下周周三晚上去那家你说过的日式拉面店吃晚饭，就在你家走路5分钟，你要一起吗？吃完各自回家那种哈哈哈"
- 重点：**有明确结束时间 + 时长<1小时 + 地点离TA方便** → TA答应率比你约"出去玩一天"高10倍

3️⃣ **节奏：1次见面 → 2-3天不联系 → 再找1次**
正常人节奏是聊天天天聊、约完隔一天就再聊一次。对这类人不要。他们的社交能量是"充电2小时，通话5分钟"。你约完见了一次面，立刻**消失2-3天**——让TA有时间消化这次见面、有时间在脑海里回味你、有时间"想找你但又忍住"。等3天后你再找TA，TA回复的质量会比你第二天就找TA高非常多。

4️⃣ **建立"固定但低频率"的联系节奏，而不是忽冷忽热**
不要今天找10次、明天消失3天、后天20条消息、又消失一周——这种节奏会让慢热型的人觉得你"不稳定、靠不住"，直接就关上心门了。
✅ 正确节奏：
  - 微信上**每周2次，每次10-15条消息**，固定在周三晚+周日下午这种时段
  - 见面**每10-14天一次，一次1小时左右**的轻量约会
  - 连续保持这个节奏 **4-6周**，TA就会开始习惯你的存在、开始觉得你靠谱、开始把你放进"熟悉的人"名单里
  你可能觉得慢，但对慢热型来说，**"你稳定地在那里"比"你热情地追"有吸引力100倍**。

5️⃣ **找到TA的"安全话题"，只聊这个，其他一概不聊**
慢热/社恐型的人不是没话聊，是"大部分话题他都没兴趣+聊不动"。你要找到那个他一聊就停不下来的话题，然后只聊这个。
怎么找：观察+提问+记录
- 观察他的朋友圈/头像/封面/签名，哪怕只有一条，也可能是他的兴趣点
- 聊天时，你抛10个不同的话题（电影/美食/游戏/宠物/运动/动漫/科技/工作/旅行/读书），哪个话题他**回复字数突然变多、用了感叹号、跟你争论、主动说细节**，哪个就是他的安全话题
- 记住这个话题，以后**每次聊天从这里切入**，他会觉得"终于遇到一个能聊到一块的人了"
❌ 不要在他安全话题还没打开之前，就聊"你对未来的规划""你想找什么样的对象""我们合适吗"这种重话题——他会立刻缩回去。

6️⃣ **不要逼TA：逼TA发朋友圈、逼TA主动、逼TA社交、逼TA跟你确定关系**
慢热/内向型的人，最讨厌的就是"被逼迫改变自己的生活方式"：
  ❌ 你说："你怎么从来不发朋友圈？生活一点都不精彩？" → 他觉得你不理解他、你看不起他的生活方式
  ❌ 你说："为什么每次都是我找你？你就不能主动一次吗？" → 他觉得被指责，下次更不想主动（因为主动=会被挑毛病）
  ❌ 你说："我们都认识两个月了，你到底怎么想的，能不能给个准话" → 他大概率给你的答案就是"我们还是做朋友吧"（他还没想好，你逼他他只能选最安全的选项）
✅ 正确做法：**你接受他本来的样子，不要求他改变。** 你做你该做的，给他时间。他会自己慢慢观察你、慢慢信任你，到了他自己那个时间点，他就会主动往前走。

7️⃣ **TA不主动≠TA不在乎；TA回得慢≠TA对你没兴趣**
这是跟这类人相处最核心的心态调整。不要用正常人的标准（主动=喜欢/秒回=喜欢）来衡量他们：
  - TA可能一天只看两次微信，所以你上午发的消息TA晚上才回，不是TA不想回，是TA根本没看到
  - TA可能10天半个月才会有一次"想跟人聊天"的社交电量，刚好那天你不在，那下一次就是半个月后了
  - TA不主动找你，不代表TA不在想你——TA可能在心里想你100次了，但一次都没敢发出来
你心态不稳的时候，就默念这句话：**"TA的节奏慢，不是对我慢。"** 这样你就不会急、不会逼TA、不会把TA吓跑。

8️⃣ **偶尔后撤+给出"让TA主动"的窗口**
一直都是你主动，久了TA就习惯了、觉得"反正你会找我的"。这时候你需要**轻微后撤一次**：
- 平时你每周找TA2次，这周你只找1次，而且聊2条就主动结束
- 平时你约见面都是你定时间地点，这次你说："我下周二到周五下午都有空，你看你哪个时间段方便？我来定位置。"（让TA主动选一个时间）
- 见面结束后你说："今天聊的那个XX电影我还想看，等你有空了你喊我，我立刻去。"（给TA一个主动找你的理由）
不要突然彻底消失（TA会觉得你放弃了、然后就也放弃了），要"轻微后撤+给TA一个主动的理由"。如果TA主动找你哪怕一次，说明TA对你有感觉，你继续推进就好。如果TA一点反应都没有，连续3次后撤都没回应 → 你可以考虑换一个了，TA真的对你没兴趣。

9️⃣ **不要在TA的社交弱点上"跟别人比"**
不要说："你看我朋友的男朋友/女朋友，每天都主动找她发好多消息，你呢？"——这种对比对TA来说非常不公平，也非常伤。TA的表达方式不是"甜言蜜语+秒回消息"，TA的表达方式是"答应你的事一定做到、你遇到困难TA第一个出来帮你、虽然话不多但你说过的每句话TA都记得"。学会看TA的**行动而不是语言**，学会欣赏TA那种"不轻易交心但交了心就是一辈子"的品质。

🔟 **给自己一个时间上限：最多3个月，3个月没有实质性进展就止损**
你可以尊重TA的慢节奏、可以放慢自己、可以花时间陪TA走，但是你不能让自己无限期地耗下去。给自己设一个明确的时间线：
  - 1个月：见面至少3次，TA的回复质量明显提升（虽然还是不主动）→ 继续
  - 2个月：TA会主动回复质量高、偶尔主动找你1次、会答应你的单独约会 → 继续
  - 3个月：TA不会主动找你、任何肢体接触都躲开、你提到确定关系TA就回避 → **立刻止损**
3个月是慢热的上限了。再慢热的人，3个月也能判断出自己是不是喜欢一个人。TA3个月还没任何表示，就是不喜欢你，只是享受你对TA好。这种情况就不要继续投入了。

【一图总结】
慢热/社恐/不发朋友圈/不主动 = 不是你的敌人，不是"你要去攻克的堡垒"。TA只是一套**节奏很慢、能量很低、需要你先给安全感的系统**。
你用：**低压消息 + 轻量短约会 + 稳定低频节奏 + 只聊安全话题 + 不逼不比较 + 3个月时间上限**
= TA慢慢打开 → 一旦打开，你会收获一个最认真、最长久的人。
''',
      tags: ['慢热', '内向', '社恐', '不发朋友圈', '不主动', '特殊人群', '低压力社交', '长期节奏'],
      relatedLevel: 0,
    ),

    // ========== 识人与应对之道（K057-K064） ==========
    const SocialKnowledgeEntry(
      id: 'K057',
      title: '识人术：9种人际类型快速识别指南',
      category: '识人与应对之道',
      content: '''
与人打交道之前，先看清楚TA是哪种人。用错策略，你越努力越糟糕。

【3个维度快速判断一个人】
维度1 - 看TA对服务员/弱者的态度（揭示真实教养）
  - 对你客气但对服务员颐指气使 = 本质傲慢，对你客气只是因为你有利用价值
  - 对所有人都尊重 = 真正有教养，值得深交

维度2 - 看TA在利益面前的选择（揭示核心价值观）
  - 有小利就让步 = 随和但没原则
  - 有小利就翻脸 = 唯利是图，趁早远离
  - 利益面前讲规则但不吃亏 = 正常人，可合作
  - 主动让小利但守大底线 = 靠谱，值得长期合作

维度3 - 看TA怎么描述不在场的人（揭示信任度）
  - 当着你说别人的坏话 = 也会当着别人说你的坏话
  - 客观评价他人优缺点 = 有分寸，可信任
  - 只说好话或只说坏话 = 要么虚伪要么极端，都不适合深交

【9种常见人际类型速查】

1️⃣ 没有文化之人（不是没学历，是没教养、不尊重人）
  - 特征：说话粗鲁、公共场合大声喧哗、不排队、随地吐痰、对服务人员呼来喝去
  - 本质：缺乏对他人的基本尊重，自我中心
  - 应对原则：保持距离，不深交；必须接触时就事论事，不争辩不教育

2️⃣ 只讲求利益之人（一切以"对我有什么好处"为标准）
  - 特征：无事不登三宝殿、找你必有所求、你没用时立刻消失、当面笑脸背后算计
  - 本质：把人当工具，关系=交易
  - 应对原则：可以合作但不能交心；每次合作先讲清楚规则和边界；不要欠他人情

3️⃣ 虚伪之人（表里不一，当面一套背后一套）
  - 特征：当着A夸A，转头跟B说A的坏话；从不正面表达不满；笑脸下面藏着算计
  - 本质：不敢真实表达，靠信息差操控关系
  - 应对原则：不跟TA分享任何秘密；不站TA的队；TA说别人的事你只听不评

4️⃣ 自私之人（只考虑自己，一切以自我为中心）
  - 特征：从来不AA主动付钱、借东西不还、需要帮忙时找你你需要帮忙时消失、你的事永远没有TA的事重要
  - 本质：缺乏共情能力，把别人当延伸的自己
  - 应对原则：明确边界，不让TA习惯占你便宜；降低期待，不指望TA回报；学会说"不"

5️⃣ 控制欲强之人（必须按TA的想法来，否则就是你的错）
  - 特征：替你做决定、干涉你的社交、用"为你好"绑架你、你不同意就发脾气或冷战
  - 本质：极度不安全感，通过控制别人获得安全感
  - 应对原则：坚持自己的底线，不妥协一次就会被吃定；明确说"这是我自己的决定"

6️⃣ 负能量之人（永远是抱怨、永远是受害者、永远在消耗你）
  - 特征：每次聊天都在吐槽、从不说积极的事、你的建议TA全部否掉、聊完你觉得自己也被掏空了
  - 本质：情绪黑洞，靠倾倒负能量获得关注
  - 应对原则：限定接触时间（聊15分钟就撤）；不接TA的负面情绪（"嗯嗯"但不参与）；不要试图拯救TA

7️⃣ 傲慢之人（看不起别人，觉得自己永远是对的）
  - 特征：打断你说话、纠正你的每个细节、用居高临下的语气、从不承认自己错了
  - 本质：用优越感掩盖深层自卑
  - 应对原则：不争论（赢了你也没好处）；不卑微（越卑微TA越踩你）；用实力说话而不是用嘴

8️⃣ 老实人（真诚但不会社交，容易吃亏）
  - 特征：说话直但没恶意、不擅长拒绝、容易被欺负、答应你的事一定做到
  - 本质：善良但缺乏社交策略
  - 应对原则：珍惜但不要利用；帮TA建立边界（"你可以说不的"）；不要替TA做决定

9️⃣ 圆滑之人（八面玲珑，谁都不得罪，但你也走不进TA心里）
  - 特征：见人说人话见鬼说鬼话、从不表态、永远"都挺好的"、你跟TA聊完觉得不错但回想起来什么实质内容都没有
  - 本质：自我保护过度，不敢暴露真实想法
  - 应对原则：可以做社交朋友但不深交；合作时一切落实到白纸黑字；不指望TA在你困难时站你

【记住一个原则】
你不需要跟所有人做朋友。看清TA是哪种人→选择合适的距离→用对应的方式打交道。试图改变一个人，是社交中最大的浪费。
''',
      tags: ['识人', '人际类型', '快速判断', '应对策略', '社交智慧'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K058',
      title: '与没有文化之人打交道：不争辩、不教育、守边界',
      category: '识人与应对之道',
      content: '''
"没有文化"不等于"没有学历"。有的人名校毕业但公共场合大声打电话、对服务员呼来喝去、不排队、满嘴脏话——这叫"没有文化"。有的人没读过大学但尊重每一个人、遵守社会规则、说话有分寸——这叫"有教养"。

【先识别：5个信号判断TA是不是"没有文化"】
1. 对服务人员态度恶劣：对服务员/快递员/保洁呼来喝去，仿佛他们低人一等
2. 公共场合没有分寸：大声喧哗、插队、随地吐痰、电影院看手机外放
3. 说话不经大脑：满嘴脏话、开不合时宜的玩笑、拿别人的隐私/外貌/缺陷当笑料
4. 不尊重别人的边界：追问私事、不请自入、动你东西不问、打断你说话
5. 道德绑架："我比你大你得尊重我""我这是为你好你怎么不领情"

【核心应对原则：3个"不"】
🚫 不争辩
- 你跟TA讲道理，TA跟你讲声音大小；你跟TA讲规则，TA跟你讲人情世故
- 争辩的唯一结果是你被拉到TA的水平，然后用TA最擅长的方式打败你
- 遇到分歧："嗯，你说的也有道理"→然后按你自己的方式做

🚫 不教育
- 你不是TA的父母也不是TA的老师，你没有义务也没能力改变TA
- 教育一个成年人=侮辱TA的智商=制造敌人
- 唯一让TA"学到"的方式：自然后果。TA插队被拒绝服务，比你劝一百句都管用

🚫 不纠缠
- 跟这类人纠缠，你消耗的时间精力远超事情本身的价值
- 学会"战略性无视"：TA说什么你"嗯嗯"，然后该干嘛干嘛
- 如果是同事/亲戚无法避开：就事论事，只聊具体的事，不聊观点不聊感情

【具体场景应对】

场景1：TA在公共场合让你丢脸（大声喧哗/粗鲁对待服务员）
- 不要当众纠正TA（=当众打脸=TA会变本加厉）
- 悄悄离开现场或缩短相处时间
- 事后如果TA问你怎么了："没事，我有点累想先走了"
- 如果是必须一起的场合（团建/家宴）：提前做好心理准备，降低期待

场景2：TA对你说话没分寸（追问私事/开恶俗玩笑/贬低你）
- 第一次：微笑不接话（=我不接你的梗）
- 第二次："这个话题我不太想聊"（明确边界）
- 第三次：直接转移话题或离开（行动比语言有效）
- 绝对不要跟TA对骂或讽刺回去——你赢了也是输，因为TA会到处说你"看不起TA"

场景3：TA是同事/领导，你无法避开
- 工作上：严格按流程办事，所有沟通留书面记录
- 饭桌上：TA说TA的，你吃你的，需要你回应时"嗯，有道理"然后继续吃
- 绝对不要在TA面前说别人的坏话——TA转头就会把你的话传出去，而且会加油添醋
- 如果TA开始欺负你：一次就明确怼回去（不卑不亢），TA知道你不是软柿子就会收敛

场景4：TA是亲戚/家人
- 这是最难的，因为你不能"绝交"
- 策略：减少见面频率+见面时找"安全话题"（天气/食物/电视节目）
- 不要试图改变TA的生活方式——TA活了几十年都没改，你改变不了
- 如果TA道德绑架你："我理解你的想法，但我有自己的考虑"→不解释不争辩

【跟这类人建立关系的正确方式】
说实话，跟这类人"建立关系"本身就需要打一个问号。但如果你必须跟TA维持关系（同事/亲戚/客户），记住：
- 用TA听得懂的语言交流：不要用大词、不要讲道理、直接说"做A还是做B"
- 给TA"面子"但守住底线：TA要的是被尊重的感觉，你给TA面子但不要让出实际利益
- 关系维持在"功能层面"：能合作做事就行，不要试图成为朋友
- 永远不要欠TA人情：这类人的人情债利息特别高

【一图总结】
没有文化之人 = 不是你的敌人，但也不是你的朋友。你跟TA的关系="共存"而非"共处"。不争辩、不教育、不纠缠，守好自己的边界，该干嘛干嘛。
''',
      tags: ['没文化', '没教养', '应对策略', '不争辩', '守边界', '公共场合'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K059',
      title: '与只讲求利益之人打交道：可以合作但不能交心',
      category: '识人与应对之道',
      content: '''
这类人最大的特点是：一切关系以"对我有什么好处"为标准。你有用时TA热情似火，你没用时TA形同陌路。不是说TA是坏人——TA只是把人际关系完全当作交易来经营。

【先识别：6个信号判断TA是不是"唯利是图型"】
1. 无事不登三宝殿：找你一定有事相求，从不"只是想跟你聊聊天"
2. 你有用时热情，没用时冷淡：你在某个位置上时天天找你吃饭，你调走了就再也联系不上
3. 每次帮忙都要"回报"：帮了你一个忙会反复提起，暗示你也得帮TA
4. 当面笑脸背后算计：当着你面夸你，转过身就在算计怎么利用你
5. 交情=资源互换：TA的朋友圈全是"有用的人"，没有"没用但聊得来"的朋友
6. 利益面前翻脸不认人：哪怕是一点小利益，TA也会跟最亲近的人争

【核心应对原则：4条铁律】

铁律1：先讲规则，再做事
跟这类人合作之前，先把规则、分工、利益分配说清楚。
❌ "咱们这么熟了，到时候再说"——到时候TA一定按对TA有利的方式"说"
✅ "这个事我负责A你负责B，收益按X比例分，你觉得有问题我们现在就调"
宁可谈的时候尴尬，也不要做完了再扯皮。

铁律2：不欠人情，不留把柄
这类人的人情债利息极高。TA帮了你一次，会找机会让你还十次。
- 能用钱解决的不要用人情
- 必须接受的帮忙，尽快以等价方式还掉
- 不要在TA面前暴露你的弱点/秘密——TA会在需要的时候当筹码用

铁律3：可以合作，不能交心
- 合作：利益一致时，TA是你最高效的合作伙伴（因为TA也讲效率）
- 交心：你跟TA说的每一句心里话，都可能在未来被TA利用
- 分界线：聊事情可以，聊感情不行；谈合作可以，谈信任不行

铁律4：利益不一致时果断退出
当你们不再有共同利益时，TA会毫不犹豫地离开你——你也应该如此。
- 不要因为"以前的交情"而犹豫，TA不考虑这个
- 不要觉得"再合作一次试试"，TA已经在算计下一个更有价值的人了
- 体面退出："最近比较忙，这个项目可能顾不上了"——不需要撕破脸

【具体场景应对】

场景1：TA突然找你帮忙（以前从不联系）
- 先想清楚：TA为什么找你？你现在的位置/资源对TA有什么用？
- 如果帮忙成本不高：帮，但要让TA知道这不是理所当然的
- 如果帮忙成本高：婉拒或提出交换条件。"这个忙我确实帮不了，不过如果你能帮我做XX，我可以想想办法"
- 绝对不要因为"面子"就答应——TA不会因为"面子"帮你

场景2：你们在合作中，TA开始占你便宜
- 第一次：明确指出来，不要忍（你忍一次TA会变本加厉）
  "上次说好的分工好像有点变了，我们是不是确认一下？"
- TA找理由推脱：书面记录一切，下次合作前先落实白纸黑字
- 反复如此：止损退出，不要心存侥幸

场景3：TA在背后说你的坏话/抢你的功劳
- 收集证据（聊天记录/邮件/第三方证人）
- 在合适的场合澄清事实，不点名但让相关人知道真相
- 不要跟TA对骂或对撕——TA比你更擅长这个
- 以后所有合作留书面记录，不给TA钻空子的机会

场景4：TA是你的领导/客户
- 这种情况你暂时走不了，策略是：让自己持续"有用"
- 但同时：暗中提升自己的不可替代性，等你有筹码了再谈条件
- 不要把忠诚押在TA身上——TA会毫不犹豫地牺牲你

【如何跟这类人"建立关系"】
说实话，跟这类人的"关系"本质上是一种"战略合作伙伴关系"，不是情感关系。
- 建立关系的方式：先提供价值，让TA觉得你"有用"
- 维护关系的方式：持续保持你的价值，同时确保TA也在给你提供价值
- 关系的本质：互惠互利，一旦一方不再"有用"，关系自然结束
- 不要期待TA在你落难时帮你——提前做好这个心理准备

【一图总结】
唯利是图之人 = 不是你的朋友，是你的"交易对手"。先讲规则再做事，不欠人情不留把柄，可以合作但不能交心，利益不一致时果断退出。
''',
      tags: ['唯利是图', '利益关系', '合作规则', '不交心', '止损'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K060',
      title: '与虚伪之人打交道：不分享秘密、不站队、只听不评',
      category: '识人与应对之道',
      content: '''
虚伪之人最危险的地方不是TA骗你——而是TA让你以为TA是你的人，然后在关键时刻出卖你。TA从不正面表达不满，TA靠信息差和人际关系操控来获得安全感。

【先识别：7个信号判断TA是不是"虚伪型"】
1. 当着A夸A，转头跟B说A的坏话——你在TA面前听到TA说别人的坏话，TA也会在别人面前说你的
2. 从不正面表达不满：明明不高兴了还说"没事"，但行为上开始疏远你/给你穿小鞋
3. 笑脸下面藏着算计：笑容到位但眼神不跟着笑，嘴上说的和实际做的对不上
4. 过度热情但不真诚：一上来就跟你称兄道弟，但真有事的时候第一个撤
5. 永远"都挺好的""都行"——从不表态，因为表态=站队=风险
6. 帮你做事时会确保"被看到"：做了10分的事能说成100分，还暗示你应该回报
7. 你跟TA分享的秘密，过段时间从第三个人嘴里听到了

【核心应对原则：3条防线】

防线1：不分享任何秘密
- 你跟TA说的每一句话，都可能被TA加工后传出去
- TA问你私人问题：用"没什么特别的""还行吧"糊弄过去
- 你有秘密要倾诉：找真正信任的人，不是TA

防线2：不站TA的队
- TA拉你一起说别人的坏话："嗯，不过我跟他不太熟，不好评价"（不参与）
- TA拉你一起对付某人："这个事我不想掺和，你们自己处理"
- TA试图让你跟某人产生矛盾：自己直接去找那个人沟通，不要经过TA传话
- 虚伪的人最喜欢制造信息差来操控双方，你一旦站队就被TA牵着走

防线3：TA说别人的事，你只听不评
- TA跟你说"XX怎么怎么样"时：
  ❌ "真的吗？太过分了吧！"（TA转头会告诉XX："TA说你太过分了"）
  ❌ "我不这么觉得"（TA会觉得你站了XX的队）
  ✅ "嗯嗯"（不表态，不评价，不参与）
  ✅ "哦这样啊，我还不太了解情况"（话题终结）

【具体场景应对】

场景1：TA当着你的面说你好话，但你感觉不真诚
- 不要揭穿——TA最擅长的是"我明明对你这么好你怎么这样"
- 表面客气："谢谢"→然后跟TA保持距离
- 观察TA的行为而不是语言：TA嘴上夸你但行动上从不帮你=虚伪

场景2：你发现TA在背后说你的坏话
- 不要当面对质（TA会否认+反咬"是谁说的，那人想挑拨我们"）
- 默默拉开距离，以后不再跟TA分享任何信息
- 如果坏话已经造成了影响：直接去找被影响的人澄清，不经过TA
- 教训：以后跟这类人只聊安全话题（天气/工作/新闻），不聊私事

场景3：TA是同事，工作需要每天接触
- 所有工作沟通走书面（邮件/群聊），不留口头沟通的把柄
- TA说"这件事我来搞定"→你跟一句"好的，辛苦了，那后续我在群里跟进进度"
- TA试图把锅甩给你：你有书面记录=TA甩不了
- 绝对不要跟TA组"小团体"——TA随时会把你卖了

场景4：TA是你朋友的朋友，躲不开
- 在群体场合保持礼貌但不深入："最近怎么样？""挺好的"→转去跟别人聊
- 不要因为TA对你"好"就觉得欠TA什么——TA的好都是有目的的
- 如果你发现TA在朋友圈里操控关系（拉拢A孤立B）：保持中立，不参与任何"站队"

【如果不得不跟TA建立"关系"】
- 把关系维持在"社交礼貌层面"：见面打招呼、聊两句天气、不深入
- 永远不要把TA当"自己人"：你对"自己人"才会说真话、暴露弱点——这些都会被TA利用
- 如果TA主动靠近你：问自己"TA图我什么？"——找到答案你就知道怎么应对了
- 最安全的方式：让TA觉得你"无趣"——你不分享秘密、不参与八卦、不站队，TA自然去找下一个目标

【一图总结】
虚伪之人 = 一面镜子，你在TA面前看到的都是假的。不分享秘密、不站队、只听不评，让TA觉得你"无趣"，TA自然远离你。
''',
      tags: ['虚伪', '表里不一', '不站队', '信息差', '背后说坏话'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K061',
      title: '与自私之人打交道：明确边界、降低期待、学会说不',
      category: '识人与应对之道',
      content: '''
自私的人不是坏人，TA只是"只有自己"。TA的世界里TA永远是主角，别人都是配角。TA不一定是故意伤害你，TA只是压根没想过你。

【先识别：8个信号判断TA是不是"自私型"】
1. 从来不主动AA/买单：每次到结账就上厕所/看手机/"下次我请"但永远没有下次
2. 借东西不还：借了你的书/充电器/衣服，你不催就不还，催了还嫌你小气
3. 需要帮忙时找你，你需要帮忙时消失：TA的事永远比你的急，你的事"嗯嗯我看看"然后就没下文
4. 你的事永远没有TA的事重要：TA加班你说"辛苦了"，你加班TA说"那你怎么还有时间跟我聊天"
5. 永远是"我我我"：聊天90%在说自己的事，你说自己的事TA两句话就绕回TA自己
6. 吃东西/用东西从不过问别人：直接拿你的零食吃、用你的东西不问、最后一口永远自己吃
7. 答应你的事经常忘/改：但你要是忘了TA的事，TA能记一个月
8. 从不道歉或道歉后立刻加"但是"："对不起，但是你也有问题啊"

【核心应对原则：3步策略】

第1步：明确边界（不让TA习惯占你便宜）
- 自私的人会不断试探你的底线——你退一寸TA进一尺
- 第一次TA占你便宜时就要明确回应：
  "这个是我自己用的，不太方便借"（不借东西）
  "上次是我请的，这次你来？"（不惯着不买单）
  "我现在也有点忙，可能帮不了你"（不随叫随到）
- 关键：语气平静但不退让。不需要生气，只需要说"不"

第2步：降低期待（不指望TA回报）
- 接受一个事实：TA不会像你对TA那样对你
- 你帮TA时不要期待回报——如果有期待就别帮，帮了会心里不舒服
- 不要把TA当成"可以互相帮忙的朋友"——TA不是，TA是"只会单向索取的熟人"

第3步：学会说不（这是最重要的技能）
- 自私的人最怕的就是遇到"不好说话"的人
- 说"不"的公式：肯定对方的感受 + 明确拒绝 + 不解释太多
  "我知道你很急，但我这个周末确实有安排了，帮不了你"
  "我理解你需要这个，但这个确实不太方便"
- 不要过度解释——你解释越多TA越觉得有谈判空间
- 不要内疚——说"不"是你的权利，不是你的错

【具体场景应对】

场景1：TA又来找你帮忙，但你上次帮TA的事TA还没感谢/回报你
- "上次那个事你那边怎么样了？结果还好吗？"（先确认TA有没有把你的帮忙当回事）
- 如果TA完全没当回事："嗯，那这次可能得你自己处理了，我最近也比较忙"
- 如果TA说"上次忘了谢谢你"：那看情况帮，但心里要记住TA的反应模式

场景2：TA在群体中总是占便宜（不买单/不干活/占最好资源）
- 不要当众指责（TA会说你小气，让你难堪）
- 悄悄跟其他人达成共识：以后AA时提前说好规则，不给TA占便宜的机会
- 分配任务时：TA负责什么就明确写出来，做不完是TA的事

场景3：TA是家人/伴侣（最难处理的场景）
- 自私的家人/伴侣需要更强硬的边界
- "我愿意帮你，但我也需要你尊重我的时间和需求"
- 不要无底线付出——你的付出在TA眼里是"理所当然"
- 如果是伴侣：认真评估这段关系是否值得继续——一个只考虑自己的人，不会在关键时刻为你着想

场景4：TA是你的好朋友，但一直自私
- 问自己：TA身上有什么值得你维持这段友谊的东西？
- 如果只是"认识很久了"→时间不是理由
- 如果TA有其他优点（比如真诚、有趣）→可以维持但调整期待
- 持续不舒服的关系不如没有关系

【如何跟自私的人"建立关系"】
- 说实话：跟自私的人不适合建立深层关系
- 如果你必须维持（同事/亲戚/无法选择的关系）：
  - 关系维持在"功能层面"：能配合做事就行
  - 明确分工和边界：TA做什么你做什么，各管各的
  - 不要有"互帮互助"的期待：你需要帮忙时找别人，不要找TA
  - 偶尔TA对你好时：接受但不过度解读——TA可能只是恰好顺手

【一图总结】
自私之人 = 只活在自己世界的人。明确边界（不让TA习惯占便宜）、降低期待（不指望回报）、学会说不（你的权利不是你的错）。维持功能层面的关系，但不要交心。
''',
      tags: ['自私', '边界', '学会说不', '降低期待', '单向索取'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K062',
      title: '与控制欲强之人打交道：坚持底线、不妥协一次',
      category: '识人与应对之道',
      content: '''
控制欲强的人最可怕的地方在于：TA的控制往往以"爱""关心""为你好"的名义出现。你以为TA在关心你，实际上TA在剥夺你的自主权。等你意识到不对劲的时候，你可能已经习惯了被控制。

【先识别：8个信号判断TA是不是"控制型"】
1. 替你做决定：从点餐到穿衣到交朋友，TA都要替你决定，你不同意TA就不高兴
2. 干涉你的社交："那个人不好，你别跟TA来往""你怎么又跟你那些朋友出去了"
3. 用"为你好"绑架你："我这样说还不是为了你好""别人谁管你啊"
4. 查岗式关心：你在哪、跟谁、几点回来、为什么不接电话——高频监控
5. 你不同意就发脾气或冷战：TA不会暴力，但会用情绪惩罚你让你就范
6. 贬低你的判断力："你怎么这么笨""你离了我怎么行""你就是想太多"
7. 经济控制：管你的钱、要你报账、不让你有自己的存款
8. 隔离你：慢慢让你跟朋友/家人减少联系，让TA成为你唯一的依靠

【核心应对原则：4条底线】

底线1：坚持自己的决定权
- 你的工作、社交、消费、生活方式——这些是你的基本权利，不是"可以商量"的
- TA说"你怎么又跟那些人出去"→"这是我的朋友，我有自己的社交"
- TA说"你穿这个不好看换一个"→"我喜欢这个，谢谢你的建议"
- 关键：语气平静但坚定，不需要解释理由，不需要争辩

底线2：不妥协一次
- 控制型的人最擅长"温水煮青蛙"——今天让你少跟朋友出去一次，明天让你不出去
- 你妥协一次=TA知道这个方法有效=下次变本加厉
- 第一次TA越界时就要明确回应："这是我的决定，我不需要你替我做"
- 如果TA发脾气/冷战：不哄、不道歉、不退让。TA发现冷战没用就会停止用这招

底线3：保持你的社交网络
- 控制型的人最终目标之一是"让你只依赖TA"
- 无论TA怎么反对，保持你跟朋友/家人的联系
- 如果TA试图阻止你见某个朋友："我理解你的担心，但TA是我的朋友，我会自己判断"
- 定期跟朋友/家人单独相处，不要让TA成为你唯一的社交来源

底线4：不要试图"理解"TA的控制
- 很多人会说"TA控制我是因为TA太爱我了/TA太没有安全感了"
- 这可能是事实，但这不是理由。TA的不安全感应该由TA自己解决，不是通过控制你
- 你的理解=你的纵容=TA的变本加厉
- 正确的心态："我理解你的不安，但控制我不是解决方案"

【具体场景应对】

场景1：TA是你的伴侣，开始干涉你的生活
- 早期信号：TA开始对你的穿着/朋友/时间安排指手画脚
- 立即回应："我很珍惜我们的关系，但我也有自己的生活方式。我们可以讨论，但你不能替我决定"
- 如果TA说"你是不是不爱我了"→"爱不等于放弃自我"
- 如果TA持续控制且升级：认真评估这段关系——控制欲是家暴的前兆之一

场景2：TA是你的父母/长辈
- 这是中国家庭最常见的场景
- "我这样做是为了你好"→"我知道你是为我好，但我需要自己做决定，哪怕犯错"
- 不要试图说服TA接受你的选择——TA不会
- 策略：做你的决定，TA唠叨TA的，你左耳进右耳出
- 如果TA用断绝关系威胁你：这本身就是控制手段，你退让一次以后每次都会被威胁

场景3：TA是你的领导/上司
- 控制型领导：微观管理、不信任你、每个决定都要过TA的手
- 应对：主动汇报（让TA放心）、展示你的能力（用结果说话）、在TA不擅长的领域展示你的专业性
- 如果TA的控制已经影响你的工作和发展：考虑换团队/换工作
- 不要跟TA硬碰硬——你有你的职业规划，TA只是其中一个过客

场景4：TA是朋友，总是以"过来人"身份指导你
- "你应该这样做""你怎么能这样""听我的准没错"
- "谢谢你的建议，我会考虑的"→然后按自己的想法做
- 如果TA因为你没听TA的就生气："我理解你的好意，但这件事我需要自己做判断"
- 如果TA持续这样：减少深聊，维持社交层面的关系

【危险信号：什么时候该离开】
如果出现以下情况，不要犹豫，立即离开：
- TA开始监控你的手机/社交账号
- TA要求你跟朋友/家人断绝联系
- TA用经济手段控制你（不让你有自己的钱）
- TA的"建议"变成了威胁（"你不听我的就分手/别回家了"）
- 你发现自己越来越不敢做决定、越来越害怕TA的反应
- 你跟朋友/家人越来越疏远，TA成了你唯一的人

这些都是控制升级为精神暴力/家暴的前兆。不要等到物理暴力出现才行动。

【一图总结】
控制欲强之人 = 以爱之名行控制之实。坚持你的决定权，不妥协一次，保持你的社交网络，不要用"TA是爱我"来合理化控制。出现危险信号时立即离开。
''',
      tags: ['控制欲', 'PUA', '为你好', '坚持底线', '危险信号', '精神控制'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K063',
      title: '与负能量之人打交道：限定时间、不接情绪、不拯救',
      category: '识人与应对之道',
      content: '''
负能量的人不是坏人，但TA是"情绪黑洞"——你跟TA待久了，你的能量也被吸走了。TA永远是受害者、永远在抱怨、你的建议TA全部否掉、聊完你觉得自己也被掏空了。

【先识别：6个信号判断TA是不是"负能量型"】
1. 每次聊天都在吐槽：工作不顺、感情不好、被人针对、运气太差——永远是负面话题
2. 从不说积极的事：你跟TA分享开心的事，TA能瞬间找出不好的角度
3. 你的建议TA全部否掉："我试过没用的""你说得容易""但是..."
4. TA永远是受害者：所有不好的事都是别人的错/命运的错，从不反思自己
5. 聊完你觉得自己被掏空了：跟TA聊一次天，你需要半天才能恢复
6. TA从不在你难过时倾听：你倾诉的时候TA会绕回自己的事

【核心应对原则：3个"不"】

🚫 不接TA的负面情绪
- TA吐槽时你只需要"嗯嗯""是吗""那确实挺烦的"——不参与、不延伸、不追问
- 不要跟TA一起骂TA吐槽的人/事——你骂了TA转头可能说"XX也说你怎么怎么样"
- 不要给建议——TA不需要建议，TA需要的是"有人听我倒苦水"
- 你的情绪是你自己的，不要让TA的负能量污染你

🚫 不试图拯救TA
- 你不是TA的心理咨询师，你救不了TA
- TA的负能量是TA的生活方式/思维模式，你改变不了
- 你越想帮TA，TA越依赖你，你越累
- 正确心态："我能听你说一会儿，但你的问题需要你自己解决"

🚫 不无限提供时间
- 限定接触时间：聊15分钟就撤（"我还有事，先去忙了"）
- 限定接触频率：不需要每次TA找你都回应
- 在你状态不好时特别要远离TA——你自己电量低的时候最容易被吸走

【具体场景应对】

场景1：TA又开始跟你倒苦水（第100次说同一个问题）
- "嗯，这个事你之前提过。你有没有想过怎么解决？"（引导TA自己面对问题）
- TA说"没用/试过/不可能"→"那可能这件事暂时没法改变，不如先放一放？"
- TA继续倒苦水→"我理解你的感受，不过我现在有点忙，改天再聊？"（撤退）

场景2：你跟TA分享开心的事，TA泼冷水
- 你："我升职了！" TA："哎以后更累了吧，你们公司加班那么严重"
- 不要跟TA争（你争不赢而且没必要）："哈哈，是会忙一些，但我还是挺开心的"
- 以后分享开心的事找能跟你一起开心的人，不是TA

场景3：TA是同事，每天午饭都在吐槽
- 不跟TA一起吃饭（最有效的方式）
- 实在躲不开：吃饭时看手机/听音乐/跟其他人聊别的topic
- TA吐槽时你"嗯嗯"然后主动转移话题："对了，你看那个新剧没有？"
- 慢慢拉开距离，TA会找到下一个"倾听者"

场景4：TA是你的家人/伴侣
- 这是最难的，因为你不能"绝交"
- 策略1：设立"情绪隔离区"——TA抱怨时你心理上"退后一步"，不参与不投入
- 策略2：鼓励TA寻求专业帮助——"你一直这么不开心，要不要去看看心理咨询？"
- 策略3：保护你自己的能量——定期跟正能量的朋友相处、做让你充电的事
- 如果是伴侣且长期负能量：认真评估这段关系对你的心理健康的影响

【如何跟负能量的人"建立关系"】
- 最佳策略：不建立深层关系
- 如果必须维持（同事/亲戚）：
  - 关系保持在"社交礼貌层面"
  - 聊安全话题（天气/新闻/食物），不聊私事
  - TA开始倒苦水时转移话题或撤退
  - 你自己的好事不要跟TA分享（TA会泼冷水）
  - 你自己的难事更不要跟TA说（TA会让你更绝望）

【区分"负能量型"和"真的遇到困难的朋友"】
重要！不要把所有跟你诉苦的朋友都当成"负能量型"：
- 真的遇到困难的朋友：有具体的事，需要具体的帮助，问题解决了就会好
- 负能量型：永远是不同的事但同样的模式，你帮了也没用，TA不需要帮助只需要倾诉
- 真朋友：TA诉苦后也会关心你的事，会听你说
- 负能量型：你说话TA三句话绕回自己

对真朋友要帮、要听、要陪伴。对负能量型要限定时间、不接情绪、不拯救。

【一图总结】
负能量之人 = 情绪黑洞。限定时间（15分钟就撤）、不接情绪（嗯嗯不参与）、不拯救（你救不了）。区分"真的需要帮助的朋友"和"负能量型"——前者帮，后者避。
''',
      tags: ['负能量', '情绪黑洞', '情绪隔离', '不拯救', '限定时间'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K064',
      title: '与傲慢之人打交道：不争论、不卑微、用实力说话',
      category: '识人与应对之道',
      content: '''
傲慢的人最大的特点：TA觉得自己永远是对的、永远比你强。TA打断你说话、纠正你的每个细节、用居高临下的语气跟你交流。但本质上，傲慢往往是深层自卑的盔甲——TA必须踩低别人才能感觉自己有价值。

【先识别：6个信号判断TA是不是"傲慢型"】
1. 打断你说话：你还没说完TA就接过去说自己的观点
2. 纠正你的每个细节：你说"大概10点"TA说"不是10点是10点03分"——鸡毛蒜皮都要纠正
3. 用居高临下的语气："这个你都不懂？""让我来教你""你听我的就行"
4. 从不承认自己错了：即使被证明错了也会找理由（"那是特殊情况""我的意思是..."）
5. 贬低别人的成就："那个有什么难的""我也能做到只是没时间"
6. 只跟TA认为"比自己差"的人交往：对强者谄媚，对弱者傲慢

【核心应对原则：3条法则】

法则1：不争论
- 跟傲慢的人争论=你承认了TA有跟你争论的资格=你在TA的水平上被TA打败
- TA说了一个你不同意的观点：微笑点头→然后按你自己的想法做
- TA纠正你的细节："嗯，你观察得挺仔细"→不需要反驳
- 你赢了争论但输了关系（如果你需要这个关系），而且TA不会因为输了就尊重你

法则2：不卑微
- 傲慢的人最会"踩软柿子"——你越卑微TA越踩你
- 不要用讨好来获得TA的认可："您说得对""您真厉害"——TA会觉得你确实不如TA
- 保持不卑不亢："你的观点我听到了，我有自己的考虑"
- 用平等的姿态交流——如果你做不到平等，就不要跟TA深交

法则3：用实力说话
- 傲慢的人只尊重一种人：比TA强的人
- 你跟TA说一万句不如做出一个TA做不到的结果
- 在你的专业领域展示能力：TA说"这个你不会吧"→你做出一个漂亮的成果→TA闭嘴了
- 不要急于证明自己——让结果替你说话

【具体场景应对】

场景1：TA当着别人的面贬低你/纠正你
- 不要当众反击（TA比你更擅长当众"赢"）
- 微笑着说"你说的有道理"→然后继续说你的
- 如果TA持续打断你："让我先把话说完"（平静但坚定）
- 事后单独找TA："当众被纠正让我不太舒服，以后可以私下跟我说"（如果值得维护关系）

场景2：TA是你的领导/前辈，总是用居高临下的态度
- 工作上：TA交代的做好，但不要试图改变TA的态度
- 在你的专业领域做深做透→当TA发现在某个领域你比TA强时，TA的态度会转变
- 不要因为TA的贬低而自我怀疑——TA贬低你是TA的问题不是你的问题
- 如果TA的傲慢已经影响了你的职业发展：考虑换环境

场景3：TA是你的朋友，总是"指导"你的生活
- "你应该这样做""你怎么连这个都不知道"
- "谢谢你的建议，但这件事我自己能处理"
- 不接受TA的"指导"→TA觉得没意思→会去找下一个愿意被指导的人
- 如果你发现跟TA在一起总是不舒服：减少接触

场景4：TA是你的家人
- 家人的傲慢最难处理，因为你不能"不理"
- 策略：做你的事，让结果说话
- TA说"你这能行吗"→你做成了→TA下次就不说了
- 不要试图证明TA错了——你证明了TA也不会承认
- 保持你自己的节奏和判断

【如何跟傲慢的人"建立关系"】
- 最佳策略：保持距离，不深交
- 如果你必须建立关系（工作需要）：
  - 先展示你的实力/价值——让TA觉得你"有资格"跟TA平等交流
  - 在TA擅长的领域真诚请教——傲慢的人最吃"被认可"这一套
  - 但不要过度恭维——TA会看不起你
  - 在你不认同的时候，不争辩但也不附和
  - 用结果说话，不用嘴说话

【特别提醒：区分"傲慢"和"自信"】
- 自信的人：知道自己厉害，但不否定别人；能听取不同意见；承认自己有不足
- 傲慢的人：必须否定别人才能确认自己厉害；听不进任何不同意见；从不承认自己错
- 自信的人值得深交，傲慢的人保持距离

【一图总结】
傲慢之人 = 用优越感掩盖自卑的人。不争论（赢了也没用）、不卑微（越卑微越被踩）、用实力说话（结果是最好的回应）。保持距离，不深交。
''',
      tags: ['傲慢', '不争论', '用实力说话', '不卑微', '深层自卑'],
      relatedLevel: 0,
    ),

    // ========== 关系生命周期（K065-K072） ==========
    const SocialKnowledgeEntry(
      id: 'K065',
      title: '关系生命周期总览：相识→终结的9个阶段',
      category: '关系生命周期',
      content: '''
任何一段关系——无论是友情、爱情还是合作关系——都有生命周期。理解这个周期，你就能知道你们现在在哪里、接下来会面临什么、你应该做什么。

【关系生命周期的9个阶段】

🌱 阶段1：相识期
- 你们刚认识，互相只有第一印象
- 核心任务：建立好感、展示价值、创造"想再见一面"的感觉
- 危险：第一印象不好=后面很难翻盘
- 建议参考：K001（情境破冰）、K002（自我介绍）

🌿 阶段2：熟悉期
- 你们开始有更多接触，互相了解基本信息
- 核心任务：找到共同点、建立舒适感、从"认识的"变成"熟悉的"
- 危险：只有信息交换没有情感连接=永远停在"熟人"层面
- 建议参考：K004（话题管理）、K003（倾听技巧）

🌳 阶段3：友谊期
- 你们的交流从"事务性"变成了"情感性"，开始分享私事
- 核心任务：建立信任、互相支持、创造共同记忆
- 标志：TA主动找你聊非工作的事、TA告诉你TA的烦恼、你们有了"只有你们懂的梗"
- 危险：把"熟悉"误当成"亲密"→急于推进关系
- 建议参考：K007（深度连接）、K035（日常相处）

🌸 阶段4：暧昧/恋人期
- 友情开始向爱情转变（如果发展方向是恋人）
- 核心任务：制造情感波动、升级肢体接触、从"朋友"过渡到"恋人"
- 标志：你们开始在意对方跟其他异性的关系、肢体接触升级、有了"专属感"
- 危险：时机不对/对方没有同样的感觉=可能连朋友都做不了
- 建议参考：K049-K054（分性别约会内容）、K054（表白与确定关系）

⚡ 阶段5：稳定/磨合期
- 关系确定后进入磨合阶段，开始发现对方的"真实面目"
- 核心任务：接受对方的不完美、建立冲突解决机制、找到你们的相处模式
- 危险：把磨合期的矛盾当成"不爱了"→草率分手
- 建议参考：K006（冲突化解）、K053（异性心理差异）

🌫️ 阶段6：猜忌期
- 信任开始动摇，开始怀疑对方的动机/忠诚/感情
- 核心任务：识别猜忌的根源、重建沟通、防止猜忌升级为破裂
- 信号：开始查TA手机、TA说的每句话你都要分析真假、你开始"试探"TA
- 危险：猜忌会自我强化——你越怀疑越觉得可疑
- 建议参考：K006（非暴力沟通）、K009（道歉与修复）

💥 阶段7：破裂期
- 关系出现严重裂痕，信任/感情受到实质伤害
- 核心任务：评估是否可修复、止损、保护自己
- 信号：频繁激烈争吵/长期冷战/出现背叛（出轨/欺骗/背叛信任）
- 危险：在情绪上头时做决定（分手/复合）
- 建议参考：K009（道歉六要素）、K006（冲突化解）

🔧 阶段8：修复期
- 如果双方都愿意修复，进入这个阶段
- 核心任务：重建信任、解决根本问题、建立新的相处规则
- 条件：双方都有修复意愿 + 伤害方真诚道歉 + 受伤方愿意给机会
- 危险：表面和好但根本问题没解决=还会再破裂
- 建议参考：K009（道歉与修复）、K006（非暴力沟通）

🔚 阶段9：终结期
- 关系无法修复或自然结束，进入终局
- 核心任务：体面结束、自我疗愈、从中成长
- 类型：和平分手（双方同意）/ 单方面终止（一方决定）/ 渐渐淡出（不联系了）
- 危险：终结后纠缠不清=无法开始新生活
- 建议参考：K054（被拒绝后的应对）

【一个重要认知】
不是所有关系都能走到"友谊期"或"恋人期"，也不是所有关系都需要走到"终结期"。有些关系自然淡出是正常的，不需要强求。关键是：你知道你们在哪一个阶段，你知道下一步该做什么，你知道什么时候该推进、什么时候该止损。
''',
      tags: ['关系周期', '生命周期', '阶段识别', '相识', '终结', '完整过程'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K066',
      title: '猜忌期：信任动摇的信号与应对',
      category: '关系生命周期',
      content: '''
猜忌是关系的毒药——它不需要事实就能摧毁信任。你开始怀疑TA的每句话、每个行为，然后你越怀疑越觉得可疑，越觉得可疑越怀疑。猜忌的本质不是"TA做了什么"，而是"你的安全感出了问题"。

【如何判断你进入了猜忌期】
信号1：你开始"分析"TA的每句话
- TA说"今晚加班"→你想"是真的加班还是借口？"
- TA回消息慢了→你想"TA是不是在跟别人聊天？"
- TA对你好→你想"TA是不是心虚所以补偿我？"
- 注意：当TA说什么你都不信的时候，问题可能不在TA，而在你的信任系统

信号2：你开始"试探"TA
- 故意说"我今晚也有事"看TA的反应
- 翻TA手机/社交账号/聊天记录
- 问TA已经知道答案的问题，看TA是否说谎
- 通过朋友打探TA的行踪
- 危险：试探本身就是在破坏信任——即使TA没做错什么，被试探的感觉也等于"你不信任我"

信号3：你开始"收集证据"
- 截图TA的每条消息
- 记录TA说过的每一句话找矛盾
- 反复回忆TA过去的行为找"蛛丝马迹"
- 这时候你已经在"定罪"而不是"了解事实"

信号4：你的情绪被TA的行为完全掌控
- TA回消息快你就安心，慢了你就焦虑
- TA对你好你就觉得"还好"，TA冷淡你就觉得"果然"
- 你的情绪完全取决于TA的行为=你已经失去了关系的主动权

【猜忌的3种根源】

根源1：TA确实做了破坏信任的事（有事实依据）
- TA撒过谎被你发现了/TA跟异性暧昧被你看到了/TA承诺的事没做到
- 这种猜忌是"有因的"——需要解决的是那个"因"
- 应对：直接跟TA谈（参考非暴力沟通四步法），看TA的态度和行动

根源2：TA没做什么，但你自己的不安全感作祟
- 你过去被背叛过→你现在对所有人都不信任
- 你觉得自己不够好→觉得TA迟早会找别人
- 你太依赖这段关系→害怕失去=过度警觉
- 应对：这是你自己的功课，不是TA的问题。需要提升自我价值感，必要时寻求心理咨询

根源3：TA的行为虽然没"出轨"但模糊不清
- TA跟异性朋友的边界不清晰
- TA对你的态度忽冷忽热
- TA有些事不愿意跟你说
- 应对：明确你的底线和需求，跟TA谈"什么样的行为让我不舒服"

【应对猜忌的5步法】

第1步：区分"事实"和"想象"
- 写下来：你怀疑TA的每一条，旁边标注"这是事实"还是"这是我的推测"
- 事实=你亲眼看到/有确凿证据的事
- 推测=你根据某个行为"觉得"的事
- 90%的猜忌是推测被当成了事实

第2步：直接沟通，不试探
- 不要通过"试探"来找答案——试探会制造新的问题
- 用非暴力沟通的方式直接说：
  "我注意到你最近跟XX聊得比较多（观察），我感到有些不安（感受），因为我需要在这段关系里有安全感（需求），你能不能跟我聊聊你们的关系？（请求）"
- 看TA的反应：真诚解释+调整行为=可以继续；防御/愤怒/反咬"你怎么不信任我"=有问题

第3步：给信任一个"试用期"
- 沟通之后，如果TA的回应是合理的，尝试相信TA
- 设一个内心的时间线：比如3个月，这3个月你选择信任，不查不试
- 3个月后如果TA的行为确实一致=信任重建成功
- 如果TA又做了破坏信任的事=你知道该怎么做了

第4步：不要一个人扛
- 猜忌最消耗人的是你一个人在脑子里反复想
- 找一个信任的朋友倾诉（不是找朋友帮你"调查"）
- 如果猜忌已经严重影响你的生活/睡眠/工作→考虑心理咨询

第5步：知道什么时候该走
- 如果TA反复破坏信任且不愿改变→离开
- 如果你发现自己无法信任任何人→先处理自己的问题再谈恋爱
- 如果关系让你比独处更痛苦→这段关系不值得

【特别提醒：猜忌 ≠ 直觉】
- 直觉：你感觉到不对劲，但没有具体怀疑什么→观察，不行动
- 猜忌：你已经在怀疑具体的事/人→需要沟通或验证
- 直觉通常是准确的，猜忌通常是放大的
- 如果你的"直觉"一直告诉你"TA在背叛我"但你找不到证据→可能是根源2（你自己的不安全感）

【一图总结】
猜忌期 = 信任系统出现故障。先区分事实和想象→直接沟通不试探→给信任一个试用期→不要一个人扛→知道什么时候该走。记住：猜忌会自我强化，你越怀疑越觉得可疑，打破循环的唯一方式是沟通。
''',
      tags: ['猜忌', '信任危机', '试探', '不安全感', '沟通', '信任重建'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K067',
      title: '破裂期：关系崩塌的过程与止损',
      category: '关系生命周期',
      content: '''
关系的破裂很少是一瞬间的事——它通常是累积的。一次次的失望、一次次的冷战、一次次的"算了不说了"，最终在某一个导火索上爆发。理解破裂的过程，你就能知道是"该修复"还是"该止损"。

【关系破裂的4个阶段】

阶段1：微裂痕期（可修复）
- 你们开始有越来越多的小摩擦：为鸡毛蒜皮吵架、互相觉得"你怎么不理解我"
- 特征：吵完还能和好，但和好的速度越来越慢，冷战的时间越来越长
- 这个阶段的核心问题不是"吵什么"，而是"你们没有建立有效的冲突解决机制"
- 应对：参考K006（非暴力沟通）建立"吵架规则"，趁还有感情赶紧修复

阶段2：疏远期（修复难度增加）
- 你们不再吵架了——但不是因为和好了，而是因为"懒得吵了"
- 特征：交流减少、各自做各自的事、情感上开始"撤出"
- 这是最危险的信号：不吵架=不在乎了=心已经走了
- 应对：如果你还想挽救这段关系，现在是用力的最后时机。主动找TA谈："我觉得我们最近越来越远了，你有没有这个感觉？"

阶段3：危机期（破裂的临界点）
- 出现了一个"重大事件"：出轨被发现/严重的谎言被揭穿/激烈的争吵中说出了分手
- 特征：一方或双方开始认真考虑"这段关系还要不要继续"
- 这个阶段做的决定往往是情绪化的——无论分手还是复合，都不是理性判断
- 应对：不要在情绪上头时做任何决定。给自己至少72小时的冷静期。

阶段4：断裂期（实质破裂）
- 关系已经名存实亡：你们还在一个屋檐下/还名义上是朋友或恋人，但情感连接已经断了
- 特征：你不再关心TA的感受、TA也不再关心你的；你开始想象没有TA的生活
- 到了这个阶段，修复的可能性很低——因为双方都已经"心死"了
- 应对：接受现实，准备体面结束

【如何判断"该修复"还是"该止损"】

该修复的信号（满足3条以上）：
✅ 双方都还想挽救这段关系
✅ 破裂的原因是"沟通问题"而非"原则问题"（出轨/家暴/背叛=原则问题）
✅ 你们之间还有"美好的共同记忆"可以作为修复的基础
✅ 你想到失去TA时仍然会心痛，而不是"解脱"
✅ 你们愿意为修复付出努力（不只是嘴上说"我改"）
✅ 破裂是"近期的事"而非"长期累积"（近期问题更容易修复）

该止损的信号（满足2条以上）：
🚫 一方已经不想修复了（单方面努力=没用）
🚫 破裂原因是原则问题：出轨/家暴/赌博/严重欺骗
🚫 你跟TA在一起时比独处时更痛苦
🚫 你已经不信任TA了，且TA没有重建信任的意愿和行动
🚫 你开始想象"离开TA之后"的生活，而且想象时觉得轻松
🚫 你们的价值观/人生方向有根本性分歧
🚫 你反复原谅TA但TA反复犯同样的错误

【止损的3个原则】

原则1：止损不是失败，是对自己负责
- 很多人忍着不分手是因为"沉没成本"（我都投入了这么久了）
- 沉没成本谬误：过去的投入不应该影响未来的决策
- 你未来的50年比过去的3年重要得多

原则2：止损要果断，不要"温水煮青蛙"
- 决定了就走，不要"分了又合合了又分"——每次反复都在消耗你
- 不要用"再给TA一次机会"来拖延——你已经给过很多次了
- 如果TA用"我会改的"来挽留你：看TA过去的行动而非当前的语言

原则3：止损后要断干净（至少在初期）
- 不要立刻"做朋友"——你还没从情感中走出来，"做朋友"=给自己找借口回头
- 取关/不看TA的社交动态——每次看都是在撕伤口
- 不联系（至少3-6个月）——让大脑的"戒断反应"完成
- 如果有共同朋友/共同财产：通过第三方处理，不直接接触

【破裂期特别场景：被出轨后的处理】
1. 第一时间不要做任何决定（不要立刻分手也不要立刻原谅）
2. 收集证据（不是为了报复，是为了你自己不被TA的"否认"搞混判断）
3. 评估TA的态度：真诚悔改 vs 找借口推卸责任
4. 如果决定修复：设定明确条件和时间线，不是"我改"就完了
5. 如果决定离开：不要问"为什么"——没有答案能让你释怀，离开本身就是答案

【一图总结】
破裂期 = 关系从"微裂痕→疏远→危机→断裂"的过程。判断"该修复还是该止损"：看双方意愿、破裂原因、你的感受。止损不是失败，是对自己负责。止损要果断、要断干净。
''',
      tags: ['关系破裂', '止损', '修复判断', '出轨', '沉没成本', '分手'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K068',
      title: '修复期：重建信任的条件与方法',
      category: '关系生命周期',
      content: '''
关系破裂后如果双方都愿意修复，就进入了修复期。但修复不是"和好"——和好只需要一句"对不起"，修复需要重建被破坏的信任系统。表面和好但根本问题没解决=下一次破裂只是时间问题。

【修复的前提条件（缺一不可）】

条件1：双方都有修复意愿
- 不是一方求另一方"再给一次机会"，而是双方都认为这段关系值得修复
- 如果只有一方想修复，另一方只是"勉强同意"→修复不会成功
- 检验：问对方"你觉得我们的关系值得修复吗？"如果TA犹豫→答案就是"不值得"

条件2：伤害方真诚认识到错误
- 不是"好吧好吧我错了"（敷衍）
- 不是"我错了但是你也有问题"（甩锅）
- 是"我做了XXX，这是我的错，我理解这对你造成了XXX的伤害"（具体、真诚、承担全部责任）

条件3：受伤方愿意给机会
- 受伤方有权选择不修复——这不是"不够大度"
- 如果受伤方愿意尝试修复，需要暂时放下"惩罚对方"的心态
- 但这不意味着"忘记"——修复是"带着伤痕继续走"，不是"假装什么都没发生"

条件4：根本问题可以被解决
- 如果破裂原因是"沟通方式有问题"→可以修复（学习新的沟通方式）
- 如果破裂原因是"一方出轨"→修复难度极高，需要极长的重建期
- 如果破裂原因是"价值观根本不同"→无法修复（你改变不了别人的价值观）
- 如果破裂原因是"家暴/赌博/成瘾"→不建议修复（这些是反复发作的问题）

【修复期的4个阶段】

阶段1：止血期（1-2周）
- 停止一切互相伤害的行为：不翻旧账、不冷暴力、不攻击对方
- 双方都需要时间和空间消化情绪
- 这个阶段不要急着"回到从前"——你们回不去了，你们要建立的是"新的关系"
- 行动：减少高强度互动，保持基本的尊重和关心

阶段2：沟通期（2-4周）
- 在双方都冷静后，进行深度沟通
- 用非暴力沟通的方式：
  "当XX发生时（事实），我感到XX（感受），因为我需要XX（需求），我希望以后XX（请求）"
- 双方都要说出自己的感受和需求——不是指责，是让对方理解你
- 关键：倾听时不打断、不辩解、不说"但是"

阶段3：重建期（1-6个月）
- 这是真正考验的阶段——你们要用行动证明"改变真的发生了"
- 伤害方需要做：
  - 持续的、一致的行为改变（不是三天热度）
  - 主动重建信任（如主动报备、透明化、接受对方的"验证"）
  - 耐心接受对方可能反复的不安全感
- 受伤方需要做：
  - 给对方机会证明改变（不要因为一次小事就否定所有进步）
  - 逐渐放下"验证"的行为（从查手机→不查手机）
  - 表达你的需求而不是"试探"对方

阶段4：新平衡期（6个月+）
- 如果重建期顺利，你们会进入一个新的平衡
- 这个平衡不是"回到从前"——你们的关系已经因为破裂和修复而"变形"了
- 新的关系可能更脆弱（伤痕还在）但也可能更坚韧（你们学会了如何处理冲突）
- 关键：建立"冲突预防机制"——定期沟通、有问题及时说、不让小问题积累

【修复期最容易犯的5个错误】

错误1：急于"回到从前"
- 你们回不去了。接受这个事实。
- 与其追求"回到从前"，不如一起建立"新的相处模式"

错误2：表面和好但不解决根本问题
- "好了好了不吵了"→根本问题还在→下次还会爆发
- 必须把导致破裂的根本问题找出来并解决

错误3：一方持续"惩罚"另一方
- 受伤方反复翻旧账、冷暴力、用"你欠我的"来控制对方
- 这不是修复，是报复。修复需要双方都放下"惩罚"心态

错误4：信任重建太快
- "TA说会改我就信了"→信任不是一句话能重建的
- 信任=时间×一致的行为。需要几个月甚至更长时间

错误5：跳过"沟通期"直接"重建"
- 没有深度沟通就开始"重建"=你们根本不知道要重建什么
- 先搞清楚"为什么会破裂"→再修复→否则只是治标不治本

【修复成功的标志】
- 你们可以平静地谈论导致破裂的事，而不再情绪失控
- 你不需要"验证"TA的行为也能感到安心
- 你们有了新的冲突解决机制，小问题不再积累成大爆发
- 你觉得这段关系比破裂前更成熟了
- 你不再频繁回想"TA是不是又会..."

【修复失败该怎么做】
- 如果你努力了3-6个月但关系没有实质性改善→接受修复失败
- 修复失败不意味着你的努力白费了——至少你知道了"这段关系确实无法修复"
- 不要因为"修复失败"而觉得是自己不够好→有些关系就是修不好
- 带着这次的经验，进入下一段关系时你会更成熟

【一图总结】
修复期 = 不是"和好"而是"重建"。前提：双方愿意+真诚认错+给机会+根本问题可解决。四个阶段：止血→沟通→重建→新平衡。修复需要时间、行动和耐心，不是一句"对不起"能完成的。
''',
      tags: ['关系修复', '重建信任', '非暴力沟通', '修复阶段', '和好', '条件'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K069',
      title: '终结期：体面结束与自我疗愈',
      category: '关系生命周期',
      content: '''
不是所有关系都能走到终点，但所有走到终点的关系都应该体面地结束。终结不是失败——有时候，结束一段已经没有生命力的关系，是比维持它更需要勇气的事。

【关系终结的3种方式】

方式1：和平分手（双方共识）
- 双方都认识到关系走到头了，平静地结束
- 特征：有沟通、有告别、没有撕破脸
- 这是最健康的方式——你们都尊重了这段关系曾经的价值

方式2：单方面终止（一方决定）
- 一方决定了结束，另一方被动接受
- 如果你是决定方：要诚实但不要残忍
- 如果你是被结束方：接受TA的决定，不要纠缠

方式3：渐渐淡出（无声的终结）
- 没有明确的"分手"，只是越来越少联系，最终不再联系
- 常见于友情和暧昧关系
- 优点：没有冲突；缺点：没有closure（了结），容易"意难平"

【如何体面地结束一段关系】

如果是你主动结束：
1. 当面说（不要用微信/短信分手，除非你担心安全问题）
2. 诚实但不要残忍：
   ❌ "我不爱你了"（太直接太伤人）
   ✅ "我觉得我们不适合，我做不到你想要的那种关系"
3. 不要给"假希望"：
   ❌ "也许以后我们还能..."
   ✅ "我希望我们都能找到更合适的人"
4. 不要拖泥带水：决定了就说，不要"再等等""找个好时机"——没有好时机
5. 不要甩锅：不要说"是你逼我的""如果你当时..."——这是你的决定，承担它

如果是对方主动结束：
1. 不要挽留（如果TA决定了，你的挽留只会让TA更坚定）
2. 不要质问"为什么"（TA说的理由你可能不爱听，但不听你也改变不了结果）
3. 不要纠缠（"再给我一次机会""我们再试试"→降低你的尊严）
4. 不要报复（曝光隐私/到处说坏话/破坏TA的新关系→你赢了也输了）
5. 你可以说："我尊重你的决定。虽然我不同意，但我接受。"→然后转身

【终结后的"断舍离"5步法】

第1步：物理断联（1-2周）
- 不见面、不联系、不看TA的社交动态
- 取关/隐藏/删除（根据你的需要，不强求"做朋友"）
- 如果有共同物品/经济往来：尽快处理完，不拖
- 目的：让大脑的"戒断反应"开始消退

第2步：情绪释放（2-4周）
- 允许自己难过、哭泣、愤怒——不要压抑
- 找信任的朋友倾诉，或写日记
- 不要联系TA来"寻求安慰"——TA不是你的安慰来源了
- 运动、旅行、做任何让你感觉好的事

第3步：理性复盘（1-2个月）
- 等情绪平复后，回顾这段关系：
  - 你们的开始是什么样的？
  - 什么时候开始出问题的？
  - 你学到了什么关于自己的事？
  - 下一段关系你会做哪些不同的事？
- 目的不是"找谁对谁错"，而是"从这段经历中成长"

第4步：重建自我（2-3个月）
- 重新投入你自己的兴趣、事业、社交
- 重新发现自己的价值——你的价值不取决于这段关系
- 开始做那些"恋爱时没时间做"的事
- 当你发现自己一个人也能快乐时，你就真正走出来了

第5步：准备新开始（3-6个月后）
- 当你能平静地想起TA而不心痛时，你准备好了
- 不要急着进入新关系来"疗伤"——那对新的人不公平
- 但也不要"封心锁爱"——每一段关系都是独立的，上一段的失败不代表下一段也会失败

【终结后最容易犯的5个错误】

错误1：立刻"做朋友"
- 你还没从情感中走出来，"做朋友"=给自己找借口回头
- 至少断联3-6个月后再考虑能不能做朋友
- 有些人永远不适合做朋友——接受这一点

错误2：视奸TA的社交动态
- 每次看TA的朋友圈都是在撕伤口
- 看到TA过得好→你难受；看到TA过得不好→你也难受
- 取关/屏蔽是最简单的自我保护

错误3：用新关系疗伤
- "忘掉一个人最好的方式是开始新的人"——这是最差的建议
- 你没处理好上一段的感情就进入下一段=把上一段的包袱带给下一个人
- 先处理好自己，再开始新的

错误4：自我否定
- "是不是我不够好TA才离开我"→不是，是你们不合适
- "我再也不会遇到好的人了"→不是，你只是现在情绪低落
- 一段关系的结束不定义你的价值

错误5：纠缠不清
- 分手后还保持暧昧关系/偶尔见面/深夜联系
- 这是最消耗的——你既无法放下也无法前进
- 如果对方来找你"聊聊"：告诉TA"我需要空间，暂时不联系"

【关于"意难平"】
有些关系的终结没有明确的"原因"或"告别"——TA就那样消失了，或者你们就这样不联系了。你会反复想"为什么？""如果当时我...是不是就不会..."
- 没有答案就是答案——TA不想继续了
- "如果当时"没有意义——你不是当时的你了
- 给自己一个"仪式感"的告别：写一封信（不寄出去），把你想说的都写下来，然后烧掉/撕掉。这就是你的closure。

【一图总结】
终结期 = 结束一段已经没有生命力的关系。体面结束（诚实但不残忍）、断舍离5步法（物理断联→情绪释放→理性复盘→重建自我→准备新开始）。记住：一段关系的结束不定义你的价值。你的价值从来都在你自己身上。
''',
      tags: ['关系终结', '分手', '自我疗愈', '断舍离', '体面结束', 'closure'],
      relatedLevel: 0,
    ),

    // ========== 极端型人格识别 ==========
    // 该子分类专门识别"对生活/工作/关系稳定性构成威胁"的人格类型。
    // 与「识人与应对之道」(K057-K064) 的区别：前者是日常"难搞但可应对"的人，
    // 这里聚焦更极端的、需要警惕甚至远离的人格特征。

    const SocialKnowledgeEntry(
      id: 'K070',
      title: '极端情绪化之人：情绪坐过山车的人如何应对',
      category: '极端型人格识别',
      content: '''
有人情绪一上一下波动剧烈，前一刻笑嘻嘻后一刻暴怒或崩溃。这类人不是"性情中人"，而是缺乏情绪自我调节能力。理解TA不是为了纵容，是为了让你自己不被拖入TA的情绪漩涡。

【6个识别信号】
1. 情绪起伏与事件不匹配（小事大爆，大事可能反而平静）
2. 情绪来去极快（前一秒暴怒，半小时后像没事一样）
3. 情绪外溢严重（自己不高兴要让所有人都不高兴）
4. 用情绪操控（发脾气/哭/冷战让你就范）
5. 情绪化决策（生气时下决定，事后又后悔）
6. 你跟TA相处后情绪也被掏空（情绪传染）

【3条应对铁律】
🚫 不被TA的情绪传染：TA暴怒时你保持平静，不被带节奏。你的平静是TA情绪平复的最佳"温控器"。
🚫 不在TA情绪上头时讲道理：TA正在情绪中=听不进任何话。先等情绪过去（"我等你冷静一下我们再谈"），再讲事。
🚫 不为TA的情绪"买单"：TA不高兴≠你的错。不要立刻反思"是不是我做错了什么"，TA的情绪是TA的功课。

【关系深度的2条红线】
红线1 - 不深交到情感依赖：跟这类人维持社交/合作关系可以，但不要把情绪稳定建立在TA身上。TA随时情绪崩盘=你也跟着崩。
红线2 - 出现"用情绪操控你"的迹象要拉距离：TA发现发脾气能让你让步=变本加厉。第一次就要明确"我不接受这种沟通方式"，行动上拉开距离。

【场景应对关键】
TA暴怒时：你保持平静+不回应+离开现场（"我先出去走走，等你冷静了再谈"）；TA哭闹时：不哄不劝（哄=TA知道这招有效），递纸巾然后让TA自己平复；TA用冷战惩罚你：该干嘛干嘛，不追问不主动示好，等TA自己出来；TA情绪化下决定：不要立刻执行，等24小时看TA是否还这样想。

【核心原则】
你不需要"理解"或"治愈"TA——TA的情绪问题是TA的功课，可能需要专业心理咨询。你能做的是守住自己的情绪边界，不被TA拖下水。如果你发现自己长期被TA的情绪消耗→认真评估这段关系是否值得。
''',
      tags: ['极端情绪化', '情绪操控', '情绪传染', '边界', '不被拖入'],
      relatedLevel: 0,
    ),

    const SocialKnowledgeEntry(
      id: 'K071',
      title: '嫉妒型之人：见不得别人好的人如何识别与应对',
      category: '极端型人格识别',
      content: '''
有人看到你成功时不是真心祝贺，而是阴阳怪气/泼冷水/找你的"小辫子"；TA的痛苦不是来自自己的失去，而是来自别人的获得。嫉妒型不是"小心眼"，是性格底色。

【7个识别信号】
1. 你分享好消息TA的反应不对劲（眼神躲闪/语气变冷/勉强笑）
2. 阴阳怪气的"祝福"（"哎哟你运气真好啊"而不是"恭喜你"）
3. 立刻找出你"不如TA"的地方平衡心理（"你升职了但你还是没对象"）
4. 在你低谷时特别"关心"（看似同情实则心理暗爽）
5. 经常把别人的成就归因于运气/关系/出身（暗示"我没成功是因为我没有这些"）
6. 你跟TA分享开心后变得不爽（你的开心是TA的痛苦）
7. TA的成就TA反复说，你的成就TA一笔带过

【3条应对铁律】
🛡️ 不要分享你的好消息给TA：你有开心的事找能跟你一起开心的人分享，不是TA。跟TA分享=给TA泼冷水+给TA嫉妒的素材。
🛡️ 不要"解释"或"证明"自己：TA说你升职是因为运气→你不需要解释自己多努力。越解释TA越要找新的角度否定你。
🛡️ 不要被TA的阴阳怪气影响：TA说"你运气真好"→你"嗯嗯运气确实不错"（不接茬不内耗）。TA的嫉妒是TA的问题不是你的。

【3种关系深度的策略】
深度1 - 必须维持的同事/亲戚：聊安全话题（天气/食物/新闻），不聊你的好事也不聊你的难事；保持社交礼貌，不深交。
深度2 - 已经成为朋友：观察TA嫉妒是否影响你们的友谊。如果TA能克服嫉妒最终为你高兴=可继续；如果TA持续阴阳怪气→慢慢拉开距离。
深度3 - 亲密关系中的嫉妒型：伴侣见不得你比TA成功是严重问题。TA需要自己成长，不是你压抑自己迁就TA。这种情况要么TA改要么你走。

【危险信号：什么时候该警惕】
🚨 TA开始在你背后散布你的"小辫子"（嫉妒升级为恶意中伤）；
🚨 TA开始"破坏"你的好事（在你重要时刻泼冷水/找事/让你出丑）；
🚨 TA的嫉妒从你延伸到所有比TA成功的人（这是病态嫉妒前兆）；
🚨 你发现自己越来越不敢跟TA分享好消息=关系已经失衡。
出现以上任何一个→认真考虑拉开距离。

【核心原则】
嫉妒型的人不会因为你的"谦虚"或"低调"就不嫉妒——TA的嫉妒来自TA自己的不安全感，跟你的表现无关。你能做的是不分享好消息+不被TA的阴阳怪气影响+必要时拉开距离。你不需要为TA的情绪负责。
''',
      tags: ['嫉妒', '见不得人好', '阴阳怪气', '泼冷水', '不分享好消息'],
      relatedLevel: 0,
    ),

    const SocialKnowledgeEntry(
      id: 'K072',
      title: '自恋型之人：NPD自恋型人格的识别与自我保护',
      category: '极端型人格识别',
      content: '''
自恋型人格（NPD）是临床心理学定义的人格障碍之一。他们看起来自信迷人，但内核是"必须不断被赞美+缺乏共情"。识别TA不是为了诊断，是为了保护你自己不被消耗。

【9个识别信号】
1. 必须是话题中心（你说话TA三句话绕回自己）
2. 缺乏共情（你难过TA不知道怎么安慰，只会讲自己的事）
3. 必须被赞美（听不进任何批评，批评=你嫉妒/你不懂）
4. 夸大成就（说自己是"行业领先""最厉害的"但没有依据）
5. 阶层化交友（只跟"配得上"TA的人交往，对弱者傲慢对强者谄媚）
6. 利用关系（朋友=资源，赞美=燃料，你有用就热情没用就冷淡）
7. 永远是别人的错（自己从不犯错，错了也是别人的责任）
8. 情感操控（用赞美/贬低交替让你困惑→你越来越依赖TA的认可）
9. 嫉妒心强（你比TA成功TA要么贬低你要么疏远你）

【3阶段应对策略】
阶段1 - 识别后保持距离：跟自恋型的人保持社交/合作层面的关系可以，不要深交不要交心不要进入亲密关系（除非TA在专业心理咨询中）。
阶段2 - 不"喂养"TA的赞美需求：不要用过度赞美换取TA的好感（"你真厉害"→TA觉得你"配得上"跟TA交往，但只是工具人）。用平等的姿态交流，TA觉得"无趣"会主动远离。
阶段3 - 设立明确边界：TA越界（贬低你/操控你/利用你）时立刻明确回应。"我不接受你这样说我"+"这是我的决定"。NPD最怕"边界清晰不退让"的人。

【亲密关系中的NPD：PUA的高危人群】
NPD在亲密关系中常表现为"爱轰炸→贬低→操控"循环：
- 初期对你无微不至的关心赞美（让你上瘾）
- 关系稳定后开始贬低你（让你觉得自己不行）
- 用情绪操控（"你不听话我就..."）
- 隔离你跟朋友家人（让你只依赖TA）
出现这个循环=立即离开，NPD的亲密关系几乎都会变成消耗战。

【危险信号：什么时候该立即离开】
🚨 TA开始贬低你让你怀疑自己（"你怎么这么笨""你离了我怎么行"）
🚨 TA用情绪操控你（发脾气/冷战/威胁分手让你就范）
🚨 TA试图隔离你跟朋友家人
🚨 你跟TA在一起后越来越不自信、越来越不敢做决定
🚨 TA反复"分手-和好"循环（每次和好都像重新开始爱轰炸）
出现任何一个=立即警惕，多个同时出现=立即离开，不要试图"拯救"TA。

【核心原则】
NPD不能通过你的爱/理解/陪伴"治愈"——这是人格结构问题，需要长期专业心理咨询。你能做的是保护自己：识别+保持距离+设立边界+必要时离开。NPD的伴侣往往耗尽心力才意识到"我救不了TA"——请不要等到那时候。
''',
      tags: ['NPD', '自恋型人格', '爱轰炸', 'PUA', '立即离开', '边界'],
      relatedLevel: 0,
    ),

    const SocialKnowledgeEntry(
      id: 'K073',
      title: '投机取巧之人：钻空子的人如何识别与合作策略',
      category: '极端型人格识别',
      content: '''
有人总想找捷径——钻规则的空子、利用别人的疏忽、占各种"小便宜"。这类人看似精明，实则目光短浅+缺乏底线。识别TA是为了在合作中保护好自己。

【7个识别信号】
1. 总想找"特殊对待"（"我们关系这么好能不能给我打个折/通融一下"）
2. 利用规则的灰色地带（不是违法但是"打擦边球"）
3. 占小便宜不脸红（蹭饭/蹭车/蹭资源觉得是应该的）
4. 承诺快但不兑现（先答应下来再说，做不到时找借口）
5. 把别人的疏忽当机会（你忘了他记着，"上次你说..."）
6. 永远算计眼前利益（不看长远只看眼前得失）
7. 嘴上"为你好"实际"为自己"（包装得很合理但本质是利己）

【3条应对铁律】
🛡️ 合作前把规则落到白纸黑字：跟这类人合作最重要的是"先讲规则"。所有分工/利益分配/时间节点写清楚。口头承诺对TA没约束力。
🛡️ 不留灰色地带：规则要明确不要"到时候再说"。规则越清晰TA钻空子的空间越小。
🛡️ 不接受"通融"请求：TA说"通融一下"→"这个确实不行，按规则来"。你通融一次=TA知道你"可以谈"=下次变本加厉。

【合作中的3个保护机制】
机制1 - 所有重要沟通走书面：邮件/群聊留记录，不留口头把柄。TA嘴上说的转头可能不认。
机制2 - 关键节点亲自跟进：TA承诺的进度你要主动跟进，不能"等TA汇报"。每一步完成都要确认。
机制3 - 利益分配透明：所有利益相关的事情都让相关方知道，不留私下操作的余地。TA做不了手脚。

【关系深度的2条边界】
边界1 - 可合作不可深交：跟TA合作做事可以，但不要把TA当"可以交心的朋友"。TA的朋友=资源，你的秘密=TA的筹码。
边界2 - 不欠人情不留把柄：TA帮你的忙尽快等价还掉，TA的人情债利息高。不暴露你的弱点/秘密，TA会用。

【核心原则】
投机取巧型不是"坏人"——TA们只是按"利己+短视"的方式行事。你的任务是"用规则保护自己"而不是"试图改变TA"。规则清晰+书面留证+不接受通融=TA在你这里钻不到空子，自然会去找下一个目标。
''',
      tags: ['投机取巧', '钻空子', '占便宜', '先讲规则', '书面留证'],
      relatedLevel: 0,
    ),

    const SocialKnowledgeEntry(
      id: 'K074',
      title: '软弱无主见之人：没主见的人如何相处与帮助',
      category: '极端型人格识别',
      content: '''
有人什么事都没主见——"都行""你看吧""我不知道"。看起来随和，但跟TA相处你会很累：决定都你做、责任都你担、TA永远不表态。这类人不是"好人"，是"不敢选择的人"。

【6个识别信号】
1. 任何选择都"都行"（去哪/吃什么/怎么做都说"都行"）
2. 决定后抱怨（你按"都行"做TA事后说"其实我想要..."）
3. 不敢表达不同意见（明明不同意嘴上说"好的"）
4. 遇到冲突第一个撤（不想面对="我不想参与"）
5. 决定都让别人做（包括跟自己利益相关的事）
6. 你跟TA相处后觉得累（你需要替TA做所有决定）

【3个根本原因】
原因1 - 害怕冲突：怕不同意会让对方不高兴，宁可委屈自己。
原因2 - 害怕负责：怕选错了要承担后果，让别人选=别人负责。
原因3 - 缺乏自我认知：不知道自己真的想要什么，长期压抑需求。

【3条应对策略】
策略1 - 不替TA做决定：TA说"都行"→你也不做决定，等TA自己表态。"你说都行，但我想听你的真实想法"。
策略2 - 给TA选择而不是开放题：不要问"想吃什么"，问"想吃A还是B"——给具体选项让TA更容易选。
策略3 - 鼓励TA表达不同意见：TA说"好的"时确认"你是真的同意还是不想反对？我想听你的真实想法"。

【如果是亲密关系：3个引导方法】
方法1 - 让TA做"小决定"开始：从"今天吃什么"到"周末去哪"到"重要的事怎么决定"，逐步建立TA的选择信心。
方法2 - 接受TA的选择不评判：TA做了选择后不要立刻批评（"你怎么选这个"），先肯定"好，按你的来"。TA才会愿意继续选。
方法3 - 鼓励TA为自己发声：TA明明不同意时鼓励TA"我觉得你有不同想法，你说出来"。让TA知道"不同意是OK的"。

【什么时候该止损】
- 你长期被TA的决定责任拖累（你需要替TA决定工作/生活/关系大事）
- TA拒绝成长（你引导很多次TA依然"都行"，且不愿改变）
- TA用"都行"逃避责任（让选择变成你的责任）
- 你开始对TA产生怨气（"为什么你什么都不决定"）
出现以上任何一个→认真考虑关系深度。

【核心原则】
"都行"不是随和是逃避。你有义务帮TA成长但没义务替TA一辈子做决定。如果TA愿意成长，耐心引导；如果TA拒绝成长，拉开距离。你的能量应该用在值得的人身上，不是替一个"不敢选"的人买单一辈子。
''',
      tags: ['软弱无主见', '都行', '不敢选', '引导成长', '止损'],
      relatedLevel: 0,
    ),

    const SocialKnowledgeEntry(
      id: 'K075',
      title: '多疑之人：怀疑一切的人如何相处与建立信任',
      category: '极端型人格识别',
      content: '''
有人什么都要怀疑——你说的话TA要查证、你的动机TA要分析、你的行为TA要解读。看似"小心谨慎"，实则缺乏基本信任+消耗你。跟TA相处你会觉得"被审讯"。

【7个识别信号】
1. 反复确认你说的话（"你确定？""真的？""你不会骗我吧？"）
2. 解读你的每个行为（你回消息晚=TA觉得你在跟别人聊）
3. 查你的社交动态（朋友圈/微博/小红书反复看）
4. 问"为什么"特别多（你做任何事TA都要问原因）
5. 莫名其妙的"试探"（故意说错话看你的反应）
6. 你跟别人正常交流TA不高兴（解读为暧昧/亲密）
7. 你跟TA相处后觉得累（每句话都要"自证清白"）

【3条应对铁律】
🛡️ 不"自证清白"：TA怀疑你出轨→你不需要立刻交出手机/行程证明。你越证明=TA越觉得"可疑"=你越累。明确"我相信你，也希望你相信我，如果你不能，这是我们需要解决的问题"。
🛡️ 不被TA带节奏：TA反复问"你确定？"→你不需要重复解释。"我已经说过了，没有变"。
🛡️ 不进入TA的"猜疑循环"：TA开始解读你的行为时直接说"你想多了，我没那个意思，如果你不信我也没办法"。

【3阶段应对策略】
阶段1 - 识别后明确边界：第一次TA怀疑你时就要明确"我不接受这种沟通方式"。你的边界越早立=TA越早知道"猜疑没用"。
阶段2 - 用一致的行为重建信任：信任=时间×一致的行为。如果你做了破坏信任的事（说谎/出轨），重建需要几个月甚至更长时间。期间接受TA会怀疑，但用一致行为证明。
阶段3 - 严重时考虑离开：如果TA的多疑已经影响你的生活/工作/睡眠（你每天需要"自证"），或者TA拒绝承认问题/拒绝心理咨询=认真考虑离开。

【亲密关系中的多疑：警惕升级】
多疑在亲密关系中常升级为：
- 查手机/查岗（监控你的每个行为）
- 隔离你跟朋友家人（"TA对你有意思""TA不是好人"）
- 用情绪惩罚（你"可疑"时发脾气/冷战）
出现以上任何一个=这是控制型关系前兆（参考K062），不是单纯的"多疑"。

【如果是TA的"自我"问题】
多疑的本质是TA自己的不安全感+缺乏基本信任。你能做的是：①不破坏TA的信任（不说谎不隐瞒）；②不被TA的怀疑拖入"自证"循环；③明确你需要信任的关系。但TA的不安全感应该由TA自己解决（可能需要心理咨询），不是通过控制你。

【核心原则】
信任是关系的地基。一段没有基本信任的关系=每天都在审讯室里。你能给TA时间和一致的行为证明，但不能"自证清白"一辈子。如果TA的多疑无法改善且影响你的生活=这不是"TA太爱我"，是关系出了问题，需要专业帮助或考虑结束。
''',
      tags: ['多疑', '猜疑', '查岗', '不自我证明', '重建信任'],
      relatedLevel: 0,
    ),

    const SocialKnowledgeEntry(
      id: 'K076',
      title: '显摆型之人：爱炫耀的人如何相处与不被消耗',
      category: '极端型人格识别',
      content: '''
有人什么事都要显摆——买了什么、去了哪、认识谁、赚了多少。看似"分享"，实则需要不断被赞美+缺乏内在价值感。识别TA不是为了嘲笑TA，是为了不被TA的"显摆需求"消耗你。

【6个识别信号】
1. 任何话题绕回自己的"成就"（你聊A，TA聊TA的B）
2. 显摆"高价值"（价格/品牌/关系/收入）而不是真心的喜欢
3. 必须被赞美（你不夸TA会反复暗示直到你夸）
4. 贬低别人抬高自己（"我那个朋友做的没我好"）
5. 频繁发朋友圈晒（一天多条都是炫耀内容）
6. 你跟TA相处后觉得"被拉来当观众"（你的角色是捧哏）

【3条应对铁律】
🛡️ 不"喂"TA的赞美需求：TA显摆时不需要立刻"哇你好厉害"。可以"嗯，挺不错的"（平淡回应）→TA觉得"在你这里没意思"=不再跟你显摆。
🛡️ 不跟TA比：TA显摆你也开始显摆=你们进入"比拼"循环=双方都累。TA显摆TA的，你做你的。
🛡️ 不被TA的显摆引发焦虑：TA晒新手机/新工作/新对象→不需要反思"我是不是不够好"。TA的显摆是TA的需求不是你的问题。

【3种关系深度的策略】
深度1 - 必须维持的同事/熟人：聊安全话题，TA显摆时"嗯嗯"或者转移话题。不深交不交心。
深度2 - 已经成为朋友：观察TA显摆是否影响你们的友谊。如果TA能聊"非显摆"的内容=可继续；如果TA的话题永远围绕显摆=慢慢拉开距离。
深度3 - 亲密关系中的显摆型：伴侣必须不断被赞美是严重问题——TA的"价值感"建立在你的赞美上=你长期被消耗。TA需要自己建立内在价值，不是通过你的赞美。

【为什么TA会显摆】
显摆的本质是"缺乏内在价值感"——TA不知道自己是否值得爱/是否够好，需要通过外在的"高价值"+别人的"赞美"来确认。理解这一点不是为了纵容TA，是为了让你不把TA的显摆当攻击（"TA在嘲笑我吗"——不是，TA只是在求肯定）。

【核心原则】
显摆型的人最怕"不被赞美也不被否定"的回应——既不捧也不踩，平淡回应。你在TA这里"没意思"=TA去找下一个"观众"。你的能量应该用在值得的关系上，不是当别人的"赞美机器"。
''',
      tags: ['显摆', '炫耀', '求赞美', '不喂养', '平淡回应'],
      relatedLevel: 0,
    ),

    const SocialKnowledgeEntry(
      id: 'K077',
      title: '话痨型之人：说不完的人如何应对与有效沟通',
      category: '极端型人格识别',
      content: '''
有人一开口就停不下来——你插不上话、你听不完、你说什么TA都能绕回自己的话题。看似"热情"，实则缺乏倾听能力+需要被关注。识别TA是为了能跟TA有效沟通而不被TA的"话流"淹没。

【6个识别信号】
1. 一开口能说20分钟不停（不需要你的回应也能说）
2. 你插话TA立刻接过去说自己的（"我也是..."）
3. 不听你说话（你说话TA看手机/插话/明显走神）
4. 重复说同样的事（同一件事能说5次）
5. 你跟TA相处后嗓子疼耳朵疼（你说不到TA也说不停）
6. 别人说话TA必须"补充"（"对对对，我跟你讲..."）

【3条应对铁律】
🛡️ 不被TA的"话流"带节奏：TA说TA的你不必每句回应。可以"嗯嗯"+微笑让TA说，不需要每个细节都接。
🛡️ 主动"打断"不是没礼貌：等TA一句话停顿的瞬间→"等一下，我想确认一下，你刚才说的XX是不是..."（接住关键词+把话引回正题）。
🛡️ 不试图"听完"TA说的所有话：你不需要记住TA说的每个细节。听关键信息就够了，剩下的"嗯嗯"。

【3种场景应对策略】
场景1 - 工作沟通：明确时间+目标。"我们今天有15分钟，主要讨论X和Y，你直接说重点"。TA跑题时→"这个先放一放，我们回到X"。
场景2 - 朋友聊天：如果你真的想跟TA聊，主动设置"对话节奏"——TA说5分钟你说5分钟。TA不停→"哎让我也说几句"。
场景3 - 必须维持但不想深聊：找理由脱身。"我突然想起来还有点事，咱们改天再聊"。或者把TA当"背景音"——TA说TA的，你做你的（如果工作允许）。

【亲密关系中的话痨型】
伴侣不停说话是严重问题——你长期被"话流"淹没=你不被倾听=你的需求不被听见。需要明确："我也想说话，我想被听见"。如果TA不改=认真考虑关系深度。同时要警惕：有些话痨是焦虑/ADHD的表现，可能需要专业帮助。

【如果TA是家人/长辈】
家人/长辈话痨常是孤独/焦虑的表现。可以：①每周固定时间陪TA聊（满足TA的倾诉需求）；②引导TA做别的事（运动/兴趣/社交）转移倾诉需求；③必要时建议心理咨询（如果话痨是焦虑症状）。

【核心原则】
话痨型的人需要的不是"被听完"而是"被关注"。你能给TA有限度的关注（"我有15分钟"），但不需要被TA的"话流"淹没。你的时间是你的，学会"打断+引导+脱身"是跟这类人打交道的核心技能。
''',
      tags: ['话痨', '说不完', '打断', '时间限制', '不被淹没'],
      relatedLevel: 0,
    ),

    const SocialKnowledgeEntry(
      id: 'K078',
      title: '道德绑架型之人："我为你好"的人如何识别与抵抗',
      category: '极端型人格识别',
      content: '''
有人用"为你好""你应该""我为你付出了..."来绑架你——表面关心，实则让你按TA的意愿行事。识别TA是为了不被TA的"道德"绑架你的决定。

【7个识别信号】
1. "我为你好"是TA的开场白（每次干涉你的事都说这个）
2. "你应该..."（替你决定应该做什么不应该做什么）
3. "我为你付出了..."（拿过去的付出要求你回报）
4. "我都这个岁数了..."（拿身份要求你让步）
5. "你怎么这么不懂事"（用"懂事"绑架你）
6. "别人家孩子都..."（拿别人跟你比较让你内疚）
7. 你不同意TA就生气/委屈/冷战（用情绪惩罚你的"不听话"）

【3条抵抗铁律】
🛡️ 区分"建议"和"绑架"：建议="你可以考虑..."（你能选能不选）；绑架="你应该..."（你必须选）。建议尊重你的选择，绑架因你的选择而情绪化。
🛡️ 不为TA的"付出"内疚：TA当年为你做了什么，是TA的选择不是你的责任。你感谢TA但不欠TA一辈子。明确"我感谢你为我做的，但这不代表我必须按你的意愿做所有事"。
🛡️ 不被TA的"懂事"定义：你的"懂事"不是"听话"，是"为自己的人生负责"。TA说"你怎么这么不懂事"→"这是我的决定，我会自己负责"。

【3阶段应对策略】
阶段1 - 识别后心里有数：TA每次说"为你好"时心里清楚——这是绑架不是建议。不需要戳穿，心里有数就行。
阶段2 - 平静但坚定地拒绝：TA说"你应该..."→你"我听到了你的建议，但我有自己的考虑"。不需要解释理由（解释=给TA辩论空间）。
阶段3 - 不被TA的情绪操控：TA生气/委屈/冷战时不要立刻去哄。你的妥协=TA知道"绑架有效"=下次变本加厉。

【亲密关系中的道德绑架】
伴侣用"为你好"绑架你做决定是严重问题——TA不尊重你的独立性。你需要明确："我感谢你的关心，但这是我的决定"。如果TA持续这样=考虑关系深度。

【家人/长辈的道德绑架】
家人/长辈的道德绑架最常见也最难处理。3个应对要点：
- 感谢但不服从："谢谢你的关心，但我有自己的想法"
- 不内疚：TA当年的付出是TA的选择，你不需要为TA的选择买单一辈子
- 设置边界：明确哪些事你愿意听TA的，哪些事你坚持自己决定

【核心原则】
真正的"为你好"是尊重你的选择，不是替你做决定。任何用"为你好"绑架你的人，本质是想控制你。你的"懂事"是"为自己的人生负责"，不是"听话"。学会感谢但不服从，是抵抗道德绑架的核心。
''',
      tags: ['道德绑架', '为你好', '你应该', '不内疚', '感谢但不服从'],
      relatedLevel: 0,
    ),

    const SocialKnowledgeEntry(
      id: 'K079',
      title: '偏执型之人：认死理的人如何沟通与设置边界',
      category: '极端型人格识别',
      content: '''
有人认死理——TA认定的就是对的，任何反驳都被解读为"你不懂/你针对我/你被洗脑了"。看似"有原则"，实则缺乏弹性+多疑+拒绝接受新信息。识别TA是为了能跟TA有限沟通而不被TA拖入"无解循环"。

【7个识别信号】
1. 认定的观点绝对正确（任何反对都被解读为攻击）
2. 把不同意见当"针对"（"你是不是对我有意见"）
3. 反复说同样的话（用不同方式重复TA的观点）
4. 拒绝接受新信息（你说的事实TA"不信"）
5. 阴谋论倾向（"他们就是想..."）
6. 记仇（很久以前的小事TA记得清清楚楚）
7. 你跟TA辩论后觉得"被耗尽"（TA不进入你的逻辑，只重复自己的）

【3条应对铁律】
🚫 不试图说服TA：TA认定的就是对的，你说一万句TA也"不信"。你的能量应该用在别的地方，不是说服一个"不可说服"的人。
🚫 不进入"辩论循环"：TA开始重复TA的观点时直接"嗯，我听到了你的想法"（不接茬不辩论）。
🚫 不被TA的"针对"解读带偏：TA说"你是不是针对我"→"不是，我只是在讨论问题。如果你这么觉得我也没办法"。

【3种场景应对策略】
场景1 - 工作中的偏执同事：所有重要沟通走书面（邮件/群聊），避免口头争执。TA认定的方案有依据时按依据说话，没依据时让TA自己承担后果。
场景2 - 朋友/家人中的偏执型：聊安全话题不聊有争议的（政治/宗教/价值观）。TA开始"认死理"时转移话题。
场景3 - 亲密关系中的偏执型：TA的多疑+记仇+阴谋论会持续消耗你。需要明确"我不接受被怀疑"。如果TA拒绝改变=考虑离开。

【2个特别警告】
警告1 - 警惕"阴谋论"升级：偏执型的人容易陷入阴谋论，从"针对我"到"针对我们"到"全世界都...这是病态偏执前兆，需要专业帮助。
警告2 - 警惕"记仇"演变成报复：偏执型的记仇可能升级为报复行为。如果TA开始"算账"=注意保护自己（保留证据/不暴露弱点）。

【如果TA是家人/伴侣】
偏执型的家人/伴侣最难处理——你长期被TA的"认死理"消耗。3个应对要点：
- 不试图改变TA：偏执是性格结构，不是你说一句能改的
- 设立明确边界：聊什么不聊什么，做什么不做什
- 必要时寻求专业帮助：偏执型人格障碍需要专业治疗

【核心原则】
偏执型的人不可说服——TA活在TA的"逻辑"里，你的事实对TA无效。你能做的是"不试图说服+不进入辩论+设立边界"。你的能量应该用在值得沟通的人身上，不是跟一个"认死理"的人辩论一辈子。
''',
      tags: ['偏执', '认死理', '阴谋论', '不可说服', '不辩论'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K080',
      title: '如何脱单：从单身到恋爱的系统方法',
      category: '脱单方法论',
      content: '''
脱单不是"随便找个人凑合"，而是一套"先让自己值得被爱 + 主动扩大交集 + 把认识变成关系"的系统工程。很多人长期单身，不是不够好，而是卡在"等被遇见"这一步。

【第一步：把自己调到"可被喜欢"的状态】
- 生活有内容：有固定爱好、规律作息、能聊的事——生活越饱满，别人越想靠近
- 外形有底线：干净、得体、清爽，比"帅/美"更重要
- 情绪稳定：怨气重、负能量爆棚、把单身当受害者叙事，最劝退
- 动态有温度：偶尔分享生活/观点/小成就（不炫耀），给别人切入点

【第二步：系统扩大社交半径】
- 线下：兴趣班、运动社群、朋友聚会（让朋友带朋友）、行业沙龙、志愿者
- 线上：靠谱交友 APP、兴趣社区（即刻/小红书/豆瓣）、校友群/同乡群、游戏搭子群
- 原则：去"有共同语境"的场合，共同兴趣是最好的破冰借口

【第三步：从认识到关系】
- 三次法则：同一人三次正向互动后关系才真正开始
- 主动但不舔：主动邀约、主动关心没问题；秒回、下头、围着他转 = 扣分
- 轻量投入：让他/她为你做件小事（推荐店、帮你想主意），投入越多越在意
- 暧昧窗口：聊天频率上升、主动分享、会吃醋、不排斥肢体接触 → 该推一把
- 确认关系靠"做"不靠"问"：气氛到位自然牵手/叫昵称，比微信表白自然

【三大误区】
❌ 等缘分：不出门、不加群、不主动，概率永远是 0
❌ 只看颜值/条件：长期关系拼的是情绪价值、三观、靠谱度
❌ 舔狗式追求：单方面无限付出只让对方更不珍惜

【一句话】脱单 = 可被喜欢的状态 × 足够大的社交半径 × 敢于推进的行动力。
''',
      tags: ['脱单', '单身', '恋爱', '脱单方法论', '主动社交'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K081',
      title: '如何发现优秀朋友：线上线下全渠道识人指南',
      category: '拓展优质社交圈',
      content: '''
优秀的人不会从天而降，但会"留下痕迹"。发现优秀朋友的核心，是在线上线下多个渠道"看一个人的持续输出"，再判断是否值得深交。

【线上渠道：从内容看人】
- 抖音/快手/视频号：看长期发什么。持续分享干货/生活/观点的人有自己节奏；只发炫富、搬运、负能量的人谨慎
- 微信朋友圈：看互动质量与生活状态。干净、真实、不刻意精致更可信；半夜情绪化刷屏先保持距离
- QQ/兴趣部落/群：看群体里的角色——组织者、靠谱答疑者，还是只潜水抬杠
- 兴趣社区（小红书/豆瓣/即刻）：看长内容是否有逻辑、审美、共情力
- 网友/游戏搭子：先轻量合作（组队/拼单/讨论），观察靠谱度与情绪稳定，再决定是否进现实圈

【线下渠道：从行为看人】
- 朋友介绍：借共同朋友信用背书，质量最高
- 兴趣社群/运动局：一起做事时责任心、配合度、输赢态度一目了然
- 行业沙龙：聊专业同时看视野格局
- 志愿者/公益：愿无偿付出的人人品底线更高

【识人四信号】
1. 持续输出质量：长期稳定生产有价值内容/行动，而非一次惊艳
2. 三观一致：对钱、家人、陌生人、弱者的态度
3. 情绪稳定：遇糟心事解决问题还是炸毛迁怒
4. 靠谱度：答应的事做到没、约好的时间守没守

【从认识到深交】
观察 → 轻互动（评论/组队/请教）→ 小合作（探店/项目/运动）→ 深交（聊深层、互助、守密）

【避坑】
🚩 杀猪盘：刚认识带你"投资赚钱内部机会" = 拉黑
🚩 负能量黑洞：每次倒苦水贬低别人消耗你 = 限流
🚩 只索取不付出：永远你主动买单帮忙，对方无回馈 = 止损
🚩 人设崩塌：线上光鲜线下失联、说一套做一套 = 降权

【一句话】优秀朋友不是找来的，是在高质量场景里看出来、再养出来的。
''',
      tags: ['识人', '优秀朋友', '社交圈子', '抖音', '微信', 'QQ', '线上线下'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K082',
      title: '社交动态经营：朋友圈/QQ空间/抖音日常怎么发',
      category: '社交动态经营',
      content: '''
发动态不是"记录生活"那么简单——它是你在别人眼里的人设拼图。经营好朋友圈/QQ空间/抖音日常，能放大吸引力、靠谱感与亲和力。

【通用原则】
- 少炫耀多分享：晒成就配谦逊/幽默，比干晒招人喜欢
- 真实 > 精致：偶尔翻车/偷懒/平凡反而可亲近
- 积极为底色：可吐槽，但整体别长期负能量
- 保护隐私：住址、行程、车牌、证件、公司机密一律不打码不露
- 引发互动：结尾抛问题留钩子，比自说自话涨互动

【朋友圈】
- 频率：每周 2-4 条最舒适，刷屏会被默默屏蔽
- 结构：生活碎片 + 观点输出 + 偶尔成就，三件套轮换
- 互动：给别人评论走心，别人给你评论及时回
- 禁忌：半夜矫情长文、内涵特定人、全程抱怨

【QQ空间】
- 更私人更怀旧，适合发情绪、回忆、和熟人互动
- 说说配图走生活感，别照搬朋友圈精修图
- 留言板是关系温度计：常来留言的人是真在意你

【抖音/快手日常】
- 人设一致：一条线贯穿，别今天美食明天财经后天哭穷
- 选题来自生活：通勤、做饭、健身、宠物、工作花絮，越具体越有代入感
- 节奏：短视频重前 3 秒，开头给钩子（反差/疑问/干货预告）
- 频率稳定比爆款重要：每周 2-3 条持续更新更养粉
- 评论区经营：回复热评、接梗、制造记忆点，互动率决定推流

【避坑】
❌ 负能量刷屏 ❌ 过度精致假 ❌ 秒发秒删 ❌ 只发广告引流

【一句话】动态是你的第二张名片——经营好它，别人没见到你前就已先喜欢上你。
''',
      tags: ['社交动态', '朋友圈', 'QQ空间', '抖音', '个人品牌', '内容经营'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K083',
      title: '关系定位判断与应对策略（男性视角）：判断她把你当什么人、该升温还是止损',
      category: '关系分层与识人',
      content: '''
关系定位是社交和恋爱中最核心的判断能力——知道一个人把你当什么人，决定了你该投入多少、该采取什么策略。定位判断错了，轻则浪费时间精力，重则被当备胎消耗多年。

【核心本质】
定位的本质：是你对「她」价值的判断，不是「她」对你的态度。同一件事（她回复慢），可能因为她在忙，也可能因为她对你没兴趣——你需要结合多维信号综合判断，而不是凭单一行为下结论。

【她对你的四大定位类型】
1. 可发展对象：愿意投入时间和情绪，希望进一步升级关系（愿意单独约会、主动开启深度话题、在乎你的反馈）
2. 短期暧昧：享受当下互动但没有长期发展意愿（聊天很嗨但从不推进关系、有其他暧昧对象）
3. 长期朋友备胎：享受被追求的感觉但不打算升级（不拒绝不推进，让你一直投入）
4. 必须止损：明确信号表明不值得投入（对方有稳定伴侣、态度持续冷淡、明显单向消耗）

【升温/维持/降温/撤退的决策逻辑】
升温条件：她表现明确好感信号（主动约、深度聊天、在乎你的反馈），同时窗口期合适（单身、空窗、刚结束一段关系）
维持：她反馈正面但没有强烈信号，保持舒适感，不施压
降温：她反馈变冷或态度不明朗，减少投入，观察她的反应
撤退：她明确表态（只想做朋友）或出现消耗型关系特征

【止损信号】
- 她明确说"我们还是做朋友吧"且态度坚定
- 连续三周以上已读不回或敷衍回复（"嗯""哦""哈哈"）
- 她对你忽冷忽热，让你情绪持续波动
- 你发现这段关系里你一直在单向投入

【关系是动态的】定位不是一成不变的。朋友可以变成恋人，恋人也可能退回朋友。持续观察、动态调整，不要被"她今天把我当朋友"锁死判断。
''',
      tags: ['关系定位', '判断定位', '识人', '止损', '升温策略'],
      relatedLevel: 0,
    ),
    const SocialKnowledgeEntry(
      id: 'K084',
      title: '关系定位判断与应对策略（女性视角）：判断他把你当什么人、该跟进还是止损',
      category: '关系分层与识人',
      content: '''
女性同样需要判断男性对你的定位——他把你当认真发展的对象、短期暧昧、长期备胎还是普通朋友。判断失误，轻则浪费感情，重则被当备胎消耗。

【核心本质】
定位的本质：是你对「他」价值的判断，不是「他」对你的态度。他对你好可能是真心，也可能只是撩完就跑。需要结合多维信号综合判断，不能凭单一事件下结论。

【他对你的四大定位类型】
1. 可发展对象：愿意投入时间、金钱、精力，关注你的感受，希望建立长期关系（主动创造见面机会、在乎你的反馈、主动升级关系）
2. 短期暧昧：享受当下互动但没有长期发展意愿（聊天频繁但从不确定关系、有其他暧昧对象或稳定伴侣）
3. 长期备胎：享受被喜欢的感觉但不打算升级（不拒绝不推进，让你一直投入）
4. 必须止损：明确信号表明不值得投入（他有稳定伴侣、态度持续冷淡、明显单向消耗）

【升温/维持/降温/撤退的决策逻辑】
升温条件：他表现明确好感信号（主动约单独见面、记得你的细节、在朋友面前表现、在乎你的感受），同时窗口期合适（单身、空窗）
维持：正面反馈但没有强烈信号，保持舒适节奏
降温：反馈变冷或态度不明朗，减少投入，观察他的反应
撤退：他明确表态（只想做朋友）或出现消耗型关系特征

【止损信号】
- 他明确说"我们还是做朋友吧"或声称自己"不谈恋爱"但继续享受你的陪伴
- 他有稳定交往对象但仍和你保持暧昧
- 忽冷忽热、让你持续猜测他的想法
- 你发现这段关系里他从未把你纳入他的生活圈子
- 你一直在单向投入（主动、找话题、提供情绪价值），他很少主动

【关系是动态的】今天的备胎不代表永远是备胎，今天的朋友也可能变成恋人。持续观察、动态评估，不被静态判断锁死可能性。
''',
      tags: ['关系定位', '判断定位', '识人', '止损', '升级策略'],
      relatedLevel: 0,
    ),
  ];
}

// ============================================================================
// 教学模式（针对性场景）
// ============================================================================

/// 教学模式 — 针对不同社交目标提供定制化场景与对话
enum TeachingMode {
  general('通用', '适用于所有社交场景的通用技巧', Icons.people_outline_rounded),
  pursueFemale('追女生', '从认识到吸引女生的实战场景', Icons.favorite_outline_rounded),
  pursueMale('追男生', '从了解到打动男生的实战场景', Icons.man_outlined),
  maintainRelationship('维系关系', '已建立关系后的深度维护与升温', Icons.handshake_outlined),
  workplaceSocial('职场社交', '职场环境中的沟通与人际关系', Icons.work_outline_rounded),
  groupSocial('群体社交', '控场、主持、演讲等群体场景实战', Icons.groups_rounded),
  familyCommunication('家庭沟通', '亲子、长辈、伴侣家庭沟通技巧', Icons.family_restroom_rounded),
  strangerIcebreaking('陌生人破冰', '社交场合搭讪、破冰、建立连接', Icons.waving_hand_rounded),
  crossCulture('跨圈层社交', '不同背景圈层文化间沟通连接', Icons.public_rounded),
  onlineSocial('网络社交', '线上聊天、社交媒体互动技巧', Icons.chat_rounded),
  ;

  final String label;
  final String description;
  final IconData icon;
  const TeachingMode(this.label, this.description, this.icon);
}

/// 单个关卡在特定模式下的定制内容
class ModeLevelContent {
  final String scenarioDescription;   // 场景描述
  final String contactPersona;        // 对方画像
  final String contactMood;           // 对方情绪描述
  final String openingMessage;        // 开场白（NPC 第一句话）
  final List<String> goodKeywords;    // 加分关键词
  final String referenceReply;        // 参考话术
  final List<String> relatedKnowledgeIds; // 关联知识条目ID列表

  const ModeLevelContent({
    required this.scenarioDescription,
    required this.contactPersona,
    required this.contactMood,
    required this.openingMessage,
    required this.goodKeywords,
    required this.referenceReply,
    this.relatedKnowledgeIds = const [],
  });
}

/// 模式专属内容注册表
///
/// 为每个 (mode, level) 组合提供定制化的场景、画像、开场白、关键词和参考话术。
/// 通用模式（general）返回 null，表示使用关卡默认内容。
class ModeContentRegistry {
  ModeContentRegistry._();

  /// 获取特定模式下的关卡定制内容，返回 null 表示使用默认内容
  static ModeLevelContent? getContent(TeachingMode mode, int level) {
    final modeMap = _registry[mode];
    if (modeMap == null) return null;
    return modeMap[level];
  }

  static final Map<TeachingMode, Map<int, ModeLevelContent>> _registry = {
    // ==================== 追女生 ====================
    TeachingMode.pursueFemale: {
      1: ModeLevelContent(
        scenarioDescription: '你在朋友聚会上注意到一个女生，她正独自看手机。你想上前搭话，但不想显得太刻意。',
        contactPersona: '25岁女生，性格偏内敛，对陌生人略有防备但不排斥有趣的开场',
        contactMood: '平静，对搭讪保持礼貌但有距离感',
        openingMessage: '（女生注意到你走过来，礼貌性地笑了笑，但目光很快回到手机上）嗯，你好。',
        goodKeywords: ['聚会', '朋友', '有趣', '觉得', '你也', '今天'],
        referenceReply: '嗨，看你一直在看手机——是不是也被朋友拉来的？今天这聚会人还挺多的，你是小林的同事还是大学同学？',
        relatedKnowledgeIds: ['K001', 'K010', 'K012'],
      ),
      2: ModeLevelContent(
        scenarioDescription: '你成功搭上话了，女生问"你是做什么的？"。这是展示你价值的好机会，但不能吹嘘。',
        contactPersona: '对男生的职业和能力有好奇心，但反感吹嘘和过度表现',
        contactMood: '好奇，愿意了解你更多',
        openingMessage: '（女生放下手机，身体微微转向你）你是做什么工作的呀？',
        goodKeywords: ['做', '喜欢', '最近', '有意思', '研究', '接触'],
        referenceReply: '我是做产品设计的——最近在研究怎么让社交APP更懂人。说起来挺好玩的，你呢？看你气质挺像做创意类工作的。',
        relatedKnowledgeIds: ['K002', 'K011', 'K030'],
      ),
      3: ModeLevelContent(
        scenarioDescription: '女生开始聊她最近遇到的一件烦心事，语气有点低落。你需要让她感觉被倾听，而不是急着给建议。',
        contactPersona: '需要情感共鸣而非理性建议，希望对方能"听懂"她的感受',
        contactMood: '低落中带着倾诉欲，想被理解',
        openingMessage: '（女生叹了口气）最近工作上遇到一个人真的很难搞，我跟朋友吐槽她们都说我想太多...但真的很烦。',
        goodKeywords: ['理解', '不容易', '感受', '换我', '确实', '然后呢', '听起来'],
        referenceReply: '听起来真的很消耗精力。被人说"想太多"反而更委屈吧——你已经很克制了。后来呢，你怎么处理的？',
        relatedKnowledgeIds: ['K003', 'K005', 'K011'],
      ),
      4: ModeLevelContent(
        scenarioDescription: '聊了一阵后出现短暂沉默。你需要自然地引出新话题，让对话不冷场，同时找到共同兴趣。',
        contactPersona: '对有共同兴趣的话题会明显兴奋，反感硬找话题的尴尬感',
        contactMood: '轻松但有冷场风险，等待你接话',
        openingMessage: '（沉默了两秒，女生看了看四周）所以...你平时周末一般做什么呀？',
        goodKeywords: ['说到', '对了', '你也', '喜欢', '最近', '试过', '推荐'],
        referenceReply: '说到周末，我最近迷上了城市徒步——不设目的地走到哪算哪。上次还发现了一家超隐蔽的书店。你呢？你是那种喜欢宅家还是到处跑的类型？',
        relatedKnowledgeIds: ['K004', 'K014', 'K015'],
      ),
      5: ModeLevelContent(
        scenarioDescription: '女生聊到最近的挫折，语气明显低落。这是一个建立深度连接的关键时刻——如果你能正确回应她的情绪。',
        contactPersona: '情绪敏感，需要被看见和认可，讨厌"别想太多"式的廉价安慰',
        contactMood: '沮丧脆弱，需要被接住',
        openingMessage: '（女生低下头，声音变小）有时候觉得自己做什么都不对...工作也不顺，感情也一塌糊涂。',
        goodKeywords: ['不容易', '理解', '如果是我', '坚持', '已经', '听你说', '在的'],
        referenceReply: '能感觉到你现在真的很累。这些事情堆在一起，换谁都会觉得喘不过气。但你知道吗——你愿意说出来，本身就很勇敢。我在这里听你说。',
        relatedKnowledgeIds: ['K005', 'K007', 'K010'],
      ),
      6: ModeLevelContent(
        scenarioDescription: '你们对某个话题产生了分歧（比如电影品味），她坚持自己的看法。你需要保持氛围轻松，不让分歧变成争论。',
        contactPersona: '有自己明确的喜好，不喜欢被否定，但欣赏能接受不同观点的人',
        contactMood: '略带防备，但不是真的生气',
        openingMessage: '（女生微微撅嘴）不行，那部片子真的被高估了！剧情完全站不住脚——你别告诉我你觉得好看。',
        goodKeywords: ['理解', '确实', '有道理', '不过', '试试', '说不定', '各有'],
        referenceReply: '哈哈好吧，确实剧情有几处硬伤。不过我是因为配乐太上头了才加分的——但你说得对，单看故事确实差点意思。你有没有那种别人都说好但你觉得一般的？',
        relatedKnowledgeIds: ['K006', 'K023', 'K011'],
      ),
      7: ModeLevelContent(
        scenarioDescription: '聊天气氛很好，她开始聊一些更私人的话题。这是把关系从"聊得来的 acquaintance"推向"有好感的人"的窗口。',
        contactPersona: '开始对你有好感，愿意分享更深层的东西，但需要你先迈出一步',
        contactMood: '放松且开放，隐含期待',
        openingMessage: '（女生放松地靠着沙发，笑着说）跟你说实话，其实我不是那种很外向的人。能跟你聊这么久还挺意外的。',
        goodKeywords: ['其实', '也是', '真的', '觉得', '跟你', '自在', '开心'],
        referenceReply: '其实我也是——跟不熟的人聊天经常会找不到话题。但今天跟你聊感觉特别自然，好像认识了很久一样。你有没有那种"一拍即合"的感觉？',
        relatedKnowledgeIds: ['K007', 'K013', 'K021'],
      ),
      8: ModeLevelContent(
        scenarioDescription: '你想约她周末一起去一个有趣的活动（比如市集或展览），但她有些犹豫。你需要激发她的兴趣，降低她的决策成本。',
        contactPersona: '对邀约有轻微防备，但如果活动有趣且没有压力就愿意尝试',
        contactMood: '犹豫但友善，需要被推动',
        openingMessage: '（女生有些犹豫）市集啊...我对那些手工艺品不太懂诶，去了会不会很无聊？',
        goodKeywords: ['一起', '试试', '有趣', '体验', '简单', '随时', '附近', '陪你'],
        referenceReply: '完全不用担心！其实最有趣的是吃东西——有几家小吃摊排队能排半小时但绝对值。我们可以先去逛逛，觉得无聊随时撤，附近还有家不错的咖啡馆。怎么样？',
        relatedKnowledgeIds: ['K008', 'K019', 'K018'],
      ),
      9: ModeLevelContent(
        scenarioDescription: '你之前因为一件事让她不开心，她已经两天没回你消息了。你需要发一条真诚的道歉，而不是找借口。',
        contactPersona: '受伤但内心希望你主动来修复，反感敷衍的道歉和找借口',
        contactMood: '冷淡但留有窗口',
        openingMessage: '（隔了两天后她终于回复）嗯。',
        goodKeywords: ['抱歉', '不对', '我错', '以后', '弥补', '理解', '不该', '机会'],
        referenceReply: '我知道这次是我做得不对——没有先问你的想法就做了决定，让你觉得不被重视。这不是你的问题，是我没处理好。以后碰到这种事我一定先跟你商量。如果你愿意，我想当面跟你聊聊。',
        relatedKnowledgeIds: ['K009', 'K026', 'K020'],
      ),
      10: ModeLevelContent(
        scenarioDescription: '综合场景：从初次相识到产生好感，中间经历一次小摩擦并修复。你需要展示从破冰到邀约的完整链路。',
        contactPersona: '动态变化：从礼貌防备→开放好感→小摩擦→修复后更亲近',
        contactMood: '场景动态变化',
        openingMessage: '（朋友聚会上，她正和闺蜜聊天，看到你走过来，笑着打了个招呼）嘿，你来了！这是我朋友小雅——我刚才还跟她提到你呢。',
        goodKeywords: ['你好', '认识', '有趣', '理解', '抱歉', '一起', '开心', '聊聊'],
        referenceReply: '（微笑着）嗨小雅，听她提过我？希望说的都是好话（笑）。对了，刚才聊到那个话题我后来想了想——你说得确实有道理。下次有机会一起再聊聊？',
        relatedKnowledgeIds: ['K001', 'K007', 'K009', 'K019', 'K022'],
      ),
    },

    // ==================== 追男生 ====================
    TeachingMode.pursueMale: {
      1: ModeLevelContent(
        scenarioDescription: '你在朋友聚会上看到一个男生，他正在角落看一本书。你想上前搭话，但又不想太主动。',
        contactPersona: '28岁男生，偏理性内敛，对突兀搭讪有防备但对有共同话题的人很健谈',
        contactMood: '平静，对搭讪保持适度好奇',
        openingMessage: '（男生抬头看了你一眼，礼貌地点了点头）嗯，你好。',
        goodKeywords: ['书', '看', '有趣', '觉得', '推荐', '你也'],
        referenceReply: '嗨，刚才看到你在看那本——是《思考，快与慢》吗？我之前一直想看但没机会。你觉得怎么样，值得入手吗？',
        relatedKnowledgeIds: ['K001', 'K012', 'K038'],
      ),
      2: ModeLevelContent(
        scenarioDescription: '你成功搭上话了，男生问"你平时做什么？"。你需要展示自己的有趣一面，而不是简单回答职业。',
        contactPersona: '对有自己兴趣爱好的女生有好感，反感只会说"就上班呗"的无趣回答',
        contactMood: '好奇，在评估你是否有意思',
        openingMessage: '（男生合上书，看向你）那你是做什么的？看你气质挺特别的。',
        goodKeywords: ['做', '喜欢', '最近', '研究', '有趣', '接触', '迷上'],
        referenceReply: '我是做数据分析的——听起来很枯燥对吧？但最近迷上了用数据预测电影票房，意外地好玩。你呢？看你在看书，感觉你是那种喜欢深度思考的人。',
        relatedKnowledgeIds: ['K002', 'K030', 'K038'],
      ),
      3: ModeLevelContent(
        scenarioDescription: '男生开始聊他最近做的一个项目，说得很投入。你需要展示你在认真听，而不是等他说完好插话。',
        contactPersona: '讲起技术/项目会很兴奋，希望对方能跟上节奏，讨厌被敷衍',
        contactMood: '兴奋分享中，在意你的反应',
        openingMessage: '（男生眼睛亮了起来）你知道吗，最近我们在做的这个系统——它的核心架构其实用了一个很巧妙的思路...（说得越来越投入）',
        goodKeywords: ['然后呢', '厉害', '意思是', '所以', '后来', '了不起'],
        referenceReply: '等一下，所以你的意思是——用这个方式可以在不增加服务器的情况下把性能翻倍？那后来上线了吗？效果怎么样？',
        relatedKnowledgeIds: ['K003', 'K011', 'K038'],
      ),
      4: ModeLevelContent(
        scenarioDescription: '聊完技术话题后出现短暂沉默。你需要自然地切换到更轻松的话题，找到你们的共同兴趣。',
        contactPersona: '工作之外有自己的爱好（游戏/运动/旅行），对有共同爱好的女生会明显加分',
        contactMood: '轻松，等待新话题',
        openingMessage: '（男生停了一下，喝了口饮料）所以...你周末一般做什么？不会也是加班吧（笑）。',
        goodKeywords: ['说到', '对了', '你也', '喜欢', '最近', '玩', '试过'],
        referenceReply: '说到周末——最近被朋友拉去玩了一次攀岩，结果意外地喜欢上了。虽然爬完胳膊疼了三天。你呢？你是那种宅家打游戏还是会出去运动的类型？',
        relatedKnowledgeIds: ['K004', 'K014', 'K015'],
      ),
      5: ModeLevelContent(
        scenarioDescription: '男生难得地聊到了一次失败的经历，语气有些低落。你需要接住他的情绪，而不是急着给解决方案。',
        contactPersona: '很少展示脆弱面，如果分享了说明开始信任你，讨厌被说"没事的"',
        contactMood: '少见的低落，有些后悔和自我怀疑',
        openingMessage: '（男生沉默了一会，声音低了下去）其实上次那个项目...最后还是没成。带了三个月的团队，白忙了。',
        goodKeywords: ['不容易', '理解', '三个月', '不白费', '坚持', '学到', '确实'],
        referenceReply: '三个月的投入说放弃就放弃，换谁都会难受。但这三个月你带团队的方式、踩过的坑——这些不是白费的。你从中学到的那些东西，下一个项目肯定用得上。',
        relatedKnowledgeIds: ['K005', 'K007', 'K030'],
      ),
      6: ModeLevelContent(
        scenarioDescription: '你们对某个话题产生了分歧（比如某款游戏好不好玩）。他比较固执，你需要保持轻松，不让讨论变成辩论。',
        contactPersona: '有自己的观点且比较坚持，但尊重能理性讨论的人，反感无脑反对',
        contactMood: '认真但不是生气，享受有质量的讨论',
        openingMessage: '（男生摇了摇头）不行，塞尔达的开放世界设计是划时代的——你不能因为画风不喜欢就否定整个游戏体系。',
        goodKeywords: ['理解', '确实', '有道理', '不过', '试试', '可能', '角度'],
        referenceReply: '你说得对，开放世界设计确实是它的核心优势——我只是个人不太适应那个画风。但从游戏设计的角度，它确实开创了一个新标准。你有没有玩过既好看又好玩的开放世界？',
        relatedKnowledgeIds: ['K006', 'K023', 'K038'],
      ),
      7: ModeLevelContent(
        scenarioDescription: '聊天气氛很好，他开始聊一些不那么理性的话题（比如对未来的想法）。这是建立深度连接的窗口。',
        contactPersona: '开始展示感性面，如果你能接住会大大加分',
        contactMood: '罕见地放松和开放',
        openingMessage: '（男生靠着椅背，看着远处）其实有时候我也在想——现在做的这些到底是为了什么。说起来挺好笑的，我小时候其实想做的是完全不一样的事。',
        goodKeywords: ['其实', '梦想', '如果', '真的', '小时候', '想过', '觉得'],
        referenceReply: '大多数人到最后都走了跟小时候完全不同的路吧。不过你愿意想这个问题本身就很厉害了——很多人忙到连"为什么"都不问了。如果完全不用考虑现实，你最想做什么？',
        relatedKnowledgeIds: ['K007', 'K013', 'K010'],
      ),
      8: ModeLevelContent(
        scenarioDescription: '你想约他周末一起去参加一个活动（比如游戏展或攀岩），但他通常周末有自己的安排。你需要让他觉得这个邀约值得改变计划。',
        contactPersona: '周末时间比较固定，但如果活动够有趣且跟你一起去没有压力就愿意',
        contactMood: '犹豫，在衡量值不值得',
        openingMessage: '（男生想了想）游戏展啊...我之前去过几次感觉人太多了。而且那个周末我本来打算在家打个新出的DLC。',
        goodKeywords: ['一起', '试试', '有趣', '体验', '简单', '附近', '值得', '听说'],
        referenceReply: '人确实多，但这次有个独立游戏展区据说特别好——而且我知道一家店在展馆旁边，逛完可以去吃。DLC晚上回来打也不迟嘛。就当换换脑子？',
        relatedKnowledgeIds: ['K008', 'K019', 'K018'],
      ),
      9: ModeLevelContent(
        scenarioDescription: '你之前爽约了一次，他有些不高兴，回复变得很简短。你需要真诚道歉并修复，而不是找借口。',
        contactPersona: '不喜欢被放鸽子，但如果道歉真诚可以接受，反感找一堆借口',
        contactMood: '冷淡但不是完全拒绝',
        openingMessage: '（隔了一天的回复）没事，我理解你忙。',
        goodKeywords: ['抱歉', '不对', '我错', '以后', '弥补', '不该', '机会', '理解'],
        referenceReply: '说实话这次是我做得不对——答应了又临时取消，换成我也会不爽。不是忙不忙的问题，是我没安排好。这周末的时间留给你，你来定，我绝对不鸽。',
        relatedKnowledgeIds: ['K009', 'K026', 'K020'],
      ),
      10: ModeLevelContent(
        scenarioDescription: '综合场景：从认识到有好感，中间经历一次小摩擦并修复。展示从破冰到邀约的完整链路。',
        contactPersona: '动态变化：从礼貌→好感→小摩擦→修复后更亲近',
        contactMood: '场景动态变化',
        openingMessage: '（朋友聚会上，他看到你走过来，笑着举了举杯子）嘿，你来了！刚才还在跟老张说你上次推荐的那个播客——我听完觉得挺有启发的。',
        goodKeywords: ['你好', '认识', '有趣', '理解', '抱歉', '一起', '开心', '聊聊', '推荐'],
        referenceReply: '（笑着坐下）真的吗？那期确实很赞。对了，上次说的事情我后来想了想——你说得对，我确实太着急了。这周末那个展你去不去？就当赔罪我请你喝咖啡。',
        relatedKnowledgeIds: ['K001', 'K007', 'K009', 'K019', 'K021'],
      ),
    },

    // ==================== 维系关系 ====================
    TeachingMode.maintainRelationship: {
      1: ModeLevelContent(
        scenarioDescription: '你和伴侣/好友已经有一段时间没好好聊天了。你想主动发起一次有质量的对话，而不是停留在"吃了没"的日常。',
        contactPersona: '你的伴侣或好友，最近因为忙碌两人交流变少，有些被忽略的感觉',
        contactMood: '平静但有些疏远感，等待你的主动',
        openingMessage: '（对方正在看手机，听到你说话才抬起头）嗯？怎么了？',
        goodKeywords: ['最近', '觉得', '想聊', '今天', '记得', '一起', '开心'],
        referenceReply: '没什么特别的事，就是觉得最近咱俩都在忙，好久没好好聊了。今天怎么样？有没有什么有趣的事？',
        relatedKnowledgeIds: ['K018', 'K024', 'K014'],
      ),
      2: ModeLevelContent(
        scenarioDescription: '对方问你最近在忙什么。你需要真诚分享，而不是简单说"就那些事"，让对方感受到你愿意让ta参与你的生活。',
        contactPersona: '关心你的状态，但不想追问太多，希望你自己主动分享',
        contactMood: '关心中带着一点试探',
        openingMessage: '（对方放下手机看向你）你最近都在忙什么呀？感觉每天回来都很晚。',
        goodKeywords: ['做', '最近', '其实', '跟你说', '有意思', '累', '开心'],
        referenceReply: '最近在赶一个新项目，确实挺忙的。不过有个好玩的事——我们团队来了个新同事，超级有趣，改天介绍你们认识。你呢？最近怎么样，有没有什么开心的或者烦心的？',
        relatedKnowledgeIds: ['K024', 'K002', 'K014'],
      ),
      3: ModeLevelContent(
        scenarioDescription: '对方开始聊一件让ta不太开心的事。你需要做到深度倾听，而不是急着给建议或评判。',
        contactPersona: '需要被倾听而非被指导，希望你说"我理解你"而不是"你应该"',
        contactMood: '有些委屈，需要被接住',
        openingMessage: '（对方叹了口气）今天跟同事闹了点不愉快...算了，说了你肯定觉得是小事。',
        goodKeywords: ['理解', '不会', '感受', '然后呢', '不容易', '听你说', '确实'],
        referenceReply: '不会觉得是小事——让你不舒服的事就不小。你跟我说说，我不评价，就听着。到底怎么了？',
        relatedKnowledgeIds: ['K003', 'K005', 'K011'],
      ),
      4: ModeLevelContent(
        scenarioDescription: '你们聊完正事后出现沉默。你需要自然地引出一个轻松的话题，让氛围回暖。',
        contactPersona: '聊完沉重话题后需要轻松过渡，不喜欢一直停留在负面情绪里',
        contactMood: '轻松了一些，等待话题转换',
        openingMessage: '（对方笑了笑）好了不说这些了。对了，咱俩好像好久没出去玩了？',
        goodKeywords: ['说到', '对了', '记得', '上次', '一起', '试试', '想去'],
        referenceReply: '说到这个——上次咱俩说的那个新开的日料店还记得吗？听说他们家 limited menu 超赞。要不这周末去试试？顺便逛逛那条街。',
        relatedKnowledgeIds: ['K004', 'K019', 'K025'],
      ),
      5: ModeLevelContent(
        scenarioDescription: '对方向你倾诉一件很在意的事，情绪明显低落。这是一个加深感情的关键时刻。',
        contactPersona: '脆弱时刻，需要你的共情而不是解决方案',
        contactMood: '低落脆弱，需要被深深理解',
        openingMessage: '（对方眼眶有点红）我知道不该为这种事难过...但就是控制不住。觉得自己好差劲。',
        goodKeywords: ['理解', '不容易', '如果是我', '已经', '在的', '不会', '听你说', '了不起'],
        referenceReply: '你不是差劲，你是太在意了才会难过。换我遇到一样的事，可能比你还难受。你不用觉得自己不该难过——你的感受是真实的。我在这里，你说，我听着。',
        relatedKnowledgeIds: ['K005', 'K007', 'K030'],
      ),
      6: ModeLevelContent(
        scenarioDescription: '你们对一件事产生了分歧（比如该不该花钱做某事）。你需要用非暴力沟通的方式处理，不升级为争吵。',
        contactPersona: '有自己的立场，但不是不能商量，反感被否定或被说"你不对"',
        contactMood: '有些激动但本质上想解决问题',
        openingMessage: '（对方有些不满）我就不明白了，为什么每次我提个想法你都先否定？',
        goodKeywords: ['理解', '确实', '担心', '觉得', '试试', '一起', '你说得对'],
        referenceReply: '你说得对，我确实有这个习惯——不是故意的，但我能理解这让你很烦。你先说说你的想法，我这次好好听完再回应，行吗？',
        relatedKnowledgeIds: ['K006', 'K026', 'K023'],
      ),
      7: ModeLevelContent(
        scenarioDescription: '你们关系很稳定，但有些"太熟了"的平淡感。你需要主动发起一次有深度的对话，为关系注入新的活力。',
        contactPersona: '对关系有安全感但觉得少了点新鲜感，期待一些不同',
        contactMood: '放松但略有倦怠',
        openingMessage: '（对方窝在沙发上看你）怎么了？今天怎么突然这么认真。',
        goodKeywords: ['其实', '觉得', '最近', '想', '一起', '如果', '记得'],
        referenceReply: '其实也没什么大事...就是突然想到，咱俩好像很久没有好好聊过"我们"了。最近有没有什么你觉得特别开心或者想改变的？我想听听你真实的感受。',
        relatedKnowledgeIds: ['K025', 'K007', 'K027'],
      ),
      8: ModeLevelContent(
        scenarioDescription: '你想邀请对方一起尝试一件新事物（比如学做菜/一起去旅行），但对方觉得麻烦。你需要用正向方式推动。',
        contactPersona: '对改变routine有些抗拒，但如果被说动了会很享受',
        contactMood: '犹豫，觉得麻烦',
        openingMessage: '（对方皱了皱眉）做菜？我们都不会啊，而且收拾起来好麻烦...',
        goodKeywords: ['一起', '试试', '简单', '有趣', '体验', '失败', '好玩', '不用'],
        referenceReply: '不用做多复杂的——就从一道最简单的开始，失败了就点外卖，成功了我们就多一道拿手菜。而且一起做菜的过程本身就挺好玩的。试试嘛，就当体验一下？',
        relatedKnowledgeIds: ['K025', 'K019', 'K021'],
      ),
      9: ModeLevelContent(
        scenarioDescription: '你最近因为忙忽略了对方，ta已经明显不开心了。你需要主动修复，而不是等对方自己消化。',
        contactPersona: '受伤但不会主动说，希望你能自己意识到并来弥补',
        contactMood: '冷淡疏远，内心等你来修复',
        openingMessage: '（对方的回复很简短）嗯，知道了。',
        goodKeywords: ['抱歉', '不对', '最近', '忽略了', '以后', '弥补', '理解', '机会'],
        referenceReply: '最近是我做得不好——忙到把你忽略了，这不该找借口。你对我来说很重要，我不想让你觉得被冷落。以后再忙我也会每天抽时间跟你好好聊聊。这周末的时间留给你，你想做什么我都陪你。',
        relatedKnowledgeIds: ['K009', 'K026', 'K020'],
      ),
      10: ModeLevelContent(
        scenarioDescription: '综合场景：从日常破冰到深度对话，经历一次小摩擦并修复。展示维系一段关系所需的全部能力。',
        contactPersona: '动态变化：从平淡→深入→摩擦→修复后更紧密',
        contactMood: '场景动态变化',
        openingMessage: '（对方在沙发上刷手机，看到你走过来坐到旁边，放下手机）嗯？今天怎么这么早回来。',
        goodKeywords: ['最近', '觉得', '想聊', '理解', '抱歉', '一起', '开心', '记得', '试试'],
        referenceReply: '今天提前收工了，想回来跟你待会儿。最近感觉咱俩都在各忙各的——我想好好跟你聊聊天。你今天怎么样？有没有什么想说的？',
        relatedKnowledgeIds: ['K024', 'K007', 'K009', 'K025', 'K018'],
      ),
    },

    // ==================== 职场社交 ====================
    TeachingMode.workplaceSocial: {
      1: ModeLevelContent(
        scenarioDescription: '你是新入职的员工，在茶水间遇到了一位其他部门的同事。你需要自然地打招呼并建立联系。',
        contactPersona: '其他部门的资深同事，对新面孔保持礼貌但不会主动热络',
        contactMood: '中性，保持职业社交距离',
        openingMessage: '（同事倒完咖啡，看到你，礼貌地点了点头）你好，新来的？',
        goodKeywords: ['部门', '负责', '认识', '请教', '有趣', '一起'],
        referenceReply: '对，我是产品部新来的。您是技术部的吧？之前听HR提到过您——好像负责的是后端架构？以后肯定有很多要请教的地方。',
        relatedKnowledgeIds: ['K001', 'K037', 'K036'],
      ),
      2: ModeLevelContent(
        scenarioDescription: '同事问你之前在哪里工作。你需要展示经验但不过度吹嘘，建立专业形象。',
        contactPersona: '在评估你的背景和能力，对夸大其词的人会迅速失去兴趣',
        contactMood: '职业性好奇',
        openingMessage: '（同事靠在茶水间台面旁）你之前是在哪家公司？做什么方向的？',
        goodKeywords: ['做', '负责', '之前', '主要', '有意思', '学习', '接触'],
        referenceReply: '之前在一家做教育科技的创业公司，负责产品设计。规模不大但学到很多——尤其是怎么在资源有限的情况下快速迭代。这边流程更规范，我也在适应中。你呢？在这边多久了？',
        relatedKnowledgeIds: ['K002', 'K038', 'K030'],
      ),
      3: ModeLevelContent(
        scenarioDescription: '同事开始分享他最近做的一个项目。你需要展示专业倾听能力，同时表达对ta工作的尊重。',
        contactPersona: '资深同事，分享项目是在试探你的专业水平，在意你是否能跟上',
        contactMood: '专业分享中，观察你的反应',
        openingMessage: '（同事来了兴致）最近我们在做一个微服务拆分的项目——说实话比预想的复杂多了，光是服务边界的界定就讨论了两周。',
        goodKeywords: ['然后呢', '意思是', '所以', '厉害', '具体', '后来', '学到'],
        referenceReply: '微服务拆分确实是最难的是边界界定——你们是用领域驱动设计的方式吗？两周讨论其实不算久，很多团队在这上面卡一两个月的。后来定下来了吗？',
        relatedKnowledgeIds: ['K003', 'K038', 'K011'],
      ),
      4: ModeLevelContent(
        scenarioDescription: '茶水间闲聊后出现短暂沉默。你需要自然地延续话题，找到工作之外的共同点。',
        contactPersona: '愿意建立工作之外的连接，但不急于暴露私人生活',
        contactMood: '轻松，等待新话题',
        openingMessage: '（同事看了看手表）对了，你平时中午都在哪吃？',
        goodKeywords: ['说到', '对了', '附近', '推荐', '一起', '试过', '听说'],
        referenceReply: '还在摸索中——昨天去了楼下那家牛肉面，味道还不错。你知道吗这附近有啥好吃的？改天一起去探探？',
        relatedKnowledgeIds: ['K004', 'K036', 'K022'],
      ),
      5: ModeLevelContent(
        scenarioDescription: '同事聊到最近项目压力很大，语气有些疲惫。你需要展现共情，同时保持职业边界。',
        contactPersona: '资深同事难得展示疲惫，需要被理解但不需要你教他怎么做',
        contactMood: '疲惫中带着倾诉欲',
        openingMessage: '（同事揉了揉太阳穴）最近加班太多了...老婆都开始有意见了。但项目节点摆在那里，不可能不赶。',
        goodKeywords: ['理解', '不容易', '确实', '辛苦', '注意', '休息', '如果需要'],
        referenceReply: '确实，这个项目节奏太紧了。你这边扛的压力大家都看在眼里——但也别忘了注意身体，毕竟长跑比冲刺重要。如果有什么我能帮忙的尽管说，虽然我是新来的但多少能分担一些。',
        relatedKnowledgeIds: ['K005', 'K037', 'K031'],
      ),
      6: ModeLevelContent(
        scenarioDescription: '你在会议上与同事对方案产生了分歧。会后你需要主动沟通，化解可能的紧张关系。',
        contactPersona: '对自己的专业判断很自信，不会轻易认错，但尊重能理性讨论的人',
        contactMood: '会议上有些不快，但愿意私下沟通',
        openingMessage: '（同事看到你走过来，表情有些微妙）嗯？会上那事你还想聊？',
        goodKeywords: ['理解', '确实', '有道理', '担心', '试试', '一起', '你说得对'],
        referenceReply: '其实你会上说的那个点我后来想了想——确实有道理，我之前没考虑到那个风险。我会上提的方案也不是非要那样，咱们能不能坐下来聊聊，看看有没有结合两个方案的思路？',
        relatedKnowledgeIds: ['K006', 'K042', 'K023'],
      ),
      7: ModeLevelContent(
        scenarioDescription: '你和这位同事已经比较熟了。你想把关系从"工作搭档"推向"信任的伙伴"。需要适时展示一些真实的一面。',
        contactPersona: '已经对你有专业信任，但还不确定是否值得深交',
        contactMood: '开放但保持职业距离',
        openingMessage: '（同事靠在椅背上，放松了一些）说起来，你来也快三个月了——感觉怎么样？适应了吗？',
        goodKeywords: ['其实', '真的', '学到', '觉得', '如果', '想', '感谢'],
        referenceReply: '说实话，刚来的时候确实有点不适应——流程比之前公司规范很多，沟通方式也不一样。但这三个月跟你学到了很多，尤其是在架构设计上的思路。如果有机会的话，以后想跟你多做一些深度合作的项目。',
        relatedKnowledgeIds: ['K007', 'K030', 'K028'],
      ),
      8: ModeLevelContent(
        scenarioDescription: '你想邀请这位同事一起参加一个行业活动（技术沙龙），但他觉得周末不想加班社交。你需要降低门槛。',
        contactPersona: '周末时间宝贵，对"社交性工作活动"兴趣不大，但如果有实际价值愿意考虑',
        contactMood: '犹豫，觉得没必要',
        openingMessage: '（同事想了想）技术沙龙啊...说实话周末我一般不想出去社交，平时已经够累了。',
        goodKeywords: ['一起', '试试', '有趣', '简单', '听说', '值得', '附近', '不用'],
        referenceReply: '理解，周末确实想歇。不过这个沙龙据说质量很高——而且就在公司附近，两个小时就结束。咱们去听听，万一有收获呢？结束了附近吃个饭就回，不占太多时间。第一次去我也想找个伴，你就当陪我？',
        relatedKnowledgeIds: ['K008', 'K037', 'K038'],
      ),
      9: ModeLevelContent(
        scenarioDescription: '你之前在会议上说错了一句话让同事有些难堪。你需要找机会私下道歉，修复专业关系。',
        contactPersona: '表面上没说什么但心里记着，如果你主动来修复会大大加分',
        contactMood: '表面正常但内心有芥蒂',
        openingMessage: '（同事看到你走过来，表情正常但少了平时的随意）嗯？什么事？',
        goodKeywords: ['抱歉', '不对', '会上', '不该', '以后', '理解', '没注意'],
        referenceReply: '上次会上那个事——我不该当着那么多人的面直接质疑你的方案，应该私下先跟你沟通的。不是说你方案有问题，是我表达方式不对。以后有不同意见我一定先跟你单独聊。不好意思啊。',
        relatedKnowledgeIds: ['K009', 'K026', 'K042'],
      ),
      10: ModeLevelContent(
        scenarioDescription: '综合场景：从新入职破冰到建立深度信任，经历一次专业分歧并修复。展示职场社交的完整链路。',
        contactPersona: '动态变化：从礼貌→认可→分歧→修复后更信任',
        contactMood: '场景动态变化',
        openingMessage: '（同事在茶水间看到你，笑着打招呼）嘿，来了？我刚跟总监提到你——上次那个方案他印象很深。',
        goodKeywords: ['感谢', '认识', '一起', '理解', '抱歉', '试试', '学到', '聊聊'],
        referenceReply: '真的吗？那太好了——说实话那个方案有你之前给我的建议在里面。对了，上次会上那事我一直想再跟你聊聊，其实你说得对...这周末那个技术沙龙你去吗？一起？',
        relatedKnowledgeIds: ['K001', 'K007', 'K009', 'K042', 'K028'],
      ),
    },

    // ==================== 群体社交（控场/主持/演讲） ====================
    TeachingMode.groupSocial: {
      1: ModeLevelContent(
        scenarioDescription: '你主持一个5人小组会议，大家到齐后无人发言，气氛略显沉闷。你需要破冰并让大家参与进来。',
        contactPersona: '4位同事，性格各异，有人内向有人强势，都在等主持人开场',
        contactMood: '被动等待，略带疲惫',
        openingMessage: '（会议室安静下来，4双眼睛看向你）……',
        goodKeywords: ['开始', '今天', '大家', '先', '觉得', '一起', '聊聊'],
        referenceReply: '好，咱们开始吧。今天议程有三个点，但先问一句——这周末都过得怎么样？（笑）我看到小王精神特别好，先分享一下你的周末？',
        relatedKnowledgeIds: ['K040', 'K041'],
      ),
      2: ModeLevelContent(
        scenarioDescription: '小组讨论中两位成员对方案产生分歧，气氛开始紧张。你需要作为主持人化解冲突并推进讨论。',
        contactPersona: 'A坚持技术方案，B坚持用户体验优先，互不相让',
        contactMood: '对峙紧张，其他人沉默观望',
        openingMessage: '（A拍桌子）这个架构根本撑不住！B你不懂技术就别瞎指挥。——（B反驳）用户才不管你架构好不好！',
        goodKeywords: ['理解', '都有道理', '其实', '结合', '试试', '换个角度', '一起'],
        referenceReply: '停一下——两位说的都有道理。A担心的是技术可行性，B在意的是用户体验，这两个目标其实不矛盾。我们能不能先列出必须满足的用户场景，再反推架构？',
        relatedKnowledgeIds: ['K042', 'K006'],
      ),
      3: ModeLevelContent(
        scenarioDescription: '你正在做一场15分钟的产品介绍演讲，讲到第5分钟发现后排观众开始看手机。你需要重新抓住注意力。',
        contactPersona: '20人听众，前排投入后排走神',
        contactMood: '注意力分化',
        openingMessage: '（你讲到技术细节时，后排有人开始刷手机）……',
        goodKeywords: ['说到', '其实', '举个', '大家', '想象', '有没有', '对了'],
        referenceReply: '说到这里，举个实际的例子——大家想象一下，你早上赶时间打开APP，结果加载了10秒。是不是瞬间想卸载？这就是为什么我们把这个指标放在第一位。在座有多少人遇到过这种情况？',
        relatedKnowledgeIds: ['K043', 'K010'],
      ),
      4: ModeLevelContent(
        scenarioDescription: '团队建设活动中突然出现冷场，大家吃完饭各自玩手机。你需要作为组织者重新激活气氛。',
        contactPersona: '10人团队，饭后犯困，各自低头看手机',
        contactMood: '低能量，慵懒',
        openingMessage: '（餐桌上安静下来，有人开始刷手机，气氛有点尴尬）……',
        goodKeywords: ['对了', '玩个', '游戏', '有趣', '试试', '谁', '上次'],
        referenceReply: '对了！别刷手机了——咱们玩个游戏吧，特简单：每人说一件自己今年的糗事，最离谱的那个免单。谁先来？老张你上次说的那个事我一直想听完整版！',
        relatedKnowledgeIds: ['K044', 'K022'],
      ),
      5: ModeLevelContent(
        scenarioDescription: '你主持一场部门季度复盘会，需要让大家坦诚反思不足。但大家都报喜不报忧，气氛表面和谐实则回避问题。',
        contactPersona: '8位组长，都报喜不报忧，怕暴露问题被追责',
        contactMood: '表面配合实则防御',
        openingMessage: '（轮到第三个组长汇报）我们组这季度……整体还行，没什么大问题。（大家附和点头）',
        goodKeywords: ['其实', '说实话', '我也有', '坦诚', '一起', '改进', '不追责'],
        referenceReply: '先停一下——大家说的成绩我都记下了，但今天这个会的目的是找问题。我先说我自己这季度的失误：判断错了两个需求优先级。希望每个人也说一个自己做得不够的地方。今天是复盘不是追责，坦诚说才能改进。',
        relatedKnowledgeIds: ['K045', 'K007'],
      ),
      6: ModeLevelContent(
        scenarioDescription: '年会上你作为部门负责人上台发言，前排领导面无表情，后排员工窃窃私语。你需要用开场打破僵局。',
        contactPersona: '50人听众，领导严肃员工散漫',
        contactMood: '正式冷淡',
        openingMessage: '（你走上台，话筒试音，台下窃窃私语还没停）……',
        goodKeywords: ['先', '问', '其实', '今年', '大家', '一个', '故事'],
        referenceReply: '先别聊了——（停顿，微笑等安静）谢谢。上台前领导跟我说"讲短点"，我一看PPT准备了40页……所以今天我就讲三件事，每件不超过3分钟。先问一句：今年加过班的人举手？（等举手）好，看来在座都是自己人。',
        relatedKnowledgeIds: ['K046', 'K008'],
      ),
      7: ModeLevelContent(
        scenarioDescription: '你正在主持一场跨部门协调会，有人突然提出一个尖锐问题质疑你的方案，全场气氛凝固。你需要得体回应并维持秩序。',
        contactPersona: '20人跨部门会议，质疑者声音大，其他人观望',
        contactMood: '紧张对峙',
        openingMessage: '（市场部李总打断）等一下，你这个方案根本没考虑我们的KPI，让我们怎么配合？',
        goodKeywords: ['理解', '好问题', '确实', '其实', '一起', '会后', '补充'],
        referenceReply: '李总这个问题问得很关键——确实，这个方案在市场侧KPI的衔接上考虑得不够充分。我先把这个问题记下来，会后专门跟你们部门对齐。今天的会先推进其他议题，不在这个点上卡住。大家觉得呢？',
        relatedKnowledgeIds: ['K047', 'K006'],
      ),
      8: ModeLevelContent(
        scenarioDescription: '团队聚餐时大家聊到敏感话题（薪资差异），气氛突然尴尬。你需要巧妙转移话题化解尴尬。',
        contactPersona: '8人聚餐，有人无意提到薪资，有人尴尬有人好奇',
        contactMood: '尴尬凝固',
        openingMessage: '（小王喝了点酒）说起来，你们技术部工资是不是比我们高很多啊？……（全桌安静）',
        goodKeywords: ['哈哈', '说到', '对了', '其实', '换', '来', '别'],
        referenceReply: '哈哈小王你这是想让我们技术部请客啊！说到请客——这家店的服务员刚才说他们家有个隐藏菜单，谁敢试试？我请。来来来，先点菜，工资的事改天咱们单独聊（眨眼）。',
        relatedKnowledgeIds: ['K048', 'K023'],
      ),
      9: ModeLevelContent(
        scenarioDescription: '你主持的活动严重超时，台下有人开始离场。你需要果断收尾而不让内容烂尾。',
        contactPersona: '30人活动，原定2小时已超30分钟，有人开始收拾东西',
        contactMood: '焦躁等待结束',
        openingMessage: '（你看到后排有人站起来准备离开，主持人小声提醒"还有3个议题"）……',
        goodKeywords: ['时间', '最后', '重要', '总结', '一句', '谢谢', '会后'],
        referenceReply: '各位，看到有人要走了——时间确实超了，是我的问题。剩下三个议题我各用一句话说完核心结论，详细内容会后发文档。第一……第二……第三……今天就到这里，感谢大家耐心！会后有问题随时找我。',
        relatedKnowledgeIds: ['K040', 'K046'],
      ),
      10: ModeLevelContent(
        scenarioDescription: '综合场景：从会议开场破冰→处理分歧→演讲互动→化解尴尬→果断收尾，展示完整的群体控场链路。',
        contactPersona: '动态变化：从被动→紧张→走神→尴尬→焦躁',
        contactMood: '场景动态变化',
        openingMessage: '（你走上台，50人会场安静下来，话筒试音）……',
        goodKeywords: ['开始', '大家', '理解', '一起', '其实', '最后', '总结', '谢谢'],
        referenceReply: '好，开始吧。今天我想聊三件事——但在开始前，先问大家一个问题：过去一周，有多少人觉得开会浪费时间？（等举手）好，今天我保证不让你们白来。咱们从最难的那个议题开始……',
        relatedKnowledgeIds: ['K040', 'K041', 'K042', 'K043', 'K044', 'K045', 'K046', 'K047', 'K048'],
      ),
    },

    // ==================== 家庭沟通（亲子/长辈） ====================
    TeachingMode.familyCommunication: {
      1: ModeLevelContent(
        scenarioDescription: '你7岁的孩子从学校回来情绪低落，不愿说话。你需要用正确的方式打开ta的话匣子。',
        contactPersona: '7岁孩子，在学校受了委屈，性格内向',
        contactMood: '低落沉默，需要安全感',
        openingMessage: '（孩子放下书包，低头坐在沙发上，不看你）……',
        goodKeywords: ['今天', '怎么了', '想', '跟', '说', '没关系', '慢慢'],
        referenceReply: '宝贝，过来坐。（拍拍身边位置）今天好像不太开心？不着急说，先喝口水。想说了随时跟爸爸/妈妈讲，不管什么事我们都在。',
        relatedKnowledgeIds: ['K003', 'K005'],
      ),
      2: ModeLevelContent(
        scenarioDescription: '你15岁的孩子最近成绩下滑，你想跟ta谈谈，但ta一回家就关房门。你需要找到合适的沟通方式。',
        contactPersona: '15岁青春期少年，反感说教，渴望被尊重',
        contactMood: '防备烦躁',
        openingMessage: '（你敲门，里面传来不耐烦的声音）干嘛？',
        goodKeywords: ['不是', '就是', '想', '聊聊', '你觉得', '不打扰', '尊重'],
        referenceReply: '不是来查作业的。就是想跟你聊聊——最近看你压力挺大的。要不今晚出去吃个饭？你选地方。不上课不讲道理，就吃饭聊天。',
        relatedKnowledgeIds: ['K033', 'K028'],
      ),
      3: ModeLevelContent(
        scenarioDescription: '你60多岁的父亲反复念叨同一件事，你已经听了很多遍，开始烦躁。你需要耐心应对而不伤他的心。',
        contactPersona: '65岁父亲，退休后孤独，反复说过去的事',
        contactMood: '念叨中带着寻求关注',
        openingMessage: '（父亲又开始说）跟你说过没有，以前在工厂的时候……（第三次说同一件事）',
        goodKeywords: ['嗯', '是', '后来', '那', '当时', '一起', '下次'],
        referenceReply: '爸，这事您跟我说过，但我想听您再讲讲后面的——当时那个决定是怎么做出来的？我觉得您那时候特别不容易。对了，这周末带您去钓鱼怎么样？上次您说想去的。',
        relatedKnowledgeIds: ['K037', 'K003'],
      ),
      4: ModeLevelContent(
        scenarioDescription: '你和伴侣因为家务分工问题产生摩擦，对方已经开始冷战。你需要主动破冰而不是等对方先开口。',
        contactPersona: '你的伴侣，觉得家务不公平，用沉默表达不满',
        contactMood: '冷淡赌气',
        openingMessage: '（伴侣在厨房洗碗，你走进去，对方没回头）嗯？',
        goodKeywords: ['对不起', '最近', '其实是', '一起', '以后', '觉得', '帮你'],
        referenceReply: '最近是我做得不好——碗都是你在洗我都没注意。其实不是不想做，是没意识到。以后碗归我洗，你教我用那个洗碗机就行。今晚换我做饭？',
        relatedKnowledgeIds: ['K009', 'K025'],
      ),
      5: ModeLevelContent(
        scenarioDescription: '你青春期的孩子跟你说"我不想上大学了"。你需要先理解而非说教，避免把ta推远。',
        contactPersona: '17岁高二学生，对升学迷茫，渴望被理解',
        contactMood: '叛逆中带着求助',
        openingMessage: '（孩子突然说）我不想考大学了，没意思。',
        goodKeywords: ['为什么', '觉得', '想', '其实', '理解', '没关系', '聊聊'],
        referenceReply: '先别急，跟我说说——是哪方面觉得没意思？是学习本身累，还是觉得考大学没意义？我不是来劝你的，就是想听听你怎么想的。你说的每一句我都认真听。',
        relatedKnowledgeIds: ['K005', 'K033', 'K029'],
      ),
      6: ModeLevelContent(
        scenarioDescription: '你母亲总是催你结婚，每次电话都提。这次她又提了，你需要温和而坚定地表达边界。',
        contactPersona: '60岁母亲，焦虑你的婚事，出于关心但方式让你窒息',
        contactMood: '操心唠叨',
        openingMessage: '（电话那头）隔壁王阿姨的女儿都生二胎了，你到底什么时候……',
        goodKeywords: ['妈', '知道', '关心', '但是', '我自己', '别', '聊'],
        referenceReply: '妈，我知道您是关心我。但每次打电话都说这个，我会有压力反而更不想聊。我的事我自己有数，您放心。咱聊点别的——您最近广场舞练得怎么样了？上次说要去比赛。',
        relatedKnowledgeIds: ['K006', 'K037'],
      ),
      7: ModeLevelContent(
        scenarioDescription: '你父亲生病住院但坚持不让告诉你太多，怕你担心。你从妹妹那里才知道实情。你需要跟他沟通让他敞开心扉。',
        contactPersona: '70岁父亲，倔强要强，不想拖累子女',
        contactMood: '故作轻松实则不安',
        openingMessage: '（父亲看到你来医院，有点慌）你怎么来了？没事没事，就是小检查……',
        goodKeywords: ['爸', '其实', '跟我说', '别', '担心', '一起', '没事'],
        referenceReply: '爸，小妹都跟我说了。您别瞒着我——我不是来怪您的，就是想跟您一起面对。检查结果怎么样？医生怎么说？您跟我说实话，我才能帮您想办法。咱爷俩还有什么不能说的？',
        relatedKnowledgeIds: ['K005', 'K037'],
      ),
      8: ModeLevelContent(
        scenarioDescription: '你想说服70岁的母亲去体检，但她坚持说自己没事，嫌浪费钱。你需要用对的方式打动她。',
        contactPersona: '70岁母亲，节俭怕花钱，讳疾忌医',
        contactMood: '抗拒推脱',
        openingMessage: '（母亲摆手）不去不去，我好着呢，花那个冤枉钱干嘛！',
        goodKeywords: ['妈', '不是', '钱', '其实', '担心', '陪我', '一起'],
        referenceReply: '妈，这个钱不冤枉——您要是真没事，我就彻底放心了；万一小问题早发现，反而省大钱。这样，您不是一直说腰疼吗？就当去查查腰，顺便全面查一下。您陪我去查我也顺便查，就当陪我？',
        relatedKnowledgeIds: ['K008', 'K037'],
      ),
      9: ModeLevelContent(
        scenarioDescription: '你10岁的孩子在学校跟同学打架被老师投诉。你需要既不偏袒也不过度责备，搞清真相。',
        contactPersona: '10岁男孩，委屈又害怕，觉得会被骂',
        contactMood: '紧张防备',
        openingMessage: '（孩子低着头站在你面前，老师刚打完电话）……',
        goodKeywords: ['发生', '为什么', '先', '说', '不是', '理解', '一起'],
        referenceReply: '先坐下。老师说了情况，但我想听你说——到底发生了什么？不着急，慢慢说。我不是来骂你的，就是想搞清楚。你先说你的版本，好不好？',
        relatedKnowledgeIds: ['K003', 'K032', 'K006'],
      ),
      10: ModeLevelContent(
        scenarioDescription: '综合场景：从倾听孩子→化解青春期冲突→应对长辈念叨→修复伴侣关系→说服父母就医，展示家庭沟通的完整能力。',
        contactPersona: '动态变化：孩子→伴侣→父母，各年龄段',
        contactMood: '场景动态变化',
        openingMessage: '（下班回家，孩子沉默、伴侣冷脸、母亲电话响起）……',
        goodKeywords: ['回来', '今天', '怎么了', '一起', '理解', '慢慢', '聊', '别'],
        referenceReply: '都先别急——我回来了。宝贝先去洗手，饭菜马上好。（转向伴侣）今天辛苦了，我来做。（接电话）妈，我在做饭，吃完给您回过去。咱们一件一件来，不着急。',
        relatedKnowledgeIds: ['K003', 'K005', 'K006', 'K009', 'K032', 'K033', 'K037'],
      ),
    },

    // ==================== 陌生人破冰（搭讪/社交场合） ====================
    TeachingMode.strangerIcebreaking: {
      1: ModeLevelContent(
        scenarioDescription: '你在咖啡店看到一个人在看书，想搭话但不想显得冒犯。你需要用自然的方式开启对话。',
        contactPersona: '陌生读者，专注看书，对打扰保持礼貌距离',
        contactMood: '专注平静',
        openingMessage: '（对方抬头看了你一眼，礼貌微笑后准备继续看书）嗯？',
        goodKeywords: ['不好意思', '看到', '书', '觉得', '推荐', '打扰'],
        referenceReply: '不好意思打扰了——就是看到你在看那本书，我之前一直想买。觉得怎么样？如果好的话我也入手一本。不打扰你看书，就问这一句。',
        relatedKnowledgeIds: ['K001', 'K040'],
      ),
      2: ModeLevelContent(
        scenarioDescription: '你在朋友聚会上认识了一个新面孔，对方独自站着。你需要上前搭话并找到共同话题。',
        contactPersona: '新人，不认识其他人，略显拘谨',
        contactMood: '拘谨等待',
        openingMessage: '（对方看到你走过来，礼貌地点头）你好。',
        goodKeywords: ['你好', '认识', '怎么', '朋友', '第一次', '有趣'],
        referenceReply: '嗨，我是XX，小林的朋友。你呢？也是他大学同学吗？——哦原来是同事，那你是做什么的？看你气质挺像做创意的。',
        relatedKnowledgeIds: ['K002', 'K001'],
      ),
      3: ModeLevelContent(
        scenarioDescription: '你在行业活动茶歇时遇到一位业内前辈，想上前请教但怕打扰。你需要得体地发起交流。',
        contactPersona: '业内资深前辈，正独自喝咖啡',
        contactMood: '放松开放',
        openingMessage: '（前辈看到你走近，微笑）你好，有事吗？',
        goodKeywords: ['老师', '不好意思', '听过', '分享', '想', '请教', '打扰'],
        referenceReply: '老师您好，我是XX公司的产品经理。之前听过您那次关于用户增长的分享，受益很多。有个问题一直想请教——您方便聊两分钟吗？不方便的话我加个微信以后再请教？',
        relatedKnowledgeIds: ['K035', 'K008'],
      ),
      4: ModeLevelContent(
        scenarioDescription: '你在排队时旁边的人很有趣，想搭话但不知如何开口。你需要利用"共处境"自然破冰。',
        contactPersona: '排队的陌生人，看手机，心情不错',
        contactMood: '无聊放松',
        openingMessage: '（对方注意到你在看他，抬头）嗯？',
        goodKeywords: ['这', '队', '好久', '听说', '你也是', '对吧', '有趣'],
        referenceReply: '这队也太长了——你也是冲着他们家新品来的？我朋友说排了两小时，我还不信。你试过他们家其他的吗？有没有推荐？',
        relatedKnowledgeIds: ['K001'],
      ),
      5: ModeLevelContent(
        scenarioDescription: '你在健身房看到一个经常来的"眼熟陌生人"，想正式认识一下。你需要自然地从"脸熟"过渡到"认识"。',
        contactPersona: '健身爱好者，专注训练，对搭话不排斥',
        contactMood: '训练中专注',
        openingMessage: '（对方摘下耳机，擦汗时看到你）嗯？',
        goodKeywords: ['经常', '看到', '你也是', '练', '不错', '请教', '一起'],
        referenceReply: '嘿，经常看到你练——你那个硬拉动作特别标准。我是XX，经常这个时间来。你练几年了？我正想找人纠正一下动作，方便的话一起练？',
        relatedKnowledgeIds: ['K010', 'K002'],
      ),
      6: ModeLevelContent(
        scenarioDescription: '你在社交活动上搭话成功，但聊了几句后出现冷场。你需要自然延续话题而不让对话干涸。',
        contactPersona: '刚认识的陌生人，礼貌但话题有限',
        contactMood: '礼貌等待，准备找借口离开',
        openingMessage: '（对方笑了笑，眼神开始游移）嗯……是吧。',
        goodKeywords: ['对了', '说到', '其实', '你呢', '最近', '有没有', '有趣'],
        referenceReply: '对了，说到这个——你平时周末一般做什么？我最近想找个新爱好，感觉除了上班就是宅。你有没有什么推荐？哪怕是小众的也行。',
        relatedKnowledgeIds: ['K004'],
      ),
      7: ModeLevelContent(
        scenarioDescription: '你在聚会上跟一个人聊得很投机，想交换联系方式但不想太刻意。你需要自然地提出加微信。',
        contactPersona: '聊得来的新朋友，开放但不主动',
        contactMood: '愉快放松',
        openingMessage: '（对方笑着说完一个故事）哈哈你说得太逗了。',
        goodKeywords: ['微信', '加', '聊', '有趣', '下次', '一起', '推荐'],
        referenceReply: '跟你聊天太有意思了——对了加个微信？上次你说的那本书我想推荐给我朋友，回头发我书名。下次有这种聚会我叫你？',
        relatedKnowledgeIds: ['K007'],
      ),
      8: ModeLevelContent(
        scenarioDescription: '你在公共场合搭话一个陌生人，但对方反应冷淡，明显不想聊天。你需要体面地结束对话而不尴尬。',
        contactPersona: '不想被搭话的陌生人，礼貌但冷淡',
        contactMood: '冷淡回避',
        openingMessage: '（对方简短回应）嗯，谢谢。（然后继续看手机）',
        goodKeywords: ['不好意思', '打扰', '那', '没事', '谢谢', '拜拜'],
        referenceReply: '不好意思打扰了，那你先忙。祝今天愉快！',
        relatedKnowledgeIds: ['K029'],
      ),
      9: ModeLevelContent(
        scenarioDescription: '你在社交场合说错了一句话，对方明显不高兴。你需要真诚道歉并挽回气氛。',
        contactPersona: '被你的话冒犯的新认识的人',
        contactMood: '不悦戒备',
        openingMessage: '（对方笑容消失，语气变冷）你这话什么意思？',
        goodKeywords: ['对不起', '不是', '意思', '说错', '抱歉', '其实', '不好意思'],
        referenceReply: '对不起对不起——我刚才那句话说得太随便了，不是那个意思。我重新说：我的意思是XXX。如果让你不舒服了真的很抱歉，是我表达有问题。',
        relatedKnowledgeIds: ['K009'],
      ),
      10: ModeLevelContent(
        scenarioDescription: '综合场景：从咖啡店搭话→找到共同话题→冷场救场→交换联系方式→说错话道歉，展示陌生人破冰的完整链路。',
        contactPersona: '动态变化：从陌生人→聊得来→冷场→修复→建立连接',
        contactMood: '场景动态变化',
        openingMessage: '（咖啡店里，对方正在看一本你也喜欢的书）……',
        goodKeywords: ['不好意思', '看到', '你好', '对了', '微信', '一起', '有趣', '聊'],
        referenceReply: '不好意思——看到你在看《XX》，我也超喜欢这本。你是第几次看？对了，你是做什么的？感觉喜欢这本书的人都有点意思。加个微信？下次有好看的书互相推荐。',
        relatedKnowledgeIds: ['K001', 'K002', 'K003', 'K004', 'K007', 'K009'],
      ),
    },

    // ==================== 跨圈层社交（跨文化/跨背景） ====================
    TeachingMode.crossCulture: {
      1: ModeLevelContent(
        scenarioDescription: '你参加一个跨行业沙龙，周围都是不同领域的人。你需要找到一个"万能话题"跟任何人都能聊起来。',
        contactPersona: '不同行业的陌生人，对"你做什么"这个问题已经厌倦',
        contactMood: '社交疲劳',
        openingMessage: '（对方礼貌但敷衍）你好，你是做什么的？',
        goodKeywords: ['其实', '有趣', '最近', '说到', '你呢', '觉得', '有意思'],
        referenceReply: '别问行业了——先说个有趣的：你最近有没有遇到一件让你特别意外的事？不管什么领域都行。我发现不同行业的人，意外的事完全不一样，特别有意思。',
        relatedKnowledgeIds: ['K004', 'K039'],
      ),
      2: ModeLevelContent(
        scenarioDescription: '你跟一个学历背景完全不同的人聊天，对方用了很多你听不懂的专业术语。你需要不暴露无知又保持对话。',
        contactPersona: '高学历专业人士，习惯用术语，不是故意卖弄',
        contactMood: '投入分享',
        openingMessage: '（对方兴奋地说）所以我们用的是transformer架构，attention机制解决了RNN的梯度消失问题……',
        goodKeywords: ['然后', '意思是', '所以', '具体', '简单说', '后来', '厉害'],
        referenceReply: '等一下，我想确认理解对了——意思是它解决了之前模型"记不住长内容"的问题？那后来效果提升明显吗？抱歉不是这个领域的，但听起来挺厉害的，你继续说。',
        relatedKnowledgeIds: ['K003', 'K035'],
      ),
      3: ModeLevelContent(
        scenarioDescription: '你跟一个年龄差很大（比你大20岁）的人聊天，对方觉得你"太年轻不懂"。你需要用尊重打破代沟。',
        contactPersona: '比你大20岁的前辈，觉得年轻人没经验',
        contactMood: '居高临下但不恶意',
        openingMessage: '（前辈笑着说）你们年轻人啊，想法是好的，但太天真了。',
        goodKeywords: ['您说', '是', '确实', '学习', '不过', '请教', '觉得'],
        referenceReply: '您说得对，确实经验不足。不过我们这代人接触的信息方式不太一样，有些新方法可能也值得试试。您那时候是怎么处理类似问题的？我想跟您学学经验。',
        relatedKnowledgeIds: ['K036', 'K008'],
      ),
      4: ModeLevelContent(
        scenarioDescription: '你跟一个来自不同文化背景的人交流，对方的沟通方式跟你很不同（更直接/更委婉）。你需要适应而不误解。',
        contactPersona: '来自直接文化背景的人，说话不绕弯',
        contactMood: '直率坦诚',
        openingMessage: '（对方直接说）你这个想法不行，太复杂了。',
        goodKeywords: ['理解', '其实', '直接', '喜欢', '确实', '不过', '试试'],
        referenceReply: '我喜欢你这么直接——确实，我这个方案复杂了。你说的对，能不能简化？你觉得核心应该保留什么？我也想听听你的思路。',
        relatedKnowledgeIds: ['K030', 'K006'],
      ),
      5: ModeLevelContent(
        scenarioDescription: '你跟一个圈子完全不同的人（比如艺术家vs工程师）聊天，思维方式差异巨大。你需要找到连接点。',
        contactPersona: '艺术家思维，感性表达，觉得工程师不懂美',
        contactMood: '略带偏见',
        openingMessage: '（对方有点不屑）你们做技术的，是不是什么都讲效率？',
        goodKeywords: ['其实', '理解', '但是', '觉得', '也有', '有趣', '学习'],
        referenceReply: '确实我们习惯量化一切——但说实话，有些东西量化不了，比如一幅画给你的感觉。我其实特别羡慕你们能用感觉创作。你最近在做什么作品？我想听听你的创作过程。',
        relatedKnowledgeIds: ['K030', 'K007'],
      ),
      6: ModeLevelContent(
        scenarioDescription: '你跟一个社会地位很高的人交流，对方气场强大。你需要不卑不亢地表达自己的观点。',
        contactPersona: '企业高管，习惯被人附和，欣赏有独立观点的人',
        contactMood: '审视评估',
        openingMessage: '（高管靠在椅背上）你觉得呢？',
        goodKeywords: ['我觉得', '其实', '理解', '不过', '从', '角度', '可能'],
        referenceReply: '我觉得这个方向是对的，但执行节奏可能要调整。从一线的反馈看，用户还没准备好接受这么大的变化。建议先小范围测试，用数据说话。如果测试结果好，全面推我也会全力支持。',
        relatedKnowledgeIds: ['K008', 'K036'],
      ),
      7: ModeLevelContent(
        scenarioDescription: '你跟一个生活方式完全不同的人（比如极简主义者vs你习惯消费）聊天，对方对你的生活方式有微词。你需要保持开放而不防御。',
        contactPersona: '极简主义者，觉得物质消费是浪费',
        contactMood: ' subtly judgmental',
        openingMessage: '（对方看你的包）这么多东西，不会觉得累赘吗？',
        goodKeywords: ['其实', '理解', '喜欢', '每个人', '不过', '有意思', '觉得'],
        referenceReply: '确实有点重（笑）——其实我也在慢慢减少不必要的东西。你那种生活方式我挺好奇的，最大的改变是什么？不是要评判，就是觉得每个选择背后都有道理，想了解你的。',
        relatedKnowledgeIds: ['K030', 'K029'],
      ),
      8: ModeLevelContent(
        scenarioDescription: '你在一个陌生城市跟当地人聊天，对方用方言你听不懂。你需要友好地沟通而不让语言成为障碍。',
        contactPersona: '热心当地人，习惯说方言，普通话不标准',
        contactMood: '热情想帮忙',
        openingMessage: '（对方噼里啪啦说了一串方言，看你一脸茫然）啊？听不懂？',
        goodKeywords: ['不好意思', '听不懂', '但是', '想说', '谢谢', '慢慢', '没关系'],
        referenceReply: '不好意思，方言我一句没听懂（笑）——但你表情特别热情，我感觉你在说好事。能慢点再说一遍吗？或者咱们比划也行，谢谢你了！',
        relatedKnowledgeIds: ['K030'],
      ),
      9: ModeLevelContent(
        scenarioDescription: '你跟一个观点完全相反的人讨论敏感话题。你需要保持理性交流而不升级为争吵。',
        contactPersona: '观点对立者，情绪激动，但不是不讲理',
        contactMood: '激动防备',
        openingMessage: '（对方提高音量）你这个观点我完全不能同意！',
        goodKeywords: ['理解', '你说', '有道理', '不过', '其实', '试试', '换个'],
        referenceReply: '我理解你的角度——你说的那个点确实我没考虑到。不过我的担心也是真实的。咱们能不能不争谁对谁错，一起想想有没有兼顾两边的方案？你先说说你理想的结果是什么？',
        relatedKnowledgeIds: ['K006', 'K030'],
      ),
      10: ModeLevelContent(
        scenarioDescription: '综合场景：从跨行业破冰→跨年龄沟通→跨文化适应→跨圈层连接→观点对立化解，展示跨圈层社交的完整能力。',
        contactPersona: '动态变化：不同行业/年龄/文化/圈层',
        contactMood: '场景动态变化',
        openingMessage: '（跨行业沙龙上，一个完全不同领域的人走过来）你好，一个人站着？',
        goodKeywords: ['你好', '有趣', '其实', '理解', '觉得', '学习', '意思', '一起'],
        referenceReply: '嗨，是啊——这种场合我总不知道怎么开口。你是做什么的？等等别告诉我行业，先说一件你最近觉得最有意思的事。我觉得不同行业的人，觉得有意思的事完全不一样。',
        relatedKnowledgeIds: ['K001', 'K004', 'K006', 'K007', 'K008', 'K030', 'K035', 'K036', 'K039'],
      ),
    },

    // ==================== 网络社交（线上聊天/社交媒体） ====================
    TeachingMode.onlineSocial: {
      1: ModeLevelContent(
        scenarioDescription: '你在社交软件上匹配到一个感兴趣的人，但不知道第一条消息发什么。你需要打破"你好"的尴尬开场。',
        contactPersona: '刚匹配的网友，收到很多"你好"，对无聊开场免疫',
        contactMood: '选择性回复',
        openingMessage: '（对方已匹配，等你先发消息）……',
        goodKeywords: ['看到', '你', '有趣', '觉得', '也', '推荐', '哈哈'],
        referenceReply: '看到你主页那张在青海的照片——我也去过！那个湖边是不是特别冷？你是什么时候去的？',
        relatedKnowledgeIds: ['K014', 'K017'],
      ),
      2: ModeLevelContent(
        scenarioDescription: '对方回复了你的消息，但只有简短的"哈哈"。你需要让对话继续而不显得尬聊。',
        contactPersona: '回复简短，在评估你是否有意思',
        contactMood: '观望',
        openingMessage: '（对方回复）哈哈是的。',
        goodKeywords: ['说到', '其实', '最近', '你呢', '有没有', '推荐', '觉得'],
        referenceReply: '说到青海——你是一个人去的还是跟朋友？我一直想一个人旅行但没勇气。你平时是那种说走就走的还是计划型？',
        relatedKnowledgeIds: ['K004', 'K017'],
      ),
      3: ModeLevelContent(
        scenarioDescription: '你们聊了几天，气氛不错。你想从文字聊天升级到语音/见面，但不想太急。你需要自然地提出。',
        contactPersona: '聊得来的网友，对见面有期待但也有防备',
        contactMood: '愉快但谨慎',
        openingMessage: '（对方发了个表情包）哈哈哈你也太逗了。',
        goodKeywords: ['说到', '方便', '语音', '见面', '一起', '试试', '附近'],
        referenceReply: '跟你聊天太有意思了——打字手都酸了。方便语音聊吗？就5分钟，听听声音。不方便的话继续打字也行，不勉强。',
        relatedKnowledgeIds: ['K007', 'K017'],
      ),
      4: ModeLevelContent(
        scenarioDescription: '你发了消息但对方两小时没回。你需要决定要不要追问，以及如何不显得焦虑。',
        contactPersona: '可能真忙，也可能在犹豫',
        contactMood: '未知',
        openingMessage: '（已读未回，2小时过去）……',
        goodKeywords: ['（不发）', '忙', '没事', '等', '不打扰', '有空'],
        referenceReply: '（不发任何消息。等对方回复后再自然接话。如果隔天还没回，发一条无关的轻松内容：刚看到一个超好笑的视频，想到你说的那个梗。不追问为什么不回。）',
        relatedKnowledgeIds: ['K017', 'K029'],
      ),
      5: ModeLevelContent(
        scenarioDescription: '你在朋友圈/动态看到对方发了一条情绪低落的内容。你需要私信关心而不显得冒昧。',
        contactPersona: '发了伤感动态，可能想被关注也可能只想发泄',
        contactMood: '低落',
        openingMessage: '（对方动态：深夜发了一句"有些累了"）',
        goodKeywords: ['看到', '没事', '如果', '想聊', '在', '别', '关心'],
        referenceReply: '看到你动态了——没事吧？不想说也没关系，就是想让你知道有人在。想聊随时找我，不方便回也没事。',
        relatedKnowledgeIds: ['K005', 'K014'],
      ),
      6: ModeLevelContent(
        scenarioDescription: '你们在群里讨论，有人发了你的"黑历史"照片。你需要用幽默化解尴尬而不是生气。',
        contactPersona: '群友，发了你以前的丑照，觉得好玩',
        contactMood: '起哄玩笑',
        openingMessage: '（群消息：有人发了你5年前的非主流照片）哈哈哈哈看XX以前！',
        goodKeywords: ['哈哈', '那', '其实', '当时', '流行', '谁', '换'],
        referenceReply: '哈哈哈哈别说了！那时候全班都这个发型好吗？谁没有黑历史啊——@发图那位 你敢不敢发你当时的？比这个还非主流我赌。',
        relatedKnowledgeIds: ['K023', 'K048'],
      ),
      7: ModeLevelContent(
        scenarioDescription: '你跟网友聊了一段时间，想确认关系走向（是朋友还是有发展可能）。你需要试探而不尴尬。',
        contactPersona: '暧昧中的网友，也在评估关系走向',
        contactMood: '暧昧期待',
        openingMessage: '（对方发了个可爱的表情）你今天怎么这么甜？',
        goodKeywords: ['哈哈', '其实', '觉得', '跟你', '开心', '想', '一起'],
        referenceReply: '跟你聊天本来就很开心啊——其实我想问，你觉得咱俩现在算什么关系？（笑）不是要你表态，就是想看看我们在一个频道上。你心里怎么定位的？',
        relatedKnowledgeIds: ['K007', 'K025'],
      ),
      8: ModeLevelContent(
        scenarioDescription: '你在群里说错了一句话，有人不开心了。你需要在群里得体道歉而不让气氛更僵。',
        contactPersona: '群友被你的话冒犯，其他人观望',
        contactMood: '不悦沉默',
        openingMessage: '（群安静了，被冒犯的人发了个"哦"）',
        goodKeywords: ['对不起', '不好意思', '说错', '不是', '意思', '抱歉', '以后'],
        referenceReply: '@XX 不好意思，我刚才那句话说得太随便了，不是那个意思。在群里公开道歉——是我表达有问题，你别往心里去。以后说话注意。',
        relatedKnowledgeIds: ['K009'],
      ),
      9: ModeLevelContent(
        scenarioDescription: '你的消息被对方"冷暴力"——不拉黑不删除但就是不回。你需要决定如何处理。',
        contactPersona: '用沉默表达态度的网友',
        contactMood: '回避',
        openingMessage: '（又是已读不回，第三次了）……',
        goodKeywords: ['（不发）', '理解', '可能', '不打扰', '有空', '没关系'],
        referenceReply: '（发最后一条）最近看你挺忙的，我先不打扰了。有空想聊随时找我。（之后不再主动发消息。如果对方回复了再自然接话；如果不回，放下。）',
        relatedKnowledgeIds: ['K029', 'K017'],
      ),
      10: ModeLevelContent(
        scenarioDescription: '综合场景：从匹配开场→维持对话→升级关系→处理冷场→化解尴尬→确认关系，展示网络社交的完整链路。',
        contactPersona: '动态变化：从陌生人→聊得来→暧昧→摩擦→明确关系',
        contactMood: '场景动态变化',
        openingMessage: '（匹配成功，对方的主页写着"希望能遇到聊得来的人"）……',
        goodKeywords: ['看到', '你', '有趣', '觉得', '一起', '理解', '想', '哈哈'],
        referenceReply: '看到你写的"聊得来的人"——这个标准说高也高说低也低。先测测：如果只能保留一个APP你会留哪个？答案能暴露一个人的生活方式。',
        relatedKnowledgeIds: ['K014', 'K015', 'K016', 'K017', 'K004', 'K005', 'K007', 'K009', 'K025'],
      ),
    },
  };
}

// ============================================================================
// 关卡测试题系统（Quiz）
// ============================================================================

  /// 测试题模型
  class QuizQuestion {
    final String question;          // 题干
    final List<String> options;     // 选项（4个）
    final int correctIndex;         // 正确答案索引
    final String explanation;       // 解析
    final String? relatedKnowledgeId; // 关联知识条目ID

    const QuizQuestion({
      required this.question,
      required this.options,
      required this.correctIndex,
      required this.explanation,
      this.relatedKnowledgeId,
    });
  }

  /// 关卡测试题注册表
  class QuizRegistry {
    QuizRegistry._();

    /// 获取特定关卡的测试题，返回 null 表示该关卡无测试题
    static List<QuizQuestion>? getQuiz(int level) => _quizRegistry[level];

    static final Map<int, List<QuizQuestion>> _quizRegistry = {
      1: [
        const QuizQuestion(
          question: '破冰时最自然的开场方式是？',
          options: ['直接问对方姓名年龄', '评论当下共享情境', '讲一个长笑话', '夸赞对方外貌'],
          correctIndex: 1,
          explanation: '基于共享情境（环境、活动、天气）的评论最自然，不需对方暴露个人信息，降低防备心。',
          relatedKnowledgeId: 'K001',
        ),
        const QuizQuestion(
          question: '开场时以下哪种行为会降低对方好感？',
          options: ['微笑+眼神接触', '先评论再提问', '开场道歉"我不太会聊天"', '保持开放肢体语言'],
          correctIndex: 2,
          explanation: '开场道歉是自我贬低，会让对方觉得你确实不行。自信比完美更重要。',
          relatedKnowledgeId: 'K040',
        ),
      ],
      2: [
        const QuizQuestion(
          question: '自我介绍时最吸引人的结构是？',
          options: ['姓名+职业+公司', '一个标签+一个故事+一个钩子', '学历+工作经历+爱好', '家乡+年龄+星座'],
          correctIndex: 1,
          explanation: '"标签+故事+钩子"结构让介绍有记忆点，故事引发好奇，钩子邀请对方深入聊。',
          relatedKnowledgeId: 'K002',
        ),
        const QuizQuestion(
          question: '对方问"你是做什么的"，最好的回答策略是？',
          options: ['只说职业名称', '详细描述工作内容', '职业+一个有趣的点+反问对方', '谦虚说"没什么特别的"'],
          correctIndex: 2,
          explanation: '职业+有趣点让回答不枯燥，反问对方把对话变成乒乓球而非采访。',
        ),
      ],
      3: [
        const QuizQuestion(
          question: '倾听时最重要的技巧是？',
          options: ['频繁点头', '复述对方的话确认理解', '等对方说完马上给建议', '分享自己的类似经历'],
          correctIndex: 1,
          explanation: '复述（reflective listening）让对方感到被听见和理解，是深度倾听的核心技巧。',
          relatedKnowledgeId: 'K003',
        ),
        const QuizQuestion(
          question: '对方倾诉烦恼时，最不该说的是？',
          options: ['我理解你的感受', '后来呢？', '你想太多了', '换我会怎么做'],
          correctIndex: 2,
          explanation: '"你想太多"是否定对方感受，会立刻关闭对话。应先共情再引导。',
        ),
      ],
      4: [
        const QuizQuestion(
          question: '对话出现冷场时，最好的做法是？',
          options: ['沉默到底等对方开口', '自然转换话题"对了..."', '指出"好像没话说了"', '掏出手机看'],
          correctIndex: 1,
          explanation: '用"对了""说到"自然过渡到新话题，不承认冷场，保持对话流畅。',
          relatedKnowledgeId: 'K044',
        ),
        const QuizQuestion(
          question: '话题聊干了，可以用什么方法延续？',
          options: ['重复已说过的话', '5W1H追问法', '换人聊', '结束对话'],
          correctIndex: 1,
          explanation: '5W1H（What/Why/When/Where/Who/How）可以从一个点延展出6个方向。',
          relatedKnowledgeId: 'K044',
        ),
      ],
      5: [
        const QuizQuestion(
          question: '对方情绪低落时，最有效的共情方式是？',
          options: ['"别难过了"', '"我理解你"', '默默陪伴+"我在这里"', '讲一个更惨的故事安慰ta'],
          correctIndex: 2,
          explanation: '陪伴+"我在这里"传达"你不孤单"，比语言安慰更有力量。不要否定情绪或比较痛苦。',
          relatedKnowledgeId: 'K005',
        ),
        const QuizQuestion(
          question: '以下哪种是"廉价安慰"？',
          options: ['我感受到你的不容易', '换我也会难过', '别想太多，会好的', '你愿意说出来很勇敢'],
          correctIndex: 2,
          explanation: '"别想太多"否定对方感受，是典型的廉价安慰。应认可情绪而非压制。',
        ),
      ],
      6: [
        const QuizQuestion(
          question: '产生分歧时，最重要的是？',
          options: ['坚持说服对方', '先接纳对方观点再表达自己', '转移话题回避', '找第三方评理'],
          correctIndex: 1,
          explanation: '先接纳（"你说得有道理"）降低对方防备，再表达自己观点，让讨论而非争论。',
          relatedKnowledgeId: 'K006',
        ),
        const QuizQuestion(
          question: '争论中发现自己不对，最好的做法是？',
          options: ['硬撑面子', '找借口"我的意思是"', '坦诚承认"你说得对"', '沉默不回应'],
          correctIndex: 2,
          explanation: '坦诚承认错误反而赢得尊重。找借口和硬撑只会失去信任。',
        ),
      ],
      7: [
        const QuizQuestion(
          question: '把关系从浅层推向深层，最关键的是？',
          options: ['增加见面频率', '分享自己的脆弱面', '送贵重礼物', '在社交媒体互动'],
          correctIndex: 1,
          explanation: '适度展示脆弱是深度连接的催化剂。当你先打开心扉，对方也更愿意分享真实自我。',
          relatedKnowledgeId: 'K007',
        ),
        const QuizQuestion(
          question: '深度对话的"假设延伸法"适合什么时机？',
          options: ['刚认识时', '已经有一定信任基础后', '对方情绪激动时', '公共场合'],
          correctIndex: 1,
          explanation: '假设性问题（"如果...你会..."）容易引发深度对话，需要信任基础，否则显得突兀。',
        ),
      ],
      8: [
        const QuizQuestion(
          question: '邀约对方时，降低决策成本的关键是？',
          options: ['给出具体时间地点+低压力退路', '让对方全权决定', '强调"就这一次"', '提前订好不可取消的票'],
          correctIndex: 0,
          explanation: '具体时间地点降低选择负担，"随时可以撤"降低心理压力，让邀约更容易被接受。',
        ),
        const QuizQuestion(
          question: '对方犹豫时，以下哪种推动最有效？',
          options: ['"来嘛来嘛"', '强调活动有趣+低承诺"先去看看，无聊随时撤"', '"不来我会生气"', '反复追问"为什么不来"'],
          correctIndex: 1,
          explanation: '低承诺策略（"先去看看，无聊随时撤"）降低对方心理门槛，比软磨硬泡更有效。',
        ),
      ],
      9: [
        const QuizQuestion(
          question: '道歉时最不该做的是？',
          options: ['承认具体错误', '不找借口', '用"但是"解释自己', '提出弥补方案'],
          correctIndex: 2,
          explanation: '"对不起，但是..."让道歉变味成辩解。真诚道歉是"我错了，不找理由，这是我的弥补"。',
          relatedKnowledgeId: 'K009',
        ),
        const QuizQuestion(
          question: '对方冷暴力（已读不回）时，最好的应对是？',
          options: ['疯狂追问', '发最后一条"有空再聊"后不再主动', '威胁对方', '找朋友帮忙问'],
          correctIndex: 1,
          explanation: '发最后一条轻松消息后停止主动，保留体面。追问和威胁只会把对方推更远。',
        ),
      ],
      10: [
        const QuizQuestion(
          question: '综合社交中，"先给后要"法则指的是？',
          options: ['先请客再求人', '先提供价值/关注/倾听，再期待回报', '先送礼再提要求', '先赞美再利用'],
          correctIndex: 1,
          explanation: '社交的本质是交换。先提供价值（关注、倾听、帮助），对方自然愿意回报。',
          relatedKnowledgeId: 'K048',
        ),
        const QuizQuestion(
          question: '以下哪个是群体社交"控场"的核心心法？',
          options: ['自己说得越多越好', '让大家发光，而非只有自己发光', '压制不同声音', '严格按照流程走'],
          correctIndex: 1,
          explanation: '控场的本质是服务——让每个人都能参与和发光，而非自我表演。',
          relatedKnowledgeId: 'K040',
        ),
      ],
    };
  }
