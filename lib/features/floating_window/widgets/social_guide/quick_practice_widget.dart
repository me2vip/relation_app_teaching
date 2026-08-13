/// 快速练习 Widget
///
/// 独立于关卡系统的快速社交练习入口。
/// 提供多个典型场景，可选难度，3-5轮即时评分反馈。
/// 适合碎片化练习，无需通关解锁。
library quick_practice_widget;

import 'dart:math';
import 'package:flutter/material.dart';

// ============================================================================
// 快速练习场景数据
// ============================================================================

class PracticeScenario {
  final String id;
  final String title;
  final String description;
  final String category;
  final Difficulty difficulty;
  final String contactPersona;
  final String openingMessage;
  final List<String> goodKeywords;
  final String referenceReply;
  final String successTip;

  const PracticeScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.contactPersona,
    required this.openingMessage,
    required this.goodKeywords,
    required this.referenceReply,
    required this.successTip,
  });
}

enum Difficulty {
  easy('简单', '日常场景，容错率高', Colors.green),
  medium('中等', '需要一定技巧，有冷场风险', Colors.orange),
  hard('困难', '高难度场景，需要综合能力', Colors.red),
  ;

  final String label;
  final String description;
  final Color color;
  const Difficulty(this.label, this.description, this.color);
}

class PracticeScenarioRegistry {
  PracticeScenarioRegistry._();

  static List<PracticeScenario> get scenarios => _scenarios;

