import '../option.dart';
import '../typeclass/eq.dart';
import '../typeclass/order.dart';
import 'iterable_extension.dart';
import 'option_extension.dart';

/// Functional programming functions on a mutable dart [Map] using `fpdart`.
extension FpdartOnMap<K, V> on Map<K, V> {
  /// Return number of keys in the [Map] (`keys.length`).
  int get size => keys.length;

  /// Convert each **value** of the [Map] using
  /// the `update` function and returns a new [Map].
  ///
  /// Immutable version of `Map.updateAll`.
  Map<K, A> mapValue<A>(A Function(V value) update) => map(
        (key, value) => MapEntry(key, update(value)),
      );

  /// Convert each **value** of the [Map] using
  /// the `update` function and returns a new [Map].
  Map<K, A> mapWithIndex<A>(A Function(V value, int index) update) =>
      Map.fromEntries(
        entries.mapWithIndex(
          (entry, index) => MapEntry(
            entry.key,
            update(entry.value, index),
          ),
        ),
      );

  /// Returns the list of those elements of the [Map] whose **value** satisfies `test`.
  Map<K, V> filter(bool Function(V value) test) => Map.fromEntries(
        entries.where(
          (entry) => test(entry.value),
        ),
      );

  /// Returns the list of those elements of the [Map] whose **value** satisfies `test`.
  Map<K, V> filterWithIndex(bool Function(V value, int index) test) =>
      Map.fromEntries(
        entries.filterWithIndex(
          (entry, index) => test(entry.value, index),
        ),
      );

  /// Returns the list of those elements of the [Map] whose key/value satisfies `test`.
  Map<K, V> filterWithKey(bool Function(K key, V value) test) =>
      Map.fromEntries(
        entries.where(
          (entry) => test(entry.key, entry.value),
        ),
      );

  /// Returns the list of those elements of the [Map] whose key/value satisfies `test`.
  Map<K, V> filterWithKeyAndIndex(
    bool Function(K key, V value, int index) test,
  ) =>
      Map.fromEntries(
        entries.filterWithIndex(
          (entry, index) => test(
            entry.key,
            entry.value,
            index,
          ),
        ),
      );

  /// Returns this [Map] if it contains a key based on `eq`.
  Option<Map<K, V>> containsKeyEq(Eq<K> eq, K key) => Option.tryCatch(
        () => keys.firstWhere((entryKey) => eq.eqv(entryKey, key)),
      ).map((_) => {...this});

  /// Get the value at given `key` if present, otherwise return [None].
  Option<V> lookup(K key) => Option.fromNullable(this[key]);

  /// Get the value at given `key` if present using `eq`, otherwise return [None].
  Option<V> lookupEq(Eq<K> eq, K key) => Option.tryCatch(
        () => entries.firstWhere((entry) => eq.eqv(entry.key, key)).value,
      );

  /// Get the value and key at given `key` if present, otherwise return [None].
  Option<(K, V)> lookupWithKey(K key) {
    final value = this[key];
    return value != null ? some((key, value)) : const None();
  }

