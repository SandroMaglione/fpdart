import 'dart:collection';

import '../function.dart';
import '../option.dart';
import '../typeclass/eq.dart';
import '../typeclass/order.dart';
import 'predicate_extension.dart';

/// {@template fpdart_iterable_extension_head}
/// Get the first element of the [Iterable].
/// If the [Iterable] is empty, return [None].
/// {@endtemplate}

/// Functional programming functions on a mutable dart [Iterable] using `fpdart`.
extension FpdartOnIterable<T> on Iterable<T> {
  /// {@macro fpdart_iterable_extension_head}
  ///
  /// Same as `firstOption`.
  Option<T> get head {
    var it = iterator;
    if (it.moveNext()) return some(it.current);
    return const None();
  }

  /// {@macro fpdart_iterable_extension_head}
  ///
  /// Same as `head`.
  Option<T> get firstOption => head;

  /// Get the last element of the [Iterable].
  /// If the [Iterable] is empty, return [None].
  ///
  /// **Note**: Because accessing the last element of an [Iterable] requires
  /// stepping through all the other elements, `lastOption` **can be slow**.
  Option<T> get lastOption => isEmpty ? const None() : some(last);

  /// Return all the elements of a [Iterable] except the first one.
  /// If the [Iterable] is empty, return [None].
  ///
  /// **Notice**: This operation checks whether the iterable is empty
  /// at the time when the [Option] is returned.
  /// The length of a non-empty iterable may change before the returned
  /// iterable is iterated. If this original iterable has become empty
  /// at that point, the returned iterable will also be empty, same
  /// as if this iterable has only one element.
  Option<Iterable<T>> get tail => isEmpty ? const None() : some(skip(1));

  /// Return all the elements of a [Iterable] except the last one.
  /// If the [Iterable] is empty, return [None].
  ///
  /// **Notice**: This operation checks whether the iterable is empty
  /// at the time when the [Option] is returned.
  /// The length of a non-empty iterable may change before the returned
  /// iterable is iterated. If this original iterable has become empty
  /// at that point, the returned iterable will also be empty, same
  /// as if this iterable has only one element.
  Option<Iterable<T>> get init {
    if (isEmpty) return const None();
    return some(this.dropRight(1));
  }

  /// Drops the last [count] element of this iterable.
  ///
  /// If this iterable contains fewer than [count] elements,
  /// the returned iterable is empty.
  ///
  /// The [count] must be non-negative.
  Iterable<T> dropRight([int count = 1]) {
    if (count < 0) throw RangeError.range(count, 0, null, "count");
    if (count == 0) return this;
    if (count == 1) return _dropLastHelper(this);
    return _dropRightHelper(this, count);
  }

  // Simpler version of [_dropRightHelper] for single element drop.
  static Iterable<E> _dropLastHelper<E>(Iterable<E> elements) sync* {
    var it = elements.iterator;
    if (!it.moveNext()) return;
    var last = it.current;
    while (it.moveNext()) {
      var element = last;
      last = it.current;
      yield element;
    }
  }

  static Iterable<E> _dropRightHelper<E>(
      Iterable<E> elements, int count) sync* {
    var it = elements.iterator;
    var queue = Queue<E>();
    for (var i = 0; i < count; i++) {
      if (!it.moveNext()) return;
      queue.add(it.current);
    }
    while (it.moveNext()) {
      var element = queue.removeFirst();
      queue.add(it.current);
      yield element;
    }
    queue.clear();
  }

  /// Returns the list of those elements that satisfy `test`.
  ///
  /// Equivalent to `Iterable.where`.
  Iterable<T> filter(bool Function(T t) test) => where(test);

  /// Returns the list of those elements that satisfy `test`.
  Iterable<T> filterWithIndex(bool Function(T t, int index) test) sync* {
    var index = 0;
    for (var value in this) {
      if (test(value, index)) {
        yield value;
      }
      index += 1;
    }
  }

  /// Extract all elements **starting from the first** as long as `test` returns `true`.
  ///
  /// Equivalent to `Iterable.takeWhile`.
  Iterable<T> takeWhileLeft(bool Function(T t) test) => takeWhile(test);

  /// Remove all elements **starting from the first** as long as `test` returns `true`.
  ///
  /// Equivalent to `Iterable.skipWhile`.
  Iterable<T> dropWhileLeft(bool Function(T t) test) => skipWhile(test);

  /// Return a record where first element is longest prefix (possibly empty) of this [Iterable]
  /// with elements that **satisfy** `test` and second element is the remainder of the [Iterable].
  (Iterable<T>, Iterable<T>) span(bool Function(T t) test) =>
      (takeWhile(test), skipWhile(test));

