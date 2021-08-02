/// Compose functions that given a generic value [T] return a `bool`.
class Predicate<T> {
  final bool Function(T t) _predicate;

  /// Build a [Predicate] given a function returning a `bool`.
  const Predicate(this._predicate);

  /// Run the predicate and extract its [bool] value given `t`.
  bool call(T t) => _predicate(t);

  /// Apply `fun` to the value of this `Predicate<T>` and return a new `Predicate<A>`.
  ///
  /// Similar to `map` for [Predicate]s.
  Predicate<A> contramap<A>(T Function(A a) fun) =>
      Predicate((a) => _predicate(fun(a)));

  /// Compose this [Predicate] with the given `predicate` using **AND**.
  Predicate<T> and(Predicate<T> predicate) =>
      Predicate((t) => _predicate(t) && predicate(t));

  /// Compose this [Predicate] with the given `predicate` using **AND**.
  Predicate<T> or(Predicate<T> predicate) =>
      Predicate((t) => _predicate(t) || predicate(t));

  /// Compose this [Predicate] with the given `predicate` using **XOR**.
  Predicate<T> xor(Predicate<T> predicate) => Predicate((t) {
        final boolThis = _predicate(t);
        final boolOther = predicate(t);
        return boolThis ? !boolOther : boolOther;
      });

  /// Build a [Predicate] that returns **NOT** (**!**) of the given `predicate`.
  factory Predicate.not(Predicate<T> predicate) =>
      Predicate((t) => !predicate(t));
}
