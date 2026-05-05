class BestiaryEntry {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final double baseHealth;
  final double baseDamage;

  BestiaryEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.baseHealth,
    required this.baseDamage,
  });
}

// Lista fixa com todos os inimigos do seu jogo
final List<BestiaryEntry> fullBestiary = [
  BestiaryEntry(
    id: 'rat',
    name: 'Rato Gigante',
    description: 'Um roedor mutante comum nas masmorras. Não subestime seus dentes.',
    imagePath: 'assets/images/sprites/inimigos/rat.png',
    baseHealth: 10,
    baseDamage: 1,
  ),
  BestiaryEntry(
    id: 'orc',
    name: 'Guerreiro Orc',
    description: 'Brutal e implacável. Prefere resolver tudo na base da machadada.',
    imagePath: 'assets/images/sprites/inimigos/orc.png',
    baseHealth: 45,
    baseDamage: 3,
  ),
  // Adicione todos os seus monstros aqui...
];