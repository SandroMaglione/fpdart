import 'package:fpdart/fpdart.dart';
import 'package:glados/glados.dart';

extension AnyOption on Any {
  /// `glados` [Generator] for [Option] of any type [T], given
  /// a generator for type [T].
  ///
  /// The occurrence of [Some] is 90%, while [None] is 10%.
  Generator<Option<T>> optionGenerator<T>(Generator<T> source) =>
      (random, size) => (random.nextDouble() > 0.1
          ? source.map(some)
          : source.map((value) => none<T>()))(random, size);

  /// [Generator] for `Option<int>`
  Generator<Option<int>> get optionInt => optionGenerator(any.int);

  /// [Generator] for `Option<double>`
  Generator<Option<double>> get optionDouble => optionGenerator(any.double);

  /// [Generator] for `Option<String>`
  Generator<Option<String>> get optionString =>
      optionGenerator(any.letterOrDigits);
}

extension AnyEither on Any {
  /// `glados` [Generator] for [Either] of any type [L] and [R], given
  /// a generator for type [L] and [R].
  ///
  /// The occurrence of [Left] and [Right] is 50/50.
  Generator<Either<L, R>> eitherGenerator<L, R>(
    Generator<L> leftSource,
    Generator<R> rightSource,
  ) =>
      (random, size) => (random.nextBool()
          ? leftSource.map<Either<L, R>>(left)
          : rightSource.map<Either<L, R>>(right))(random, size);

  /// [Generator] for `Either<String, int>`
  Generator<Either<String, int>> get eitherStringInt =>
      eitherGenerator(any.letterOrDigits, any.int);
}
