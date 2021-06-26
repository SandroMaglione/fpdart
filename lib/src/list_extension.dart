import 'tuple.dart';

/// Functional programming functions on a mutable dart [Iterable] using `fpdart`.
extension FpdartOnMutableIterable<T> on Iterable<T> {
  /// Join elements at the same index from two different [List] into
  /// one [List] containing the result of calling `f` on the elements pair.
  List<C> zipWith<B, C>(C Function(B b) Function(T t) f, Iterable<B> lb) =>
      isEmpty || lb.isEmpty
          ? []
          : [
              f(elementAt(0))(lb.elementAt(0)),
              ...skip(1).zipWith(f, lb.skip(1)),
            ];

  /// `zip` is used to join elements at the same index from two different [List]
  /// into one [List] of [Tuple2].
  /// ```dart
  /// final list1 = ['a', 'b'];
  /// final list2 = [1, 2];
  /// final zipList = list1.zip(list2);
  /// print(zipList); // -> [Tuple2(a, 1), Tuple2(b, 2)]
  /// ```
  List<Tuple2<T, B>> zip<B>(List<B> lb) =>
      zipWith<B, Tuple2<T, B>>((a) => (b) => Tuple2(a, b), lb);

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the first to the last**.
  ///
  /// Same as standard `fold`.
  B foldLeft<B>(B initialValue, B Function(B b, T t) f) =>
      fold(initialValue, f);

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the first to the last** using their index.
  B foldLeftWithIndex<B>(
          B initialValue, B Function(B accumulator, T element, int index) f) =>
      fold<Tuple2<B, int>>(
        Tuple2(initialValue, 0),
        (p, e) => Tuple2(f(p.first, e, p.second), p.second + 1),
      ).first;

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the last to the first**.
  B foldRight<B>(B initialValue, B Function(B accumulator, T element) f) =>
      toList().reversed.fold(initialValue, f);

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the last to the first** using their index.
  B foldRightWithIndex<B>(
          B initialValue, B Function(B accumulator, T element, int index) f) =>
      foldRight<Tuple2<B, int>>(
        Tuple2(initialValue, 0),
        (p, e) => Tuple2(f(p.first, e, p.second), p.second + 1),
      ).first;

  /// Map [Iterable] from type `T` to type `B` using the index.
  Iterable<B> mapWithIndex<B>(B Function(T t, int index) f) =>
      foldLeftWithIndex([], (a, e, i) => [...a, f(e, i)]);

  /// Apply `f` to each element of the [Iterable] and flat the result using `concat`.
  ///
  /// Same as `bind` and `flatMap`.
  Iterable<B> concatMap<B>(Iterable<B> Function(T t) f) => map(f).concat;

  /// Apply `f` to each element of the [Iterable] using the index
  /// and flat the result using `concat`.
  ///
  /// Same as `bindWithIndex` and `flatMapWithIndex`.
  Iterable<B> concatMapWithIndex<B>(Iterable<B> Function(T t, int index) f) =>
      mapWithIndex(f).concat;

  /// Apply all the functions inside `fl` to the [Iterable].
  Iterable<B> ap<B>(Iterable<B Function(T t)> fl) =>
      fl.concatMap((f) => map(f));

  /// For each element of the [Iterable] apply function `f` and flat the result.
  ///
  /// Same as `bind` and `concatMap`.
  Iterable<B> flatMap<B>(Iterable<B> Function(T t) f) => concatMap(f);

  /// For each element of the [Iterable] apply function `f` with the index and flat the result.
  ///
  /// Same as `bindWithIndex` and `concatMapWithIndex`.
  Iterable<B> flatMapWithIndex<B>(Iterable<B> Function(T t, int index) f) =>
      concatMapWithIndex(f);

  /// For each element of the [Iterable] apply function `f` and flat the result.
  ///
  /// Same as `flatMap` and `concatMap`.
  Iterable<B> bind<B>(Iterable<B> Function(T t) f) => flatMap(f);

  /// For each element of the [Iterable] apply function `f` with the index and flat the result.
  ///
  /// Same as `flatMapWithIndex` and `concatMapWithIndex`.
  Iterable<B> bindWithIndex<B>(Iterable<B> Function(T t, int index) f) =>
      concatMapWithIndex(f);
}

/// Functional programming functions on a mutable dart `Iterable<Iterable<T>>` using `fpdart`.
extension FpdartOnMutableIterableOfIterable<T> on Iterable<Iterable<T>> {
  /// From a container of `Iterable<Iterable<T>>` return a `Iterable<T>` of their concatenation.
  Iterable<T> get concat => foldRight([], (a, e) => [...a, ...e]);
}
