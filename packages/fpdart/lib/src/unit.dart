/// Used instead of `void` as a return statement for a function when no value is to be returned.
///
/// Read [this article](https://medium.com/flutter-community/the-curious-case-of-void-in-dart-f0535705e529)
/// to understand why it is better to not use `void` and use [Unit] instead.
///
/// There is only one value of type [Unit].
final class Unit {
  static const Unit _unit = Unit._instance();
  const Unit._instance();

  @override
  String toString() => '()';
}

/// Used instead of `void` as a return statement for a function when no value is to be returned.
///
/// Read [this article](https://medium.com/flutter-community/the-curious-case-of-void-in-dart-f0535705e529)
/// to understand why it is better to not use `void` and use [Unit] instead.
const unit = Unit._unit;
