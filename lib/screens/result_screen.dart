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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF90CAF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
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
                                fontSize: 32,
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
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 11),
                          child: Text(
                            'Nueva Batalla',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        icon: const Icon(Icons.home),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 11),
                          child: Text('Volver al Inicio'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text('Danio total causado: ${stats.totalDamage}'),
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
