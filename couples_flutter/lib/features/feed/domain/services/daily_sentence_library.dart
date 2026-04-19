class DailySentence {
  const DailySentence({
    required this.text,
    required this.tags,
  });

  final String text;
  final List<String> tags;
}

class DailySentenceLibrary {
  const DailySentenceLibrary._();

  static const List<String> tags = <String>[
    '全部',
    '甜蜜',
    '鼓励',
    '想念',
    '日常',
  ];

  static const List<DailySentence> sentences = <DailySentence>[
    DailySentence(text: '爱有时候很安静，但它一直都在出现。', tags: <String>['甜蜜', '日常']),
    DailySentence(text: '今天也很适合温柔回应彼此，再靠近一点。', tags: <String>['甜蜜', '日常']),
    DailySentence(text: '一个小小的回应，也能让整天都暖起来。', tags: <String>['甜蜜', '日常']),
    DailySentence(text: '想你已经变成日常，而这正说明它很真实。', tags: <String>['想念', '甜蜜']),
    DailySentence(text: '希望我们都能继续成为彼此安心的地方。', tags: <String>['鼓励', '甜蜜']),
    DailySentence(text: '你不用完美，也值得被认真喜欢。', tags: <String>['鼓励']),
    DailySentence(text: '再忙的一天，也可以给爱留下一点柔软。', tags: <String>['日常', '甜蜜']),
    DailySentence(text: '我还是会第一时间想把小事先告诉你。', tags: <String>['想念', '日常']),
    DailySentence(text: '被记住那些小细节，本身也是一种浪漫。', tags: <String>['甜蜜']),
    DailySentence(text: '慢一点没关系，我们还是可以靠得很近。', tags: <String>['鼓励']),
    DailySentence(text: '好的关系，常常是很多普通夜晚慢慢搭起来的。', tags: <String>['日常']),
    DailySentence(text: '一想到“家”，脑海里总会先出现你的名字。', tags: <String>['想念', '甜蜜']),
    DailySentence(text: '继续加油呀，有人在认真为你打气。', tags: <String>['鼓励']),
    DailySentence(text: '爱有时候也只是问一句：你今天吃饭了吗？', tags: <String>['日常', '甜蜜']),
    DailySentence(text: '如果今天有点重，也可以把一部分放在这里。', tags: <String>['鼓励', '想念']),
    DailySentence(text: '下一个小小的里程碑，常常就是再多一次回应。', tags: <String>['鼓励', '日常']),
  ];

  static List<DailySentence> byTag(String tag) {
    if (tag == '全部') {
      return sentences;
    }
    return sentences.where((item) => item.tags.contains(tag)).toList();
  }
}
