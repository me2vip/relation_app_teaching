/// 知识词典扩展：练习、测试、知识点提炼数据系统
library knowledge_extensions;

import 'package:flutter/material.dart';
import 'teaching_level_system.dart';
import 'knowledge_extensions_part1.dart';
import 'knowledge_extensions_part2.dart';
import 'knowledge_extensions_part3.dart';

// ============================================================================
// 知识点提炼：核心要点数据模型
// ============================================================================

class KnowledgeKeyPoint {
  final String title;        // 要点标题
  final String content;      // 要点内容
  final IconData? icon;      // 要点图标
  final String importance;   // 重要程度：核心/重要/了解

  const KnowledgeKeyPoint({
    required this.title,
    required this.content,
    this.icon,
    this.importance = '重要',
  });
}

// ============================================================================
// 练习题：基于知识点的情景练习
// ============================================================================

class KnowledgePractice {
  final String id;
  final String scenario;           // 练习场景
  final String contactPersona;     // 对方画像
  final String openingMessage;     // 开场第一句话
  final List<String> goodKeywords; // 加分关键词
  final String referenceReply;     // 参考回复
  final String tip;                // 练习提示

  const KnowledgePractice({
    required this.id,
    required this.scenario,
    required this.contactPersona,
    required this.openingMessage,
    required this.goodKeywords,
    required this.referenceReply,
    required this.tip,
  });
}

// ============================================================================
// 测试题：选择题 / 判断题
// ============================================================================

enum QuestionType { singleChoice, multipleChoice, trueFalse }

class KnowledgeQuestion {
  final String id;
  final QuestionType type;
  final String question;
  final List<String> options;       // 选项（单选/多选），判断题为 ['正确', '错误']
  final List<int> correctIndices;   // 正确答案索引
  final String explanation;         // 答案解析
  final int difficulty;             // 1-3 难度

  const KnowledgeQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctIndices,
    required this.explanation,
    this.difficulty = 1,
  });
}

// ============================================================================
// 分步骤指导：将知识点拆解为可操作的步骤
// ============================================================================

class KnowledgeGuideStep {
  final int step;               // 步骤序号（1, 2, 3...）
  final String title;           // 步骤标题
  final String instruction;     // 指导说明（做什么、为什么）
  final String example;         // 示范话术 / 示范动作
  final String tip;             // 注意事项 / 常见错误
  final List<String> keywords;  // 本步骤关键词

  const KnowledgeGuideStep({
    this.step = 0,
    required this.title,
    required this.instruction,
    required this.example,
    this.tip = '',
    this.keywords = const [],
  });
}

class KnowledgeStepGuide {
  final String id;                           // 指导主题ID（可空）
  final String title;                        // 指导主题
  final String scenario;                     // 适用场景描述（可空）
  final List<KnowledgeGuideStep> steps;      // 分步骤

  const KnowledgeStepGuide({
    this.id = '',
    required this.title,
    this.scenario = '',
    required this.steps,
  });
}

// ============================================================================
// 知识点完整扩展：为每个知识点绑定提炼/练习/测试/分步指导
// ============================================================================

class KnowledgeExtensionBundle {
  final String knowledgeId;                    // 对应 SocialKnowledgeEntry.id
  final List<KnowledgeKeyPoint> keyPoints;     // 核心要点提炼
  final List<KnowledgePractice> practices;     // 情景练习题
  final List<KnowledgeQuestion> questions;     // 测试题
  final List<KnowledgeStepGuide> stepGuides;   // 分步骤指导

  const KnowledgeExtensionBundle({
    required this.knowledgeId,
    required this.keyPoints,
    required this.practices,
    required this.questions,
    this.stepGuides = const [],
  });
}

// ============================================================================
// 扩展注册表：为每个知识条目提供扩展数据
// ============================================================================

class KnowledgeExtensionRegistry {
  KnowledgeExtensionRegistry._();