  static final List<PracticeScenario> _scenarios = [
    // ========== 简单 ==========
    const PracticeScenario(
      id: 'P001',
      title: '咖啡店搭话',
      description: '咖啡店里看到一个人在看一本你也喜欢的书',
      category: '破冰',
      difficulty: Difficulty.easy,
      contactPersona: '陌生人，专注看书，对打扰保持礼貌',
      openingMessage: '（对方抬头看了你一眼，礼貌微笑）嗯？',
      goodKeywords: ['不好意思', '看到', '书', '觉得', '也', '推荐'],
      referenceReply: '不好意思——看到你在看《XX》，我也超喜欢。你觉得怎么样？',
      successTip: '利用"共同兴趣"自然破冰，不问私人信息。',
    ),
    const PracticeScenario(
      id: 'P002',
      title: '新同事打招呼',
      description: '茶水间遇到不认识的新同事',
      category: '职场',
      difficulty: Difficulty.easy,
      contactPersona: '其他部门的同事，对新面孔保持礼貌',
      openingMessage: '（同事倒完咖啡，看到你）你好，新来的？',
      goodKeywords: ['对', '部门', '负责', '认识', '请教', '以后'],
      referenceReply: '对，我是产品部新来的。您是哪个部门的？以后多交流。',
      successTip: '简单介绍+反问对方，让对话双向流动。',
    ),
    const PracticeScenario(
      id: 'P003',
      title: '朋友聚会寒暄',
      description: '到达聚会时跟已到的朋友打招呼',
      category: '日常',
      difficulty: Difficulty.easy,
      contactPersona: '朋友的朋友，见过一面但不太熟',
      openingMessage: '（对方看到你，笑着招手）嘿！你来了，好久不见。',
      goodKeywords: ['好久', '最近', '怎么样', '挺好的', '你呢', '有趣'],
      referenceReply: '好久不见！最近忙什么呢？上次听你说在做那个项目，后来怎么样了？',
      successTip: '回忆上次话题+关心近况，展示你在意对方。',
    ),

    // ========== 中等 ==========
    const PracticeScenario(
      id: 'P004',
      title: '安慰低落的朋友',
      description: '朋友发了一条情绪低落的朋友圈，你私信关心',
      category: '共情',
      difficulty: Difficulty.medium,
      contactPersona: '情绪低落的朋友，需要被理解而非被建议',
      openingMessage: '（朋友回复你的私信）唉，没什么，就是有点累。',
      goodKeywords: ['理解', '不容易', '在的', '想聊', '没关系', '听你说'],
      referenceReply: '累了就歇会。不想说也没关系，就是想让你知道我在。想聊随时找我。',
      successTip: '陪伴>建议，让对方感到不孤单是最重要的。',
    ),
    const PracticeScenario(
      id: 'P005',
      title: '会议冷场救场',
      description: '你主持的小组会议突然没人说话，气氛尴尬',
      category: '控场',
      difficulty: Difficulty.medium,
      contactPersona: '5位同事，等待有人打破沉默',
      openingMessage: '（会议室安静下来，大家互相对视，没人开口）……',
      goodKeywords: ['好', '开始', '先', '大家', '觉得', '聊聊', '今天'],
      referenceReply: '好，咱们开始吧。先问一句——大家这周末过得怎么样？（笑）看到小王精神特别好。',
      successTip: '用轻松话题破冰，点名让特定人参与。',
    ),
    const PracticeScenario(
      id: 'P006',
      title: '处理已读不回',
      description: '你发消息给在意的人，对方已读3小时没回',
      category: '网络社交',
      difficulty: Difficulty.medium,
      contactPersona: '可能真忙，也可能在犹豫',
      openingMessage: '（已读未回，3小时过去）……',
      goodKeywords: ['（不发）', '等', '忙', '有空', '不打扰'],
      referenceReply: '（不发任何消息。耐心等待。不追问、不焦虑、不连发。）',
      successTip: '已读不回时最好的做法就是——不发。给对方空间。',
    ),
    const PracticeScenario(
      id: 'P007',
      title: '跟青春期孩子沟通',
      description: '你15岁的孩子一回家就关房门，你想跟ta聊聊',
      category: '家庭',
      difficulty: Difficulty.medium,
      contactPersona: '15岁青春期少年，反感说教',
      openingMessage: '（你敲门，里面传来）干嘛？',
      goodKeywords: ['不是', '就是', '想', '聊聊', '吃饭', '不打扰'],
      referenceReply: '不是来查作业的。想跟你出去吃个饭？你选地方，就吃饭聊天。',
      successTip: '不说教、不查问，用"一起做某事"代替"谈谈"。',
    ),

    // ========== 困难 ==========
    const PracticeScenario(
      id: 'P008',
      title: '公开演讲救场',
      description: '演讲中设备突然故障，PPT无法播放，50人等待',
      category: '控场',
      difficulty: Difficulty.hard,
      contactPersona: '50人听众，开始窃窃私语',
      openingMessage: '（PPT黑屏，技术人员慌张调试，台下开始议论）……',
      goodKeywords: ['看来', '正好', '故事', '大家', '聊聊', '没关系'],
      referenceReply: '看来老天也想让我们多聊聊（笑）——正好，PPT上的内容我本来就觉得太多。咱们今天换个方式，我就讲故事，你们随时提问。',
      successTip: '幽默化解+立即启动B计划，不让观众等待。',
    ),
    const PracticeScenario(
      id: 'P009',
      title: '化解争吵',
      description: '你和伴侣因为一件事产生分歧，对方开始激动',
      category: '冲突',
      difficulty: Difficulty.hard,
      contactPersona: '你的伴侣，情绪激动，觉得自己不被理解',
      openingMessage: '（伴侣提高音量）我就不明白了，为什么每次我提个想法你都先否定！',
      goodKeywords: ['你说得对', '理解', '确实', '先', '听听', '试试', '以后'],
      referenceReply: '你说得对，我确实有这个习惯——不是故意的，但我理解这让你很烦。你先说你的想法，我这次好好听完。',
      successTip: '先承认自己的问题，降低对方防备，再引导理性沟通。',
    ),
    const PracticeScenario(
      id: 'P010',
      title: '跨文化沟通',
      description: '你跟一个来自完全不同文化背景的人合作，对方沟通方式很直接',
      category: '跨文化',
      difficulty: Difficulty.hard,
      contactPersona: '来自直接文化背景的人，说话不绕弯',
      openingMessage: '（对方直接说）你这个方案不行，太复杂了。',
      goodKeywords: ['理解', '确实', '直接', '喜欢', '简化', '试试', '一起'],
      referenceReply: '我喜欢你这么直接——确实，我复杂了。你觉得核心应该保留什么？一起想想怎么简化。',
      successTip: '把"直接"视为优点而非冒犯，顺势合作而非防御。',
    ),

    // ========== 群体社交 ==========
    const PracticeScenario(
      id: 'P011',
      title: '聚会中认识新朋友',
      description: '朋友带你参加一个聚会，全场陌生人，你需要主动融入',
      category: '群体社交',
      difficulty: Difficulty.easy,
      contactPersona: '另一个独自站着的宾客，也在观望',
      openingMessage: '（对方看到你，礼貌点头微笑）你好，你也是第一次来？',
      goodKeywords: ['对', '朋友', '介绍', '你', '觉得', '过来'],
      referenceReply: '对，朋友带我来的。你呢？跟谁来的？这边你认识人多吗？',
      successTip: '主动递出"话题球"，让对方有话可接。',
    ),
    const PracticeScenario(
      id: 'P012',
      title: '主持沙龙暖场',
      description: '你被邀请主持一场小型沙龙，开场5分钟冷场',
      category: '群体社交',
      difficulty: Difficulty.medium,
      contactPersona: '20位参与者，彼此陌生',
      openingMessage: '（你站在前面，大家看着你，没人主动开口）……',
      goodKeywords: ['好', '咱们', '先', '大家', '简单', '聊聊', '最近'],
      referenceReply: '好，咱们先不正式开始——大家今天过来，路上花了多久？（笑）我先说说我自己，我是XX，今天特别期待跟大家聊聊XX。',
      successTip: '用自我介绍+轻松话题开场，降低参与门槛。',
    ),
    const PracticeScenario(
      id: 'P013',
      title: '被要求即兴发言',
      description: '饭局上朋友突然说"来，你说两句"，全场看向你',
      category: '群体社交',
      difficulty: Difficulty.hard,
      contactPersona: '10位朋友+朋友的朋友，期待有趣的发言',
      openingMessage: '（朋友举杯）来！XX最近干了件大事，让他说两句！',
      goodKeywords: ['哈哈', '其实', '最近', '跟', '大家', '开心', '干杯'],
      referenceReply: '哈哈，别搞我——其实就是最近在尝试一些新东西，跟大家分享一个小感悟：社交中最重要的不是说什么，而是听什么。来，敬我们这些善于倾听的人！干杯！',
      successTip: '用幽默化解紧张+分享小感悟+把焦点转回群体。',
    ),

    // ========== 追求异性 ==========
    const PracticeScenario(
      id: 'P014',
      title: '第一次加女生微信',
      description: '朋友把女生微信推给你，你加上后第一条消息怎么发',
      category: '追求',
      difficulty: Difficulty.easy,
      contactPersona: '刚认识的女生，对你充满好奇但也有防备',
      openingMessage: '（微信已添加，对方通过好友申请，等待你先发消息）……',
      goodKeywords: ['你好', '我是', '朋友', '说过', '很高兴', '认识'],
      referenceReply: '你好！我是XX的朋友XX，他跟我提过你，说你喜欢XX。很高兴认识你～',
      successTip: '提及共同朋友+对方的兴趣点，证明不是群发。',
    ),
    const PracticeScenario(
      id: 'P015',
      title: '追女生的第一次约会',
      description: '你们聊了两周，终于约出来喝咖啡，第一次面对面',
      category: '追求',
      difficulty: Difficulty.medium,
      contactPersona: '对你有好感但还在观察的女生',
      openingMessage: '（女生坐下，微笑）你比照片上看起来更……本人？',
      goodKeywords: ['你好', '漂亮', '点单', '喜欢', '聊聊', '最近', '看什么'],
      referenceReply: '你好！你本人比照片还好看——别打我，我说的是实话。你想喝点什么？（点单后）聊聊吧，你最近在追什么剧？',
      successTip: '适度赞美+主动掌控节奏+找共同点。',
    ),
    const PracticeScenario(
      id: 'P016',
      title: '男生被追但不想耽误对方',
      description: '一个女生对你有好感，你想礼貌拒绝但不想伤害她',
      category: '追求',
      difficulty: Difficulty.hard,
      contactPersona: '喜欢你的女生，期待你的回应',
      openingMessage: '（女生鼓起勇气）我……我喜欢你，你愿意做我男朋友吗？',
      goodKeywords: ['谢谢你', '真的', '很好', '但', '不合适', '希望', '朋友'],
      referenceReply: '谢谢你，真的——你是个特别好的女孩，但我觉得我们可能不太合适。我不想耽误你，希望我们还能做朋友。',
      successTip: '先感谢肯定+明确拒绝+不给模糊希望。',
    ),

    // ========== 维系关系 ==========
    const PracticeScenario(
      id: 'P017',
      title: '异地恋日常联系',
      description: '你和恋人异地，每天视频但感觉话题越来越少',
      category: '维系关系',
      difficulty: Difficulty.medium,
      contactPersona: '你的异地恋伴侣，同样觉得没话聊',
      openingMessage: '（视频接通）嘿……今天怎么样？',
      goodKeywords: ['今天', '看到', '觉得', '有趣', '明天', '一起', '计划'],
      referenceReply: '今天看到一个超好笑的视频，等下发你——对了，明天你那边天气怎么样？我这边降温了，你要多穿。我们下个月见面想去哪？',
      successTip: '分享趣事+关心日常+规划未来，制造共同期待。',
    ),
    const PracticeScenario(
      id: 'P018',
      title: '和伴侣吵架后修复',
      description: '你们吵了一架，冷战半天，你想打破僵局',
      category: '维系关系',
      difficulty: Difficulty.hard,
      contactPersona: '还在生气的伴侣，等着你先开口',
      openingMessage: '（沉默良久）……',
      goodKeywords: ['对不起', '不该', '情绪', '不是', '你', '重要', '我'],
      referenceReply: '对不起，刚才不该那么情绪化说话——不是针对你，是我自己的问题。你对我来说最重要，我不该让你难过。',
      successTip: '先道歉+解释情绪来源+表达对方的重要性。',
    ),

    // ========== 家庭沟通 ==========
    const PracticeScenario(
      id: 'P019',
      title: '跟父母报平安',
      description: '在外打拼，妈妈打电话来，你想让她放心',
      category: '家庭',
      difficulty: Difficulty.easy,
      contactPersona: '关心你的妈妈，总想多问几句',
      openingMessage: '（电话接通）儿子/女儿，最近怎么样？吃饭了吗？',
      goodKeywords: ['挺好的', '吃了', '别担心', '工作', '注意', '身体'],
      referenceReply: '妈，我挺好的，刚吃完饭。别担心我，你和爸要注意身体。周末我打视频回去。',
      successTip: '简洁回应+主动关心+给明确的见面预期。',
    ),
    const PracticeScenario(
      id: 'P020',
      title: '跟长辈提不同意见',
      description: '长辈在家族群里发了一条你觉得不太对的消息',
      category: '家庭',
      difficulty: Difficulty.medium,
      contactPersona: '坚持己见的长辈，不喜欢被晚辈反驳',
      openingMessage: '（家族群里）长辈：这个XX就是好，你们年轻人不懂！',
      goodKeywords: ['其实', '了解', '不同', '想法', '您', '经验', '参考'],
      referenceReply: '其实我也了解过这个，可能不同的人看法不一样——您的经验很宝贵，我觉得可以参考，但也可以多一种选择～',
      successTip: '先尊重+表达差异+给台阶，不硬杠。',
    ),

    // ========== 网络社交 ==========
    const PracticeScenario(
      id: 'P021',
      title: '朋友圈回复评论',
      description: '你发了一条朋友圈，有人评论但你不想深聊',
      category: '网络社交',
      difficulty: Difficulty.easy,
      contactPersona: '不太熟的朋友，评论"牛逼"',
      openingMessage: '（朋友圈评论）牛逼啊！',
      goodKeywords: ['哈哈', '谢谢', '路过', '运气', '改天', '聚聚'],
      referenceReply: '哈哈谢谢～运气好而已。改天聚！',
      successTip: '简短回应+转移话题+给未来期待。',
    ),
    const PracticeScenario(
      id: 'P022',
      title: '网上被怼了怎么回',
      description: '你在社交平台发的内容被人恶意评论',
      category: '网络社交',
      difficulty: Difficulty.hard,
      contactPersona: '网络杠精，专门挑事',
      openingMessage: '（评论区）就这？也配发出来？',
      goodKeywords: ['尊重', '不同', '意见', '而已', '不必', '回喷'],
      referenceReply: '尊重不同意见，但请保持礼貌。不喜欢可以划走，不必恶语相向。',
      successTip: '不回喷+表明态度+划清界限。',
    ),

    // ========== 陌生人破冰 ==========
    const PracticeScenario(
      id: 'P023',
      title: '电梯里遇到邻居',
      description: '你和邻居一起等电梯，气氛有点尴尬',
      category: '破冰',
      difficulty: Difficulty.easy,
      contactPersona: '隔壁邻居，见过几次面但没说过话',
      openingMessage: '（电梯门打开，你们同时进电梯）……',
      goodKeywords: ['你好', '住几楼', '方便', '搬来', '好久', '了'],
      referenceReply: '你好！你也住这栋楼？我搬来快半年了，好像没怎么见过你。',
      successTip: '用共同环境作为切入点，自然破冰。',
    ),
    const PracticeScenario(
      id: 'P024',
      title: '自我介绍卡壳',
      description: '新同事让你自我介绍，你脑子一片空白',
      category: '破冰',
      difficulty: Difficulty.medium,
      contactPersona: '部门6位同事，期待认识你',
      openingMessage: '（HR看向你）来，你做个自我介绍吧～',
      goodKeywords: ['大家好', '我是', '负责', '兴趣', '很高兴', '加入'],
      referenceReply: '大家好，我是XX，负责XX这块。平时喜欢XX，周末爱去XX。很高兴加入团队，请多关照！',
      successTip: '姓名+职责+兴趣+礼貌，四要素齐全。',
    ),

    // ========== 职场社交 ==========
    const PracticeScenario(
      id: 'P025',
      title: '跟领导汇报进度',
      description: '领导突然来找你问项目进度，你还没准备好',
      category: '职场',
      difficulty: Difficulty.medium,
      contactPersona: '你的直属领导，关心进展和风险',
      openingMessage: '（领导走过来）XX，那个项目怎么样了？',
      goodKeywords: ['目前', '进度', '完成', '遇到', '问题', '计划', '明天'],
      referenceReply: '目前进度70%，核心功能已完成。遇到一个XX问题，正在排查。计划明天解决，后天提交测试。',
      successTip: '数据+进展+问题+计划，结构化汇报。',
    ),
    const PracticeScenario(
      id: 'P026',
      title: '同事甩锅给你',
      description: '项目出了问题，同事在会议上暗示是你的责任',
      category: '职场',
      difficulty: Difficulty.hard,
      contactPersona: '想推卸责任的同事，在领导面前',
      openingMessage: '（同事发言）这个问题可能跟XX那边的配合有关……',
      goodKeywords: ['其实', '具体', '时间线', '负责', '确认', '记录'],
      referenceReply: '其实这块我记得很清楚——具体时间线是这样：X月X日我确认过XX，有记录为证。如果有配合问题，我们可以一起看看怎么解决。',
      successTip: '用事实+记录说话，不情绪化指责。',
    ),
  ];
}

