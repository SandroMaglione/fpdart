import 'either.dart';
import 'option.dart';

/// `fpdart` extension to work on nullable values `T?`
extension FpdartOnNullable<T> on T? {
  /// Convert a nullable type `T?` to [Option]:
  /// - [Some] if the value is **not** `null`
  /// - [None] if the value is `null`
  Option<T> toOption() => Option.fromNullable(this);

  /// Convert a nullable type `T?` to [Either]:
  /// - [Right] if the value is **not** `null`
  /// - [Left] containing the result of `onNull` if the value is `null`
  Either<L, T> toEither<L>(L Function(T?) onNull) =>
      Either.fromNullable(this, onNull);
}
