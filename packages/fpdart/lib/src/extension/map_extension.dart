import '../option.dart';
import '../typeclass/eq.dart';
import '../typeclass/order.dart';
import '../typedef.dart';
import 'iterable_extension.dart';
import 'option_extension.dart';

/// Functional programming functions on a mutable dart [Map] using `fpdart`.
extension FpdartOnMutableMap<K, V> on Map<K, V> {
  /// Convert each **value** of the [Map] using the `update` function and returns a new [Map].
  Map<K, A> mapValue<A>(A Function(V value) update) =>
      map((key, value) => MapEntry(key, update(value)));

  /// Convert each **value** of the [Map] using the `update` function and returns a new [Map].
  Map<K, A> mapWithIndex<A>(A Function(V value, int index) update) {
    final entries = this.entries;
    final mapped = <K, A>{};
    var i = 0;
    for (final item in entries) {
      mapped.addEntries([MapEntry(item.key, update(item.value, i))]);
      i += 1;
    }
    return mapped;
  }

  /// Returns the list of those elements of the [Map] whose **value** satisfies `predicate`.
  Map<K, V> filter(bool Function(V value) predicate) {
    final entries = this.entries;
    final filteredMap = <K, V>{};
    for (final item in entries) {
      if (predicate(item.value)) {
        filteredMap.addEntries([item]);
      }
    }
    return filteredMap;
  }

  /// Returns the list of those elements of the [Map] whose **value** satisfies `predicate`.
  Map<K, V> filterWithIndex(bool Function(V value, int index) predicate) {
    final entries = this.entries;
    final filteredMap = <K, V>{};
    var i = 0;
    for (final item in entries) {
      if (predicate(item.value, i)) {
        filteredMap.addEntries([item]);
      }
      i += 1;
    }
    return filteredMap;
  }

  /// Returns the list of those elements of the [Map] whose key/value satisfies `predicate`.
  Map<K, V> filterWithKey(bool Function(K key, V value) predicate) {
    final entries = this.entries;
    final filteredMap = <K, V>{};
    for (final item in entries) {
      if (predicate(item.key, item.value)) {
        filteredMap.addEntries([item]);
      }
    }
    return filteredMap;
  }

  /// Returns the list of those elements of the [Map] whose key/value satisfies `predicate`.
  Map<K, V> filterWithKeyAndIndex(
      bool Function(K key, V value, int index) predicate) {
    final entries = this.entries;
    final filteredMap = <K, V>{};
    var i = 0;
    for (final item in entries) {
      if (predicate(item.key, item.value, i)) {
        filteredMap.addEntries([item]);
      }
      i += 1;
    }
    return filteredMap;
  }

  /// Get the value at given `key` if present, otherwise return [None].
  Option<V> lookup(K key) => Option.fromNullable(this[key]);

  /// Get the value and key at given `key` if present, otherwise return [None].
  Option<(K, V)> lookupWithKey(K key) {
    final value = this[key];
    return value != null ? some((key, value)) : none();
  }

  /// Return an [Option] that conditionally accesses map keys, only if they match the
  /// given type.
  /// Useful for accessing nested JSON.
  ///
  /// ```
  /// expect(
  ///   { 'test': 123 }.extract<int>('test'),
  ///   Option.of(123),
  /// );
  /// expect(
  ///   { 'test': 'string' }.extract<int>('test'),
  ///   Option.none(),
  /// );
  /// ```
  Option<T> extract<T>(K key) {
    final value = this[key];
    if (value is T) return Option.of(value);
    return Option.none();
  }

  /// Return an [Option] that conditionally accesses map keys, if they contain a map
  /// with the same key type.
  /// Useful for accessing nested JSON.
  ///
  /// ```
  /// expect(
  ///   { 'test': { 'foo': 'bar' } }.extractMap('test'),
  ///   Option.of({ 'foo': 'bar' }),
  /// );
  /// expect(
  ///   { 'test': 'string' }.extractMap('test'),
  ///   Option.none(),
  /// );
  /// ```
  Option<Map<K, dynamic>> extractMap(K key) => extract<Map<K, dynamic>>(key);

  /// Test whether or not `key` exists in this [Map]
  ///
  /// Same as dart's `containsKey`.
  bool member(K key) => containsKey(key);

  /// Test whether or not `value` exists in this [Map]
  ///
  /// Same as dart's `containsValue`.
  bool elem(V value) => containsValue(value);

  /// If the given `key` is present in the [Map], then modify its value
  /// using `modify` and return a the new [Map].
  /// Otherwise, return [None].
  Option<Map<K, V>> Function(K key, V Function(V value)) modifyAt(Eq<K> eq) =>
      (K key, V Function(V value) modify) => member(key)
          ? some(
              map(
                (k, v) =>
                    eq.eqv(k, key) ? MapEntry(key, modify(v)) : MapEntry(k, v),
              ),
            )
          : none();

