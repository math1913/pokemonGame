enum MoveType { quick, normal, strong, heal }

extension MoveTypeConfig on MoveType {
  String get label {
    switch (this) {
      case MoveType.quick:
        return 'Ataque Rapido';
      case MoveType.normal:
        return 'Ataque Normal';
      case MoveType.strong:
        return 'Ataque Fuerte';
      case MoveType.heal:
        return 'Curacion';
    }
  }

  int get ppCost {
    switch (this) {
      case MoveType.quick:
        return 5;
      case MoveType.normal:
        return 10;
      case MoveType.strong:
        return 20;
      case MoveType.heal:
        return 15;
    }
  }

  int get minDamage {
    switch (this) {
      case MoveType.quick:
        return 10;
      case MoveType.normal:
        return 20;
      case MoveType.strong:
        return 35;
      case MoveType.heal:
        return 0;
    }
  }

  int get maxDamage {
    switch (this) {
      case MoveType.quick:
        return 15;
      case MoveType.normal:
        return 25;
      case MoveType.strong:
        return 45;
      case MoveType.heal:
        return 0;
    }
  }

  bool get isHealing => this == MoveType.heal;
}

class PlayerBattleStats {
  PlayerBattleStats()
      : moveUsage = {for (final move in MoveType.values) move: 0};

  final Map<MoveType, int> moveUsage;
  int totalDamage = 0;
  int totalPpSpent = 0;
  int totalHealing = 0;
  int successfulActions = 0;

  void registerMove(
    MoveType move, {
    required int ppSpent,
    int damage = 0,
    int healed = 0,
    bool wasSuccessful = true,
  }) {
    moveUsage[move] = (moveUsage[move] ?? 0) + 1;
    totalDamage += damage;
    totalHealing += healed;
    totalPpSpent += ppSpent;

    if (wasSuccessful) {
      successfulActions++;
    }
  }

  int usageOf(MoveType move) => moveUsage[move] ?? 0;

  MoveType get mostUsedMove {
    return moveUsage.entries.reduce((current, next) {
      return current.value >= next.value ? current : next;
    }).key;
  }
}

class MoveLogEntry {
  const MoveLogEntry({
    required this.attackerName,
    required this.move,
    required this.value,
    required this.wasMissed,
    required this.wasCritical,
  });

  final String attackerName;
  final MoveType move;
  final int value;
  final bool wasMissed;
  final bool wasCritical;

  String get description {
    if (wasMissed) {
      return '$attackerName intento ${move.label}, pero fallo.';
    }

    if (move.isHealing) {
      return '$attackerName uso ${move.label} y recupero $value PS.';
    }

    final criticalText = wasCritical ? ' (Critico)' : '';
    return '$attackerName uso ${move.label} e hizo $value de da\u00f1o$criticalText.';
  }
}

class BattleResult {
  const BattleResult({
    required this.winnerName,
    required this.totalAttacks,
    required this.duration,
    required this.playerOneStats,
    required this.playerTwoStats,
    required this.history,
  });

  final String winnerName;
  final int totalAttacks;
  final Duration duration;
  final PlayerBattleStats playerOneStats;
  final PlayerBattleStats playerTwoStats;
  final List<MoveLogEntry> history;
}
