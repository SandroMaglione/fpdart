extension FpdartOnPredicate on bool Function() {
  /// Negate the return value of this function.
  /// ```dart
  /// bool alwaysTrue() => true;
  /// final alwaysFalse = alwaysTrue.negate;
  /// ```
  bool get negate => !this();

  /// Compose using `&&` this function with `predicate`.
  bool Function() and(bool Function() predicate) => () => this() && predicate();

  /// Compose using `||` this function with `predicate`.
  bool Function() or(bool Function() predicate) => () => this() || predicate();

  /// Compose **xor** this function with `predicate`.
  bool Function() xor(bool Function() predicate) => () {
        final thisPredicate = this();
        final otherPredicate = predicate();
        return thisPredicate ? !otherPredicate : otherPredicate;
      };
}

extension FpdartOnPredicate1<P> on bool Function(P) {
  /// Negate the return value of this function.
  /// ```dart
  /// bool isEven(int n) => n % 2 == 0;
  /// final isOdd = isEven.negate;
  /// ```
  bool Function(P) get negate => (p) => !this(p);

  /// Compose using `&&` this function with `predicate`.
  bool Function(P) and(bool Function(P p) predicate) =>
      (p) => this(p) && predicate(p);

  /// Compose using `||` this function with `predicate`.
  bool Function(P) or(bool Function(P) predicate) =>
      (p) => this(p) || predicate(p);

  /// Compose **xor** this function with `predicate`.
  bool Function(P) xor(bool Function(P) predicate) =>
      (p) => this(p) ^ predicate(p);

  /// Apply `map` to the value of the parameter `P` and return a new `bool Function(A)`.
  ///
  /// Similar to `map` for functions that return `bool`.
  /// ```dart
  /// bool even(int n) => n % 2 == 0;
  /// final evenLength = even.contramap<String>((a) => a.length);
  /// ```
  bool Function(A) contramap<A>(P Function(A a) map) => (a) => this(map(a));
}
