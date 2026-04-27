class ExcerptNote {
  const ExcerptNote({
    required this.id,
    required this.coupleId,
    required this.authorUserId,
    required this.category,
    required this.quoteText,
    required this.createdAt,
    required this.updatedAt,
    this.sourceTitle,
    this.sourceAuthor,
    this.sourceDetail,
    this.personalNote,
    this.cardStyle,
    this.colorStyle,
    this.commentCount = 0,
  });

  static const String categoryBook = 'book';
  static const String categoryMovie = 'movie';
  static const String categoryLyric = 'lyric';
  static const String categoryCustom = 'custom';

  static const List<String> supportedCategories = <String>[
    categoryBook,
    categoryMovie,
    categoryLyric,
    categoryCustom,
  ];

  static const List<String> supportedCardStyles = <String>[
    'minimal',
    'paper',
    'magazine',
    'sticky',
    'floral',
  ];

  static const List<String> supportedColorStyles = <String>[
    'lavender',
    'rose',
    'cream',
    'sage',
    'mist',
  ];

  final String id;
  final String coupleId;
  final String authorUserId;
  final String category;
  final String quoteText;
  final String? sourceTitle;
  final String? sourceAuthor;
  final String? sourceDetail;
  final String? personalNote;
  final String? cardStyle;
  final String? colorStyle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int commentCount;

  bool authoredBy(String? userId) => userId != null && authorUserId == userId;
}
