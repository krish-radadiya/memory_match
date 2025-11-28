import 'package:flutter/foundation.dart';

@immutable
class MemoryCard {
  final int id;
  final String pairId;
  final bool isFaceUp;
  final bool isMatched;

  const MemoryCard({
    required this.id,
    required this.pairId,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({int? id, String? pairId, bool? isFaceUp, bool? isMatched}) {
    return MemoryCard(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
