import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokemon/models/pokemon.dart';
import 'package:pokemon/screens/battle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PokemonTemplate _playerOneSelection = availablePokemons.first;
  PokemonTemplate _playerTwoSelection = availablePokemons[1];

  Future<void> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Salir'),
          content: const Text('Quieres cerrar la aplicacion?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      await SystemNavigator.pop();
    }
  }

  void _startBattle() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BattleScreen(
          playerOneTemplate: _playerOneSelection,
          playerTwoTemplate: _playerTwoSelection,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF42A5F5), Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'POKEMON',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              color: Color(0xFF0D47A1),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Battle Arena',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Selecciona Pokemon para cada jugador y comienza la batalla.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _PokemonSelectionCard(
                      title: 'Jugador 1',
                      selectedPokemon: _playerOneSelection,
                      onChanged: (pokemon) {
                        if (pokemon != null) {
                          setState(() => _playerOneSelection = pokemon);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    _PokemonSelectionCard(
                      title: 'Jugador 2',
                      selectedPokemon: _playerTwoSelection,
                      onChanged: (pokemon) {
                        if (pokemon != null) {
                          setState(() => _playerTwoSelection = pokemon);
                        }
                      },
                    ),
                    const SizedBox(height: 22),
                    FilledButton.icon(
                      onPressed: _startBattle,
                      icon: const Icon(Icons.sports_kabaddi),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Comencar Batalla',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _showExitDialog,
                      icon: const Icon(Icons.exit_to_app),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Salir',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PokemonSelectionCard extends StatelessWidget {
  const _PokemonSelectionCard({
    required this.title,
    required this.selectedPokemon,
    required this.onChanged,
  });

  final String title;
  final PokemonTemplate selectedPokemon;
  final ValueChanged<PokemonTemplate?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: const Color(0xFFBBDEFB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.network(
                  selectedPokemon.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.catching_pokemon),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<PokemonTemplate>(
                  value: selectedPokemon,
                  decoration: const InputDecoration(
                    labelText: 'Pokemon',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: availablePokemons
                      .map(
                        (pokemon) => DropdownMenuItem<PokemonTemplate>(
                          value: pokemon,
                          child: Text(
                            '${pokemon.name} - PS ${pokemon.maxHp} / PP ${pokemon.maxPp}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
