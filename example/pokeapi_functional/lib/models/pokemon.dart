import 'package:pokeapi_functional/models/sprite.dart';

/// Pokemon information, with method to deserialize json
class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;
  final Sprite sprites;

  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.sprites,
  });

  static Pokemon fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      weight: json['weight'] as int,
      height: json['height'] as int,
      sprites: Sprite.fromJson(json['sprites'] as Map<String, dynamic>),
    );
  }
}
