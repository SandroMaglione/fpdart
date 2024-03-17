import '../effect.dart';
import '../order.dart';
import 'iterable_extension.dart';

/// Functional programming functions on a mutable dart [Map] using `fpdart`.
extension FpdartOnMap<K, V> on Map<K, V> {
  /// Return number of elements in the [Map] (`keys.length`).
  int get size => keys.length;

  /// Convert each **value** of the [Map] using
  /// the `update` function and returns a new [Map].
  Map<K, A> mapValue<A>(A Function(V value) update) =>
      {for (var MapEntry(:key, :value) in entries) key: update(value)};

  /// Convert each **value** of the [Map] using
  /// the `update` function and returns a new [Map].
  Map<K, A> mapWithIndex<A>(A Function(V value, int index) update) => {
        for (var (index, MapEntry(:key, :value)) in entries.indexed)
          key: update(value, index)
      };

  /// Returns a new [Map] containing all the elements of this [Map]
  /// where the **value** satisfies `test`.
  Map<K, V> filter(bool Function(V value) test) => {
        for (var MapEntry(:key, :value) in entries)
          if (test(value)) key: value
      };

  /// Returns a new [Map] containing all the elements of this [Map]
  /// where the **value** satisfies `test`.
  Map<K, V> filterWithIndex(bool Function(V value, int index) test) => {
        for (var (index, MapEntry(:key, :value)) in entries.indexed)
          if (test(value, index)) key: value
      };

  /// Returns a new [Map] containing all the elements of this [Map]
  /// where **key/value** satisfies `test`.
  Map<K, V> filterWithKey(bool Function(K key, V value) test) => {
        for (var (MapEntry(:key, :value)) in entries)
          if (test(key, value)) key: value
      };

  /// Returns a new [Map] containing all the elements of this [Map]
  /// where **key/value** satisfies `test`.
  Map<K, V> filterWithKeyAndIndex(
    bool Function(K key, V value, int index) test,
  ) =>
      {
        for (var (index, MapEntry(:key, :value)) in entries.indexed)
          if (test(key, value, index)) key: value
      };

  /// Get the value at given `key` if present, otherwise return [None].
  Option<V> lookup(K key) {
    var value = this[key];
    if (value != null) return Some(value);
    if (containsKey(key)) return Some(value as V);
    return None();
  }

  /// Get the value and key at given `key` if present, otherwise return [None].
  Option<(K, V)> lookupWithKey(K key) {
    final value = this[key];
    if (value != null) return Some((key, value));
    if (containsKey(key)) return Some((key, value as V));
    return None();
  }

  /// Return an [Option] that conditionally accesses map keys, only if they match the
  /// given type.
  ///
  /// Useful for accessing nested JSON.
  ///
  /// ```dart
  /// { 'test': 123 }.extract<int>('test'); /// `Some(123)`
  /// { 'test': 'string' }.extract<int>('test'); /// `None()`
  /// ```
  Option<T> extract<T>(K key) {
    final value = this[key];
    if (value is T) return Some(value);
    return None();
  }

  /// Return an [Option] that conditionally accesses map keys if they contain a value
  /// with a [Map] value.
  ///
  /// Useful for accessing nested JSON.
  ///
  /// ```dart
  /// { 'test': { 'foo': 'bar' } }.extractMap('test'); /// `Some({ 'foo': 'bar' })`
  /// { 'test': 'string' }.extractMap('test'); /// `None()`
  /// ```
  Option<Map<K, dynamic>> extractMap(K key) => extract<Map<K, dynamic>>(key);

  /// Delete entry at given `key` if present in the [Map] and return updated [Map].
  ///
  /// See also `pop`.
  Map<K, V> deleteAt(K key) => filterWithKey((k, v) => k != key);

  /// Apply `compose` to all the values of this [Map] sorted based on `order` on their key,
  /// and return the result of combining all the intermediate values.
  A foldLeft<A>(Order<K> order, A initial, A Function(A acc, V value) compose) {
    final sorted = toSortedList(order);
    var result = initial;
    for (final item in sorted) {
      result = compose(result, item.value);
    }
    return result;
  }

  /// Apply `compose` to all the values of this [Map] sorted based on `order` on their key,
  /// and return the result of combining all the intermediate values.
  A foldLeftWithKey<A>(
    Order<K> order,
    A initial,
    A Function(A acc, K key, V value) compose,
  ) {
    final sorted = toSortedList(order);
    var result = initial;
    for (final item in sorted) {
      result = compose(result, item.key, item.value);
    }
    return result;
  }

