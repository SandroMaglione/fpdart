import 'package:fpdart/fpdart.dart';

/// Return a `Tuple2(a, b)`.
Tuple2<A, B> tuple2<A, B>(A a, B b) => Tuple2(a, b);

/// Tag the [HKT2] interface for the actual [Tuple2].
abstract class _Tuple2HKT {}

/// `Tuple2<T1, T2>` is a type that contains a value of type `T1` and a value of type `T2`.
///
/// Used to avoid creating a custom class that contains two different types
/// or to return two values from one function.
class Tuple2<T1, T2> extends HKT2<_Tuple2HKT, T1, T2>
    with
        Functor2<_Tuple2HKT, T1, T2>,
        Extend2<_Tuple2HKT, T1, T2>,
        Foldable2<_Tuple2HKT, T1, T2> {
  final T1 _value1;
  final T2 _value2;

  /// Build a [Tuple2] given its first and second values.
  const Tuple2(this._value1, this._value2);

  /// Get first value inside the [Tuple].
  T1 get first => _value1;

  /// Get second value inside the [Tuple].
  T2 get second => _value2;

  /// Return result of calling `f` given `value1` and `value2` from this [Tuple].
  A apply<A>(A Function(T1 first, T2 second) f) => f(_value1, _value2);

  /// Change type of first value of the [Tuple] from `T1` to `TN` using `f`.
  Tuple2<TN, T2> mapFirst<TN>(TN Function(T1 first) f) =>
      Tuple2(f(_value1), _value2);

  /// Change type of second value of the [Tuple] from `T2` to `TN` using `f`.
  Tuple2<T1, TN> mapSecond<TN>(TN Function(T2 second) f) =>
      Tuple2(_value1, f(_value2));

  /// Change type of second value of the [Tuple] from `T2` to `C` using `f`.
  ///
  /// Same as `mapSecond`.
  @override
  Tuple2<T1, C> map<C>(C Function(T2 a) f) => mapSecond(f);

  /// Convert the second value of the [Tuple2] from `T2` to `Z` using `f`.
  @override
  Tuple2<T1, Z> extend<Z>(Z Function(Tuple2<T1, T2> t) f) =>
      Tuple2(_value1, f(this));

  /// Wrap this [Tuple2] inside another [Tuple2].
  @override
  Tuple2<T1, Tuple2<T1, T2>> duplicate() => extend(identity);

  /// Convert the first value of the [Tuple2] from `T1` to `Z` using `f`.
  Tuple2<Z, T2> extendFirst<Z>(Z Function(Tuple2<T1, T2> t) f) =>
      Tuple2(f(this), _value2);

  /// Return value of type `C` by calling `f` with `b` and the second value of the [Tuple2].
  ///
  /// Same as `foldLeft`.
  @override
  C foldRight<C>(C b, C Function(C acc, T2 a) f) => f(b, _value2);

  /// Return value of type `C` by calling `f` with `b` and the first value of the [Tuple2].
  ///
  /// Same as `foldLeftFirst`.
  C foldRightFirst<C>(C b, C Function(C acc, T1 a) f) => f(b, _value1);

  /// Return value of type `C` by calling `f` with `b` and the second value of the [Tuple2].
  ///
  /// Same as `foldRight`.
  @override
  C foldLeft<C>(C b, C Function(C b, T2 a) f) =>
      foldMap<Endo<C>>(dualEndoMonoid(), (a) => (C b) => f(b, a))(b);

  /// Return value of type `C` by calling `f` with `b` and the first value of the [Tuple2].
  ///
  /// Same as `foldRightFirst`.
  C foldLeftFirst<C>(C b, C Function(C b, T1 a) f) =>
      foldMapFirst<Endo<C>>(dualEndoMonoid(), (a) => (C b) => f(b, a))(b);

  /// Return value of type `C` by applying `f` on `monoid`.
  @override
  C foldMap<C>(Monoid<C> monoid, C Function(T2 a) f) =>
      foldRight(monoid.empty, (c, b) => monoid.combine(c, f(b)));

  /// Return value of type `C` by applying `f` on `monoid`.
  C foldMapFirst<C>(Monoid<C> monoid, C Function(T1 a) f) =>
      foldRightFirst(monoid.empty, (c, t) => monoid.combine(f(t), c));

  /// Return value of type `C` by calling `f` with `b` and the second value of the [Tuple2].
  @override
  C foldRightWithIndex<C>(C c, C Function(int i, C acc, T2 b) f) =>
      foldRight<Tuple2<C, int>>(
        Tuple2(c, length() - 1),
        (t, a) => Tuple2(f(t.second, t.first, a), t.second - 1),
      ).first;

  /// Return value of type `C` by calling `f` with `b` and the first value of the [Tuple2].
  C foldRightFirstWithIndex<C>(C c, C Function(int i, C c, T1 b) f) =>
      foldRightFirst<Tuple2<C, int>>(
        Tuple2(c, length() - 1),
        (t, a) => Tuple2(f(t.second, t.first, a), t.second - 1),
      ).first;

  /// Return value of type `C` by calling `f` with `b` and the second value of the [Tuple2].
  @override
  C foldLeftWithIndex<C>(C c, C Function(int i, C acc, T2 b) f) =>
      foldLeft<Tuple2<C, int>>(
        Tuple2(c, 0),
        (t, a) => Tuple2(f(t.second, t.first, a), t.second + 1),
      ).first;

  /// Return value of type `C` by calling `f` with `b` and the first value of the [Tuple2].
  C foldLeftFirstWithIndex<C>(C c, C Function(int i, C c, T1 b) f) =>
      foldLeftFirst<Tuple2<C, int>>(
        Tuple2(c, 0),
        (t, a) => Tuple2(f(t.second, t.first, a), t.second + 1),
      ).first;

  /// Returns `1`.
  @override
  int length() => foldLeft(0, (b, _) => b + 1);

  /// Return the result of calling `predicate` on the second value of the [Tuple2].
  @override
  bool any(bool Function(T2 a) predicate) => foldMap(boolOrMonoid(), predicate);

  /// Return the result of calling `predicate` on the second value of the [Tuple2].
  @override
  bool all(bool Function(T2 a) predicate) =>
      foldMap(boolAndMonoid(), predicate);

  /// Combine the second value of [Tuple2] using `monoid`.
  /// ```dart
  /// const tuple = Tuple2('abc', 10);
  /// final ap = tuple.concatenate(Monoid.instance(0, (a1, a2) => a1 + a2));
  /// expect(ap, 10);
  /// ```
  @override
  T2 concatenate(Monoid<T2> monoid) => foldMap(monoid, identity);

  /// Swap types `T1` and `T2` of [Tuple2].
  Tuple2<T2, T1> swap() => Tuple2(_value2, _value1);

  /// Create a copy of this [Tuple] by changing `value1` and/or `value2`.
  Tuple2<T1, T2> copyWith({
    T1? value1,
    T2? value2,
  }) =>
      Tuple2(value1 ?? _value1, value2 ?? _value2);

  @override
  String toString() => 'Tuple2($_value1, $_value2)';

  @override
  bool operator ==(Object other) =>
      (other is Tuple2) && other._value1 == _value1 && other._value2 == _value2;

  @override
  int get hashCode => _value1.hashCode ^ _value2.hashCode;
}
