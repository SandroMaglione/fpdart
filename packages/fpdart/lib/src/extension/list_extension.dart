/// Functional programming functions on a mutable dart [Iterable] using `fpdart`.
extension FpdartOnList<T> on List<T> {
  /// Fold this [List] into a single value by aggregating each element of the list
  /// **from the last to the first**.
  B foldRight<B>(
    B initialValue,
    B Function(B previousValue, T element) combine,
  ) {
    var value = initialValue;
    for (var element in reversed) {
      value = combine(value, element);
    }
    return value;
  }

  /// Same as `foldRight` but provides also the `index` of each mapped
  /// element in the `combine` function.
  B foldRightWithIndex<B>(
    B initialValue,
    B Function(B previousValue, T element, int index) combine,
  ) {
    var index = 0;
    var value = initialValue;
    for (var element in reversed) {
      value = combine(value, element, index);
      index += 1;
    }
    return value;
  }

  /// Extract all elements **starting from the last** as long as `test` returns `true`.
  Iterable<T> takeWhileRight(bool Function(T t) test) =>
      reversed.takeWhile(test);

  /// Remove all elements **starting from the last** as long as `test` returns `true`.
  Iterable<T> dropWhileRight(bool Function(T t) test) =>
      reversed.skipWhile(test);
}
