/// Pokemon sprite image, with methods to serialize and deserialize json
class Sprite {
  final String front_default;
  const Sprite({required this.front_default});

  static Sprite fromJson(Map<String, dynamic> json) {
    return Sprite(
      front_default: json['front_default'] as String,
    );
  }

  Map<String, dynamic> toJson(Sprite instance) => <String, dynamic>{
        'front_default': instance.front_default,
      };
}
