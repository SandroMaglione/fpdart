import '../date.dart';
import '../function.dart';
import '../option.dart';
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
  Option<T> get head => isEmpty ? const None() : some(first);

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
  Option<Iterable<T>> get tail => isEmpty ? const None() : some(skip(1));

  /// Return all the elements of a [Iterable] except the last one.
  /// If the [Iterable] is empty, return [None].
  Option<Iterable<T>> get init =>
      isEmpty ? const None() : some(take(length - 1));

  /// Returns the list of those elements that satisfy `test`.
  ///
  /// Equivalent to `Iterable.where`.
  Iterable<T> filter(bool Function(T t) test) => where(test);

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
  Iterable<T> prependAll(Iterable<T> other) sync* {
    yield* other;
    yield* this;
  }

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
    if (isNotEmpty && iterable.isNotEmpty) {
      yield combine(first, iterable.first);
      yield* skip(1).zipWith(
        combine,
        iterable.skip(1),
      );
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
    if (isEmpty) {
      yield element;
    } else {
      if (order.compare(element, first) > 0) {
        yield first;
        yield* skip(1).insertBy(order, element);
      } else {
        yield element;
        yield* this;
      }
    }
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
    if (isEmpty) {
      yield element;
    } else {
      if (order.compare(extract(element), extract(first)) > 0) {
        yield first;
        yield* skip(1).insertWith(extract, order, element);
      } else {
        yield element;
        yield* this;
      }
    }
  }

  /// Remove the **first occurrence** of `element` from this [Iterable].
  Iterable<T> delete(T element) sync* {
    if (isNotEmpty) {
      if (first != element) {
        yield first;
        yield* skip(1).delete(element);
      } else {
        yield* skip(1);
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
    if (isEmpty) return const None();

    var max = first;
    for (var element in skip(1)) {
      if (order.compare(element, max) > 0) {
        max = element;
      }
    }

    return some(max);
  }

  /// The least element of this [Iterable] based on `order`.
  ///
  /// If the list is empty, return [None].
  Option<T> minimumBy(Order<T> order) {
    if (isEmpty) return const None();

    var min = first;
    for (var element in skip(1)) {
      if (order.compare(element, min) < 0) {
        min = element;
      }
    }

    return some(min);
  }

  /// Apply all the functions inside `iterable` to this [Iterable].
  Iterable<B> ap<B>(Iterable<B Function(T)> iterable) => iterable.flatMap(map);

  /// Return the intersection of two [Iterable] (all the elements that both [Iterable] have in common).
  Iterable<T> intersect(Iterable<T> iterable) sync* {
    for (var element in this) {
      try {
        final e = iterable.firstWhere((e) => e == element);
        yield e;
      } catch (_) {
        continue;
      }
    }
  }

  /// Return an [Iterable] placing an `middle` in between elements of the this [Iterable].
  Iterable<T> intersperse(T middle) sync* {
    if (isNotEmpty) {
      try {
        // Check not last element
        elementAt(1);

        yield first;
        yield middle;
        yield* skip(1).intersperse(middle);
      } catch (_) {
        // No element at 1, this is the last of the list
        yield first;
      }
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
      sortWith(getDate, dateOrder);
}

/// Functional programming functions on `Iterable<Iterable<T>>` using `fpdart`.
extension FpdartOnIterableOfIterable<T> on Iterable<Iterable<T>> {
  /// From a `Iterable<Iterable<T>>` return a `Iterable<T>` of their concatenation.
  Iterable<T> get flatten => expand(identity);
}