  /// Return a record where first element is longest prefix (possibly empty) of this [Iterable]
  /// with elements that **do not satisfy** `test` and second element is the remainder of the [Iterable].
  (Iterable<T>, Iterable<T>) breakI(bool Function(T t) test) =>
      (takeWhile(test.negate), skipWhile(test.negate));

  /// Return a record containing the values of this [Iterable]
  /// for which `test` is `false` in the first element,
  /// and the values for which it is `true` in the second element.
  (Iterable<T>, Iterable<T>) partition(bool Function(T t) test) =>
      (where(test.negate), where(test));

  /// Return a record where first element is an [Iterable] with the first `n` elements of this [Iterable],
  /// and the second element contains the rest of the [Iterable].
  (Iterable<T>, Iterable<T>) splitAt(int n) => (take(n), skip(n));

  /// Return the suffix of this [Iterable] after the first `n` elements.
  ///
  /// Equivalent to `Iterable.skip`.
  Iterable<T> drop(int n) => skip(n);

  /// Checks whether every element of this [Iterable] satisfies [test].
  ///
  /// Equivalent to `Iterable.every`.
  bool all(bool Function(T t) test) => every(test);

  /// Creates the lazy concatenation of this [Iterable] and `other`.
  ///
  /// Equivalent to `Iterable.followedBy`.
  Iterable<T> concat(Iterable<T> other) => followedBy(other);

  /// Insert `element` at the beginning of the [Iterable].
  Iterable<T> prepend(T element) sync* {
    yield element;
    yield* this;
  }

  /// Insert all the elements inside `other` at the beginning of the [Iterable].
  Iterable<T> prependAll(Iterable<T> other) => other.followedBy(this);

  /// Insert `element` at the end of the [Iterable].
  Iterable<T> append(T element) sync* {
    yield* this;
    yield element;
  }

  /// Check if `element` is contained inside this [Iterable].
  ///
  /// Equivalent to `Iterable.contains`.
  bool elem(T element) => contains(element);

  /// Check if `element` is **not** contained inside this [Iterable].
  bool notElem(T element) => !elem(element);

  /// Get first element equal to [element] in this [Iterable].
  ///
  /// Returns `None` if no such element.
  Option<T> lookupEq(Eq<T> eq, T element) {
    for (var e in this) {
      if (eq.eqv(e, element)) return some(e);
    }
    return const None();
  }

  /// Fold this [Iterable] into a single value by aggregating each element of the list
  /// **from the first to the last**.
  ///
  /// Equivalent to `Iterable.fold`.
  B foldLeft<B>(B initialValue, B Function(B b, T t) combine) =>
      fold(initialValue, combine);

  /// Same as `foldLeft` (`fold`) but provides also the `index` of each mapped
  /// element in the `combine` function.
  B foldLeftWithIndex<B>(
    B initialValue,
    B Function(B previousValue, T element, int index) combine,
  ) {
    var index = 0;
    var value = initialValue;
    for (var element in this) {
      value = combine(value, element, index);
      index += 1;
    }
    return value;
  }

  /// For each element of the [Iterable] apply function `toElements` and flat the result.
  ///
  /// Equivalent to `Iterable.expand`.
  Iterable<B> flatMap<B>(Iterable<B> Function(T t) toElements) =>
      expand(toElements);

  /// Join elements at the same index from two different [Iterable] into
  /// one [Iterable] containing the result of calling `combine` on
  /// each element pair.
  ///
  /// If one input [Iterable] is shorter,
  /// excess elements of the longer [Iterable] are discarded.
  Iterable<C> zipWith<B, C>(
    C Function(T t, B b) combine,
    Iterable<B> iterable,
  ) sync* {
    var it = iterator;
    var otherIt = iterable.iterator;
    while (it.moveNext() && otherIt.moveNext()) {
      yield combine(it.current, otherIt.current);
    }
  }

  /// `zip` is used to join elements at the same index from two different [Iterable]
  /// into one [Iterable] of a record.
  /// ```dart
  /// final list1 = ['a', 'b'];
  /// final list2 = [1, 2];
  /// final zipList = list1.zip(list2);
  /// print(zipList); // -> [(a, 1), (b, 2)]
  /// ```
  Iterable<(T, B)> zip<B>(Iterable<B> iterable) =>
      zipWith((a, b) => (a, b), iterable);

  /// Insert `element` into the list at the first position where it is less than or equal to the next element
  /// based on `order` ([Order]).
  ///
  /// Note: The element is added **before** an equal element already in the [Iterable].
  Iterable<T> insertBy(Order<T> order, T element) sync* {
    var it = iterator;
    while (it.moveNext()) {
      if (order.compare(it.current, element) < 0) {
        yield it.current;
        continue;
      }
      yield element;
      do {
        yield it.current;
      } while (it.moveNext());
      return;
    }
    yield element;
  }

