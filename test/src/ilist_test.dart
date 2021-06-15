import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('IList', () {
    group('is a', () {
      test('Applicative', () {
        final iList = IList.fromList([1, 2, 3, 4]);
        expect(iList, isA<Applicative>());
      });

      test('Foldable', () {
        final iList = IList.fromList([1, 2, 3, 4]);
        expect(iList, isA<Foldable>());
      });
    });

    test('fromList', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      expect(iList.head(), isA<Some<int>>());
    });

    test('map', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final map = iList.map((a) => a + 1).toList();
      expect(map, [2, 3, 4, 5]);
    });

    test('foldRight', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final map = iList.foldRight<String>('', (a, b) => '$b$a');
      expect(map, '4321');
    });

    test('foldLeft', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final map = iList.foldLeft<String>('', (a, b) => '$a$b');
      expect(map, '1234');
    });

    test('foldMap', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final map =
          iList.foldMap(Monoid.instance('', (a1, a2) => '$a1$a2'), (a) => '$a');
      expect(map, '1234');
    });

    test('plus', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final plus = iList.plus(iList);
      expect(plus.toList(), [1, 2, 3, 4, 1, 2, 3, 4]);
    });

    test('reverse', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final plus = iList.reverse();
      expect(plus.toList(), [4, 3, 2, 1]);
    });

    test('append', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final plus = iList.append(5);
      expect(plus.toList(), [1, 2, 3, 4, 5]);
    });

    test('prepend', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final plus = iList.prepend(5);
      expect(plus.toList(), [5, 1, 2, 3, 4]);
    });

    test('concat', () {
      final iList = IList.concat<int>(IList.fromList([
        IList.fromList([1, 2]),
        IList.fromList([3, 4]),
        IList.fromList([5, 6])
      ]));
      expect(iList.toList(), [1, 2, 3, 4, 5, 6]);
    });

    test('concatMap', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final cmap = iList.concatMap((t) => IList.fromList([t + 1, t * 2]));
      expect(cmap.toList(), [2, 2, 3, 4, 4, 6, 5, 8]);
    });

    test('ap', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final cmap = iList.ap(IList.fromList([(a) => a + 1, (a) => a * 2]));
      expect(cmap.toList(), [2, 2, 3, 4, 4, 6, 5, 8]);
    });

    test('flatMap', () {
      final iList = IList.fromList([1, 2, 3, 4]);
      final fmap = iList.flatMap((a) => IList.fromList([a, a + 1]));
      expect(fmap.toList(), [1, 2, 2, 3, 3, 4, 4, 5]);
    });
  });
}
