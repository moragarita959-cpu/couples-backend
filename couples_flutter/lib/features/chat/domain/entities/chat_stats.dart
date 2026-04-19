class ChatStats {
  const ChatStats({
    required this.totalMessages,
    required this.streakDays,
    required this.meInitiativeRatio,
    required this.partnerInitiativeRatio,
    required this.totalCharacterCount,
    required this.meCharacterCount,
    required this.partnerCharacterCount,
  });

  final int totalMessages;
  final int streakDays;
  final double meInitiativeRatio;
  final double partnerInitiativeRatio;
  final int totalCharacterCount;
  final int meCharacterCount;
  final int partnerCharacterCount;
}
