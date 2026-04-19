class FeedSummaryBuilder {
  const FeedSummaryBuilder._();

  static String todoCreated({
    required String title,
    required bool isPartnerTask,
  }) {
    if (isPartnerTask) {
      return '你给 TA 新增了待办：$title';
    }
    return '你新增了待办：$title';
  }

  static String todoCompleted({required String title}) {
    return '你完成了待办：$title';
  }

  static String todoDeleted({required String title}) {
    return '你删除了待办：$title';
  }

  static String billCreated({
    required String categoryLabel,
    required double amount,
  }) {
    return '你新增了一笔$categoryLabel：${amount.toStringAsFixed(2)}';
  }

  static String billUpdated({
    required String categoryLabel,
    required double amount,
  }) {
    return '你更新了$categoryLabel账单：${amount.toStringAsFixed(2)}';
  }

  static String billDeleted({
    required String categoryLabel,
    required double amount,
  }) {
    return '你删除了$categoryLabel账单：${amount.toStringAsFixed(2)}';
  }

  static String countdownCreated({required String name}) {
    return '你新增了纪念日：$name';
  }

  static String countdownUpdated({required String name}) {
    return '你修改了纪念日：$name';
  }

  static String countdownDeleted({required String name}) {
    return '你删除了纪念日：$name';
  }

  static String songAdded({required String songName}) {
    return '你把《$songName》加入了共享歌单';
  }

  static String songReviewAdded({required String songName}) {
    return '你给《$songName》写了新的乐评';
  }

  static String songReviewUpdated({required String songName}) {
    return '你更新了《$songName》的乐评';
  }

  static String courseCreated({required String title}) {
    return '你添加了课程：$title';
  }

  static String courseUpdated({required String title}) {
    return '你修改了课程：$title';
  }

  static String courseDeleted({required String title}) {
    return '你删除了课程：$title';
  }
}
