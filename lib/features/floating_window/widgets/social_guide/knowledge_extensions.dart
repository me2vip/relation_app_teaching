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

    // ==================================================================
    // K080 - 如何脱单：从单身到恋爱的系统方法
    // ==================================================================
    'K080': KnowledgeExtensionBundle(
      knowledgeId: 'K080',
      keyPoints: [
        KnowledgeKeyPoint(
          title: '可被喜欢的状态',
          content: '生活有内容、外形有底线、情绪稳定、动态有温度——先把"自己"调到值得被爱，再去扩大接触面。',
          icon: Icons.favorite_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '系统扩大社交半径',
          content: '线下（兴趣班/聚会/沙龙/志愿）+ 线上（交友APP/兴趣社区/校友群）。去"有共同语境"的场合，共同兴趣是最好的破冰借口。',
          icon: Icons.people_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '从认识到关系',
          content: '三次法则（三次正向互动才真正开始）+ 主动但不舔 + 轻量投入（让对方为你做小事）+ 抓住暧昧窗口推一把。',
          icon: Icons.favorite_outline_rounded,
          importance: '重要',
        ),
        KnowledgeKeyPoint(
          title: '三大误区',
          content: '❌等缘分（概率永远0） ❌只看颜值条件 ❌舔狗式追求（单方面付出只让对方更不珍惜）。',
          icon: Icons.error_outline_rounded,
          importance: '重要',
        ),
      ],
      practices: [
        KnowledgePractice(
          id: 'K080-P1',
          scenario: '你在健身房的固定时间总能遇到同一个人，已经点头之交。今天你想把"认识"往前推一步。',
          contactPersona: '同健身房的人，礼貌但互不了解，对你印象中性偏好',
          openingMessage: '（对方刚练完，擦着汗和你点头）哟，今天也来啦。',
          goodKeywords: ['一起', '组', '约', '最近', '动作', '请教', '你呢'],
          referenceReply: '哈哈对，今天也来了。我看你硬拉动作特别标准，我总觉得腰发力不对，能不能请教你两下？',
          tip: '从共同场景切入，用"请教"制造轻量互动，比直接要微信自然得多。',
        ),
        KnowledgePractice(
          id: 'K080-P2',
          scenario: '你和一个聊了两周、感觉不错的异性约了第一次咖啡。聊得不错，你想在临走前推进关系，但不想显得急切。',
          contactPersona: '对你有好感但还在观察期的异性，聊天积极、会主动分享',
          openingMessage: '（喝完咖啡，对方看了眼时间）今天聊得挺开心的，时间过得真快。',
          goodKeywords: ['下次', '一起', '喜欢', '推荐', '想去', '约', '再'],
          referenceReply: '我也是！对了，你上次说那家手冲店，我超想去——下次换我请你，顺便带你去？',
          tip: '抓住暧昧窗口用"下次+具体邀约"推一把，把模糊好感落成下一次见面，而不是停留在"聊得开心"。',
        ),
        KnowledgePractice(
          id: 'K080-P3',
          scenario: '你主动约了三次，对方两次放鸽子、回复越来越慢、从不主动找你。你想体面地止损。',
          contactPersona: '对你兴趣明显下降的人，仍在礼貌维系但不投入',
          openingMessage: '（你发去第四次邀约，对方隔了一天才回）这周末有空吗？还是老地方？',
          goodKeywords: ['最近', '忙', '理解', '先', '慢慢', '不勉强', '下次'],
          referenceReply: '哈哈最近确实有点忙，先不约啦，理解一下～你先忙你的，下次有机会再说。',
          tip: '对方冷淡时别追问"为什么"，直接降低投入、把注意力转回自己，沉默比纠缠体面。',
        ),
      ],
      questions: [
        KnowledgeQuestion(
          id: 'K080-Q1',
          type: QuestionType.trueFalse,
          question: '长期单身的人只要"等缘分"、不出门不主动，总有一天会遇到的。',
          options: ['正确', '错误'],
          correctIndices: [1],
          explanation: '正确答案：错误。脱单是概率游戏，不出门、不加群、不主动，接触面永远是0，缘分无从降临。',
          difficulty: 1,
        ),
        KnowledgeQuestion(
          id: 'K080-Q2',
          type: QuestionType.singleChoice,
          question: '下列哪项是"主动但不舔"的正确做法？',
          options: [
            '对方不回消息就连续发十几条追问',
            '主动邀约、主动关心，但也保持自己的生活节奏',
            '对方发一条你秒回十条，全程围着对方转',
            '为对方无条件付出金钱和时间以表诚意',
          ],
          correctIndices: [1],
          explanation: '正确答案是2。主动邀约和关心没问题，但秒回、围着他转、单方面无限付出（舔狗式）只会让对方更不珍惜。',
          difficulty: 2,
        ),
        KnowledgeQuestion(
          id: 'K080-Q3',
          type: QuestionType.multipleChoice,
          question: '脱单系统工程的三个核心支柱包括？（多选）',
          options: [
            '把自己调到可被喜欢的状态',
            '系统扩大社交半径',
            '长期宅家等被遇见',
            '把认识变成关系（推进行动力）',
          ],
          correctIndices: [0, 1, 3],
          explanation: '正确答案是1、2、4。脱单=可被喜欢的状态 × 足够大的社交半径 × 敢于推进的行动力；"宅家等被遇见"是最大误区。',
          difficulty: 2,
        ),
        KnowledgeQuestion(
          id: 'K080-Q4',
          type: QuestionType.multipleChoice,
          question: '下列哪些是"对方对你有兴趣"的积极信号？（多选）',
          options: [
            '回复速度快、字数多',
            '主动找话题、问你的事',
            '从不主动联系但一直和你聊天',
            '愿意为你做件小事（帮你/赴约）',
          ],
          correctIndices: [0, 1, 3],
          explanation: '正确答案是1、2、4。"从不主动但一直聊天"往往是骑驴找马或养鱼，及时止损比死磕更划算。',
          difficulty: 2,
        ),
      ],
      stepGuides: [
        KnowledgeStepGuide(
          id: 'K080-G1',
          title: '脱单三步执行流程',
          scenario: '从"想脱单"到"进入一段关系"的系统推进',
          steps: [
            KnowledgeGuideStep(
              title: '第一步：调状态',
              instruction: '先把生活填满、外形收拾干净、情绪稳住，并偶尔分享有温度的生活动态，让别人有切入点。',
              example: '这周约一次运动/兴趣活动，发一条不炫耀的真实动态。',
              tip: '怨气重、负能量爆棚、把单身当受害者叙事，是最劝退的状态。',
              keywords: ['生活内容', '外形底线', '情绪稳定'],
            ),
            KnowledgeGuideStep(
              title: '第二步：扩半径',
              instruction: '按"有共同语境"原则选场合：兴趣班、朋友聚会、行业沙龙、靠谱交友APP、兴趣社区。',
              example: '让朋友带朋友组局，或报名一个连续性的线下兴趣班。',
              tip: '去有共同兴趣的场合，共同语境是最好的破冰借口，比盲目搭讪高效。',
              keywords: ['共同语境', '线下+线上', '扩大接触面'],
            ),
            KnowledgeGuideStep(
              title: '第三步：推进关系',
              instruction: '三次正向互动后关系才真正开始；主动邀约但不舔；让对方为你做件小事增加投入；抓住暧昧窗口自然推进。',
              example: '第三次愉快互动后，主动约一次具体活动："下次换我请你，带你去那家店？"',
              tip: '确认关系靠"做"不靠"问"——气氛到位自然牵手/叫昵称，比微信表白自然得多。',
              keywords: ['三次法则', '主动不舔', '暧昧窗口'],
            ),
          ],
        ),
        KnowledgeStepGuide(
          id: 'K080-G2',
          title: '脱单避坑自检清单',
          scenario: '开始行动前，先对照这四条误区给自己打分',
          steps: [
            KnowledgeGuideStep(
              title: '误区一：等缘分',
              instruction: '不出门、不加群、不主动 = 接触面为0。缘分需要接触面，先把自己放进人群里。',
              example: '这周至少参加1次线下活动或主动约1个朋友组局。',
              tip: '把"等遇到"改成"去遇到"。',
              keywords: ['接触面', '主动'],
            ),
            KnowledgeGuideStep(
              title: '误区二：跪舔/单方面付出',
              instruction: '一味讨好换不来尊重，只会让对方失去兴趣。双向投入才是健康关系的起点。',
              example: '对方不回就先忙自己的，不秒回、不连环追问。',
              tip: '你的价值不靠讨好证明。',
              keywords: ['不舔', '双向'],
            ),
            KnowledgeGuideStep(
              title: '误区三：同时聊很多人比较',
              instruction: '同时养多条线既消耗精力，也极易穿帮、伤口碑。专注2-3个重点就好。',
              example: '把聊天对象控制在能认真回应的数量内。',
              tip: '质量 > 数量。',
              keywords: ['专注', '质量'],
            ),
            KnowledgeGuideStep(
              title: '误区四：社交平台发伤感文案求关注',
              instruction: '成年人的体面是收拾好情绪再出门。负能量刷屏只会劝退潜在对象。',
              example: '想吐槽时先发给死党，不在公开动态里卖惨。',
              tip: '动态是你的名片，别写成情绪垃圾桶。',
              keywords: ['体面', '情绪'],
            ),
          ],
        ),
      ],
    ),

    // ==================================================================
    // K081 - 如何发现优秀朋友：线上线下全渠道识人指南
    // ==================================================================
    'K081': KnowledgeExtensionBundle(
      knowledgeId: 'K081',
      keyPoints: [
        KnowledgeKeyPoint(
          title: '线上：从内容看人',
          content: '抖音/快手看长期发什么；朋友圈看互动质量；社区看长内容逻辑与审美；网友/搭子先轻量合作再进现实圈。',
          icon: Icons.visibility_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '线下：从行为看人',
          content: '朋友介绍（信用背书最高）、兴趣社群（责任心/配合度）、行业沙龙（视野格局）、志愿者（人品底线）。',
          icon: Icons.people_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '识人四信号',
          content: '1.持续输出质量 2.三观一致（对钱/家人/弱者态度）3.情绪稳定 4.靠谱度（说到做到、守时守约）。',
          icon: Icons.verified_rounded,
          importance: '重要',
        ),
        KnowledgeKeyPoint(
          title: '避坑信号',
          content: '🚩杀猪盘（带你投资）🚩负能量黑洞（只倒苦水）🚩只索取不付出🚩人设崩塌（说一套做一套）。',
          icon: Icons.shield_rounded,
          importance: '重要',
        ),
      ],
      practices: [
        KnowledgePractice(
          id: 'K081-P1',
          scenario: '你在一个本地读书群里潜水两周，发现有人持续认真推荐书单、耐心解答新人问题。你想把TA从"群友"变成"可深交的人"。',
          contactPersona: '群里活跃的靠谱答疑者，温和有底气，对你无偏见',
          openingMessage: '（你在群里问了个关于某本书的问题，TA认真回了你）谢谢！你之前推荐的那本我也去看了。',
          goodKeywords: ['推荐', '一起', '线下', '活动', '喜欢', '你呢', '约'],
          referenceReply: '不客气～其实这周末有个线下读书会，你是本地的吧？感兴趣可以一起来，人不多聊得比较深。',
          tip: '从群里已有的价值对话切入，用"共同活动"轻量邀约，比冷不丁"在吗"自然，也便于线下观察。',
        ),
        KnowledgePractice(
          id: 'K081-P2',
          scenario: '一个刚认识的网友和你组队打了几次游戏，配合不错。对方提议"加微信经常一起玩"，你判断要不要拉进现实圈。',
          contactPersona: '游戏搭子，技术不错、输了不炸毛、会鼓励队友',
          openingMessage: '（对方）这把配合绝了！加个微信呗，以后经常一起上分。',
          goodKeywords: ['可以', '先', '组队', '项目', '观察', '慢慢', '靠谱'],
          referenceReply: '好啊，先加着，咱们多组几次队我看看你靠不靠谱——要是每次都准时上线不鸽，再约线下撸串哈哈。',
          tip: '先轻量合作观察靠谱度与情绪稳定，再决定是否进现实圈，避免一把冲动把陌生人拉进核心社交。',
        ),
        KnowledgePractice(
          id: 'K081-P3',
          scenario: '朋友组局吃饭，带了三位你都不熟的新朋友。你想在不尴尬的前提下，自然融入并建立一两段新连接。',
          contactPersona: '朋友的朋友，放松、无偏见、对陌生人友好',
          openingMessage: '（落座后，有人问你）你是XX（共同朋友）哪儿认识的呀？',
          goodKeywords: ['一起', '朋友', '也', '喜欢', '组', '下次', '聊'],
          referenceReply: '我是和XX在读书会认识的～听他说你特能聊电影，我最近正好片荒，有啥必看的有狠货？',
          tip: '从"共同朋友"和"对方擅长的话题"切入，把话题抛回去让对方当主角，融入最快。',
        ),
      ],
      questions: [
        KnowledgeQuestion(
          id: 'K081-Q1',
          type: QuestionType.trueFalse,
          question: '刚认识的网友带你参与"内部投资赚钱机会"时，正确的做法是先小投一笔试试水。',
          options: ['正确', '错误'],
          correctIndices: [1],
          explanation: '正确答案：错误。这是典型杀猪盘信号，刚认识就带你"投资赚钱"应直接拉黑，绝不转账。',
          difficulty: 1,
        ),
        KnowledgeQuestion(
          id: 'K081-Q2',
          type: QuestionType.singleChoice,
          question: '下列最能标志"值得深交"的信号是？',
          options: [
            '对方朋友圈全是精修大片，看起来很成功',
            '长期稳定输出有价值内容，且对弱者/陌生人有礼貌',
            '认识第二天就送你贵重礼物',
            '每次聊天都先问你收入多少',
          ],
          correctIndices: [1],
          explanation: '正确答案是2。识人看"持续输出质量"和"对弱者的态度"，比一时的光鲜或热情更可靠。',
          difficulty: 2,
        ),
        KnowledgeQuestion(
          id: 'K081-Q3',
          type: QuestionType.multipleChoice,
          question: '"识人四信号"包含哪些？（多选）',
          options: [
            '持续输出质量',
            '三观一致',
            '情绪稳定',
            '朋友圈点赞数多',
          ],
          correctIndices: [0, 1, 2],
          explanation: '正确答案是1、2、3。识人四信号是持续输出质量、三观一致、情绪稳定、靠谱度；点赞数多不等于值得深交。',
          difficulty: 2,
        ),
        KnowledgeQuestion(
          id: 'K081-Q4',
          type: QuestionType.multipleChoice,
          question: '下列哪些属于"需要远离的消耗型关系"避坑信号？（多选）',
          options: [
            '杀猪盘：刚认识就带你投资赚钱',
            '负能量黑洞：只倒苦水、从不给反馈',
            '只索取不付出：借money/吐槽但从不帮回',
            '人设崩塌：说一套做一套、背后说人坏话',
          ],
          correctIndices: [0, 1, 2, 3],
          explanation: '正确答案：全选。这四类都是典型消耗/危险信号，遇到应主动疏远或直接拉黑（杀猪盘）。',
          difficulty: 2,
        ),
      ],
      stepGuides: [
        KnowledgeStepGuide(
          id: 'K081-G1',
          title: '识人四步：从观察到深交',
          scenario: '在高质量场景里看出优秀朋友，再逐步养出来',
          steps: [
            KnowledgeGuideStep(
              title: '第一步：观察',
              instruction: '线上看长期输出（内容/互动），线下看行为（责任心/配合度/输赢态度），记录对方的一致性。',
              example: '在群里观察两周，谁是组织者、谁只潜水抬杠。',
              tip: '不凭一次惊艳下结论，看"持续"而非"瞬间"。',
              keywords: ['持续输出', '行为观察', '一致性'],
            ),
            KnowledgeGuideStep(
              title: '第二步：轻互动',
              instruction: '从评论、组队、请教切入，制造低压力接触，检验对方回应质量与情绪稳定。',
              example: '就群里有价值的对话认真评论，或约一次轻量组队。',
              tip: '别一上来就"在吗"，带着具体的事或问题去互动。',
              keywords: ['评论', '组队', '低压力'],
            ),
            KnowledgeGuideStep(
              title: '第三步：小合作',
              instruction: '一起做一件具体的小事（探店/项目/运动），在协作中看靠谱度与配合度。',
              example: '约一次线下读书会或组队完成一个小任务。',
              tip: '合作是照妖镜：答应的事做到没、约好的时间守没守，一目了然。',
              keywords: ['小合作', '靠谱度', '配合度'],
            ),
            KnowledgeGuideStep(
              title: '第四步：深交',
              instruction: '确认信号后进入深层交流：聊深层观点、互助、守密，把关系养厚。',
              example: '分享一个真实困扰，看对方是否接得住、守得住。',
              tip: '同时果断远离消耗型关系（只索取/人设崩塌/负能量黑洞）。',
              keywords: ['深层交流', '互助', '止损'],
            ),
          ],
        ),
        KnowledgeStepGuide(
          id: 'K081-G2',
          title: '朋友质量自检：维护 vs 远离',
          scenario: '定期给朋友圈做个体检，把精力放在对的人身上',
          steps: [
            KnowledgeGuideStep(
              title: '维护：少而精 + 持续投入',
              instruction: '核心朋友（3-5人）保持每月至少一次深度交流；对方需要时第一时间出现；能吃亏、守边界。',
              example: '每月固定和2-3个核心朋友单独约一次饭或电话。',
              tip: '高质量关系靠"持续"而非"频繁"。',
              keywords: ['核心圈', '持续投入'],
            ),
            KnowledgeGuideStep(
              title: '远离：消耗型关系',
              instruction: '见面后你感觉累/被否定/自我怀疑；只索取从不反馈；背后说其他朋友坏话——主动疏远。',
              example: '把总是单方面吐槽你的人，从"常聊"名单里降权。',
              tip: '别因为"认识久了"勉强维持消耗关系。',
              keywords: ['止损', '降权'],
            ),
            KnowledgeGuideStep(
              title: '边界：再熟也留空间',
              instruction: '朋友的私事不过问太多，不比较成就，不背后说坏话；有边界的关系才长久。',
              example: '朋友没主动提的事，不追问；对方吐槽时倾听但不拱火。',
              tip: '边界感是友谊的保鲜剂。',
              keywords: ['边界', '不比较'],
            ),
          ],
        ),
      ],
    ),

    // ==================================================================
    // K082 - 社交动态经营：朋友圈/QQ空间/抖音日常怎么发
    // ==================================================================
    'K082': KnowledgeExtensionBundle(
      knowledgeId: 'K082',
      keyPoints: [
        KnowledgeKeyPoint(
          title: '通用五原则',
          content: '少炫耀多分享 / 真实>精致 / 积极为底色 / 保护隐私 / 结尾抛钩子引互动。',
          icon: Icons.auto_awesome_rounded,
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '朋友圈节奏',
          content: '每周2-4条最舒适；生活碎片+观点+偶尔成就三件套轮换；走心评论、及时回评；忌半夜矫情长文。',
          icon: Icons.chat_bubble_rounded,
          importance: '重要',
        ),
        KnowledgeKeyPoint(
          title: 'QQ空间定位',
          content: '更私人更怀旧，适合发情绪/回忆/熟人互动；说说走生活感；留言板是关系温度计。',
          icon: Icons.favorite_outline_rounded,
          importance: '了解',
        ),
        KnowledgeKeyPoint(
          title: '抖音日常人设',
          content: '人设一条线贯穿；选题来自生活越具体越有代入感；前3秒给钩子；频率稳定比爆款重要；经营评论区。',
          icon: Icons.camera_alt_rounded,
          importance: '重要',
        ),
      ],
      practices: [
        KnowledgePractice(
          id: 'K082-P1',
          scenario: '你拿到一个挺有分量的小成就（项目上线/考过证），想发朋友圈，但怕显得炫耀。',
          contactPersona: '朋友圈里的同事和半熟人，对你有基本好感但保持距离',
          openingMessage: '（你正犹豫要不要发）……',
          goodKeywords: ['谢谢', '团队', '运气', '顺便', '大家', '一起', '分享'],
          referenceReply: '项目终于上线啦🎉 其实一半靠队友carry，一半靠运气——顺便问下大家最近都在用哪款协作工具，求安利～',
          tip: '成就配谦逊/幽默+把功劳分给他人+结尾留钩子，既展示又不得罪人，还涨互动。',
        ),
        KnowledgePractice(
          id: 'K082-P2',
          scenario: '你想做一条抖音日常，但前几秒总是留不住人、推流差。你在琢磨怎么改开头。',
          contactPersona: '刷到你视频的陌生观众，注意力只有3秒，没钩子就划走',
          openingMessage: '（镜头对准你，你准备开口）……',
          goodKeywords: ['你', '知道', '吗', '其实', '原来', '反差', '先别'],
          referenceReply: '你以为健身最难的的是坚持？其实80%的人第一天就输在了装备上——先别划走，我教你三件性价比最高的东西。',
          tip: '前3秒给反差/疑问/干货预告当钩子，把"你以为…其实…"这种结构用起来，完播率决定推流。',
        ),
        KnowledgePractice(
          id: 'K082-P3',
          scenario: '你发了一条抖音/朋友圈，热评里有人认真夸你、还有人抛梗接话。你想把互动率做起来。',
          contactPersona: '评论区里的活跃观众，对你内容有好感、爱玩梗',
          openingMessage: '（评论区）楼主这个反转绝了哈哈，求更新下集！',
          goodKeywords: ['谢谢', '下集', '安排', '梗', '也', '你们', '评论'],
          referenceReply: '谢谢宝子！下集已经在剪了，你们想看啥扣1，点赞高的我先拍～',
          tip: '回复热评、接梗、把决定权抛给观众（"你们想看啥"），互动率直接拉动推流。',
        ),
      ],
      questions: [
        KnowledgeQuestion(
          id: 'K082-Q1',
          type: QuestionType.trueFalse,
          question: '朋友圈可以全天候随时发，半夜发一段矫情长文也没关系，朋友会理解。',
          options: ['正确', '错误'],
          correctIndices: [1],
          explanation: '正确答案：错误。半夜矫情长文、刷屏、全程抱怨是朋友圈禁忌，会被默默屏蔽，整体调性应保持积极。',
          difficulty: 1,
        ),
        KnowledgeQuestion(
          id: 'K082-Q2',
          type: QuestionType.singleChoice,
          question: '抖音短视频最该在什么时候给观众"钩子"？',
          options: [
            '视频结尾总结时',
            '前3秒开头',
            '中间转场时',
            '字幕里随便放',
          ],
          correctIndices: [1],
          explanation: '正确答案是2。短视频重前3秒，开头就用反差/疑问/干货预告给钩子，才能留住人、拿到推流。',
          difficulty: 2,
        ),
        KnowledgeQuestion(
          id: 'K082-Q3',
          type: QuestionType.multipleChoice,
          question: '社交动态经营的"通用五原则"包括？（多选）',
          options: [
            '少炫耀多分享',
            '真实大于精致',
            '保护隐私不打码不露',
            '结尾抛问题留钩子引互动',
          ],
          correctIndices: [0, 1, 3],
          explanation: '正确答案是1、2、4。"保护隐私"是原则之一，但做法是"一律打码/不露"，选项3说"不打码不露"是错的。',
          difficulty: 2,
        ),
        KnowledgeQuestion(
          id: 'K082-Q4',
          type: QuestionType.multipleChoice,
          question: '下列哪些属于社交动态的"避坑清单"内容？（多选）',
          options: [
            '负能量刷屏、当别人的情绪垃圾桶',
            '过度精致假、全是精修大片没人信',
            '秒发秒删、显得极度在意外界评价',
            '只发广告/引流、把朋友当客户池',
          ],
          correctIndices: [0, 1, 2, 3],
          explanation: '正确答案：全选。四类都会减分；动态的底色应是积极、真实、有互动，而非表演或营销。',
          difficulty: 2,
        ),
      ],
      stepGuides: [
        KnowledgeStepGuide(
          id: 'K082-G1',
          title: '社交动态经营四步',
          scenario: '把动态经营成你的第二张名片',
          steps: [
            KnowledgeGuideStep(
              title: '第一步：定人设',
              instruction: '先想清楚你想在别人眼里是什么样的人，一条主线贯穿所有平台，别今天美食明天财经后天哭穷。',
              example: '在便签写下3个关键词（如：爱运动/会做饭/懂穿搭），发之前对照。',
              tip: '人设一致才有记忆点，频繁切换人设会让观众困惑、掉粉。',
              keywords: ['人设', '主线', '一致性'],
            ),
            KnowledgeGuideStep(
              title: '第二步：控频率',
              instruction: '朋友圈每周2-4条；抖音每周2-3条稳定更新。刷屏会被屏蔽，断更会掉权重。',
              example: '用日历排期，把生活碎片/观点/成就三件套轮换着发。',
              tip: '频率稳定比偶尔爆款更重要，平台按稳定更新给基础推流。',
              keywords: ['频率', '排期', '稳定'],
            ),
            KnowledgeGuideStep(
              title: '第三步：引互动',
              instruction: '结尾抛问题/留钩子，给别人评论走心，别人评你及时回；抖音回复热评、接梗制造记忆点。',
              example: '发成就配"大家最近都在用哪款工具？求安利～"。',
              tip: '互动率（评论/回复）直接决定朋友圈可见度与抖音推流。',
              keywords: ['钩子', '走心评论', '互动率'],
            ),
            KnowledgeGuideStep(
              title: '第四步：护隐私',
              instruction: '住址、行程、车牌、证件、公司机密一律打码/不露；不秒发秒删、不全程负能量。',
              example: '发定位只到商圈，不发具体门牌；车票打码再发。',
              tip: '真实≠裸奔，保护隐私是经营长期人设的底线。',
              keywords: ['隐私', '打码', '底线'],
            ),
          ],
        ),
        KnowledgeStepGuide(
          id: 'K082-G2',
          title: '动态经营避坑清单',
          scenario: '发之前对照这四条，避免辛苦经营反而减分',
          steps: [
            KnowledgeGuideStep(
              title: '避坑一：负能量刷屏',
              instruction: '谁都不想当你的情绪垃圾桶。可以偶尔吐槽，但整体调性保持积极。',
              example: '想抱怨时发给死党私聊，不在公开动态连发。',
              tip: '积极为底色，吐槽是调味不是主菜。',
              keywords: ['积极', '不刷屏'],
            ),
            KnowledgeGuideStep(
              title: '避坑二：过度精致假',
              instruction: '全是大片精修，没人信那是真实生活；偶尔翻车、平凡反而更可亲。',
              example: '精修图配一句自嘲，比干晒更招人喜欢。',
              tip: '真实 > 精致。',
              keywords: ['真实', '不装'],
            ),
            KnowledgeGuideStep(
              title: '避坑三：秒发秒删',
              instruction: '发完又删，显得你极度在意外界评价，反而减分；想清楚再发。',
              example: '发之前默数三秒，确认不后悔再点发送。',
              tip: '稳定感比完美感更贵。',
              keywords: ['稳定', '不删'],
            ),
            KnowledgeGuideStep(
              title: '避坑四：只发广告/引流',
              instruction: '朋友不是你的客户池；纯广告动态会被默默屏蔽。',
              example: '真要推广，放进"偶尔"而非"全部"，并先给价值再带链接。',
              tip: '先有交情，再有转化。',
              keywords: ['不引流', '价值先'],
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    // K083 关系定位判断与应对策略（男性视角）
    // =========================================================================
    'K083': KnowledgeExtensionBundle(
      knowledgeId: 'K083',
      keyPoints: [
        KnowledgeKeyPoint(
          title: '定位的本质',
          content: '定位是你对「她」价值的判断，不是她对你的态度。同一个行为（她回复慢）可能是因为忙，也可能是因为没兴趣——必须结合多维信号综合判断，不能凭单一事件下结论。',
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '判断定位的八大行为信号',
          content: '① 回复速度与主动性 ② 话题深度与延续度 ③ 私密动态可见范围 ④ 约会邀约态度 ⑤ 肢体语言暗示 ⑥ 朋友圈互动行为 ⑦ 关键时刻选择 ⑧ 社交圈开放程度。多个信号交叉验证比单一信号更可靠。',
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '四大定位类型与核心特征',
          content: '① 可发展对象：主动升温，主动创造见面机会，在乎你的反馈 ② 短期暧昧：互动频繁但不推进，有其他暧昧对象或关系不明确 ③ 长期朋友备胎：不拒绝也不推进，享受被追但不给你名分 ④ 必须止损：对方有稳定伴侣、态度持续冷淡、单向消耗你。',
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '升温 / 维持 / 降温 / 撤退的决策框架',
          content: '升温条件：她表现明确好感信号且窗口期合适（单身/空窗）→主动推进。维持：正面反馈但无强烈信号，保持舒适感不施压。降温：反馈变冷，减少投入观察反应。撤退：她明确表态只想做朋友或出现消耗型特征。',
          importance: '重要',
        ),
        KnowledgeKeyPoint(
          title: '止损的四个关键信号',
          content: '① 明确说"我们还是做朋友"且态度坚定 ② 连续三周以上已读不回或敷衍回复 ③ 忽冷忽热让你情绪持续波动 ④ 你发现这段关系里你一直在单向投入。出现任一信号，应果断减少投入、转向其他机会。',
          importance: '重要',
        ),
      ],
      stepGuides: [
        KnowledgeStepGuide(
          id: 'K083-G1',
          title: '定位判断八步法',
          scenario: '面对一个女生，通过八个维度系统判断她把你当什么人',
          steps: [
            KnowledgeGuideStep(
              title: '第一步：沟通信号',
              instruction: '观察她的回复速度和主动性。秒回且主动开启话题=强兴趣；回复慢但认真回答=中等兴趣；经常不回复或敷衍=低兴趣。注意区分习惯性秒回和有意图的秒回。',
              example: '她不仅秒回，还主动问"今天那个电影你看了吗，感觉怎么样？"=主动延续话题，是强兴趣信号。',
              tip: '深夜聊天频率和话题深度比白天聊天更能说明问题。',
              keywords: ['秒回', '主动', '深度话题'],
            ),
            KnowledgeGuideStep(
              title: '第二步：社交动态信号',
              instruction: '看她朋友圈/空间动态对你是否可见、是否主动展示个人生活给你。朋友圈三天可见且没有特别互动=定位不明；主动给你看她的日常=定位较高。',
              example: '她主动发一张自拍给你说"今天加班累死了"=在向你分享个人情绪，定位信号较强。',
              tip: '仅靠朋友圈三天可见来判断是片面的，要结合其他信号。',
              keywords: ['私密动态', '朋友圈可见', '分享生活'],
            ),
            KnowledgeGuideStep(
              title: '第三步：约会邀约态度',
              instruction: '约她出来的反应是最直接定位信号。欣然答应并主动配合=强兴趣；答应但总临时有事=存疑；找理由推脱或模糊应对=低兴趣或朋友定位。',
              example: '你说"周六有空吗，有个展不错"，她说"可以啊，你定时间，我提前空出来"=定位较高。',
              tip: '连续三次邀约都推脱，基本可以判断定位不高。',
              keywords: ['约会', '邀约', '临时有事'],
            ),
            KnowledgeGuideStep(
              title: '第四步：肢体语言（当面场合）',
              instruction: '当面接触时：愿意靠近你站/坐、积极的眼神接触、主动制造轻微肢体接触（如碰你手臂）=强兴趣信号。相反则定位较低。注意不要混淆礼貌性和兴趣性肢体语言。',
              example: '你们聊天时她身体一直倾向你，笑的时候会轻轻拍你手臂=好感信号。',
              tip: '结合多场景判断，一次肢体语言不等于定位结论。',
              keywords: ['肢体语言', '眼神接触', '靠近'],
            ),
          ],
        ),
        KnowledgeStepGuide(
          id: 'K083-G2',
          title: '策略选择决策树',
          scenario: '根据定位判断结果，决定该升温、维持、降温还是撤退',
          steps: [
            KnowledgeGuideStep(
              title: '升温条件检查',
              instruction: '必须同时满足：① 多个信号显示她对你有明显好感 ② 她目前单身/空窗/刚结束一段关系 ③ 你自己也对她有真实兴趣。任何一条不满足贸然升温都可能适得其反。',
              example: '她经常主动约你、聊天深入、愿意单独见面+你也很喜欢她=升温时机成熟。',
              tip: '不要把"她对我很好"直接等同于"她喜欢我"，先确认她的窗口期。',
              keywords: ['窗口期', '好感信号', '升温时机'],
            ),
            KnowledgeGuideStep(
              title: '止损条件检查',
              instruction: '出现以下任一情况应立即减少投入：① 她明确表态只想做朋友 ② 连续三周以上冷淡 ③ 关系里你持续单向投入 ④ 她有稳定伴侣。不要为不值得的人消耗自己。',
              example: '你表白后她说"你人真的很好，但我们还是做朋友吧"=止损信号，停止追求投入。',
              tip: '止损不是失败，是理性决策。转向其他更值得投入的人是正确选择。',
              keywords: ['止损', '明确拒绝', '单向投入'],
            ),
          ],
        ),
      ],
      practices: [
        KnowledgePractice(
          id: 'K083-P1',
          scenario: '认识一个女生一个月，她聊天很积极，经常主动开启话题，回复快，但每次约她出来她都说"最近比较忙"或"那天有事"',
          contactPersona: '条件不错的女生，同事介绍认识，聊天风格活泼，喜欢发表情包',
          openingMessage: '"最近发现一部电影挺有意思的，周末有空一起去看看吗？"',
          goodKeywords: ['尊重', '不施压', '给台阶', '转向'],
          referenceReply: '先给邀约，如果她继续推脱三次以上，直接点出"感觉你挺忙的，那改天再说，你先忙"，停止主动邀约，观察她是否会主动找你。如果继续冷淡则降温或撤退。',
          tip: '聊天好但约不出来，可能是朋友定位或备胎定位，不要把时间全押在聊天上。',
        ),
        KnowledgePractice(
          id: 'K083-P2',
          scenario: '一个女生经常主动找你聊天，回复速度很快，但你提到"要不要单独吃个饭"时她就会岔开话题，或者用"下次叫上其他朋友一起吧"来模糊化',
          contactPersona: '大学同学，有共同好友，线上聊天特别频繁，经常深夜也聊',
          openingMessage: '"今天加班好累，感觉整个城市都空了"（看她如何回应，观察是否主动关心你的状态）',
          goodKeywords: ['试探', '观察', '不点破', '设止损线'],
          referenceReply: '继续正常聊天，但不再主动提约会，观察她的反应。如果她开始主动升温（例如主动约你），则跟进；如果持续保持现状，两周内减少主动找她的频率，测试她的反应。',
          tip: '长期愿意聊天但回避单独约会，通常是朋友或备胎定位。',
        ),
        KnowledgePractice(
          id: 'K083-P3',
          scenario: '在一次聚会中认识了一个女生，聚会结束后她加了你微信，第二天就开始主动找你聊天，话题延伸很好，但一周后突然冷淡，三四天才回一次',
          contactPersona: '社交场合认识，条件很好，身边有多人追求，聚会中对你有好感表现（眼神接触、主动靠近）',
          openingMessage: '（不主动，等她是否主动找）如果她超过两天没找你，主动发一条轻松消息："上次聚会那个游戏你还记得吗，感觉你玩得挺投入的哈哈"',
          goodKeywords: ['等待', '试探', '不过度解读', '接受动态'],
          referenceReply: '发完轻松消息后正常等待回应，不要追问。如果她回复正常则继续；如果她继续冷淡，停止主动，关系进入降温状态。忽冷忽热本身是定位不明或备胎的信号。',
          tip: '忽冷忽热的本质是她在权衡多个选择。不要过度投入，接受关系的不确定性。',
        ),
      ],
      questions: [
        KnowledgeQuestion(
          id: 'K083-Q1',
          type: QuestionType.trueFalse,
          question: '女生经常主动找你聊天、回复快、话题延伸好，说明她把你当可发展对象。',
          options: ['正确', '错误'],
          correctIndices: [1],
          explanation: '聊天积极只是必要条件，不是充分条件。如果她从不单独约会你、从不推进关系、回避升温话题，说明她可能只是把你当朋友备胎。判断可发展对象需要多维信号，聊天只是其中之一。',
          difficulty: 1,
        ),
        KnowledgeQuestion(
          id: 'K083-Q2',
          type: QuestionType.singleChoice,
          question: '以下哪种情况是关系定位中最明确的止损信号？',
          options: ['她回复慢但有回复', '她明确说"我们还是做朋友吧"且态度坚定', '她偶尔忘记回复消息', '她对你的话题不感兴趣但保持礼貌'],
          correctIndices: [1],
          explanation: '明确表态是止损信号里最直接的。选项A/C/D都可能是对方在忙或性格原因，不构成止损条件。只有对方明确表态"只想做朋友"且态度坚定，才应立即减少投入、转向其他机会。',
          difficulty: 1,
        ),
        KnowledgeQuestion(
          id: 'K083-Q3',
          type: QuestionType.singleChoice,
          question: '当一个女生对你忽冷忽热时，最合理的应对是？',
          options: ['继续加大投入，用热情打动她', '停止主动，等她来找你并观察是否改变', '直接问她到底什么意思', '找她身边的朋友打听情况'],
          correctIndices: [1],
          explanation: '忽冷忽热的本质是她对这段关系态度不明朗或正在权衡。选项A只会让你消耗更多；选项C在关系不明朗时直接追问会让对方有压力；选项D打探朋友是大忌。选项B是成本最低、最体面的策略：停止主动，看她是否主动找你，从而判断她的真实兴趣。',
          difficulty: 2,
        ),
        KnowledgeQuestion(
          id: 'K083-Q4',
          type: QuestionType.multipleChoice,
          question: '以下哪些是判断「可发展对象」的强信号？（可多选）',
          options: [
            '愿意单独出来约会且不临时取消',
            '记得你说过的细节（喜欢的食物、工作情况等）',
            '愿意把你介绍给她的朋友',
            '聊天时偶尔深夜也回消息',
          ],
          correctIndices: [0, 1, 2],
          explanation: '选项0（愿单独约会）是升温的最直接信号。选项1（记得细节）说明她在认真关注你，不是随口敷衍。选项2（介绍朋友）说明她愿意把你纳入社交圈，是关系升级的强信号。选项3（深夜聊天）只是社交活跃的表现，不构成关系发展的明确信号。',
          difficulty: 2,
        ),
      ],
    ),

    // =========================================================================
    // K084 关系定位判断与应对策略（女性视角）
    // =========================================================================
    'K084': KnowledgeExtensionBundle(
      knowledgeId: 'K084',
      keyPoints: [
        KnowledgeKeyPoint(
          title: '定位的本质',
          content: '定位是你对「他」价值的判断，不是他对你的态度。他对你好可能是真心喜欢，也可能是习惯性撩完就跑。需要结合多维信号综合判断，不能凭单一事件下结论。',
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '判断定位的八大行为信号',
          content: '① 是否主动开启话题 ② 是否愿意投入时间/精力/金钱 ③ 是否把你纳入社交圈（朋友、家人） ④ 约会质量与态度 ⑤ 肢体语言（紧张 vs 冷淡） ⑥ 社交媒体互动 ⑦ 关键时刻的选择 ⑧ 对其他异性的态度。多个信号交叉验证比单一信号更可靠。',
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '四大定位类型与核心特征',
          content: '① 可发展对象：主动升级关系、在乎你的感受、愿意投入、把你纳入生活 ② 短期暧昧：互动频繁但不确定关系，有其他暧昧对象或稳定伴侣 ③ 长期备胎：不拒绝不推进，享受被喜欢但不给承诺 ④ 必须止损：他已有稳定伴侣、长期忽冷忽热、单向消耗你。',
          importance: '核心',
        ),
        KnowledgeKeyPoint(
          title: '升温 / 维持 / 降温 / 撤退的决策框架',
          content: '升温：他的多个信号显示认真兴趣+目前单身→给予正面反馈，主动跟进。维持：正面反馈但无明确信号，保持舒适节奏。降温：反馈变冷或态度不明，减少投入。撤退：他明确表态只想做朋友或出现消耗型特征，立即止损。',
          importance: '重要',
        ),
        KnowledgeKeyPoint(
          title: '止损的四个关键信号',
          content: '① 他明确说"只做朋友"但继续享受你的陪伴 ② 他有稳定交往对象但仍和你保持暧昧 ③ 忽冷忽热让你持续猜测 ④ 你一直在单向投入（主动、找话题、提供情绪价值），他很少主动。任何一条出现都应果断止损。',
          importance: '重要',
        ),
      ],
      stepGuides: [
        KnowledgeStepGuide(
          id: 'K084-G1',
          title: '定位判断八步法',
          scenario: '面对一个男生，通过八个维度系统判断他把你当什么人',
          steps: [
            KnowledgeGuideStep(
              title: '第一步：沟通信号',
              instruction: '看他是否主动开启话题，以及话题的深度。他主动找你聊天且延伸话题深度=有真实兴趣；他只在晚上找你聊天（暧昧试探）=定位可疑；他从不主动找你=对你兴趣有限。',
              example: '他早上主动发"今天天气真好，下班要不要去那个新开的咖啡店？"=主动投入，是认真发展兴趣信号。',
              tip: '只在晚上找你聊天的男生，可能只是想找晚上的"陪伴"，不一定想发展正经关系。',
              keywords: ['主动', '话题深度', '晚上试探'],
            ),
            KnowledgeGuideStep(
              title: '第二步：资源投入信号',
              instruction: '他是否愿意为你投入时间、金钱或精力。主动请你吃饭/打车/送礼+从不提让你请回来=认真投入；让你AA或总是哭穷却从不付出=在节省成本。注意排除海王式广泛撒网（对所有人都请客）。',
              example: '约会时他主动规划行程、订餐厅、主动买单=愿意为你投入，是认真兴趣信号。',
              tip: '要看他对你和其他人的差别，而不是单纯看他花了多少钱。',
              keywords: ['投入', '主动买单', '成本'],
            ),
            KnowledgeGuideStep(
              title: '第三步：社交圈开放程度',
              instruction: '他是否愿意把你带入他的生活圈子。见朋友/同事=他认真考虑这段关系；只在你俩单独约会=定位不明；见家人=认真度很高。排除有稳定伴侣的情况（见朋友可能是在掩盖）。',
              example: '他说"下周有个朋友聚会，你要不要一起来？"=愿意让你进入他的社交圈，是强兴趣信号。',
              tip: '有稳定伴侣的男生也可能带你见朋友，要结合其他信号综合判断。',
              keywords: ['社交圈', '见朋友', '见家人'],
            ),
            KnowledgeGuideStep(
              title: '第四步：关键时刻选择',
              instruction: '当你需要帮助或遇到重要事情时，他是否出现。你生病了他主动关心+送药=把你当重要的人；你有事他总是"太忙"或"走不开"=在你生命中的分量不高。注意区分客观条件和主观意愿。',
              example: '你加班到很晚，他说"我顺路去接你吧，反正不远"=在你需要的时候出现，是关系重要的信号。',
              tip: '看他是否主动知道你生活中的重要事件，而不只是等你求助。',
              keywords: ['关键时刻', '主动关心', '出现'],
            ),
          ],
        ),
        KnowledgeStepGuide(
          id: 'K084-G2',
          title: '策略选择决策树',
          scenario: '根据定位判断结果，决定该跟进、维持、降温还是止损',
          steps: [
            KnowledgeGuideStep(
              title: '跟进条件检查',
              instruction: '必须同时满足：① 多个信号显示他对你有真实发展兴趣（非单纯暧昧） ② 他目前单身且窗口期合适 ③ 你也对他有真实兴趣。任何一条不满足贸然跟进都可能导致被动定位。',
              example: '他主动约你单独见面、记得你的细节、愿意为你投入+你也喜欢他=跟进时机成熟，适当主动回应。',
              tip: '女生可以适度主动，但不要全程追着跑。让他也有机会追你。',
              keywords: ['跟进', '窗口期', '女生主动'],
            ),
            KnowledgeGuideStep(
              title: '止损条件检查',
              instruction: '出现以下任一情况应立即止损：① 他明确表态只想做朋友但继续享受你的陪伴 ② 有稳定伴侣还和你暧昧 ③ 持续单向消耗（你在投入他很少回应） ④ 关系让你长期焦虑或情绪低落。',
              example: '他说"我现在不想谈恋爱"但继续每天找你聊天、约你单独出去=止损信号，他只是在享受陪伴而非想发展关系。',
              tip: '止损不是放弃自尊，是保护自己的时间和感情。值得的人会让你感到被珍惜，不值得的人只会让你不断怀疑自己。',
              keywords: ['止损', '海王信号', '消耗'],
            ),
          ],
        ),
      ],
      practices: [
        KnowledgePractice(
          id: 'K084-P1',
          scenario: '一个条件不错的男生经常主动找你聊天，回复速度快且话题延伸好，但每次提到"什么时候一起吃个饭"他都说"最近比较忙"或者岔开话题',
          contactPersona: '社交软件认识，朋友圈展示精致，工作体面，说话幽默风趣',
          openingMessage: '"最近有家餐厅评分很高，周末有空吗？"（试探他的实际态度）',
          goodKeywords: ['试探', '看行动', '设止损线', '不被聊天迷惑'],
          referenceReply: '给邀约，如果他继续推脱两次以上，直接问他"你是不是只把我当聊天对象？"。如果他继续模糊，停止主动邀约，减少回复频率，观察他的反应。',
          tip: '只愿意聊天不愿意见面，是典型的朋友定位或暧昧定位。不要被聊天中的"聊得好"迷惑。',
        ),
        KnowledgePractice(
          id: 'K084-P2',
          scenario: '一个男生经常约你单独见面，聊天时表现得很绅士很细心，但你问"我们是什么关系"时他总是岔开话题，或者用"朋友呗，还能是什么"来回避',
          contactPersona: '工作场合认识，职位不错，经常找机会接近你，记得你说的很多细节',
          openingMessage: '下次他约你时，直接问"我们最近好像走得挺近的，你觉得我们是什么关系？"',
          goodKeywords: ['直接沟通', '逼定位', '不被绅士迷惑', '止损'],
          referenceReply: '直接问关系后，如果他的回答模糊或回避，应立即停止投入（包括不再主动、降低回复热情），不要继续单方面投入时间和情绪。如果他对你有真实兴趣，被问后会有明确的进展；如果继续回避则说明他只想要暧昧，不打算给你承诺。',
          tip: '长期享受约会但不推进关系的男性，很可能在同时维护多个选择。要警惕这种"高不成低不就"的定位陷阱。',
        ),
        KnowledgePractice(
          id: 'K084-P3',
          scenario: '聚会中认识一个男生，他对你表现出好感（主动搭话、眼神接触、主动加微信、聚会后第二天就找你聊天），但你后来发现他好像对其他女生也很热情',
          contactPersona: '聚会认识，社交能力强，人缘好，朋友圈经常发和女生的合照',
          openingMessage: '不急于表态，继续观察他的行为模式，看他是否对你有特殊对待（区别于对其他女生的态度）',
          goodKeywords: ['观察', '区分', '不盲目投入', '判断特殊对待'],
          referenceReply: '他如果对所有人都很热情，则降低期待，当普通朋友对待。不要因为聚会中的好印象就认定他是认真的。给他时间，看他后续是否会对你有特殊的投入（单独约你、记住你的细节、主动推进关系）。',
          tip: '社交能力强不等于对你认真。看他对你的行为是否特殊于他对其他人的行为，才是判断关键。',
        ),
      ],
      questions: [
        KnowledgeQuestion(
          id: 'K084-Q1',
          type: QuestionType.trueFalse,
          question: '一个男生对你很好（聊天积极、经常关心、主动买单），说明他一定是把你当可发展对象。',
          options: ['正确', '错误'],
          correctIndices: [1],
          explanation: '他对你好可能只是他的性格或习惯，不等于他想认真发展关系。有些人天生对所有人都很好，有些人只是享受暧昧的感觉。判断可发展对象要看：① 是否主动推进关系 ② 是否把你纳入社交圈 ③ 是否做出关系承诺。单纯的好不等于认真定位。',
          difficulty: 1,
        ),
        KnowledgeQuestion(
          id: 'K084-Q2',
          type: QuestionType.singleChoice,
          question: '当一个男生说"我现在不想谈恋爱"但继续每天找你聊天、约你单独出去，应该怎么应对？',
          options: ['继续投入，等他改变想法', '立即停止投入，不再主动回应', '明确告诉他你的立场，让他做出选择', '不再单独出去，但保持线上聊天'],
          correctIndices: [2],
          explanation: '"不想谈恋爱"但继续享受你的陪伴是典型的备胎定位。选项A继续投入只会让你消耗更多；选项B直接切断太激进；选项D保持模糊对双方都没有好处。选项C明确立场让他做选择，既保护了自己，也给了对方机会，是最体面的策略。',
          difficulty: 2,
        ),
        KnowledgeQuestion(
          id: 'K084-Q3',
          type: QuestionType.multipleChoice,
          question: '以下哪些是判断「可发展对象」的强信号？（可多选）',
          options: [
            '主动约你单独见面，且不临时取消',
            '记得你说的重要细节（喜欢的食物、最近的工作情况）',
            '愿意带你见他的朋友或家人',
            '聊天时经常发"哈哈"和表情包',
          ],
          correctIndices: [0, 1, 2],
          explanation: '选项0（单独约且不取消）是关系推进的最直接信号。选项1（记得细节）说明他在认真关注你，是真实兴趣。选项2（见朋友/家人）说明他在认真考虑这段关系的长期发展。选项3（发哈哈）只是聊天活跃的表现，不构成关系发展的明确信号。',
          difficulty: 2,
        ),
        KnowledgeQuestion(
          id: 'K084-Q4',
          type: QuestionType.singleChoice,
          question: '以下哪种情况是判断男性「有稳定伴侣」的重要参考？',
          options: ['他从不发朋友圈', '他朋友圈发的是工作内容', '他朋友圈对你屏蔽，或者他从不发私人动态', '他朋友圈更新很频繁'],
          correctIndices: [2],
          explanation: '一个有正常社交生活的人，通常会在朋友圈发一些私人内容。如果他对你屏蔽朋友圈，或者朋友圈里几乎没有任何私人生活展示（只有工作转发），需要警惕——他可能在隐藏自己的感情状态，或者有不想让你知道的社交圈。选项A/B/D都不能直接推断有伴侣。',
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
