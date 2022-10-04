import 'package:fpdart/fpdart.dart';

import './utils/utils.dart';

/// Used to test sorting with [DateTime] (`sortWithDate`)
class SortDate {
  final int id;
  final DateTime date;
  const SortDate(this.id, this.date);
}

void main() {
  /// Check if two [Iterable] have the same element in the same order
  bool eq<T>(Iterable<T> a, Iterable<T> b) => a.foldLeftWithIndex(
        false,
        (a, e, i) => e == b.elementAt(i),
      );

  group('FpdartOnMutableIterable', () {
    test('zipWith', () {
      final list1 = [1, 2];
      final list2 = ['a', 'b'];
      final ap =
          list1.zipWith<String, double>((t) => (i) => (t + i.length) / 2);
      final result = ap(list2);

      expect(eq(result, [1.0, 1.5]), true);
    });

    test('zip', () {
      final list1 = [1, 2];
      final list2 = ['a', 'b'];
      final ap = list1.zip(list2);

      expect(eq(ap, [const Tuple2(1, 'a'), const Tuple2(2, 'b')]), true);
    });

    test('filter', () {
      final list1 = [1, 2, 3, 4, 5, 6];
      final ap = list1.filter((t) => t > 3);

      expect(eq(ap, [4, 5, 6]), true);
    });

    test('plus', () {
      final list1 = [1, 2, 3, 4, 5, 6];
      final ap = list1.plus([7, 8]);

      expect(eq(ap, [1, 2, 3, 4, 5, 6, 7, 8]), true);
    });

    test('append', () {
      final list1 = [1, 2, 3, 4, 5, 6];
      final ap = list1.append(7);

      expect(eq(ap, [1, 2, 3, 4, 5, 6, 7]), true);
    });

    test('prepend', () {
      final list1 = [1, 2, 3, 4, 5, 6];
      final ap = list1.prepend(0);

      expect(eq(ap, [0, 1, 2, 3, 4, 5, 6]), true);
    });

    test('insertBy', () {
      final list1 = [1, 2, 3, 4, 5, 6];
      final ap = list1.insertBy(Order.from((a1, a2) => a1.compareTo(a2)), 4);

      expect(eq(ap, [1, 2, 3, 4, 4, 5, 6]), true);
    });

    test('insertWith', () {
      final list1 = [
        SortDate(2, DateTime(2019)),
        SortDate(4, DateTime(2017)),
        SortDate(1, DateTime(2020)),
        SortDate(3, DateTime(2018)),
      ];
      final ap = list1.insertWith(
        (instance) => instance.date,
        dateOrder,
        SortDate(5, DateTime(2021)),
      );

      expect(ap.elementAt(4).id, 5);
      expect(ap.elementAt(4).date.year, 2021);
    });

    test('sortBy', () {
      final list1 = [2, 6, 4, 1, 5, 3];
      final ap = list1.sortBy(Order.from((a1, a2) => a1.compareTo(a2)));

      expect(eq(ap, [1, 2, 3, 4, 5, 6]), true);
    });

    test('sortWith', () {
      final list1 = [
        SortDate(2, DateTime(2019)),
        SortDate(4, DateTime(2017)),
        SortDate(1, DateTime(2020)),
        SortDate(3, DateTime(2018)),
      ];
      final ap = list1.sortWith((instance) => instance.date, dateOrder);

      expect(ap.elementAt(0).id, 4);
      expect(ap.elementAt(1).id, 3);
      expect(ap.elementAt(2).id, 2);
      expect(ap.elementAt(3).id, 1);
    });

    test('sortWithDate', () {
      final list1 = [
        SortDate(2, DateTime(2019)),
        SortDate(4, DateTime(2017)),
        SortDate(1, DateTime(2020)),
        SortDate(3, DateTime(2018)),
      ];
      final ap = list1.sortWithDate((instance) => instance.date);

      expect(ap.elementAt(0).date.year, 2017);
      expect(ap.elementAt(1).date.year, 2018);
      expect(ap.elementAt(2).date.year, 2019);
      expect(ap.elementAt(3).date.year, 2020);
    });

    test('sortBy', () {
      final list1 = [2, 6, 4, 1, 5, 3];
      final ap = list1.sortBy(Order.from((a1, a2) => a1.compareTo(a2)));

      expect(eq(ap, [1, 2, 3, 4, 5, 6]), true);
    });

    test('intersect', () {
      final list1 = [1, 2, 3, 4, 5, 6];
      final ap = list1.intersect([1, 2, 3, 10, 11, 12]);

      expect(eq(ap, [1, 2, 3]), true);
    });

    group('head', () {
      test('Some', () {
        final list1 = [1, 2];
        final ap = list1.head;
        expect(ap, isA<Some>());
        expect(ap.getOrElse(() => -1), 1);
      });

      test('None', () {
        final List<int> list1 = [];
        final ap = list1.head;
        expect(ap, isA<None>());
        expect(ap.getOrElse(() => -1), -1);
      });
    });

    group('firstOption', () {
      test('Some', () {
        final list1 = [1, 2];
        final ap = list1.firstOption;
        expect(ap, isA<Some>());
        expect(ap.getOrElse(() => -1), 1);
      });
    });

    group('tail', () {
      test('Some', () {
        final list1 = [1, 2, 3, 4];
        final ap = list1.tail;
        expect(ap, isA<Some>());
        expect(ap.getOrElse(() => []), [2, 3, 4]);
      });
    });

    group('init', () {
      test('Some', () {
        final list1 = [1, 2, 3, 4];
        final ap = list1.init;
        expect(ap, isA<Some>());
        expect(ap.getOrElse(() => []), [1, 2, 3]);
      });
    });

    group('lastOption', () {
      test('Some', () {
        final list1 = [1, 2, 3, 4];
        final ap = list1.lastOption;
        expect(ap, isA<Some>());
        expect(ap.getOrElse(() => -1), 4);
      });
    });

    test('takeWhileLeft', () {
      final list1 = [1, 2, 3, 4];
      final ap = list1.takeWhileLeft((t) => t < 3);
      expect(eq(ap, [1, 2]), true);
    });

    test('dropWhileLeft', () {
      final list1 = [1, 2, 3, 4];
      final ap = list1.dropWhileLeft((t) => t < 3);
      expect(eq(ap, [3, 4]), true);
    });

    test('takeWhileRight', () {
      final list1 = [1, 2, 3, 4];
      final ap = list1.takeWhileRight((t) => t > 2);
      expect(eq(ap, [3, 4]), true);
    });

    test('dropWhileRight', () {
      final list1 = [1, 2, 3, 4];
      final ap = list1.dropWhileRight((t) => t > 2);
      expect(eq(ap, [1, 2]), true);
    });

    test('span', () {
      final list1 = [1, 2, 3, 4];
      final ap = list1.span((t) => t < 3);
      expect(eq(ap.first, [1, 2]), true);
      expect(eq(ap.second, [3, 4]), true);
    });

    test('breakI', () {
      final list1 = [1, 2, 3, 4];
      final ap = list1.breakI((t) => t > 2);
      expect(eq(ap.first, [1, 2]), true);
      expect(eq(ap.second, [3, 4]), true);
    });

    test('splitAt', () {
      final list1 = [1, 2, 3, 4];
      final ap = list1.splitAt(2);
      expect(eq(ap.first, [1, 2]), true);
      expect(eq(ap.second, [3, 4]), true);
    });

    test('delete', () {
      final list1 = [1, 2, 3, 2, 4, 2];
      final ap = list1.delete(2);
      expect(eq(ap, [1, 3, 2, 4, 2]), true);
    });

    test('maximumBy', () {
      final list1 = [2, 5, 4, 6, 1, 3];
      final ap = list1.maximumBy(Order.from((a1, a2) => a1.compareTo(a2)));
      expect(ap.getOrElse(() => -1), 6);
    });

    test('minimumBy', () {
      final list1 = [2, 5, 4, 6, 1, 3];
      final ap = list1.minimumBy(Order.from((a1, a2) => a1.compareTo(a2)));
      expect(ap.getOrElse(() => -1), 1);
    });

    test('drop', () {
      final list1 = [1, 2, 3, 4, 5];
      final ap = list1.drop(2);
      expect(eq(ap, [3, 4, 5]), true);
    });

    test('foldLeft', () {
      final list1 = [1, 2, 3];
      final ap = list1.foldLeft<int>(0, (b, t) => b - t);
      expect(ap, -6);
    });

    test('foldLeftWithIndex', () {
      final list1 = [1, 2, 3];
      final ap = list1.foldLeftWithIndex<int>(0, (b, t, i) => b - t - i);
      expect(ap, -9);
    });

    test('foldRight', () {
      final list1 = [1, 2, 3];
      final ap = list1.foldRight<int>(0, (b, t) => b - t);
      expect(ap, 2);
    });

    test('foldRightWithIndex', () {
      final list1 = [1, 2, 3];
      final ap = list1.foldRightWithIndex<int>(0, (b, t, i) => b - t - i);
      expect(ap, 1);
    });

    test('mapWithIndex', () {
      final list1 = [1, 2, 3];
      final ap = list1.mapWithIndex<String>((t, index) => '$t$index');
      expect(eq(ap, ['10', '21', '32']), true);
    });

    test('concatMap', () {
      final list1 = [1, 2, 3];
      final ap = list1.concatMap((t) => [t, t + 1]);
      expect(eq(ap, [1, 2, 2, 3, 3, 4]), true);
    });

    test('concatMapWithIndex', () {
      final list1 = [1, 2, 3];
      final ap = list1.concatMapWithIndex((t, i) => [t, t + i]);
      expect(eq(ap, [1, 1, 2, 3, 3, 5]), true);
    });

    test('flatMap', () {
      final list1 = [1, 2, 3];
      final ap = list1.flatMap((t) => [t, t + 1]);
      expect(eq(ap, [1, 2, 2, 3, 3, 4]), true);
    });

    test('flatMapWithIndex', () {
      final list1 = [1, 2, 3];
      final ap = list1.flatMapWithIndex((t, i) => [t, t + i]);
      expect(eq(ap, [1, 1, 2, 3, 3, 5]), true);
    });

    test('bind', () {
      final list1 = [1, 2, 3];
      final ap = list1.bind((t) => [t, t + 1]);
      expect(eq(ap, [1, 2, 2, 3, 3, 4]), true);
    });

    test('bindWithIndex', () {
      final list1 = [1, 2, 3];
      final ap = list1.bindWithIndex((t, i) => [t, t + i]);
      expect(eq(ap, [1, 1, 2, 3, 3, 5]), true);
    });

    test('ap', () {
      final list1 = [1, 2, 3];
      final ap = list1.ap([(a) => a + 1, (a) => a + 2]);
      expect(eq(ap, [2, 3, 3, 4, 4, 5]), true);
    });

    test('partition', () {
      final list1 = [2, 4, 5, 6, 1, 3];
      final ap = list1.partition((t) => t > 2);
      expect(eq(ap.first, [2, 1]), true);
      expect(eq(ap.second, [4, 5, 6, 3]), true);
    });

    group('all', () {
      test('true', () {
        final list1 = [1, 2, 3, 4];
        final ap = list1.all((t) => t < 5);
        expect(ap, true);
      });

      test('false', () {
        final list1 = [1, 2, 3, 4];
        final ap = list1.all((t) => t < 4);
        expect(ap, false);
      });
    });

    group('elem', () {
      test('true', () {
        final list1 = [1, 2, 3, 4];
        final ap1 = list1.elem(1);
        final ap2 = list1.elem(2);
        final ap3 = list1.elem(3);
        final ap4 = list1.elem(4);
        expect(ap1, true);
        expect(ap2, true);
        expect(ap3, true);
        expect(ap4, true);
      });

      test('false', () {
        final list1 = [1, 2, 3, 4];
        final ap1 = list1.elem(-1);
        final ap2 = list1.elem(0);
        final ap3 = list1.elem(5);
        final ap4 = list1.elem(6);
        expect(ap1, false);
        expect(ap2, false);
        expect(ap3, false);
        expect(ap4, false);
      });
    });

    group('notElem', () {
      test('false', () {
        final list1 = [1, 2, 3, 4];
        final ap1 = list1.notElem(1);
        final ap2 = list1.notElem(2);
        final ap3 = list1.notElem(3);
        final ap4 = list1.notElem(4);
        expect(ap1, false);
        expect(ap2, false);
        expect(ap3, false);
        expect(ap4, false);
      });

      test('true', () {
        final list1 = [1, 2, 3, 4];
        final ap1 = list1.notElem(-1);
        final ap2 = list1.notElem(0);
        final ap3 = list1.notElem(5);
        final ap4 = list1.notElem(6);
        expect(ap1, true);
        expect(ap2, true);
        expect(ap3, true);
        expect(ap4, true);
      });
    });
  });

  group('FpdartOnMutableIterableOfIterable', () {
    test('concat', () {
      final list1 = [
        [1, 2],
        [2, 3],
        [3, 4]
      ];
      final ap = list1.concat;

      expect(eq(ap, [1, 2, 2, 3, 3, 4]), true);
    });
  });

  group('FpdartTraversableIterable', () {
    group('traverseOption', () {
      test('Some', () {
        final list = [1, 2, 3, 4];
        final result = list.traverseOption(some);
        result.matchTestSome((t) {
          expect(list, t);
        });
      });

      test('None', () {
        final list = [1, 2, 3, 4];
        final result =
            list.traverseOption<int>((t) => t == 3 ? none() : some(t));
        expect(result, isA<None>());
      });
    });

    group('traverseOptionWithIndex', () {
      test('Some', () {
        final list = [1, 2, 3, 4];
        final result = list.traverseOptionWithIndex((a, i) => some(a + i));
        result.matchTestSome((t) {
          expect(t, [1, 3, 5, 7]);
        });
      });

      test('None', () {
        final list = [1, 2, 3, 4];
        final result = list.traverseOptionWithIndex<int>(
            (a, i) => i == 3 ? none() : some(a + i));
        expect(result, isA<None>());
      });
    });

    group('traverseEither', () {
      test('Right', () {
        final list = [1, 2, 3, 4];
        final result = list.traverseEither(right);
        result.matchTestRight((t) {
          expect(list, t);
        });
      });

      test('Left', () {
        final list = [1, 2, 3, 4];
        final result =
            list.traverseEither((t) => t == 3 ? left("Error") : right(t));
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
      });
    });

    group('traverseEitherWithIndex', () {
      test('Right', () {
        final list = [1, 2, 3, 4];
        final result = list.traverseEitherWithIndex((a, i) => right(a + i));
        result.matchTestRight((t) {
          expect(t, [1, 3, 5, 7]);
        });
      });

      test('Left', () {
        final list = [1, 2, 3, 4];
        final result = list.traverseEitherWithIndex(
            (a, i) => i == 3 ? left("Error") : right(a + i));
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
      });
    });

    test('traverseIO', () {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = list.traverseIO<String>((a) {
        sideEffect += 1;
        return IO.of("$a");
      });
      expect(sideEffect, 0);
      final result = traverse.run();
      expect(result, ['1', '2', '3', '4', '5', '6']);
      expect(sideEffect, list.length);
    });

    test('traverseIOWithIndex', () {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = list.traverseIOWithIndex<String>((a, i) {
        sideEffect += 1;
        return IO.of("$a$i");
      });
      expect(sideEffect, 0);
      final result = traverse.run();
      expect(result, ['10', '21', '32', '43', '54', '65']);
      expect(sideEffect, list.length);
    });

    test('traverseTask', () async {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = list.traverseTask<String>((a) {
        sideEffect += 1;
        return Task.of("$a");
      });
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, ['1', '2', '3', '4', '5', '6']);
      expect(sideEffect, list.length);
    });

    test('traverseTaskWithIndex', () async {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = list.traverseTaskWithIndex<String>((a, i) {
        sideEffect += 1;
        return Task.of("$a$i");
      });
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, ['10', '21', '32', '43', '54', '65']);
      expect(sideEffect, list.length);
    });

    group('traverseTaskOption', () {
      test('Some', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskOption<String>((a) {
          sideEffect += 1;
          return TaskOption.of("$a");
        });
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestSome((t) {
          expect(t, ['1', '2', '3', '4', '5', '6']);
        });
        expect(sideEffect, list.length);
      });

      test('None', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskOption<String>((a) {
          sideEffect += 1;
          return a % 2 == 0 ? TaskOption.none() : TaskOption.of("$a");
        });
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None<List<String>>>());
        expect(sideEffect, list.length);
      });
    });

    group('traverseTaskOptionWithIndex', () {
      test('Some', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskOptionWithIndex<String>((a, i) {
          sideEffect += 1;
          return TaskOption.of("$a$i");
        });
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestSome((t) {
          expect(t, ['10', '21', '32', '43', '54', '65']);
        });
        expect(sideEffect, list.length);
      });

      test('None', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskOptionWithIndex<String>((a, i) {
          sideEffect += 1;
          return a % 2 == 0 ? TaskOption.none() : TaskOption.of("$a$i");
        });
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None<List<String>>>());
        expect(sideEffect, list.length);
      });
    });
  });
}
