import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/ilist.dart';
import 'package:fpdart/src/maybe.dart';
import 'package:test/test.dart';

void main() {
  group('IList', () {
    test('fromList', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      expect(iList.head(), isA<Just<int>>());
    });

    test('map', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final map = iList.map((a) => a + 1).toList();
      expect(map, [2, 3, 4, 5]);
    });

    test('foldRight', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final map = iList.foldRight('', (a, b) => '$a$b');
      expect(map, '4321');
    });

    test('fold', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final map = iList.fold('', (a, b) => '$a$b');
      expect(map, '1234');
    });

    test('foldMap', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final map =
          iList.foldMap(Monoid.instance('', (a1, a2) => '$a1$a2'), (a) => '$a');
      expect(map, '1234');
    });
  });
}
