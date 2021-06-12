import 'package:fpdart/fpdart.dart';

double sumToDouble(int a, int b) => (a + b).toDouble();

void main() {
  final a = Maybe.of(10);
  final b = Maybe.of(20);

  /// `map` takes one parameter [int] and returns `sumToDouble`.
  /// We therefore have a function inside a [Maybe] that we want to
  /// apply to another value!
  final Maybe<double Function(int)> map = a.map(
    (a) => (int b) => sumToDouble(a, b),
  );

  /// Using `ap`, we get the final `Maybe<double>` that we want 🚀
  final result = b.ap(map);
}
