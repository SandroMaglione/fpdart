import 'package:freezed_annotation/freezed_annotation.dart';

part 'sprite.freezed.dart';
part 'sprite.g.dart';

/// Pokemon sprite image, with method to deserialize json
@freezed
class Sprite with _$Sprite {
  const factory Sprite({
    @JsonKey(name: 'front_default') required String frontDefault,
  }) = _Sprite;

  factory Sprite.fromJson(Map<String, Object?> json) => _$SpriteFromJson(json);
}
