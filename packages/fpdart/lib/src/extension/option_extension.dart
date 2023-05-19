import '../function.dart';
import '../option.dart';
import '../typeclass/eq.dart';

extension FpdartOnOption<T> on Option<T> {
  /// Return the current [Option] if it is a [Some], otherwise return the result of `orElse`.
  ///
  /// Used to provide an **alt**ernative [Option] in case the current one is [None].
  /// ```dart
  /// [🍌].alt(() => [🍎]) -> [🍌]
  /// [_].alt(() => [🍎]) -> [🍎]
  /// ```
  Option<T> alt(Option<T> Function() orElse) =>
      this is Some<T> ? this : orElse();

  /// Return `true` when value of `a` is equal to the value inside the [Option].
  bool elem(T t, Eq<T> eq) => match(() => false, (value) => eq.eqv(value, t));

  /// If this [Option] is a [Some] then return the value inside the [Option].
  /// Otherwise return the result of `orElse`.
  /// ```dart
  /// [🍌].getOrElse(() => 🍎) -> 🍌
  /// [_].getOrElse(() => 🍎) -> 🍎
  ///
  ///  👆 same as 👇
  ///
  /// [🍌].match(() => 🍎, (🍌) => 🍌)
  /// ```
  T getOrElse(T Function() orElse) => match(orElse, identity);
}