  /// Get the value and key at given `key` if present using `eq`, otherwise return [None].
  Option<(K, V)> lookupWithKeyEq(Eq<K> eq, K key) => Option.tryCatch(
        () {
          final entry = entries.firstWhere((entry) => eq.eqv(entry.key, key));
          return (entry.key, entry.value);
        },
      );

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
    return value is T ? some(value) : const None();
  }

  /// Return an [Option] that conditionally accesses map keys if they contain a key
  /// with a [Map] value.
  ///
  /// Useful for accessing nested JSON.
  ///
  /// ```dart
  /// { 'test': { 'foo': 'bar' } }.extractMap('test'); /// `Some({ 'foo': 'bar' })`
  /// { 'test': 'string' }.extractMap('test'); /// `None()`
  /// ```
  Option<Map<K, dynamic>> extractMap(K key) => extract<Map<K, dynamic>>(key);

  /// If the given `key` is present in the [Map], then modify its value
  /// using `update` and return a the new [Map].
  ///
  /// Otherwise, return [None].
  Option<Map<K, V>> modifyAt(
    Eq<K> eq,
    V Function(V value) update,
    K key,
  ) =>
      containsKeyEq(eq, key).map(
        (newMap) => newMap.map(
          (entryKey, oldValue) => MapEntry(
            entryKey,
            eq.eqv(entryKey, key) ? update(oldValue) : oldValue,
          ),
        ),
      );

  /// If the given `key` is present in the [Map], then modify its value
  /// using `update` and return a the new [Map].
  ///
  /// Otherwise, return a copy of the original unmodified [Map].
  Map<K, V> modifyAtIfPresent(
    Eq<K> eq,
    V Function(V value) update,
    K key,
  ) =>
      modifyAt(eq, update, key).getOrElse(() => {...this});

  /// If the given `key` is present in the [Map], then update its value to `value`.
  ///
  /// Otherwise, return [None].
  Option<Map<K, V>> updateAt(Eq<K> eq, K key, V value) =>
      containsKeyEq(eq, key).map(
        (newMap) => newMap.map(
          (entryKey, oldValue) => MapEntry(
            entryKey,
            eq.eqv(entryKey, key) ? value : oldValue,
          ),
        ),
      );

  /// If the given `key` is present in the [Map], then update its value to `value`.
  /// Otherwise, return a copy of the original unmodified [Map].
  Map<K, V> updateAtIfPresent(
    Eq<K> eq,
    K key,
    V value,
  ) =>
      updateAt(eq, key, value).getOrElse(
        () => {...this},
      );

  /// Delete entry at given `key` if present in the [Map] and return updated [Map].
  Map<K, V> deleteAt(Eq<K> eq, K key) =>
      filterWithKey((k, v) => !eq.eqv(k, key));

  /// Insert or replace a key/value pair in a [Map].
  Map<K, V> upsertAt(Eq<K> eq, K key, V value) =>
      modifyAt(eq, (_) => value, key).getOrElse(
        () => {...this, key: value},
      );

  /// Delete a `key` and value from a this [Map], returning the deleted value as well as the updated [Map].
  ///
  /// If `key` is not present, then return [None].
  Option<(V, Map<K, V>)> pop(Eq<K> eq, K key) => lookupEq(eq, key).map(
        (v) => (v, deleteAt(eq, key)),
      );

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

  /// Combine the key/value of this [Map] and `map` using `combine` where the key is the same.
  Map<K, V> union(
    Eq<K> eq,
    V Function(V x, V y) combine,
    Map<K, V> map,
  ) =>
      map.foldLeftWithKey<Map<K, V>>(
        Order.allEqual(),
        {...this},
        (acc, key, value) => acc
            .modifyAt(
              eq,
              (v) => combine(v, value),
              key,
            )
            .getOrElse(
              () => acc.upsertAt(
                eq,
                key,
                value,
              ),
            ),
      );

  /// Intersect the key/value of two [Map] using `combine` where the key is the same.
  Map<K, V> intersection(
    Eq<K> eq,
    V Function(V x, V y) combine,
    Map<K, V> map,
  ) =>
      map.foldLeftWithKey<Map<K, V>>(
        Order.allEqual(),
        {},
        (acc, key, value) => lookupEq(eq, key).match(
          () => acc,
          (v) => acc.upsertAt(
            eq,
            key,
            combine(v, value),
          ),
        ),
      );

  /// Test whether or not the given `map` contains all of the keys and values contained in this [Map].
  bool isSubmap(
    Eq<K> eqK,
    Eq<V> eqV,
    Map<K, V> map,
  ) =>
      foldLeftWithKey<bool>(
        Order.allEqual(),
        true,
        (b, k, v) =>
            b &&
            map.entries.any(
              (e) => eqK.eqv(e.key, k) && eqV.eqv(e.value, v),
            ),
      );

  /// Collect all the entries in this [Map] into an [Iterable] using `compose`,
  /// with the values ordered using `order`.
  Iterable<A> collect<A>(Order<K> order, A Function(K key, V value) compose) =>
      toSortedList(order).map(
        (item) => compose(
          item.key,
          item.value,
        ),
      );

  /// Remove from this [Map] all the elements that have **key** contained in the given `map`.
  Map<K, V> difference(Eq<K> eq, Map<K, V> map) => filterWithKey(
        (key, value) => !map.keys.any(
          (element) => eq.eqv(element, key),
        ),
      );

  /// Get a sorted [List] of the key/value pairs contained in this [Map]
  /// based on `order` on keys.
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
