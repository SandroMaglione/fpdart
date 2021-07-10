/// Pokemon sprite image, with method to deserialize json
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
