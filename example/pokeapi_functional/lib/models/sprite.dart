/// Pokemon sprite image, with method to deserialize json
// ignore_for_file: non_constant_identifier_names

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
