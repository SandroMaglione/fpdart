import 'package:fpdart/fpdart.dart';
import 'package:glados/glados.dart';

extension AnyOption on Any {
  /// `glados` [Generator] for [Option] of any type [T], given
  /// a generator for type [T].
  Generator<Option<T>> optionGenerator<T>(Generator<T> source) =>
      (random, size) => (random.nextDouble() > 0.1
          ? source.map(some)
          : source.map((value) => none<T>()))(random, size);

  Generator<Option<int>> get optionInt => optionGenerator(any.int);
  Generator<Option<double>> get optionDouble => optionGenerator(any.double);
  Generator<Option<String>> get optionString => optionGenerator(any.letters);
}
