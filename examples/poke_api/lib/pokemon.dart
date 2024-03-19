class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;

  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
  });

  factory Pokemon.fromJson(Map<String, Object?> json) => Pokemon(
        id: json['id'] as int,
        name: json['name'] as String,
        height: json['height'] as int,
        weight: json['weight'] as int,
      );
}
