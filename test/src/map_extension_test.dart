import 'package:test/test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('FpdartOnMutableMap', () {
    test('mapValue', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.mapValue((value) => '${value * 2}');
      expect(ap, {'a': '2', 'b': '4', 'c': '6', 'd': '8'});
    });

    test('filter', () {
      final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
      final ap = map.filter((t) => t > 2);
      expect(ap, {'c': 3, 'd': 4});
    });

    group('lookup', () {
      test('Some', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap = map.lookup('b');
        ap.match((t) => expect(t, 2), () => null);
      });

      test('None', () {
        final map = <String, int>{'a': 1, 'b': 2, 'c': 3, 'd': 4};
        final ap = map.lookup('e');
        expect(ap, isA<None>());
      });
    });
  });
}