  /// Insert `element` into the [Iterable] at the first position where
  /// it is less than or equal to the next element
  /// based on `order` ([Order]).
  ///
  /// `order` refers to values of type `A`
  /// extracted from `element` using `extract`.
  ///
  /// Note: The element is added **before** an equal element already in the [Iterable].
  Iterable<T> insertWith<A>(
    A Function(T instance) extract,
    Order<A> order,
    T element,
  ) sync* {
    var it = iterator;
    var elementValue = extract(element);
    while (it.moveNext()) {
      if (order.compare(extract(it.current), elementValue) < 0) {
        yield it.current;
        continue;
      }
      yield element;
      do {
        yield it.current;
      } while (it.moveNext());
      return;
    }
    yield element;
  }

  /// Remove the **first occurrence** of `element` from this [Iterable].
  Iterable<T> delete(T element) sync* {
    var deleted = false;
    for (var current in this) {
      if (deleted || current != element) {
        yield current;
      } else {
        deleted = true;
      }
    }
  }

  /// Same as `map` but provides also the `index` of each mapped
  /// element in the mapping function (`toElement`).
  Iterable<B> mapWithIndex<B>(B Function(T t, int index) toElement) sync* {
    var index = 0;
    for (var value in this) {
      yield toElement(value, index);
      index += 1;
    }
  }

  /// Same as `flatMap` (`extend`) but provides also the `index` of each mapped
  /// element in the mapping function (`toElements`).
  Iterable<B> flatMapWithIndex<B>(
    Iterable<B> Function(T t, int index) toElements,
  ) sync* {
    var index = 0;
    for (var value in this) {
      yield* toElements(value, index);
      index += 1;
    }
  }

  /// The largest element of this [Iterable] based on `order`.
  ///
  /// If the list is empty, return [None].
  Option<T> maximumBy(Order<T> order) {
    var it = iterator;
    if (it.moveNext()) {
      T min = it.current;
      while (it.moveNext()) {
        if (order.compare(it.current, min) > 0) {
          min = it.current;
        }
      }
      return some(min);
    }
    return const None();
  }

  /// The least element of this [Iterable] based on `order`.
  ///
  /// If the list is empty, return [None].
  Option<T> minimumBy(Order<T> order) {
    var it = iterator;
    if (it.moveNext()) {
      T min = it.current;
      while (it.moveNext()) {
        if (order.compare(it.current, min) < 0) {
          min = it.current;
        }
      }
      return some(min);
    }
    return const None();
  }

  /// Apply all the functions inside `iterable` to this [Iterable].
  Iterable<B> ap<B>(Iterable<B Function(T)> iterable) => iterable.flatMap(map);

  /// Return the intersection of two [Iterable] (all the elements that both [Iterable] have in common).
  ///
  /// If an element occurs twice in this iterable, it occurs twice in the
  /// result, but if it occurs twice in [iterable], only the first value
  /// is used.
  Iterable<T> intersect(Iterable<T> iterable) sync* {
    // If it's not important that [iterable] can change between
    // `element`s, consider creating a set from it first,
    // for faster `contains`.
    for (var element in this) {
      if (iterable.contains(element)) yield element;
    }
  }

  /// Return an [Iterable] containing the values of this [Iterable] not included
  /// in `other` based on `eq`.
  Iterable<T> difference(Eq<T> eq, Iterable<T> other) sync* {
    for (var element in this) {
      if (!other.any((e) => eq.eqv(e, element))) {
        yield element;
      }
    }
  }

  /// Return an [Iterable] placing an `middle` in between elements of the this [Iterable].
  Iterable<T> intersperse(T middle) sync* {
    var it = iterator;
    if (!it.moveNext()) return;
    yield it.current;
    while (it.moveNext()) {
      yield middle;
      yield it.current;
    }
  }

  /// Sort this [List] based on `order` ([Order]).
  List<T> sortBy(Order<T> order) => [...this]..sort(order.compare);

  /// Sort this [Iterable] based on `order` of an object of type `A` extracted from `T` using `extract`.
  List<T> sortWith<A>(A Function(T t) extract, Order<A> order) =>
      [...this]..sort((e1, e2) => order.compare(extract(e1), extract(e2)));

  /// Sort this [Iterable] based on [DateTime] extracted from type `T` using `getDate`.
  ///
  /// Sorting [DateTime] in **ascending** order (older dates first).
  List<T> sortWithDate(DateTime Function(T instance) getDate) =>
      sortWith(getDate, Order.orderDate);
}

/// Functional programming functions on `Iterable<Iterable<T>>` using `fpdart`.
extension FpdartOnIterableOfIterable<T> on Iterable<Iterable<T>> {
  /// From a `Iterable<Iterable<T>>` return a `Iterable<T>` of their concatenation.
  Iterable<T> get flatten => expand(identity);
}
