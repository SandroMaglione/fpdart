import 'package:fpdart/fpdart.dart';

/// Functional programming functions on a mutable dart [Map] using `fpdart`.
extension FpdartOnMutableMap<K, V> on Map<K, V> {
  /// Convert each **value** of the [Map] using the `update` function and returns a new [Map].
  Map<K, A> mapValue<A>(A Function(V value) update) =>
      map((key, value) => MapEntry(key, update(value)));

  /// Returns the list of those elements of the [Map] whose **value** satisfies `predicate`.
  Map<K, V> filter(Predicate<V> predicate) {
    final entries = this.entries;
    final filteredMap = <K, V>{};
    for (final item in entries) {
      if (predicate(item.value)) {
        filteredMap.addEntries([item]);
      }
    }
    return filteredMap;
  }

  /// Get the value at given `key` if present, otherwise return [None].
  Option<V> lookup(K key) => Option.fromNullable(this[key]);
}
