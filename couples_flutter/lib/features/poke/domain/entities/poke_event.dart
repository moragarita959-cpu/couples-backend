enum PokeSender { me, partner }

class PokeEvent {
  const PokeEvent({
    required this.id,
    required this.sender,
    required this.createdAt,
    required this.message,
  });

  final String id;
  final PokeSender sender;
  final DateTime createdAt;
  final String message;
}
