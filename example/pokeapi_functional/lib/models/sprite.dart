/// Pokemon sprite image, with method to deserialize json
// ignore_for_file: non_constant_identifier_names, prefer_constructors_over_static_methods, lines_longer_than_80_chars

class Sprite {
  final String front_default;

  const Sprite({
    required this.front_default,
  });

  static Sprite fromJson(Map<String, dynamic> json) {
    return Sprite(
      front_default: json['front_default'] as String,
    );
  }
}
