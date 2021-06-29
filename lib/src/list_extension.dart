import 'option.dart';
import 'tuple.dart';
import 'typeclass/order.dart';

/// Functional programming functions on a mutable dart [Iterable] using `fpdart`.
extension FpdartOnMutableIterable<T> on Iterable<T> {
  /// Join elements at the same index from two different [List] into
  /// one [List] containing the result of calling `f` on the elements pair.
  Iterable<C> Function(Iterable<B> lb) zipWith<B, C>(
          C Function(B b) Function(T t) f) =>
      (Iterable<B> lb) => isEmpty || lb.isEmpty
          ? []
          : [
              f(elementAt(0))(lb.elementAt(0)),
              ...skip(1).zipWith(f)(lb.skip(1)),
            ];

  /// `zip` is used to join elements at the same index from two different [List]
  /// into one [List] of [Tuple2].
  /// ```dart
  /// final list1 = ['a', 'b'];
  /// final list2 = [1, 2];
  /// final zipList = list1.zip(list2);
  /// print(zipList); // -> [Tuple2(a, 1), Tuple2(b, 2)]
  /// ```
  Iterable<Tuple2<T, B>> zip<B>(Iterable<B> lb) =>
      zipWith<B, Tuple2<T, B>>((a) => (b) => Tuple2(a, b))(lb);

  /// Get the first element of the list.
  /// If the list is empty, return [None].
  ///
  /// Same as `firstOption`.
  Option<T> get head => isEmpty ? none() : some(first);

  /// Get the first element of the list.
  /// If the list is empty, return [None].
  ///
  /// Same as `head`.
  Option<T> get firstOption => head;

  /// Return all the elements of a list except the first one.
  /// If the list is empty, return [None].
  Option<Iterable<T>> get tail => isEmpty ? none() : some(skip(1));

  /// Return all the elements of a list except the last one.
  /// If the list is empty, return [None].
  Option<Iterable<T>> get init => isEmpty ? none() : some(take(length - 1));

  /// Get the last element of the list.
  /// If the list is empty, return [None].
  Option<T> get lastOption => isEmpty ? none() : some(last);

  /// Returns the list of those elements that satisfy `predicate`.
  Iterable<T> filter(bool Function(T t) predicate) =>
      foldLeft([], (a, e) => predicate(e) ? [...a, e] : a);

  /// Append `l` to this [Iterable].
  Iterable<T> plus(Iterable<T> l) => [...this, ...l];

  /// Insert element `t` at the end of the [Iterable].
  Iterable<T> append(T t) => [...this, t];

  /// Insert element `t` at the beginning of the [Iterable].
  Iterable<T> prepend(T t) => [t, ...this];

  /// Extract all elements **starting from the first** as long as `predicate` returns `true`.
  Iterable<T> takeWhileLeft(bool Function(T t) predicate) =>
      foldLeft<Tuple2<bool, Iterable<T>>>(
        const Tuple2(true, []),
        (a, e) {
          if (!a.first) {
            return a;
          }

          final check = predicate(e);
          return check
              ? Tuple2(check, [...a.second, e])
              : Tuple2(check, a.second);
        },
      ).second;

  /// Remove all elements **starting from the first** as long as `predicate` returns `true`.
  Iterable<T> dropWhileLeft(bool Function(T t) predicate) =>
      foldLeft<Tuple2<bool, Iterable<T>>>(
        const Tuple2(true, []),
        (a, e) {
          if (!a.first) {
            return Tuple2(a.first, a.second.append(e));
          }

          final check = predicate(e);
          return check
              ? Tuple2(check, a.second)
              : Tuple2(check, a.second.append(e));
        },
      ).second;

  /// Extract all elements **starting from the last** as long as `predicate` returns `true`.
  Iterable<T> takeWhileRight(bool Function(T t) predicate) =>
      foldRight<Tuple2<bool, Iterable<T>>>(
        const Tuple2(true, []),
        (e, a) {
          if (!a.first) {
            return a;
          }

          final check = predicate(e);
          return check
              ? Tuple2(check, a.second.prepend(e))
              : Tuple2(check, a.second);
        },
      ).second;

  /// Remove all elements **starting from the last** as long as `predicate` returns `true`.
  Iterable<T> dropWhileRight(bool Function(T t) predicate) =>
      foldRight<Tuple2<bool, Iterable<T>>>(
        const Tuple2(true, []),
        (e, a) {
          if (!a.first) {
            return Tuple2(a.first, a.second.prepend(e));
          }

          final check = predicate(e);
          return check
              ? Tuple2(check, a.second)
              : Tuple2(check, a.second.prepend(e));
        },
      ).second;

