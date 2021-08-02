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
  ///
  /// You can also use the `&` operator.
  Predicate<T> and(Predicate<T> predicate) =>
      Predicate((t) => _predicate(t) && predicate(t));

  /// Compose this [Predicate] with the given `predicate` using **AND**.
  Predicate<T> operator &(Predicate<T> predicate) => and(predicate);

  /// Compose this [Predicate] with the given `predicate` using **OR**.
  ///
  /// You can also use the `|` operator.
  Predicate<T> or(Predicate<T> predicate) =>
      Predicate((t) => _predicate(t) || predicate(t));

  /// Compose this [Predicate] with the given `predicate` using **OR**.
  Predicate<T> operator |(Predicate<T> predicate) => or(predicate);

  /// Compose this [Predicate] with the given `predicate` using **XOR**.
  ///
  /// You can also use the `^` operator.
  Predicate<T> xor(Predicate<T> predicate) => Predicate((t) {
        final boolThis = _predicate(t);
        final boolOther = predicate(t);
        return boolThis ? !boolOther : boolOther;
      });

  /// Compose this [Predicate] with the given `predicate` using **XOR**.
  Predicate<T> operator ^(Predicate<T> predicate) => xor(predicate);

  /// Compose this [Predicate] with the given `predicate` using **NOT** (**!**).
  ///
  /// You can also use the `~` operator.
  Predicate<T> get not => Predicate((t) => !_predicate(t));

  /// Build a [Predicate] that returns **NOT** (**!**) of the given `predicate`.
  ///
  /// You can also use the `~` operator.
  factory Predicate.not(bool Function(T) predicate) =>
      Predicate((t) => !predicate(t));

  /// Build a [Predicate] that returns **NOT** (**!**) of the given `predicate`.
  Predicate<T> operator ~() => Predicate((t) => !_predicate(t));
}
