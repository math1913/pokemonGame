import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pokemon/models/battle_stats.dart';
import 'package:pokemon/models/pokemon.dart';
import 'package:pokemon/screens/result_screen.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({
    super.key,
    required this.playerOneTemplate,
    required this.playerTwoTemplate,
  });

  final PokemonTemplate playerOneTemplate;
  final PokemonTemplate playerTwoTemplate;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final Random _random = Random();
  final PlayerBattleStats _playerOneStats = PlayerBattleStats();
  final PlayerBattleStats _playerTwoStats = PlayerBattleStats();
  final List<MoveLogEntry> _history = [];

  late PokemonFighter _playerOne;
  late PokemonFighter _playerTwo;
  late DateTime _battleStart;

  int _activePlayer = 1;
  bool _battleFinished = false;
  String _statusText = '';

  bool _playerOneAttacking = false;
  bool _playerTwoAttacking = false;
  bool _playerOneHit = false;
  bool _playerTwoHit = false;

  @override
  void initState() {
    super.initState();
    _playerOne = PokemonFighter(widget.playerOneTemplate);
    _playerTwo = PokemonFighter(widget.playerTwoTemplate);
    _battleStart = DateTime.now();
    _statusText = 'Turno de ${_playerOne.name}.';
  }

  void _toggleAttackAnimation(int player) {
    setState(() {
      if (player == 1) {
        _playerOneAttacking = true;
      } else {
        _playerTwoAttacking = true;
      }
    });

    Future<void>.delayed(const Duration(milliseconds: 160), () {
      if (!mounted) {
        return;
      }
      setState(() {
        if (player == 1) {
          _playerOneAttacking = false;
        } else {
          _playerTwoAttacking = false;
        }
      });
    });
  }

  void _toggleHitAnimation(int player) {
    setState(() {
      if (player == 1) {
        _playerOneHit = true;
      } else {
        _playerTwoHit = true;
      }
    });

    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) {
        return;
      }
      setState(() {
        if (player == 1) {
          _playerOneHit = false;
        } else {
          _playerTwoHit = false;
        }
      });
    });
  }

  bool _isChance(int percent) => _random.nextInt(100) < percent;

  int _randomDamage(MoveType move) {
    final distance = move.maxDamage - move.minDamage + 1;
    return move.minDamage + _random.nextInt(distance);
  }

  bool _canPerformAnyMove(PokemonFighter fighter) {
    return MoveType.values.any((move) => fighter.canUse(move.ppCost));
  }

  void _handleMove(MoveType move) {
    if (_battleFinished) {
      return;
    }

    final attackerPlayer = _activePlayer;
    final defenderPlayer = attackerPlayer == 1 ? 2 : 1;

    final attacker = attackerPlayer == 1 ? _playerOne : _playerTwo;
    final defender = attackerPlayer == 1 ? _playerTwo : _playerOne;
    final attackerStats =
        attackerPlayer == 1 ? _playerOneStats : _playerTwoStats;

    if (!attacker.canUse(move.ppCost)) {
      setState(() {
        _statusText = '${attacker.name} no tiene PP suficientes.';
      });
      return;
    }

    _toggleAttackAnimation(attackerPlayer);

    var registerHitOnDefender = false;
    BattleResult? result;

    setState(() {
      if (move.isHealing) {
        attacker.consumePp(move.ppCost);
        final healedAmount = attacker.heal(25);

        attackerStats.registerMove(
          move,
          ppSpent: move.ppCost,
          healed: healedAmount,
          wasSuccessful: healedAmount > 0,
        );
        _history.insert(
          0,
          MoveLogEntry(
            attackerName: attacker.name,
            move: move,
            value: healedAmount,
            wasMissed: false,
            wasCritical: false,
          ),
        );

        _statusText = healedAmount > 0
            ? '${attacker.name} recupera $healedAmount PS.'
            : '${attacker.name} esta al maximo de PS.';
        _activePlayer = defenderPlayer;
      } else {
        final missed = _isChance(5);

        if (missed) {
          attackerStats.registerMove(
            move,
            ppSpent: 0,
            wasSuccessful: false,
          );
          _history.insert(
            0,
            MoveLogEntry(
              attackerName: attacker.name,
              move: move,
              value: 0,
              wasMissed: true,
              wasCritical: false,
            ),
          );
          _statusText = 'El ataque de ${attacker.name} ha fallado.';
          _activePlayer = defenderPlayer;
          return;
        }

        attacker.consumePp(move.ppCost);
        var damage = _randomDamage(move);
        damage = (damage * attacker.damageMultiplier).round();

        final critical = _isChance(10);
        if (critical) {
          damage *= 2;
        }

        defender.takeDamage(damage);
        attackerStats.registerMove(
          move,
          ppSpent: move.ppCost,
          damage: damage,
        );
        _history.insert(
          0,
          MoveLogEntry(
            attackerName: attacker.name,
            move: move,
            value: damage,
            wasMissed: false,
            wasCritical: critical,
          ),
        );

        registerHitOnDefender = true;
        _statusText = critical
            ? 'Golpe critico de ${attacker.name}: $damage de da\u00f1o.'
            : '${attacker.name} causa $damage de da\u00f1o.';

        if (defender.isFainted) {
          _battleFinished = true;
          result = _buildResult(winnerName: attacker.name);
        } else {
          _activePlayer = defenderPlayer;
        }
      }

      if (!_battleFinished) {
        var checks = 0;
        while (checks < 2) {
          final currentFighter =
              _activePlayer == 1 ? _playerOne : _playerTwo;
          final canMove = _canPerformAnyMove(currentFighter);
          if (canMove) {
            break;
          }

          _activePlayer = _activePlayer == 1 ? 2 : 1;
          checks++;
        }

        final currentFighter = _activePlayer == 1 ? _playerOne : _playerTwo;
        final otherFighter = _activePlayer == 1 ? _playerTwo : _playerOne;
        final currentCanMove = _canPerformAnyMove(currentFighter);
        final otherCanMove = _canPerformAnyMove(otherFighter);

        if (!currentCanMove && !otherCanMove) {
          _battleFinished = true;
          final winnerByHp = _playerOne.hp >= _playerTwo.hp
              ? _playerOne.name
              : _playerTwo.name;
          _statusText = 'Sin PP disponibles. Gana $winnerByHp por PS restantes.';
          result = _buildResult(winnerName: winnerByHp);
        } else {
          final currentName =
              _activePlayer == 1 ? _playerOne.name : _playerTwo.name;
          _statusText = '$_statusText Turno de $currentName.';
        }
      }
    });

    if (registerHitOnDefender) {
      _toggleHitAnimation(defenderPlayer);
    }

    if (result != null) {
      final battleResult = result!;
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => ResultScreen(
              result: battleResult,
              playerOneTemplate: widget.playerOneTemplate,
              playerTwoTemplate: widget.playerTwoTemplate,
            ),
          ),
        );
      });
    }
  }

  BattleResult _buildResult({required String winnerName}) {
    final totalAttacks = _history.where((entry) => !entry.move.isHealing).length;
    return BattleResult(
      winnerName: winnerName,
      totalAttacks: totalAttacks,
      duration: DateTime.now().difference(_battleStart),
      playerOneStats: _playerOneStats,
      playerTwoStats: _playerTwoStats,
      history: List<MoveLogEntry>.from(_history),
    );
  }

  IconData _iconForMove(MoveType move) {
    switch (move) {
      case MoveType.quick:
        return Icons.flash_on;
      case MoveType.normal:
        return Icons.sports_martial_arts;
      case MoveType.strong:
        return Icons.whatshot;
      case MoveType.heal:
        return Icons.healing;
    }
  }

  Color _colorForMove(MoveType move) {
    switch (move) {
      case MoveType.quick:
        return const Color(0xFF00ACC1);
      case MoveType.normal:
        return const Color(0xFF3949AB);
      case MoveType.strong:
        return const Color(0xFFF57C00);
      case MoveType.heal:
        return const Color(0xFF2E7D32);
    }
  }

  Color _healthColor(double ratio) {
    if (ratio <= 0.25) {
      return Colors.red;
    }
    if (ratio <= 0.5) {
      return Colors.orange;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final currentFighter = _activePlayer == 1 ? _playerOne : _playerTwo;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batalla Pokemon'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF5FAFF), Color(0xFFDAECFF), Color(0xFFC6E0FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -70,
            left: -45,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -85,
            right: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFF9A825).withOpacity(0.09),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _BattleHeader(
                    activePlayerName:
                        _activePlayer == 1 ? _playerOne.name : _playerTwo.name,
                    statusText: _statusText,
                    isFinished: _battleFinished,
                  ),
                  const SizedBox(height: 8),
                  _PokemonBattleCard(
                    fighter: _playerOne,
                    isTurn: _activePlayer == 1 && !_battleFinished,
                    isAttacking: _playerOneAttacking,
                    isHit: _playerOneHit,
                    healthColor: _healthColor(
                      _playerOne.hp / _playerOne.maxHp,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _PokemonBattleCard(
                    fighter: _playerTwo,
                    isTurn: _activePlayer == 2 && !_battleFinished,
                    isAttacking: _playerTwoAttacking,
                    isHit: _playerTwoHit,
                    healthColor: _healthColor(
                      _playerTwo.hp / _playerTwo.maxHp,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ActionPanel(
                    title: 'Movimientos de ${currentFighter.name}',
                    enabled: !_battleFinished,
                    fighter: currentFighter,
                    onMoveSelected: _handleMove,
                    iconForMove: _iconForMove,
                    colorForMove: _colorForMove,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _HistoryPanel(history: _history),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BattleHeader extends StatelessWidget {
  const _BattleHeader({
    required this.activePlayerName,
    required this.statusText,
    required this.isFinished,
  });

  final String activePlayerName;
  final String statusText;
  final bool isFinished;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF0B5ED7).withOpacity(0.15)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isFinished ? 'Combate finalizado' : 'Turno actual: $activePlayerName',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(statusText, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PokemonBattleCard extends StatelessWidget {
  const _PokemonBattleCard({
    required this.fighter,
    required this.isTurn,
    required this.isAttacking,
    required this.isHit,
    required this.healthColor,
  });

  final PokemonFighter fighter;
  final bool isTurn;
  final bool isAttacking;
  final bool isHit;
  final Color healthColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHit ? const Color(0xFFFFEBEE) : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTurn ? const Color(0xFF1565C0) : Colors.transparent,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedSlide(
            offset: isAttacking ? const Offset(0.06, 0) : Offset.zero,
            duration: const Duration(milliseconds: 140),
            child: AnimatedScale(
              scale: isAttacking ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 140),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F4FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.network(
                  fighter.template.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Icon(Icons.catching_pokemon, size: 42);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fighter.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Multiplicador: x${fighter.damageMultiplier.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3A5A7F),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: fighter.hp / fighter.maxHp,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(100),
                  backgroundColor: const Color(0xFFFFCDD2),
                  color: healthColor,
                ),
                const SizedBox(height: 2),
                Text('PS: ${fighter.hp}/${fighter.maxHp}'),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: fighter.pp / fighter.maxPp,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(100),
                  backgroundColor: const Color(0xFFBBDEFB),
                  color: const Color(0xFF1565C0),
                ),
                const SizedBox(height: 2),
                Text('PP: ${fighter.pp}/${fighter.maxPp}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.title,
    required this.enabled,
    required this.fighter,
    required this.onMoveSelected,
    required this.iconForMove,
    required this.colorForMove,
  });

  final String title;
  final bool enabled;
  final PokemonFighter fighter;
  final ValueChanged<MoveType> onMoveSelected;
  final IconData Function(MoveType move) iconForMove;
  final Color Function(MoveType move) colorForMove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF0B5ED7).withOpacity(0.12)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: MoveType.values.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.45,
            ),
            itemBuilder: (_, index) {
              final move = MoveType.values[index];
              final canUseNow = enabled && fighter.canUse(move.ppCost);
              final moveColor = colorForMove(move);

              return ElevatedButton(
                onPressed: canUseNow ? () => onMoveSelected(move) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: moveColor.withOpacity(0.14),
                  foregroundColor: moveColor,
                  disabledBackgroundColor: const Color(0xFFE6ECF3),
                  disabledForegroundColor: const Color(0xFF8CA2BC),
                  side: BorderSide(color: moveColor.withOpacity(0.35)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(iconForMove(move), size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${move.label} (${move.ppCost})',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.history});

  final List<MoveLogEntry> history;

  @override
  Widget build(BuildContext context) {
    final shownEntries = history.take(5).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF0B5ED7).withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ultimos movimientos',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: shownEntries.isEmpty
                ? const Center(
                    child: Text('Todavia no hay acciones en el combate.'),
                  )
                : ListView.separated(
                    itemCount: shownEntries.length,
                    separatorBuilder: (_, __) => const Divider(height: 8),
                    itemBuilder: (_, index) {
                      final entry = shownEntries[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F8FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(entry.description),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
