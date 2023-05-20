extension FpdartOnPredicate on bool Function() {
  /// Negate the return value of this function.
  /// ```dart
  /// bool alwaysTrue() => true;
  /// final alwaysFalse = alwaysTrue.negate;
  /// ```
  bool get negate => !this();
}

extension FpdartOnPredicate1<P> on bool Function(P) {
  /// Negate the return value of this function.
  /// ```dart
  /// bool isEven(int n) => n % 2 == 0;
  /// final isOdd = isEven.negate;
  /// ```
  bool Function(P) get negate => (p) => !this(p);
}