  /// Return a [Tuple2] where first element is longest prefix (possibly empty) of this [Iterable]
  /// with elements that **satisfy** `predicate` and second element is the remainder of the [Iterable].
  Tuple2<Iterable<T>, Iterable<T>> span(bool Function(T t) predicate) =>
      foldLeft<Tuple2<bool, Tuple2<Iterable<T>, Iterable<T>>>>(
        const Tuple2(true, Tuple2([], [])),
        (a, e) {
          if (!a.first) {
            return Tuple2(
                a.first, a.second.mapSecond((second) => second.append(e)));
          }

          final check = predicate(e);
          return check
              ? Tuple2(check, a.second.mapFirst((first) => first.append(e)))
              : Tuple2(check, a.second.mapSecond((second) => second.append(e)));
        },
      ).second;

  /// Return a [Tuple2] where first element is longest prefix (possibly empty) of this [Iterable]
  /// with elements that **do not satisfy** `predicate` and second element is the remainder of the [Iterable].
  Tuple2<Iterable<T>, Iterable<T>> breakI(bool Function(T t) predicate) =>
      foldLeft<Tuple2<bool, Tuple2<Iterable<T>, Iterable<T>>>>(
        const Tuple2(false, Tuple2([], [])),
        (a, e) {
          if (a.first) {
            return Tuple2(
                a.first, a.second.mapSecond((second) => second.append(e)));
          }

          final check = predicate(e);
          return check
              ? Tuple2(check, a.second.mapSecond((second) => second.append(e)))
              : Tuple2(check, a.second.mapFirst((first) => first.append(e)));
        },
      ).second;

  /// Return a [Tuple2] where first element is an [Iterable] with the first `n` elements of this [Iterable],
  /// and the second element contains the rest of the [Iterable].
  Tuple2<Iterable<T>, Iterable<T>> splitAt(int n) => Tuple2(take(n), skip(n));

  /// Check if `element` is contained inside this [Iterable].
  ///
  /// Same as standard dart `contains`.
  bool elem(T element) => contains(element);

  /// Check if `element` is **not** contained inside this [Iterable].
  bool notElem(T element) => !elem(element);

  /// Insert `element` into the list at the first position where it is less than or equal to the next element
  /// based on `order`.
  ///
  /// Note: The element is added **before** an equal element already in the [Iterable].
  Iterable<T> insertBy(Order<T> order, T element) => isEmpty
      ? [element]
      : order.compare(element, first) > 0
          ? [first, ...drop(1).insertBy(order, element)]
          : [element, first, ...drop(1)];

  /// Sort this [Iterable] based on `order`.
  Iterable<T> sortBy(Order<T> order) =>
      foldRight([], (e, a) => a.insertBy(order, e));

  /// Return the intersection of two [Iterable] (all the elements that both [Iterable] have in common).
  Iterable<T> intersect(Iterable<T> l) =>
      foldLeft([], (a, e) => l.elem(e) ? [...a, e] : a);

  /// Remove the **first occurrence** of `element` from this [Iterable].
  Iterable<T> delete(T element) =>
      foldLeft<Tuple2<bool, Iterable<T>>>(const Tuple2(true, []), (a, e) {
        if (!a.first) {
          return a.mapSecond((second) => second.append(e));
        }

        return e == element
            ? a.mapFirst((first) => false)
            : a.mapSecond((second) => second.append(e));
      }).second;

  /// The largest element of this [Iterable] based on `order`.
  ///
  /// If the list is empty, return [None].
  Option<T> maximumBy(Order<T> order) => foldLeft(none(),
      (a, c) => some(a.match((t) => order.compare(c, t) > 0 ? c : t, () => c)));

  /// The least element of this [Iterable] based on `order`.
  ///
  /// If the list is empty, return [None].
  Option<T> minimumBy(Order<T> order) => foldLeft(none(),
      (a, c) => some(a.match((t) => order.compare(c, t) < 0 ? c : t, () => c)));

  /// Checks whether every element of this [Iterable] satisfies [test].
  ///
  /// Same as standard dart `every`.
  bool all(bool Function(T t) predicate) => every(predicate);

  /// Return the suffix of this [Iterable] after the first `n` elements.
  ///
  /// Same as standard dart `skip`.
  Iterable<T> drop(int n) => skip(n);

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
  B foldRight<B>(B initialValue, B Function(T element, B accumulator) f) =>
      toList().reversed.fold(initialValue, (a, e) => f(e, a));

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the last to the first** using their index.
  B foldRightWithIndex<B>(
          B initialValue, B Function(T element, B accumulator, int index) f) =>
      foldRight<Tuple2<B, int>>(
        Tuple2(initialValue, 0),
        (e, p) => Tuple2(f(e, p.first, p.second), p.second + 1),
      ).first;

  /// Map [Iterable] from type `T` to type `B` using the index.
  Iterable<B> mapWithIndex<B>(B Function(T t, int index) f) =>
      foldLeftWithIndex([], (a, e, i) => [...a, f(e, i)]);

  /// Apply all the functions inside `fl` to the [Iterable].
  Iterable<B> ap<B>(Iterable<B Function(T t)> fl) =>
      fl.concatMap((f) => map(f));

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