// ============================================================================
// 快速练习 Widget
// ============================================================================

class QuickPracticeWidget extends StatefulWidget {
  const QuickPracticeWidget({super.key});

  @override
  State<QuickPracticeWidget> createState() => _QuickPracticeWidgetState();
}

class _QuickPracticeWidgetState extends State<QuickPracticeWidget> {
  PracticeScenario? _selectedScenario;
  final _inputController = TextEditingController();
  final _random = Random();

  // 练习状态
  bool _inProgress = false;
  bool _finished = false;
  int _turn = 0;
  final int _maxTurns = 3;
  double _score = 0;
  String? _lastFeedback;
  final List<_PracticeMessage> _messages = [];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _startScenario(PracticeScenario scenario) {
    setState(() {
      _selectedScenario = scenario;
      _inProgress = true;
      _finished = false;
      _turn = 0;
      _score = 0;
      _messages.clear();
      _messages.add(_PracticeMessage(
        content: scenario.openingMessage,
        isUser: false,
      ));
    });
  }

  void _submitReply() {
    final text = _inputController.text.trim();
    if (text.isEmpty || _finished) return;
    _inputController.clear();

    final scenario = _selectedScenario!;
    double turnScore = _calculateScore(text, scenario.goodKeywords);
    _score += turnScore;

    // 生成反馈
    String feedback;
    if (turnScore >= 8) {
      feedback = '很好！用到了关键词，表达自然。';
    } else if (turnScore >= 5) {
      feedback = '不错，但可以更好。试试用关键词延伸话题。';
    } else {
      feedback = '需要改进。参考下面的示范话术。';
    }

    setState(() {
      _messages.add(_PracticeMessage(content: text, isUser: true));
      _turn++;
    });

    // 生成NPC回复
    Future.delayed(const Duration(milliseconds: 600), () {
      if (_turn >= _maxTurns) {
        setState(() {
          _finished = true;
          _lastFeedback = feedback;
        });
      } else {
        final npcReply = _generateNpcReply(turnScore);
        setState(() {
          _messages.add(_PracticeMessage(content: npcReply, isUser: false));
        });
      }
    });
  }

