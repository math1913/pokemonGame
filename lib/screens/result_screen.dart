import 'package:flutter/material.dart';
import 'package:pokemon/models/battle_stats.dart';
import 'package:pokemon/models/pokemon.dart';
import 'package:pokemon/screens/battle_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.playerOneTemplate,
    required this.playerTwoTemplate,
  });

  final BattleResult result;
  final PokemonTemplate playerOneTemplate;
  final PokemonTemplate playerTwoTemplate;

  String _durationLabel(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  MoveType _mostUsedOverall() {
    final totals = <MoveType, int>{
      for (final move in MoveType.values) move: 0,
    };

    for (final move in MoveType.values) {
      totals[move] = result.playerOneStats.usageOf(move) +
          result.playerTwoStats.usageOf(move);
    }

    return totals.entries.reduce((current, next) {
      return current.value >= next.value ? current : next;
    }).key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado de la batalla')),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B3B8A), Color(0xFF1E88E5), Color(0xFFEAF4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.13),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF0B5ED7).withOpacity(0.14),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Color(0xFFF9A825),
                            size: 46,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ganador',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            result.winnerName,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Ataques totales: ${result.totalAttacks}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Duracion aproximada: ${_durationLabel(result.duration)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ataque mas usado global: ${_mostUsedOverall().label}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _StatsCard(
                      title: playerOneTemplate.name,
                      stats: result.playerOneStats,
                    ),
                    const SizedBox(height: 12),
                    _StatsCard(
                      title: playerTwoTemplate.name,
                      stats: result.playerTwoStats,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => BattleScreen(
                              playerOneTemplate: playerOneTemplate,
                              playerTwoTemplate: playerTwoTemplate,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Nueva Batalla',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Volver al Inicio'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.title, required this.stats});

  final String title;
  final PlayerBattleStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0B5ED7).withOpacity(0.12)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 9,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadisticas de $title',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text('Acciones exitosas: ${stats.successfulActions}'),
          Text('Da\u00f1o total causado: ${stats.totalDamage}'),
          Text('Curacion total: ${stats.totalHealing}'),
          Text('PP total gastado: ${stats.totalPpSpent}'),
          Text('Movimiento mas usado: ${stats.mostUsedMove.label}'),
          const Divider(height: 18),
          Text('Uso Ataque Rapido: ${stats.usageOf(MoveType.quick)}'),
          Text('Uso Ataque Normal: ${stats.usageOf(MoveType.normal)}'),
          Text('Uso Ataque Fuerte: ${stats.usageOf(MoveType.strong)}'),
          Text('Uso Curacion: ${stats.usageOf(MoveType.heal)}'),
        ],
      ),
    );
  }
}
