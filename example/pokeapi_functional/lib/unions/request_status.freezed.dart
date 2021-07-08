// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'request_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$RequestStatusTearOff {
  const _$RequestStatusTearOff();

  InitialRequestStatus initial() {
    return const InitialRequestStatus();
  }

  LoadingRequestStatus loading() {
    return const LoadingRequestStatus();
  }

  ErrorRequestStatus error(String string) {
    return ErrorRequestStatus(
      string,
    );
  }

  SuccessRequestStatus success(Pokemon pokemon) {
    return SuccessRequestStatus(
      pokemon,
    );
  }
}

/// @nodoc
const $RequestStatus = _$RequestStatusTearOff();

/// @nodoc
mixin _$RequestStatus {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String string) error,
    required TResult Function(Pokemon pokemon) success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String string)? error,
    TResult Function(Pokemon pokemon)? success,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InitialRequestStatus value) initial,
    required TResult Function(LoadingRequestStatus value) loading,
    required TResult Function(ErrorRequestStatus value) error,
    required TResult Function(SuccessRequestStatus value) success,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InitialRequestStatus value)? initial,
    TResult Function(LoadingRequestStatus value)? loading,
    TResult Function(ErrorRequestStatus value)? error,
    TResult Function(SuccessRequestStatus value)? success,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequestStatusCopyWith<$Res> {
  factory $RequestStatusCopyWith(
          RequestStatus value, $Res Function(RequestStatus) then) =
      _$RequestStatusCopyWithImpl<$Res>;
}

/// @nodoc
class _$RequestStatusCopyWithImpl<$Res>
    implements $RequestStatusCopyWith<$Res> {
  _$RequestStatusCopyWithImpl(this._value, this._then);

  final RequestStatus _value;
  // ignore: unused_field
  final $Res Function(RequestStatus) _then;
}

/// @nodoc
abstract class $InitialRequestStatusCopyWith<$Res> {
  factory $InitialRequestStatusCopyWith(InitialRequestStatus value,
          $Res Function(InitialRequestStatus) then) =
      _$InitialRequestStatusCopyWithImpl<$Res>;
}

/// @nodoc
class _$InitialRequestStatusCopyWithImpl<$Res>
    extends _$RequestStatusCopyWithImpl<$Res>
    implements $InitialRequestStatusCopyWith<$Res> {
  _$InitialRequestStatusCopyWithImpl(
      InitialRequestStatus _value, $Res Function(InitialRequestStatus) _then)
      : super(_value, (v) => _then(v as InitialRequestStatus));

  @override
  InitialRequestStatus get _value => super._value as InitialRequestStatus;
}

/// @nodoc

class _$InitialRequestStatus
    with DiagnosticableTreeMixin
    implements InitialRequestStatus {
  const _$InitialRequestStatus();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RequestStatus.initial()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'RequestStatus.initial'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is InitialRequestStatus);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String string) error,
    required TResult Function(Pokemon pokemon) success,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String string)? error,
    TResult Function(Pokemon pokemon)? success,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InitialRequestStatus value) initial,
    required TResult Function(LoadingRequestStatus value) loading,
    required TResult Function(ErrorRequestStatus value) error,
    required TResult Function(SuccessRequestStatus value) success,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InitialRequestStatus value)? initial,
    TResult Function(LoadingRequestStatus value)? loading,
    TResult Function(ErrorRequestStatus value)? error,
    TResult Function(SuccessRequestStatus value)? success,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class InitialRequestStatus implements RequestStatus {
  const factory InitialRequestStatus() = _$InitialRequestStatus;
}

/// @nodoc
abstract class $LoadingRequestStatusCopyWith<$Res> {
  factory $LoadingRequestStatusCopyWith(LoadingRequestStatus value,
          $Res Function(LoadingRequestStatus) then) =
      _$LoadingRequestStatusCopyWithImpl<$Res>;
}

/// @nodoc
class _$LoadingRequestStatusCopyWithImpl<$Res>
    extends _$RequestStatusCopyWithImpl<$Res>
    implements $LoadingRequestStatusCopyWith<$Res> {
  _$LoadingRequestStatusCopyWithImpl(
      LoadingRequestStatus _value, $Res Function(LoadingRequestStatus) _then)
      : super(_value, (v) => _then(v as LoadingRequestStatus));

  @override
  LoadingRequestStatus get _value => super._value as LoadingRequestStatus;
}

/// @nodoc

class _$LoadingRequestStatus
    with DiagnosticableTreeMixin
    implements LoadingRequestStatus {
  const _$LoadingRequestStatus();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RequestStatus.loading()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty('type', 'RequestStatus.loading'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) || (other is LoadingRequestStatus);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String string) error,
    required TResult Function(Pokemon pokemon) success,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String string)? error,
    TResult Function(Pokemon pokemon)? success,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InitialRequestStatus value) initial,
    required TResult Function(LoadingRequestStatus value) loading,
    required TResult Function(ErrorRequestStatus value) error,
    required TResult Function(SuccessRequestStatus value) success,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InitialRequestStatus value)? initial,
    TResult Function(LoadingRequestStatus value)? loading,
    TResult Function(ErrorRequestStatus value)? error,
    TResult Function(SuccessRequestStatus value)? success,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class LoadingRequestStatus implements RequestStatus {
  const factory LoadingRequestStatus() = _$LoadingRequestStatus;
}