  /// If the given `key` is present in the [Map], then modify its value
  /// using `modify` and return a the new [Map].
  /// Otherwise, return the original unmodified [Map].
  Map<K, V> Function(K key, V Function(V value)) modifyAtIfPresent(Eq<K> eq) =>
      (K key, V Function(V value) modify) =>
          modifyAt(eq)(key, modify).getOrElse(() => this);

  /// If the given `key` is present in the [Map], then update its value to `value`.
  /// Otherwise, return [None].
  Option<Map<K, V>> Function(K key, V value) updateAt(Eq<K> eq) =>
      (K key, V value) => member(key)
          ? some(
              map(
                (k, v) =>
                    eq.eqv(k, key) ? MapEntry(key, value) : MapEntry(k, v),
              ),
            )
          : none();

  /// If the given `key` is present in the [Map], then update its value to `value`.
  /// Otherwise, return the original unmodified [Map].
  Map<K, V> Function(K key, V value) updateAtIfPresent(Eq<K> eq) =>
      (K key, V value) => updateAt(eq)(key, value).getOrElse(() => this);

  /// Delete value and key at given `key` in the [Map] and return updated [Map].
  Map<K, V> Function(K key) deleteAt(Eq<K> eq) =>
      (K key) => filterWithKey((k, v) => !eq.eqv(k, key));

  /// Insert or replace a key/value pair in a [Map].
  Map<K, V> Function(K key, V value) upsertAt(Eq<K> eq) => (K key, V value) {
        final newMap = {...this};
        newMap.addEntries([MapEntry(key, value)]);
        return newMap.modifyAtIfPresent(eq)(key, (_) => value);
      };

  /// Delete a key and value from a this [Map], returning the deleted value as well as the subsequent [Map].
  Option<(V, Map<K, V>)> Function(K key) pop(Eq<K> eq) =>
      (K key) => lookup(key).map((v) => (v, deleteAt(eq)(key)));

  /// Apply `fun` to all the values of this [Map] sorted based on `order` on their key,
  /// and return the result of combining all the intermediate values.
  A Function(A initial, A Function(A acc, V value) fun) foldLeft<A>(
          Order<K> order) =>
      (A initial, A Function(A acc, V value) fun) {
        final sorted = toIterable(order);
        var result = initial;
        for (final item in sorted) {
          result = fun(result, item.value);
        }
        return result;
      };

  /// Apply `fun` to all the values of this [Map] sorted based on `order` on their key,
  /// and return the result of combining all the intermediate values.
  A Function(A initial, A Function(A acc, K key, V value) fun)
      foldLeftWithKey<A>(Order<K> order) =>
          (A initial, A Function(A acc, K key, V value) fun) {
            final sorted = toIterable(order);
            var result = initial;
            for (final item in sorted) {
              result = fun(result, item.key, item.value);
            }
            return result;
          };

  /// Apply `fun` to all the values of this [Map] sorted based on `order` on their key,
  /// passing also the current index of the iteration,
  /// and return the result of combining all the intermediate values.
  A Function(A initial, A Function(A acc, V value, int index) fun)
      foldLeftWithIndex<A>(Order<K> order) =>
          (A initial, A Function(A acc, V value, int index) fun) {
            final sorted = toIterable(order);
            var result = initial;
            var i = 0;
            for (final item in sorted) {
              result = fun(result, item.value, i);
              i += 1;
            }
            return result;
          };

  /// Apply `fun` to all the values of this [Map] sorted based on `order` on their key,
  /// passing also the current index of the iteration,
  /// and return the result of combining all the intermediate values.
  A Function(A initial, A Function(A acc, K key, V value, int index) fun)
      foldLeftWithKeyAndIndex<A>(Order<K> order) =>
          (A initial, A Function(A acc, K key, V value, int index) fun) {
            final sorted = toIterable(order);
            var result = initial;
            var i = 0;
            for (final item in sorted) {
              result = fun(result, item.key, item.value, i);
              i += 1;
            }
            return result;
          };

  /// Apply `fun` to all the values of this [Map] sorted based on the inverse of `order` on their key,
  /// and return the result of combining all the intermediate values.
  A Function(A initial, A Function(V value, A acc) fun) foldRight<A>(
          Order<K> order) =>
      (A initial, A Function(V value, A acc) fun) {
        final sorted = toIterable(order).toList().reversed;
        var result = initial;
        for (final item in sorted) {
          result = fun(item.value, result);
        }
        return result;
      };

  /// Apply `fun` to all the values of this [Map] sorted based on the inverse of `order` on their key,
  /// and return the result of combining all the intermediate values.
  A Function(A initial, A Function(K key, V value, A acc) fun)
      foldRightWithKey<A>(Order<K> order) =>
          (A initial, A Function(K key, V value, A acc) fun) {
            final sorted = toIterable(order).toList().reversed;
            var result = initial;
            for (final item in sorted) {
              result = fun(item.key, item.value, result);
            }
            return result;
          };