  /// Apply `compose` to all the values of this [Map] sorted based on `order` on their key,
  /// passing also the current index of the iteration,
  /// and return the result of combining all the intermediate values.
  A foldLeftWithIndex<A>(
    Order<K> order,
    A initial,
    A Function(A acc, V value, int index) compose,
  ) {
    final sorted = toSortedList(order);
    var result = initial;
    var i = 0;
    for (final item in sorted) {
      result = compose(result, item.value, i);
      i += 1;
    }
    return result;
  }

  /// Apply `compose` to all the values of this [Map] sorted based on `order` on their key,
  /// passing also the current index of the iteration,
  /// and return the result of combining all the intermediate values.
  A foldLeftWithKeyAndIndex<A>(
    Order<K> order,
    A initial,
    A Function(A acc, K key, V value, int index) compose,
  ) {
    final sorted = toSortedList(order);
    var result = initial;
    var i = 0;
    for (final item in sorted) {
      result = compose(result, item.key, item.value, i);
      i += 1;
    }
    return result;
  }

  /// Apply `compose` to all the values of this [Map] sorted based on the inverse of `order` on their key,
  /// and return the result of combining all the intermediate values.
  A foldRight<A>(
    Order<K> order,
    A initial,
    A Function(V value, A acc) compose,
  ) {
    final sorted = toSortedList(order).toList().reversed;
    var result = initial;
    for (final item in sorted) {
      result = compose(item.value, result);
    }
    return result;
  }

  /// Apply `compose` to all the values of this [Map] sorted based on the inverse of `order` on their key,
  /// and return the result of combining all the intermediate values.
  A foldRightWithKey<A>(
    Order<K> order,
    A initial,
    A Function(K key, V value, A acc) compose,
  ) {
    final sorted = toSortedList(order).toList().reversed;
    var result = initial;
    for (final item in sorted) {
      result = compose(item.key, item.value, result);
    }
    return result;
  }

  /// Apply `compose` to all the values of this [Map] sorted based on the inverse of `order` on their key,
  /// passing also the current index of the iteration,
  /// and return the result of combining all the intermediate values.
  A foldRightWithIndex<A>(
    Order<K> order,
    A initial,
    A Function(V value, A acc, int index) compose,
  ) {
    final sorted = toSortedList(order).toList().reversed;
    var result = initial;
    var i = 0;
    for (final item in sorted) {
      result = compose(item.value, result, i);
      i += 1;
    }
    return result;
  }

  /// Apply `compose` to all the values of this [Map] sorted based on the inverse of `order` on their key,
  /// passing also the current index of the iteration,
  /// and return the result of combining all the intermediate values.
  A foldRightWithKeyAndIndex<A>(
    Order<K> order,
    A initial,
    A Function(K key, V value, A acc, int index) compose,
  ) {
    final sorted = toSortedList(order).toList().reversed;
    var result = initial;
    var i = 0;
    for (final item in sorted) {
      result = compose(item.key, item.value, result, i);
      i += 1;
    }
    return result;
  }

  /// Remove from this [Map] all the elements that have **key** contained in the given `map`.
  Map<K, V> difference(Map<K, V> map) => filterWithKey(
        (key, value) => !map.keys.any(
          (element) => element == key,
        ),
      );

  /// Collect all the entries in this [Map] into an [Iterable] using `compose`,
  /// with the values ordered using `order`.
  ///
  /// See also `toSortedList`.
  Iterable<A> collect<A>(Order<K> order, A Function(K key, V value) compose) =>
      toSortedList(order).map(
        (item) => compose(
          item.key,
          item.value,
        ),
      );

  /// Get a sorted [List] of the key/value pairs contained in this [Map]
  /// based on `order` on keys.
  ///
  /// See also `collect`.
  List<MapEntry<K, V>> toSortedList(Order<K> order) => entries.sortWith(
        (map) => map.key,
        order,
      );
}

extension FpdartOnOptionMap<K> on Option<Map<K, dynamic>> {
  /// Return an [Option] that conditionally accesses map keys, only if they match the
  /// given type.
  ///
  /// Useful for accessing nested JSON.
  ///
  /// ```dart
  /// { 'test': 123 }.extract<int>('test'); /// `Some(123)`
  /// { 'test': 'string' }.extract<int>('test'); /// `None()`
  /// ```
  Option<T> extract<T>(K key) => flatMap((map) => map.extract(key));

  /// Return an [Option] that conditionally accesses map keys, if they contain a map
  /// with the same key type.
  ///
  /// Useful for accessing nested JSON.
  ///
  /// ```dart
  /// { 'test': { 'foo': 'bar' } }.extractMap('test'); /// `Some({ 'foo': 'bar' })`
  /// { 'test': 'string' }.extractMap('test'); /// `None()`
  /// ```
  Option<Map<K, dynamic>> extractMap(K key) => extract<Map<K, dynamic>>(key);
}
