// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sprite.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Sprite _$SpriteFromJson(Map<String, dynamic> json) {
  return _Sprite.fromJson(json);
}

/// @nodoc
mixin _$Sprite {
  @JsonKey(name: 'front_default')
  String get frontDefault => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SpriteCopyWith<Sprite> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpriteCopyWith<$Res> {
  factory $SpriteCopyWith(Sprite value, $Res Function(Sprite) then) =
      _$SpriteCopyWithImpl<$Res, Sprite>;
  @useResult
  $Res call({@JsonKey(name: 'front_default') String frontDefault});
}

/// @nodoc
class _$SpriteCopyWithImpl<$Res, $Val extends Sprite>
    implements $SpriteCopyWith<$Res> {
  _$SpriteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frontDefault = null,
  }) {
    return _then(_value.copyWith(
      frontDefault: null == frontDefault
          ? _value.frontDefault
          : frontDefault // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SpriteCopyWith<$Res> implements $SpriteCopyWith<$Res> {
  factory _$$_SpriteCopyWith(_$_Sprite value, $Res Function(_$_Sprite) then) =
      __$$_SpriteCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'front_default') String frontDefault});
}

/// @nodoc
class __$$_SpriteCopyWithImpl<$Res>
    extends _$SpriteCopyWithImpl<$Res, _$_Sprite>
    implements _$$_SpriteCopyWith<$Res> {
  __$$_SpriteCopyWithImpl(_$_Sprite _value, $Res Function(_$_Sprite) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frontDefault = null,
  }) {
    return _then(_$_Sprite(
      frontDefault: null == frontDefault
          ? _value.frontDefault
          : frontDefault // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Sprite implements _Sprite {
  const _$_Sprite({@JsonKey(name: 'front_default') required this.frontDefault});

  factory _$_Sprite.fromJson(Map<String, dynamic> json) =>
      _$$_SpriteFromJson(json);

  @override
  @JsonKey(name: 'front_default')
  final String frontDefault;

  @override
  String toString() {
    return 'Sprite(frontDefault: $frontDefault)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Sprite &&
            (identical(other.frontDefault, frontDefault) ||
                other.frontDefault == frontDefault));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, frontDefault);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SpriteCopyWith<_$_Sprite> get copyWith =>
      __$$_SpriteCopyWithImpl<_$_Sprite>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SpriteToJson(
      this,
    );
  }
}

abstract class _Sprite implements Sprite {
  const factory _Sprite(
      {@JsonKey(name: 'front_default')
          required final String frontDefault}) = _$_Sprite;

  factory _Sprite.fromJson(Map<String, dynamic> json) = _$_Sprite.fromJson;

  @override
  @JsonKey(name: 'front_default')
  String get frontDefault;
  @override
  @JsonKey(ignore: true)
  _$$_SpriteCopyWith<_$_Sprite> get copyWith =>
      throw _privateConstructorUsedError;
}