  static final Map<String, KnowledgeExtensionBundle> _bundles = {
    // ==================================================================
    // K001 - 情境破冰法
    // ==================================================================
    'K001': KnowledgeExtensionBundle(
      knowledgeId: 'K001',
      keyPoints: [
        KnowledgeKeyPoint(
          title: '核心公式',
          content: '环境观察 → 即时评论 → 微笑先行',
          icon: Icons.lightbulb_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '观察三要素',
          content: '1. 对方在做什么\n2. 附近有什么有趣的事\n3. 当下共享情境（活动/天气/场地）',
          icon: Icons.visibility_rounded,
          importance: '重要',
        ),
        KnowledgeKeyPoint(
          title: '2秒法则',
          content: '看到想认识的人，在2秒内行动。等待越久，心理障碍越大。',
          icon: Icons.timer_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '常见误区',
          content: '❌ "你一个人来的吗"（尴尬）\n❌ 评价对方外表（缺乏深度）\n❌ 等太久才行动',
          icon: Icons.error_outline_rounded,
          importance: '重要',
        ),
      ],
      practices: [
        KnowledgePractice(
          id: 'K001-P1',
          scenario: '行业交流会上，你看到一个人站在角落里独自喝饮料，看着展架。你决定上前破冰。',
          contactPersona: '陌生人，对陌生人有轻微戒备但保持礼貌',
          openingMessage: '（对方注意到你走过来，礼貌地点了点头）……',
          goodKeywords: ['今天', '分享', '环节', '喜欢', '觉得', '你呢', '请问'],
          referenceReply: '今天的分享环节信息量挺大的，你最喜欢哪个部分？',
          tip: '基于活动情境开启对话，不要问私人问题，用开放式问题结尾。',
        ),
        KnowledgePractice(
          id: 'K001-P2',
          scenario: '咖啡店里，邻座的人正在看一本你也读过且很喜欢的书。你想搭话。',
          contactPersona: '看书入迷的人，被打扰时礼貌但可能有点不耐烦',
          openingMessage: '（对方翻页时，瞥见你在看ta的书）……',
          goodKeywords: ['不好意思', '看到', '书', '喜欢', '觉得', '怎么样', '推荐'],
          referenceReply: '不好意思打断一下——看到你在读《XX》，我也超喜欢这本。你觉得怎么样？',
          tip: '利用共同兴趣破冰，先道歉打扰，再用提问把话语权交给对方。',
        ),
      ],
      questions: [
        KnowledgeQuestion(
          id: 'K001-Q1',
          type: QuestionType.trueFalse,
          question: '看到想认识的人，应该在心里做好充分准备、想好完美话术之后再上前搭话。',
          options: ['正确', '错误'],
          correctIndices: [1],
          explanation: '正确答案：错误。2秒法则告诉我们：等待越久，心理障碍越大，也越容易被对方察觉你在犹豫。先行动，边说边调整。',
          difficulty: 1,
        ),
        KnowledgeQuestion(
          id: 'K001-Q2',
          type: QuestionType.singleChoice,
          question: '以下哪个是最佳的情境破冰开场？',
          options: [
            '"你好，我叫XX，可以认识一下吗？"',
            '"你一个人来的吗？"',
            '"今天的咖啡真不错，你觉得呢？"',
            '"你这件衣服很好看，在哪买的？"',
          ],
          correctIndices: [2],
          explanation: '正确答案是3。基于当下共享情境（咖啡）的评论最自然，既不涉及私人信息，也不评价对方外表。选项1太直接，选项2容易让对方尴尬，选项3评价外表缺乏深度。',
          difficulty: 2,
        ),
        KnowledgeQuestion(
          id: 'K001-Q3',
          type: QuestionType.multipleChoice,
          question: '情境破冰法的核心要素包括？（多选）',
          options: [
            '环境观察',
            '即时评论',
            '微笑+眼神接触',
            '自我介绍时列出所有成就',
          ],
          correctIndices: [0, 1, 2],
          explanation: '正确答案是1、2、3。情境破冰三要素：环境观察、即时评论、微笑先行。第4个选项是自我介绍阶段的事情，且方式错误，不属于破冰。',
          difficulty: 2,
        ),
      ],
    ),

    // ==================================================================
    // K002 - 自我介绍的黄金结构
    // ==================================================================
    'K002': KnowledgeExtensionBundle(
      knowledgeId: 'K002',
      keyPoints: [
        KnowledgeKeyPoint(
          title: '三句话结构',
          content: '1. 身份标签（5秒）：你是谁\n2. 价值陈述（10秒）：你做什么/关注什么\n3. 兴趣钩子（5秒）：开放性问题结尾',
          icon: Icons.account_tree_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '具体化原则',
          content: '用具体代替抽象："做消费类APP交互设计" > "做设计的"',
          icon: Icons.tune_rounded,
          importance: '重要',
        ),
        KnowledgeKeyPoint(
          title: '留钩子',
          content: '每段自我介绍必须用一个开放性问题结尾，让对方有话可接。',
          icon: Icons.anchor_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '避免自贬',
          content: '"我就是个普通的..."会直接降低对方对你的兴趣估值。',
          icon: Icons.warning_amber_rounded,
          importance: '重要',
        ),
      ],
      practices: [
        KnowledgePractice(
          id: 'K002-P1',
          scenario: '行业交流会上，对方打完招呼后问你："你是做什么的？"这是自我介绍的机会。',
          contactPersona: '刚认识的同行，对你有基本好奇心但没深入了解',
          openingMessage: '（对方微笑着问）你是做什么的呀？',
          goodKeywords: ['做', '最近', '研究', '觉得', '你呢', '感兴趣', '有意思'],
          referenceReply: '我是做AI产品设计的，最近在研究怎么让技术更懂人心——你觉得人和机器沟通，和人和人沟通，哪个更难？',
          tip: '三句话结构：身份+价值+钩子。最后一定要用问题把话抛回给对方。',
        ),
      ],
      questions: [
        KnowledgeQuestion(
          id: 'K002-Q1',
          type: QuestionType.singleChoice,
          question: '自我介绍的"兴趣钩子"是指？',
          options: [
            '说自己兴趣爱好有多广泛',
            '用一个开放性问题结尾，引发对方追问欲望',
            '讲一个有趣的故事',
            '展示自己的获奖证书',
          ],
          correctIndices: [1],
          explanation: '正确答案是2。兴趣钩子的核心是给对方创造"想追问"的欲望，用开放性问题结尾是最直接的方式。',
          difficulty: 1,
        ),
        KnowledgeQuestion(
          id: 'K002-Q2',
          type: QuestionType.trueFalse,
          question: '自我介绍时说"我就是个普通的打工人"是一种谦虚的表现，能拉近距离。',
          options: ['正确', '错误'],
          correctIndices: [1],
          explanation: '正确答案：错误。自贬式开场会直接降低对方对你的兴趣估值。用事实而非评价来描述自己，谦虚不等于自我贬低。',
          difficulty: 1,
        ),
      ],
    ),

    // ==================================================================
    // K003 - 主动倾听的四个层次
    // ==================================================================
    'K003': KnowledgeExtensionBundle(
      knowledgeId: 'K003',
      keyPoints: [
        KnowledgeKeyPoint(
          title: '倾听四层次',
          content: 'L1 假装听 → L2 选择性听 → L3 专注倾听 → L4 深度倾听（感知情绪/需求/价值观）',
          icon: Icons.graphic_eq_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '深度倾听三步法',
          content: '1. 放下预演（不想自己接下来要说什么）\n2. 简短回应鼓励继续（"嗯"/"然后呢"）\n3. 先镜像，再回应',
          icon: Icons.hearing_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '情绪标注',
          content: '每5分钟至少做一次情绪标注："听起来你很兴奋/纠结/自豪"',
          icon: Icons.emoji_emotions_rounded,
          importance: '重要',
        ),
        KnowledgeKeyPoint(
          title: '常见误区',
          content: '❌ 提前准备回答\n❌ 急于给建议\n❌ 用自己经历接话（抢走对方话筒）',
          icon: Icons.error_outline_rounded,
          importance: '重要',
        ),
      ],
      practices: [
        KnowledgePractice(
          id: 'K003-P1',
          scenario: '朋友正在跟你分享最近完成的一个项目，讲得很投入、很有成就感。你需要展示你在认真倾听。',
          contactPersona: '正在兴头上分享的朋友，期待被理解和认可',
          openingMessage: '（朋友激动地说）我跟你说，那个项目终于上线了！整整熬了三周，中间差点放弃，不过最后效果真的超出预期……',
          goodKeywords: ['听起来', '成就感', '不容易', '然后', '坚持', '真的', '细节'],
          referenceReply: '听起来你当时挺有成就感的！三周熬过来确实不容易——中间最难的时候是什么样的？',
          tip: '先做情绪标注（"听起来你很有成就感"），再追问细节，给对方继续分享的空间。不要急着说你自己类似的经历。',
        ),
      ],
      questions: [
        KnowledgeQuestion(
          id: 'K003-Q1',
          type: QuestionType.singleChoice,
          question: '对方分享完一段经历后，以下哪种回应最符合"深度倾听"？',
          options: [
            '"我也有一次类似的经历，那时候我..."',
            '"嗯，挺不错的。对了，我最近遇到一个事..."',
            '"所以你当时是坚持了三周才完成，对吗？那中间最难的时候是什么感受？"',
            '"这有什么，我上次比你还惨"',
          ],
          correctIndices: [2],
          explanation: '正确答案是3。深度倾听的关键是：1）镜像（重复关键信息"坚持了三周"）2）验证（确认理解）3）追问感受/细节。其他选项要么抢话，要么否定对方感受。',
          difficulty: 2,
        ),
      ],
    ),

    // ==================================================================
    // K005 - 情绪共鸣 vs 情绪解决
    // ==================================================================
    'K005': KnowledgeExtensionBundle(
      knowledgeId: 'K005',
      keyPoints: [
        KnowledgeKeyPoint(
          title: '核心区分',
          content: '情绪共鸣 = 让对方感到被理解\n情绪解决 = 试图帮对方消除负面情绪（往往无效）',
          icon: Icons.compare_arrows_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '共鸣金字塔',
          content: 'Layer1 确认情绪 → Layer2 共情回应 → Layer3 积极重构',
          icon: Icons.layers_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '黄金法则',
          content: '先共鸣，再解决。50%的情况下对方只需要被听见，不需要解决方案。',
          icon: Icons.g_mobiledata_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '神提问',
          content: '不确定对方需要什么时，问："你现在是需要我出主意，还是只是想找人说说话？"',
          icon: Icons.help_outline_rounded,
          importance: '重要',
        ),
      ],
      practices: [
        KnowledgePractice(
          id: 'K005-P1',
          scenario: '朋友向你吐槽："我今天开会又被领导当众批评了，真的好崩溃，我感觉自己什么都做不好..."',
          contactPersona: '情绪低落、沮丧、有点自我怀疑的朋友',
          openingMessage: '（朋友语气低落）唉，我真的好崩溃……感觉自己什么都做不好。',
          goodKeywords: ['理解', '不好受', '努力', '不容易', '委屈', '在的', '听你说'],
          referenceReply: '被当众批评确实很不好受，尤其是你已经那么努力了。如果是我遇到这种情况，可能也会觉得特别委屈。想聊聊具体是怎么回事吗？我在听。',
          tip: '按照共鸣金字塔：1）确认情绪（"很不好受"）2）共情（"如果是我也会委屈"）3）邀请继续分享。不要说"别想太多"或直接给建议。',
        ),
      ],
      questions: [
        KnowledgeQuestion(
          id: 'K005-Q1',
          type: QuestionType.singleChoice,
          question: '对方说"我今天被领导批评了，好难受"，以下哪句回应最恰当？',
          options: [
            '"别想太多了，下次做好就行了"',
            '"我能理解那种沮丧感，尤其是你已经很努力了。想聊聊具体发生了什么吗？"',
            '"你应该找领导沟通一下的，不能就这么忍了"',
            '"这有什么，我上次比你惨多了"',
          ],
          correctIndices: [1],
          explanation: '正确答案是2。情绪共鸣三步：确认情绪→共情→邀请继续分享。选项1是"廉价安慰"，选项3急于给建议，选项4否定对方感受。',
          difficulty: 1,
        ),
        KnowledgeQuestion(
          id: 'K005-Q2',
          type: QuestionType.trueFalse,
          question: '朋友情绪低落找你聊天时，最好的做法是立即给出一个切实可行的解决方案。',
          options: ['正确', '错误'],
          correctIndices: [1],
          explanation: '正确答案：错误。50%的情况下对方只需要被听见，不需要解决方案。先共鸣，再解决——如果对方想解决的话。',
          difficulty: 1,
        ),
      ],
    ),

    // ==================================================================
    // K006 - 非暴力沟通实战指南
    // ==================================================================
    'K006': KnowledgeExtensionBundle(
      knowledgeId: 'K006',
      keyPoints: [
        KnowledgeKeyPoint(
          title: 'NVC 四步法',
          content: '1. 观察（不带评判的事实）\n2. 感受（表达自己情绪）\n3. 需求（说出内在需要）\n4. 请求（具体可操作的请求）',
          icon: Icons.filter_1_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '观察 vs 评判',
          content: '❌ "你总是迟到"（评判）\n✅ "这周三次会议你都晚到10分钟以上"（观察）',
          icon: Icons.contrast_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '感受 vs 指责',
          content: '❌ "你让我很生气"（指责句式）\n✅ "我感到有些焦虑"（感受句式）',
          icon: Icons.sentiment_neutral_rounded,
          importance: '核心',
        ),
      ],
      practices: [
        KnowledgePractice(
          id: 'K006-P1',
          scenario: '你和同事合作一个项目，同事连续三次没有按时完成约定的部分，影响了整体进度。你需要在不引发冲突的前提下表达你的感受和需求。',
          contactPersona: '你的搭档同事，性格有点随性但不是故意偷懒',
          openingMessage: '（你找到同事，对方问："怎么啦？"）……',
          goodKeywords: ['注意到', '约定', '时间', '焦虑', '需要', '进度', '能不能', '确认'],
          referenceReply: '我注意到这周我们约定的三个交付节点，你那边都晚了1天以上。我感到有些焦虑，因为整体进度需要大家同步才能保证质量。我们需要找到一个双方都能按时完成的节奏——能不能明天一起花10分钟重新确认一下时间表？',
          tip: '严格按照非暴力沟通四步法：观察→感受→需求→请求。不要说"你总是拖延"（评判），要说具体事实。',
        ),
      ],
      questions: [
        KnowledgeQuestion(
          id: 'K006-Q1',
          type: QuestionType.singleChoice,
          question: '以下哪句话是"观察"而非"评判"？',
          options: [
            '"你总是不回消息"',
            '"你就是不负责任"',
            '"过去三天我发了5条消息，你只回复了1条"',
            '"你根本不在乎我"',
          ],
          correctIndices: [2],
          explanation: '正确答案是3。观察是具体的、可验证的事实，不带评判色彩。其他选项都带有"总是/就是/根本"等绝对化评判词。',
          difficulty: 1,
        ),
      ],
    ),

    // ==================================================================
    // K009 - 道歉的六要素
    // ==================================================================
    'K009': KnowledgeExtensionBundle(
      knowledgeId: 'K009',
      keyPoints: [
        KnowledgeKeyPoint(
          title: '有效道歉六要素',
          content: '1. 表达悔意\n2. 说明错在哪\n3. 承担责任\n4. 承诺改变\n5. 提供补救\n6. 请求原谅',
          icon: Icons.filter_6_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '错误道歉方式',
          content: '❌ "如果让你不舒服了我道歉"（条件式）\n❌ "对不起但是你也..."（甩锅式）\n❌ "好了我错了行了吧"（敷衍式）',
          icon: Icons.cancel_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '修复节奏',
          content: 'Day1：道歉不追问\nDay2-3：轻松互动不施压\nDay4-7：态度缓和后自然恢复',
          icon: Icons.date_range_rounded,
          importance: '重要',
        ),
      ],
      practices: [
        KnowledgePractice(
          id: 'K009-P1',
          scenario: '你因为没了解清楚情况，在一次朋友聚会上公开说了你好友的一件事，让ta很没面子。对方已经两天没联系你了，你决定发消息道歉。',
          contactPersona: '觉得被你伤害了的好友，对你仍有感情但在气头上',
          openingMessage: '（你准备发第一条道歉消息）……',
          goodKeywords: ['抱歉', '不该', '公开', '没确认', '错了', '以后', '弥补', '机会'],
          referenceReply: '真的很抱歉，那天聚会上我不该在没跟你确认的情况下，公开说那件事。这是我的问题，我说话太不注意场合了。以后这种涉及到你的事我一定先跟你确认。有没有什么我能做的来弥补？希望你能给我一个机会。',
          tip: '严格按照道歉六要素，缺一不可。不要辩解、不要用"但是"。发完后不要追问对方"原谅我了吗"。',
        ),
      ],
      questions: [
        KnowledgeQuestion(
          id: 'K009-Q1',
          type: QuestionType.multipleChoice,
          question: '有效道歉六要素包括以下哪些？（多选）',
          options: [
            '表达悔意',
            '说明错误在哪里',
            '"但是"解释为什么会犯这个错',
            '承担责任',
            '承诺改变',
            '提供补救',
            '请求原谅',
          ],
          correctIndices: [0, 1, 3, 4, 5, 6],
          explanation: '除了第3项"但是解释"，其他都是六要素。道歉中的"但是"会否定前面所有的诚意，变成甩锅式道歉。',
          difficulty: 2,
        ),
      ],
    ),
  };

