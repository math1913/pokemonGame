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
            top: -70,
            right: -50,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.14),
              ),
            ),
          ),
          Positioned(
            bottom: -90,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFF0B5ED7).withOpacity(0.14),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x26000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.catching_pokemon,
                              color: Color(0xFF0B5ED7),
                              size: 30,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'POKEMON',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          'Battle Arena',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Selecciona Pokemon para cada jugador y comenzar la batalla.',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: const [
                            _InfoChip(
                              icon: Icons.repeat,
                              text: 'Turnos Alternos',
                            ),
                            _InfoChip(
                              icon: Icons.local_fire_department,
                              text: 'Critico y Fallo',
                            ),
                            _InfoChip(
                              icon: Icons.bar_chart,
                              text: 'Estadisticas Finales',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _PokemonSelectionCard(
                    title: 'Jugador 1',
                    selectedPokemon: _playerOneSelection,
                    onChanged: (pokemon) {
                      if (pokemon != null) {
                        setState(() => _playerOneSelection = pokemon);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _PokemonSelectionCard(
                    title: 'Jugador 2',
                    selectedPokemon: _playerTwoSelection,
                    onChanged: (pokemon) {
                      if (pokemon != null) {
                        setState(() => _playerTwoSelection = pokemon);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _startBattle,
                    icon: const Icon(Icons.sports_kabaddi),
                    label: const Text(
                      'Comenzar Batalla',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _showExitDialog,
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text(
                      'Salir',
                      style: TextStyle(fontSize: 16),
                    ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

        final selector = DropdownButtonFormField<PokemonTemplate>(
          value: selectedPokemon,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Pokemon',
            isDense: true,
          ),
          selectedItemBuilder: (_) {
            return availablePokemons
                .map(
                  (pokemon) => Text(
                    pokemon.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                .toList();
          },
          items: availablePokemons
              .map(
                (pokemon) => DropdownMenuItem<PokemonTemplate>(
                  value: pokemon,
                  child: Text(
                    '${pokemon.name} (${pokemon.maxHp}/${pokemon.maxPp})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        );

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.93),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF0B5ED7).withOpacity(0.14)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 12,
                offset: Offset(0, 7),
              ),
            ],
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
              if (compact)
                Column(
                  children: [
                    _PokemonAvatar(imageUrl: selectedPokemon.imageUrl),
                    const SizedBox(height: 10),
                    selector,
                  ],
                )
              else
                Row(
                  children: [
                    _PokemonAvatar(imageUrl: selectedPokemon.imageUrl),
                    const SizedBox(width: 12),
                    Expanded(child: selector),
                  ],
                ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'PS ${selectedPokemon.maxHp} / PP ${selectedPokemon.maxPp} / x${selectedPokemon.damageMultiplier.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF21446F),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PokemonAvatar extends StatelessWidget {
  const _PokemonAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: const Color(0xFFBBDEFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.catching_pokemon),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF0B5ED7).withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0B5ED7)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B3D69),
            ),
          ),
        ],
      ),
    );
  }
}
