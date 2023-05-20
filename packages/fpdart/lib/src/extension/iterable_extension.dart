import 'package:fpdart/src/extension/predicate_extension.dart';

import '../option.dart';

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
  (Iterable<T>, Iterable<T>) breakI(bool Function(T t) test) {
    final notTest = test.negate;
    return (takeWhile(notTest), skipWhile(notTest));
  }
}