  double _calculateScore(String text, List<String> keywords) {
    double score = 3.0; // 基础分
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

  void _resetPractice() {
    setState(() {
      _selectedScenario = null;
      _inProgress = false;
      _finished = false;
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_inProgress && _selectedScenario != null) {
      return _buildPracticeView(cs);
    }
    return _buildScenarioList(cs);
  }

  Widget _buildScenarioList(ColorScheme cs) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Text(
            '选择一个场景快速练习（3轮对话，即时评分）',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: PracticeScenarioRegistry.scenarios.length,
            itemBuilder: (ctx, i) {
              final s = PracticeScenarioRegistry.scenarios[i];
              return _buildScenarioCard(cs, s);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScenarioCard(ColorScheme cs, PracticeScenario s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _startScenario(s),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: s.difficulty.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      s.difficulty.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: s.difficulty.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      s.category,
                      style: TextStyle(fontSize: 10, color: cs.primary),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.play_arrow_rounded, size: 18, color: cs.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                s.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.description,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPracticeView(ColorScheme cs) {
    final scenario = _selectedScenario!;
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
              Icon(Icons.flash_on_rounded, size: 18, color: scenario.difficulty.color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.title,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface),
                    ),
                    Text(
                      '轮次 $_turn/$_maxTurns · ${scenario.contactPersona}',
                      style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!_finished)
                TextButton(
                  onPressed: _resetPractice,
                  child: const Text('退出', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
        // 对话区
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) => _buildMessage(cs, _messages[i]),
          ),
        ),
        // 底部
        if (_finished)
          _buildResultPanel(cs, scenario, avgScore)
        else
          _buildInputBar(cs),
      ],
    );
  }

  Widget _buildMessage(ColorScheme cs, _PracticeMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? cs.primary.withValues(alpha: 0.12) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg.content,
          style: TextStyle(fontSize: 13, color: cs.onSurface, height: 1.4),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  Widget _buildResultPanel(ColorScheme cs, PracticeScenario scenario, double avgScore) {
    final isGood = avgScore >= 7;
    final isPass = avgScore >= 5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isGood ? Colors.green : (isPass ? Colors.orange : Colors.red)).withValues(alpha: 0.08),
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
                color: isGood ? Colors.green : (isPass ? Colors.orange : Colors.red),
              ),
              const SizedBox(width: 8),
              Text(
                '平均分 ${avgScore.toStringAsFixed(1)}/10',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isGood ? Colors.green.shade700 : (isPass ? Colors.orange.shade700 : Colors.red.shade700),
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
          // 反馈
          if (_lastFeedback != null) ...[
            Text('点评：$_lastFeedback', style: TextStyle(fontSize: 12, color: cs.onSurface)),
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
                    Text('参考话术', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.tertiary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(scenario.referenceReply, style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 成功提示
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
                  child: Text(scenario.successTip, style: TextStyle(fontSize: 12, color: cs.onSurface, height: 1.4)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _startScenario(scenario),
                  icon: const Icon(Icons.replay_rounded, size: 16),
                  label: const Text('再练一次'),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _resetPractice,
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

class _PracticeMessage {
  final String content;
  final bool isUser;

  _PracticeMessage({required this.content, required this.isUser});
}
