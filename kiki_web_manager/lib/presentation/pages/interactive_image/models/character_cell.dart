enum CharacterCellStatus { pending, active, completed }

class CharacterCell {
  const CharacterCell({
    required this.character,
    required this.status,
  });

  final String character;
  final CharacterCellStatus status;

  bool get shouldAnimate => status == CharacterCellStatus.active;
  bool get isVisible => status != CharacterCellStatus.pending;
}
