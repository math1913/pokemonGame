class PokemonTemplate {
  const PokemonTemplate({
    required this.name,
    required this.spriteId,
    required this.maxHp,
    required this.maxPp,
    required this.damageMultiplier,
  });

  final String name;
  final int spriteId;
  final int maxHp;
  final int maxPp;
  final double damageMultiplier;

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$spriteId.png';
}

const List<PokemonTemplate> availablePokemons = [
  PokemonTemplate(
    name: 'Pikachu',
    spriteId: 25,
    maxHp: 110,
    maxPp: 35,
    damageMultiplier: 1.05,
  ),
  PokemonTemplate(
    name: 'Charizard',
    spriteId: 6,
    maxHp: 120,
    maxPp: 30,
    damageMultiplier: 1.12,
  ),
  PokemonTemplate(
    name: 'Blastoise',
    spriteId: 9,
    maxHp: 135,
    maxPp: 28,
    damageMultiplier: 0.95,
  ),
  PokemonTemplate(
    name: 'Venusaur',
    spriteId: 3,
    maxHp: 130,
    maxPp: 32,
    damageMultiplier: 1.00,
  ),
  PokemonTemplate(
    name: 'Gengar',
    spriteId: 94,
    maxHp: 105,
    maxPp: 40,
    damageMultiplier: 1.08,
  ),
];

class PokemonFighter {
  PokemonFighter(this.template)
      : hp = template.maxHp,
        pp = template.maxPp;

  final PokemonTemplate template;
  int hp;
  int pp;

  String get name => template.name;
  int get maxHp => template.maxHp;
  int get maxPp => template.maxPp;
  double get damageMultiplier => template.damageMultiplier;
  bool get isFainted => hp <= 0;

  bool canUse(int ppCost) => !isFainted && pp >= ppCost;

  void takeDamage(int amount) {
    hp = (hp - amount).clamp(0, maxHp).toInt();
  }

  int heal(int amount) {
    final previousHp = hp;
    hp = (hp + amount).clamp(0, maxHp).toInt();
    return hp - previousHp;
  }

  void consumePp(int amount) {
    pp = (pp - amount).clamp(0, maxPp).toInt();
  }
}
