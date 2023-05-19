import '../either.dart';
import '../io_either.dart';
import '../io_option.dart';
import '../option.dart';
import '../task.dart';
import '../task_either.dart';
import '../task_option.dart';

/// `fpdart` extension to work on nullable values `T?`
extension FpdartOnNullable<T> on T? {
  /// Convert a nullable type `T?` to [Option]:
  /// {@template fpdart_on_nullable_to_option}
  /// - [Some] if the value is **not** `null`
  /// - [None] if the value is `null`
  /// {@endtemplate}
  Option<T> toOption() => Option.fromNullable(this);

  /// Convert a nullable type `T?` to [Either]:
  /// {@template fpdart_on_nullable_to_either}
  /// - [Right] if the value is **not** `null`
  /// - [Left] containing the result of `onNull` if the value is `null`
  /// {@endtemplate}
  Either<L, T> toEither<L>(L Function() onNull) =>
      Either.fromNullable(this, onNull);

  /// Convert a nullable type `T?` to [IOOption]:
  /// {@macro fpdart_on_nullable_to_option}
  IOOption<T> toIOOption() => IOOption.fromNullable(this);

  /// Convert a nullable type `T?` to [TaskOption]:
  /// {@macro fpdart_on_nullable_to_option}
  TaskOption<T> toTaskOption() => TaskOption.fromNullable(this);

  /// Convert a nullable type `T?` to [IOEither].
  IOEither<L, T> toIOEither<L>(L Function() onNull) =>
      IOEither.fromNullable(this, onNull);

  /// Convert a nullable type `T?` to [TaskEither] using a **sync function**:
  /// {@macro fpdart_on_nullable_to_either}
  ///
  /// If you want to run an **async** function `onNull`, use `toTaskEitherAsync`.
  TaskEither<L, T> toTaskEither<L>(L Function() onNull) =>
      TaskEither.fromNullable(this, onNull);

  /// Convert a nullable type `T?` to [TaskEither] using an **async function**:
  /// {@macro fpdart_on_nullable_to_either}
  ///
  /// If you want to run an **sync** function `onNull`, use `toTaskEither`.
  TaskEither<L, T> toTaskEitherAsync<L>(Task<L> onNull) =>
      TaskEither.fromNullableAsync(this, onNull);
}