  /// Apply `fun` to all the values of this [Map] sorted based on the inverse of `order` on their key,
  /// passing also the current index of the iteration,
  /// and return the result of combining all the intermediate values.
  A Function(A initial, A Function(V value, A acc, int index) fun)
      foldRightWithIndex<A>(Order<K> order) =>
          (A initial, A Function(V value, A acc, int index) fun) {
            final sorted = toIterable(order).toList().reversed;
            var result = initial;
            var i = 0;
            for (final item in sorted) {
              result = fun(item.value, result, i);
              i += 1;
            }
            return result;
          };

  /// Apply `fun` to all the values of this [Map] sorted based on the inverse of `order` on their key,
  /// passing also the current index of the iteration,
  /// and return the result of combining all the intermediate values.
  A Function(A initial, A Function(K key, V value, A acc, int index) fun)
      foldRightWithKeyAndIndex<A>(Order<K> order) =>
          (A initial, A Function(K key, V value, A acc, int index) fun) {
            final sorted = toIterable(order).toList().reversed;
            var result = initial;
            var i = 0;
            for (final item in sorted) {
              result = fun(item.key, item.value, result, i);
              i += 1;
            }
            return result;
          };

  /// Return number of keys in the [Map].
  int get size => keys.length;

  /// Get a sorted [Iterable] of the key/value pairs contained in this [Map].
  Iterable<MapEntry<K, V>> toIterable(Order<K> order) =>
      entries.sortWith((map) => map.key, order);

  /// Combine the key/value of two [Map] using `combine` where the key is the same.
  Map<K, V> Function(Map<K, V> map) union(Eq<K> eq, Magma<V> combine) =>
      (Map<K, V> map) => map.foldLeftWithKey<Map<K, V>>(Order.allEqual())(
            this,
            (acc, key, value) => acc
                .modifyAt(eq)(
                  key,
                  (v) => combine(v, value),
                )
                .getOrElse(
                  () => acc.upsertAt(eq)(key, value),
                ),
          );

  /// Intersect the key/value of two [Map] using `combine` where the key is the same.
  Map<K, V> Function(Map<K, V> map) intersection(Eq<K> eq, Magma<V> combine) =>
      (Map<K, V> map) => map.foldLeftWithKey<Map<K, V>>(Order.allEqual())(
            {},
            (acc, key, value) => lookup(key).match(
              () => acc,
              (v) => acc.upsertAt(eq)(key, combine(v, value)),
            ),
          );

  /// Test whether or not the given `map` contains all of the keys and values contained in this [Map].
  bool Function(Map<K, V>) Function(Eq<V>) isSubmap(Eq<K> eqK) =>
      (Eq<V> eqV) => (Map<K, V> map) => foldLeftWithKey<bool>(Order.allEqual())(
            true,
            (b, k, v) =>
                b &&
                map.entries.any(
                  (e) => eqK.eqv(e.key, k) && eqV.eqv(e.value, v),
                ),
          );

  /// Collect all the entries in this [Map] into an [Iterable] using `fun` with the values ordered using `order`.
  Iterable<A> Function(A Function(K key, V value)) collect<A>(Order<K> order) =>
      (A Function(K key, V value) fun) =>
          toIterable(order).map((item) => fun(item.key, item.value));

  /// Remove from this [Map] all the elements that have **key** contained in the given `map`.
  Map<K, V> Function(Map<K, V> map) difference(Eq<K> eq) =>
      (Map<K, V> map) => filterWithKey(
            (key, value) => !map.keys.any((element) => eq.eqv(element, key)),
          );
}

extension FpdartOnOptionMutableMap<K> on Option<Map<K, dynamic>> {
  /// Return an [Option] that conditionally accesses map keys, only if they match the
  /// given type.
  /// Useful for accessing nested JSON.
  ///
  /// ```
  /// expect(
  ///   { 'test': 123 }.extract<int>('test'),
  ///   Option.of(123),
  /// );
  /// expect(
  ///   { 'test': 'string' }.extract<int>('test'),
  ///   Option.none(),
  /// );
  /// ```
  Option<T> extract<T>(K key) => flatMap((map) => map.extract(key));

  /// Return an [Option] that conditionally accesses map keys, if they contain a map
  /// with the same key type.
  /// Useful for accessing nested JSON.
  ///
  /// ```
  /// expect(
  ///   { 'test': { 'foo': 'bar' } }.extractMap('test'),
  ///   Option.of({ 'foo': 'bar' }),
  /// );
  /// expect(
  ///   { 'test': 'string' }.extractMap('test'),
  ///   Option.none(),
  /// );
  /// ```
  Option<Map<K, dynamic>> extractMap(K key) => extract<Map<K, dynamic>>(key);
}