/// @nodoc
abstract class $ErrorRequestStatusCopyWith<$Res> {
  factory $ErrorRequestStatusCopyWith(
          ErrorRequestStatus value, $Res Function(ErrorRequestStatus) then) =
      _$ErrorRequestStatusCopyWithImpl<$Res>;
  $Res call({String string});
}

/// @nodoc
class _$ErrorRequestStatusCopyWithImpl<$Res>
    extends _$RequestStatusCopyWithImpl<$Res>
    implements $ErrorRequestStatusCopyWith<$Res> {
  _$ErrorRequestStatusCopyWithImpl(
      ErrorRequestStatus _value, $Res Function(ErrorRequestStatus) _then)
      : super(_value, (v) => _then(v as ErrorRequestStatus));

  @override
  ErrorRequestStatus get _value => super._value as ErrorRequestStatus;

  @override
  $Res call({
    Object? string = freezed,
  }) {
    return _then(ErrorRequestStatus(
      string == freezed
          ? _value.string
          : string // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorRequestStatus
    with DiagnosticableTreeMixin
    implements ErrorRequestStatus {
  const _$ErrorRequestStatus(this.string);

  @override
  final String string;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RequestStatus.error(string: $string)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'RequestStatus.error'))
      ..add(DiagnosticsProperty('string', string));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is ErrorRequestStatus &&
            (identical(other.string, string) ||
                const DeepCollectionEquality().equals(other.string, string)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(string);

  @JsonKey(ignore: true)
  @override
  $ErrorRequestStatusCopyWith<ErrorRequestStatus> get copyWith =>
      _$ErrorRequestStatusCopyWithImpl<ErrorRequestStatus>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String string) error,
    required TResult Function(Pokemon pokemon) success,
  }) {
    return error(string);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String string)? error,
    TResult Function(Pokemon pokemon)? success,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(string);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InitialRequestStatus value) initial,
    required TResult Function(LoadingRequestStatus value) loading,
    required TResult Function(ErrorRequestStatus value) error,
    required TResult Function(SuccessRequestStatus value) success,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InitialRequestStatus value)? initial,
    TResult Function(LoadingRequestStatus value)? loading,
    TResult Function(ErrorRequestStatus value)? error,
    TResult Function(SuccessRequestStatus value)? success,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class ErrorRequestStatus implements RequestStatus {
  const factory ErrorRequestStatus(String string) = _$ErrorRequestStatus;

  String get string => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ErrorRequestStatusCopyWith<ErrorRequestStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SuccessRequestStatusCopyWith<$Res> {
  factory $SuccessRequestStatusCopyWith(SuccessRequestStatus value,
          $Res Function(SuccessRequestStatus) then) =
      _$SuccessRequestStatusCopyWithImpl<$Res>;
  $Res call({Pokemon pokemon});
}

/// @nodoc
class _$SuccessRequestStatusCopyWithImpl<$Res>
    extends _$RequestStatusCopyWithImpl<$Res>
    implements $SuccessRequestStatusCopyWith<$Res> {
  _$SuccessRequestStatusCopyWithImpl(
      SuccessRequestStatus _value, $Res Function(SuccessRequestStatus) _then)
      : super(_value, (v) => _then(v as SuccessRequestStatus));

  @override
  SuccessRequestStatus get _value => super._value as SuccessRequestStatus;

  @override
  $Res call({
    Object? pokemon = freezed,
  }) {
    return _then(SuccessRequestStatus(
      pokemon == freezed
          ? _value.pokemon
          : pokemon // ignore: cast_nullable_to_non_nullable
              as Pokemon,
    ));
  }
}

/// @nodoc

class _$SuccessRequestStatus
    with DiagnosticableTreeMixin
    implements SuccessRequestStatus {
  const _$SuccessRequestStatus(this.pokemon);

  @override
  final Pokemon pokemon;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RequestStatus.success(pokemon: $pokemon)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'RequestStatus.success'))
      ..add(DiagnosticsProperty('pokemon', pokemon));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is SuccessRequestStatus &&
            (identical(other.pokemon, pokemon) ||
                const DeepCollectionEquality().equals(other.pokemon, pokemon)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^ const DeepCollectionEquality().hash(pokemon);

  @JsonKey(ignore: true)
  @override
  $SuccessRequestStatusCopyWith<SuccessRequestStatus> get copyWith =>
      _$SuccessRequestStatusCopyWithImpl<SuccessRequestStatus>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(String string) error,
    required TResult Function(Pokemon pokemon) success,
  }) {
    return success(pokemon);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(String string)? error,
    TResult Function(Pokemon pokemon)? success,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(pokemon);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(InitialRequestStatus value) initial,
    required TResult Function(LoadingRequestStatus value) loading,
    required TResult Function(ErrorRequestStatus value) error,
    required TResult Function(SuccessRequestStatus value) success,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(InitialRequestStatus value)? initial,
    TResult Function(LoadingRequestStatus value)? loading,
    TResult Function(ErrorRequestStatus value)? error,
    TResult Function(SuccessRequestStatus value)? success,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class SuccessRequestStatus implements RequestStatus {
  const factory SuccessRequestStatus(Pokemon pokemon) = _$SuccessRequestStatus;

  Pokemon get pokemon => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SuccessRequestStatusCopyWith<SuccessRequestStatus> get copyWith =>
      throw _privateConstructorUsedError;
}
