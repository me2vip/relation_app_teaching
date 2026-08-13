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
class SocialKnowledgeEntry {
  final String id;
  final String title;
  final String category;     // 所属分类
  final String content;      // 正文
  final List<String> tags;   // 标签
  final int relatedLevel;    // 关联关卡（1-10）
  final TeachingMode? relatedMode; // 关联模式（null=通用）

  const SocialKnowledgeEntry({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.tags,
    required this.relatedLevel,
    this.relatedMode,
  });
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
  ];

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
