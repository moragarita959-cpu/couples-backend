class IdeaNote {
  const IdeaNote({
    required this.id,
    required this.coupleId,
    required this.authorUserId,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    this.moodTag,
    this.colorStyle,
    this.layoutStyle,
    this.commentCount = 0,
  });

  static const String typeMood = 'mood';
  static const String typeIdea = 'idea';
  static const String typeWish = 'wish';

  static const List<String> supportedTypes = <String>[
    typeMood,
    typeIdea,
    typeWish,
  ];

  static const List<String> supportedMoodTags = <String>[
    '温柔',
    '开心',
    '想念',
    '低落',
    '期待',
    '平静',
    '勇敢',
  ];

  static const List<String> supportedColorStyles = <String>[
    'pink',
    'cream',
    'lavender',
    'blue',
    'green',
  ];

  static const List<String> supportedLayoutStyles = <String>[
    'plain',
    'paper',
    'grid',
    'photo',
    'floral',
  ];

  final String id;
  final String coupleId;
  final String authorUserId;
  final String type;
  final String? title;
  final String content;
  final String? moodTag;
  final String? colorStyle;
  final String? layoutStyle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int commentCount;

  bool authoredBy(String? userId) => userId != null && authorUserId == userId;
}
