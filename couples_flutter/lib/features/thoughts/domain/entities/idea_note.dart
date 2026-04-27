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
    this.moodTags = const <String>[],
    this.colorStyle,
    this.layoutStyle,
    this.stickerStyle,
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
    '想念',
    '开心',
    '期待',
    '低落',
    '平静',
    '勇敢',
  ];

  // Note paper background colors. Six soft tones to mirror the design mocks.
  static const List<String> supportedColorStyles = <String>[
    'pink',
    'cream',
    'sage',
    'mist',
    'lavender',
    'peach',
  ];

  // Paper layout templates picked at create time.
  static const List<String> supportedLayoutStyles = <String>[
    'tape',
    'pin',
    'paperclip',
    'spiral',
  ];

  // Decorative stickers picked at preview time. The values map to icon
  // glyphs rendered on the card. Null means no sticker.
  static const List<String> supportedStickerStyles = <String>[
    'heart',
    'leaf',
    'sparkle',
    'music',
    'tape',
    'flower',
  ];

  final String id;
  final String coupleId;
  final String authorUserId;
  final String type;
  final String? title;
  final String content;
  final List<String> moodTags;
  final String? colorStyle;
  final String? layoutStyle;
  final String? stickerStyle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int commentCount;

  bool authoredBy(String? userId) => userId != null && authorUserId == userId;
}