  // ====================================================================
  // 公共访问接口
  // ====================================================================

  /// 获取指定知识点的扩展数据，不存在则返回默认空扩展
  /// 查找优先级：Part1/Part2 扩展数据 → 原始内联数据 → 自动生成
  static KnowledgeExtensionBundle getBundle(String knowledgeId) {
    // 优先查找 Part1/Part2/Part3 扩展数据（K001-K054 全覆盖）
    final expanded = knowledgePart1Bundles[knowledgeId]
        ?? knowledgePart2Bundles[knowledgeId]
        ?? kGenderKnowledgeExtensions[knowledgeId];
    if (expanded != null) return expanded;
    // 回退到原始内联数据
    return _bundles[knowledgeId] ?? KnowledgeExtensionBundle(
      knowledgeId: knowledgeId,
      keyPoints: _generateDefaultKeyPoints(knowledgeId),
      practices: const [],
      questions: const [],
    );
  }

  /// 是否存在指定知识点的扩展数据
  static bool hasBundle(String knowledgeId) =>
      knowledgePart1Bundles.containsKey(knowledgeId) ||
      knowledgePart2Bundles.containsKey(knowledgeId) ||
      kGenderKnowledgeExtensions.containsKey(knowledgeId) ||
      _bundles.containsKey(knowledgeId);

