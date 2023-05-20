import 'package:fpdart/fpdart.dart';

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
  (Iterable<T>, Iterable<T>) partition(bool Function(T t) test) {
    final notTest = test.negate;
    return (takeWhile(notTest), skipWhile(notTest));
  }

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

  /// Check if `element` is contained inside this [Iterable].
  ///
  /// Equivalent to `Iterable.contains`.
  bool elem(T element) => contains(element);

  /// Check if `element` is **not** contained inside this [Iterable].
  bool notElem(T element) => !elem(element);

  /// Fold a [List] into a single value by aggregating each element of the list
  /// **from the first to the last**.
  ///
  /// Equivalent to `Iterable.fold`.
  B foldLeft<B>(B initialValue, B Function(B b, T t) combine) =>
      fold(initialValue, combine);

  /// For each element of the [Iterable] apply function `toElements` and flat the result.
  ///
  /// Equivalent to `Iterable.expand`.
  Iterable<B> flatMap<B>(Iterable<B> Function(T t) toElements) =>
      expand(toElements);

  /// Join elements at the same index from two different [Iterable] into
  /// one [Iterable] containing the result of calling `combine` on
  /// each element pair.
  Iterable<C> zipWith<B, C>(
    C Function(T t, B b) combine,
    Iterable<B> iterableB,
  ) {
    final iteratorB = iterableB.iterator;
    if (!iteratorB.moveNext()) return [];

    final resultList = <C>[];
    for (T elementT in this) {
      resultList.add(combine(elementT, iteratorB.current));
      if (!iteratorB.moveNext()) break;
    }

    return resultList;
  }
}

/// Functional programming functions on `Iterable<Iterable<T>>` using `fpdart`.
extension FpdartOnIterableOfIterable<T> on Iterable<Iterable<T>> {
  /// From a `Iterable<Iterable<T>>` return a `Iterable<T>` of their concatenation.
  Iterable<T> get flatten => expand(identity);
}
