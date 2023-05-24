import 'package:collection/collection.dart';
import 'package:test/test.dart';

final objectDeepEquality = const DeepCollectionEquality().equals;

void testImmutableMap<K, V>(
  Map<K, V> source,
  void Function(Map<K, V> value) test,
) {
  final originalSource = {...source};
  test(source);
  expect(
    objectDeepEquality(originalSource, source),
    true,
    reason:
        "The provided element is not immutable: ${source} should be ${originalSource}",
  );
}