  /// 通用核心要点生成（当知识点暂无人工编写扩展时使用）
  static List<KnowledgeKeyPoint> _generateDefaultKeyPoints(String knowledgeId) {
    final entry = SocialKnowledgeBase.getById(knowledgeId);
    if (entry == null) return const [];

    // 从 content 中提取主要段落，生成提炼要点
    final lines = entry.content.replaceAll('\r', '').split('\n');
    final keyPoints = <KnowledgeKeyPoint>[];
    String? currentTitle;
    final buffer = StringBuffer();

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // 匹配标题
      final titleMatch = RegExp(r'^[【\[](.+?)[】\]]').firstMatch(trimmed);
      if (titleMatch != null) {
        if (currentTitle != null && buffer.isNotEmpty) {
          keyPoints.add(KnowledgeKeyPoint(
            title: currentTitle,
            content: buffer.toString().trim(),
            importance: '重要',
          ));
        }
        currentTitle = titleMatch.group(1)!;
        buffer.clear();
        // 标题可能后面还跟了内容
        final rest = trimmed.substring(titleMatch.end).trim();
        if (rest.isNotEmpty) buffer.writeln(rest);
      } else if (trimmed.startsWith(RegExp(r'^\d+\.'))) {
        // 编号条目
        if (buffer.isNotEmpty) buffer.writeln();
        buffer.write(trimmed);
      } else {
        if (buffer.isNotEmpty) buffer.write(' ');
        buffer.write(trimmed);
      }
    }

    if (currentTitle != null && buffer.isNotEmpty) {
      keyPoints.add(KnowledgeKeyPoint(
        title: currentTitle,
        content: buffer.toString().trim(),
        importance: '重要',
      ));
    }

    if (keyPoints.isEmpty && entry.content.isNotEmpty) {
      keyPoints.add(KnowledgeKeyPoint(
        title: entry.title,
        content: entry.content.length > 200
            ? '${entry.content.substring(0, 200)}...'
            : entry.content,
        importance: '核心',
      ));
    }

    return keyPoints;
  }
}
