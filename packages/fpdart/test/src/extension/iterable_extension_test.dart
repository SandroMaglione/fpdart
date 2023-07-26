import 'package:fpdart/fpdart.dart';

import '../utils/utils.dart';

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

  group('FpdartOnList', () {
    test('zipWith', () {
      final list1 = [1, 2];
      final list2 = ['a', 'b'];
      final result = list1.zipWith<String, double>(
        (t, i) => (t + i.length) / 2,
        list2,
      );

      expect(eq(result, [1.0, 1.5]), true);
    });

    test('zip', () {
      final list1 = [1, 2];
      final list2 = ['a', 'b'];
      final ap = list1.zip(list2);

      expect(eq(ap, [(1, 'a'), (2, 'b')]), true);
    });

    test('filter', () {
      final list1 = [1, 2, 3, 4, 5, 6];
      final ap = list1.filter((t) => t > 3);

      expect(eq(ap, [4, 5, 6]), true);
    });

    test('filterWithIndex', () {
      final list1 = [0, 1, 2, 3, 4, 5, 6];
      final ap = list1.filterWithIndex((t, index) => t > 3 && index < 6);

      expect(eq(ap, [4, 5]), true);
    });

    test('concat', () {
      final list1 = [1, 2, 3, 4, 5, 6];
      final ap = list1.concat([7, 8]);

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

    test('prependAll', () {
      final list1 = [1, 2, 3, 4, 5, 6];
      final ap = list1.prependAll([10, 11, 12]);

      expect(eq(ap, [10, 11, 12, 1, 2, 3, 4, 5, 6]), true);
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
        Order.orderDate,
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
      final ap = list1.sortWith((instance) => instance.date, Order.orderDate);

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

    test('difference', () {
      final list1 = [1, 2, 3];
      final ap = list1.difference(
        Eq.instance<int>((a1, a2) => a1 == a2),
        [2, 3, 4],
      );

      expect(eq(ap, [1]), true);
    });

    test('intersperse', () {
      final ap = [1, 2, 3].intersperse(10);

      expect(eq(ap, [1, 10, 2, 10, 3]), true);
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

    test('span', () {
      final list1 = [1, 5, 2, 3, 4];
      final ap = list1.span((t) => t < 3);
      expect(ap.$1.length, 1);
      expect(ap.$1.elementAt(0), 1);

      expect(ap.$2.length, 4);
      expect(ap.$2.elementAt(0), 5);
      expect(ap.$2.elementAt(1), 2);
      expect(ap.$2.elementAt(2), 3);
      expect(ap.$2.elementAt(3), 4);
    });

    test('breakI', () {
      final list1 = [4, 5, 1, 3, 4];
      final ap = list1.breakI((t) => t < 3);

      expect(ap.$1.length, 2);
      expect(ap.$1.elementAt(0), 4);
      expect(ap.$1.elementAt(1), 5);

      expect(ap.$2.length, 3);
      expect(ap.$2.elementAt(0), 1);
      expect(ap.$2.elementAt(1), 3);
      expect(ap.$2.elementAt(2), 4);
    });

    test('splitAt', () {
      final list1 = [1, 2, 3, 4];
      final ap = list1.splitAt(2);
      expect(eq(ap.$1, [1, 2]), true);
      expect(eq(ap.$2, [3, 4]), true);
    });

    test('delete', () {
      final list1 = [1, 2, 3, 2];
      final ap = list1.delete(2);
      expect(ap.length, 3);
      expect(ap.elementAt(0), 1);
      expect(ap.elementAt(1), 3);
      expect(ap.elementAt(2), 2);
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

    test('mapWithIndex', () {
      final list1 = [1, 2, 3];
      final ap = list1.mapWithIndex<String>((t, index) => '$t$index');
      expect(eq(ap, ['10', '21', '32']), true);
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

    test('ap', () {
      final list1 = [1, 2, 3];
      final ap = list1.ap([(a) => a + 1, (a) => a + 2]);
      expect(eq(ap, [2, 3, 3, 4, 4, 5]), true);
    });

    test('partition', () {
      final list1 = [2, 4, 5, 6, 1, 3];
      final ap = list1.partition((t) => t > 2);

      expect(ap.$1.length, 2);
      expect(ap.$1.elementAt(0), 2);
      expect(ap.$1.elementAt(1), 1);

      expect(ap.$2.length, 4);
      expect(ap.$2.elementAt(0), 4);
      expect(ap.$2.elementAt(1), 5);
      expect(ap.$2.elementAt(2), 6);
      expect(ap.$2.elementAt(3), 3);
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
      final ap = list1.flatten;

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

    group('traverseIOEither', () {
      test('Right', () {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseIOEither<String, String>((a) {
          sideEffect += 1;
          return IOEither.of("$a");
        });
        expect(sideEffect, 0);
        final result = traverse.run();
        result.matchTestRight((t) {
          expect(t, ['1', '2', '3', '4', '5', '6']);
        });
        expect(sideEffect, list.length);
      });

      test('Left', () {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseIOEither<String, String>((a) {
          sideEffect += 1;
          return a % 2 == 0 ? IOEither.left("Error") : IOEither.of("$a");
        });
        expect(sideEffect, 0);
        final result = traverse.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
        expect(sideEffect, list.length);
      });
    });

    group('traverseIOEitherWithIndex', () {
      test('Right', () {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseIOEitherWithIndex<String, String>((a, i) {
          sideEffect += 1;
          return IOEither.of("$a$i");
        });
        expect(sideEffect, 0);
        final result = traverse.run();
        result.matchTestRight((t) {
          expect(t, ['10', '21', '32', '43', '54', '65']);
        });
        expect(sideEffect, list.length);
      });

      test('Left', () {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseIOEitherWithIndex<String, String>((a, i) {
          sideEffect += 1;
          return a % 2 == 0 ? IOEither.left("Error") : IOEither.of("$a$i");
        });
        expect(sideEffect, 0);
        final result = traverse.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
        expect(sideEffect, list.length);
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
      final traverse = list.traverseTask<String>(
        (a) => Task(
          () async {
            await AsyncUtils.waitFuture();
            sideEffect += 1;
            return "$a";
          },
        ),
      );
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, ['1', '2', '3', '4', '5', '6']);
      expect(sideEffect, list.length);
    });

    test('traverseTaskWithIndex', () async {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = list.traverseTaskWithIndex<String>(
        (a, i) => Task(
          () async {
            await AsyncUtils.waitFuture();
            sideEffect += 1;
            return "$a$i";
          },
        ),
      );
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, ['10', '21', '32', '43', '54', '65']);
      expect(sideEffect, list.length);
    });

    test('traverseTaskSeq', () async {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = list.traverseTaskSeq<String>(
        (a) => Task(
          () async {
            await AsyncUtils.waitFuture();
            sideEffect = a;
            return "$a";
          },
        ),
      );
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, ['1', '2', '3', '4', '5', '6']);
      expect(sideEffect, 6);
    });

    test('traverseTaskWithIndexSeq', () async {
      final list = [1, 2, 3, 4, 5, 6];
      var sideEffect = 0;
      final traverse = list.traverseTaskWithIndexSeq<String>(
        (a, i) => Task(
          () async {
            await AsyncUtils.waitFuture();
            sideEffect = a + i;
            return "$a$i";
          },
        ),
      );
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, ['10', '21', '32', '43', '54', '65']);
      expect(sideEffect, 11);
    });

    group('traverseIOOption', () {
      test('Some', () {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseIOOption<String>(
          (a) => IOOption(
            () {
              sideEffect += 1;
              return some("$a");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = traverse.run();
        result.matchTestSome((t) {
          expect(t, ['1', '2', '3', '4', '5', '6']);
        });
        expect(sideEffect, list.length);
      });

      test('None', () {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseIOOption<String>(
          (a) => IOOption(
            () {
              sideEffect += 1;
              return a % 2 == 0 ? some("$a") : none();
            },
          ),
        );
        expect(sideEffect, 0);
        final result = traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, list.length);
      });
    });

    group('traverseTaskOptionWithIndex', () {
      test('Some', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskOptionWithIndex<String>(
          (a, i) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return some("$a$i");
            },
          ),
        );
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
        final traverse = list.traverseTaskOptionWithIndex<String>(
          (a, i) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return a % 2 == 0 ? some("$a$i") : none();
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, list.length);
      });
    });

    group('traverseTaskOption', () {
      test('Some', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskOption<String>(
          (a) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return some("$a");
            },
          ),
        );
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
        final traverse = list.traverseTaskOption<String>(
          (a) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return a % 2 == 0 ? some("$a") : none();
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, list.length);
      });
    });

    group('traverseTaskOptionWithIndex', () {
      test('Some', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskOptionWithIndex<String>(
          (a, i) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return some("$a$i");
            },
          ),
        );
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
        final traverse = list.traverseTaskOptionWithIndex<String>(
          (a, i) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return a % 2 == 0 ? some("$a$i") : none();
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, list.length);
      });
    });

    group('traverseTaskOptionSeq', () {
      test('Some', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskOptionSeq<String>(
          (a) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect = a - 1;
              return some("$a");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestSome((t) {
          expect(t, ['1', '2', '3', '4', '5', '6']);
        });
        expect(sideEffect, 5);
      });

      test('None', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskOptionSeq<String>(
          (a) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect = a - 1;
              return a % 2 == 0 ? some("$a") : none();
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, 5);
      });
    });

    group('traverseTaskOptionWithIndexSeq', () {
      test('Some', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskOptionWithIndexSeq<String>(
          (a, i) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect = a + i;
              return some("$a$i");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestSome((t) {
          expect(t, ['10', '21', '32', '43', '54', '65']);
        });
        expect(sideEffect, 11);
      });

      test('None', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskOptionWithIndexSeq<String>(
          (a, i) => TaskOption(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect = a + i;
              return a % 2 == 0 ? some("$a$i") : none();
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, 11);
      });
    });

    group('traverseTaskEither', () {
      test('Right', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskEither<String, String>(
          (a) => TaskEither(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return right<String, String>("$a");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestRight((t) {
          expect(t, ['1', '2', '3', '4', '5', '6']);
        });
        expect(sideEffect, list.length);
      });

      test('Left', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskEither<String, String>(
          (a) => TaskEither(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return a % 2 == 0
                  ? right<String, String>("$a")
                  : left<String, String>("Error");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
        expect(sideEffect, list.length);
      });
    });

    group('traverseTaskEitherWithIndex', () {
      test('Right', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskEitherWithIndex<String, String>(
          (a, i) => TaskEither(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return right<String, String>("$a$i");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestRight((t) {
          expect(t, ['10', '21', '32', '43', '54', '65']);
        });
        expect(sideEffect, list.length);
      });

      test('Left', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskEitherWithIndex<String, String>(
          (a, i) => TaskEither(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect += 1;
              return a % 2 == 0
                  ? right<String, String>("$a$i")
                  : left<String, String>("Error");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
        expect(sideEffect, list.length);
      });
    });

    group('traverseTaskEitherSeq', () {
      test('Right', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskEitherSeq<String, String>(
          (a) => TaskEither(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect = a - 1;
              return right<String, String>("$a");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestRight((t) {
          expect(t, ['1', '2', '3', '4', '5', '6']);
        });
        expect(sideEffect, 5);
      });

      test('Left', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskEitherSeq<String, String>(
          (a) => TaskEither(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect = a - 1;
              return a % 2 == 0
                  ? right<String, String>("$a")
                  : left<String, String>("Error");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
        expect(sideEffect, 5);
      });
    });

    group('traverseTaskEitherWithIndexSeq', () {
      test('Right', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskEitherWithIndexSeq<String, String>(
          (a, i) => TaskEither(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect = a + i;
              return right<String, String>("$a$i");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestRight((t) {
          expect(t, ['10', '21', '32', '43', '54', '65']);
        });
        expect(sideEffect, 11);
      });

      test('Left', () async {
        final list = [1, 2, 3, 4, 5, 6];
        var sideEffect = 0;
        final traverse = list.traverseTaskEitherWithIndexSeq<String, String>(
          (a, i) => TaskEither(
            () async {
              await AsyncUtils.waitFuture();
              sideEffect = a + i;
              return a % 2 == 0
                  ? right<String, String>("$a$i")
                  : left<String, String>("Error");
            },
          ),
        );
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
        expect(sideEffect, 11);
      });
    });
  });

  group('FpdartSequenceIterableOption', () {
    group('sequenceOption', () {
      test('Some', () {
        final list = [some(1), some(2), some(3), some(4)];
        final result = list.sequenceOption();
        result.matchTestSome((t) {
          expect(t, [1, 2, 3, 4]);
        });
      });

      test('None', () {
        final list = [some(1), none<int>(), some(3), some(4)];
        final result = list.sequenceOption();
        expect(result, isA<None>());
      });
    });
  });

  group('FpdartSequenceIterableIO', () {
    test('sequenceIO', () {
      var sideEffect = 0;
      final list = [
        IO(() {
          sideEffect += 1;
          return 1;
        }),
        IO(() {
          sideEffect += 1;
          return 2;
        }),
        IO(() {
          sideEffect += 1;
          return 3;
        }),
        IO(() {
          sideEffect += 1;
          return 4;
        })
      ];
      final traverse = list.sequenceIO();
      expect(sideEffect, 0);
      final result = traverse.run();
      expect(result, [1, 2, 3, 4]);
      expect(sideEffect, list.length);
    });
  });

  group('FpdartSequenceIterableTask', () {
    test('sequenceTask', () async {
      var sideEffect = 0;
      final list = [
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect += 1;
          return 1;
        }),
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect += 1;
          return 2;
        }),
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect += 1;
          return 3;
        }),
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect += 1;
          return 4;
        }),
      ];
      final traverse = list.sequenceTask();
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, [1, 2, 3, 4]);
      expect(sideEffect, list.length);
    });

    test('sequenceTaskSeq', () async {
      var sideEffect = 0;
      final list = [
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect = 0;
          return 1;
        }),
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect = 1;
          return 2;
        }),
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect = 2;
          return 3;
        }),
        Task(() async {
          await AsyncUtils.waitFuture();
          sideEffect = 3;
          return 4;
        }),
      ];
      final traverse = list.sequenceTaskSeq();
      expect(sideEffect, 0);
      final result = await traverse.run();
      expect(result, [1, 2, 3, 4]);
      expect(sideEffect, 3);
    });
  });

  group('FpdartSequenceIterableEither', () {
    group('sequenceEither', () {
      test('Right', () {
        final list = [right(1), right(2), right(3), right(4)];
        final result = list.sequenceEither();
        result.matchTestRight((r) {
          expect(r, [1, 2, 3, 4]);
        });
      });

      test('Left', () {
        final list = [
          right<String, int>(1),
          left<String, int>("Error"),
          right<String, int>(3),
          right<String, int>(4)
        ];
        final result = list.sequenceEither();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
      });
    });

    test('rightsEither', () {
      final list = [
        right<String, int>(1),
        right<String, int>(2),
        left<String, int>('a'),
        left<String, int>('b'),
        right<String, int>(3),
      ];
      final result = list.rightsEither();
      expect(result, [1, 2, 3]);
    });

    test('leftsEither', () {
      final list = [
        right<String, int>(1),
        right<String, int>(2),
        left<String, int>('a'),
        left<String, int>('b'),
        right<String, int>(3),
      ];
      final result = list.leftsEither();
      expect(result, ['a', 'b']);
    });

    test('partitionEithersEither', () {
      final list = [
        right<String, int>(1),
        right<String, int>(2),
        left<String, int>('a'),
        left<String, int>('b'),
        right<String, int>(3),
      ];
      final result = list.partitionEithersEither();
      expect(result.$1, ['a', 'b']);
      expect(result.$2, [1, 2, 3]);
    });
  });

  group('FpdartSequenceIterableIOOption', () {
    group('sequenceIOOption', () {
      test('Some', () {
        var sideEffect = 0;
        final list = [
          IOOption(() {
            sideEffect += 1;
            return some(1);
          }),
          IOOption(() {
            sideEffect += 1;
            return some(2);
          }),
          IOOption(() {
            sideEffect += 1;
            return some(3);
          }),
          IOOption(() {
            sideEffect += 1;
            return some(4);
          }),
        ];
        final traverse = list.sequenceIOOption();
        expect(sideEffect, 0);
        final result = traverse.run();
        result.matchTestSome((t) {
          expect(t, [1, 2, 3, 4]);
        });
        expect(sideEffect, list.length);
      });

      test('None', () {
        var sideEffect = 0;
        final list = [
          IOOption(() {
            sideEffect += 1;
            return some(1);
          }),
          IOOption(() {
            sideEffect += 1;
            return none<int>();
          }),
          IOOption(() {
            sideEffect += 1;
            return some(3);
          }),
          IOOption(() {
            sideEffect += 1;
            return some(4);
          }),
        ];
        final traverse = list.sequenceIOOption();
        expect(sideEffect, 0);
        final result = traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, list.length);
      });
    });
  });

  group('FpdartSequenceIterableTaskOption', () {
    group('sequenceTaskOption', () {
      test('Some', () async {
        var sideEffect = 0;
        final list = [
          TaskOption(() async {
            sideEffect += 1;
            return some(1);
          }),
          TaskOption(() async {
            sideEffect += 1;
            return some(2);
          }),
          TaskOption(() async {
            sideEffect += 1;
            return some(3);
          }),
          TaskOption(() async {
            sideEffect += 1;
            return some(4);
          }),
        ];
        final traverse = list.sequenceTaskOption();
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestSome((t) {
          expect(t, [1, 2, 3, 4]);
        });
        expect(sideEffect, list.length);
      });

      test('None', () async {
        var sideEffect = 0;
        final list = [
          TaskOption(() async {
            sideEffect += 1;
            return some(1);
          }),
          TaskOption(() async {
            sideEffect += 1;
            return none<int>();
          }),
          TaskOption(() async {
            sideEffect += 1;
            return some(3);
          }),
          TaskOption(() async {
            sideEffect += 1;
            return some(4);
          }),
        ];
        final traverse = list.sequenceTaskOption();
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, list.length);
      });
    });

    group('sequenceTaskOptionSeq', () {
      test('Some', () async {
        var sideEffect = 0;
        final list = [
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 0;
            return some(1);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 1;
            return some(2);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 2;
            return some(3);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 3;
            return some(4);
          }),
        ];
        final traverse = list.sequenceTaskOptionSeq();
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestSome((t) {
          expect(t, [1, 2, 3, 4]);
        });
        expect(sideEffect, 3);
      });

      test('None', () async {
        var sideEffect = 0;
        final list = [
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 0;
            return some(1);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 1;
            return none<int>();
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 2;
            return some(3);
          }),
          TaskOption(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 3;
            return some(4);
          }),
        ];
        final traverse = list.sequenceTaskOptionSeq();
        expect(sideEffect, 0);
        final result = await traverse.run();
        expect(result, isA<None>());
        expect(sideEffect, 3);
      });
    });
  });

  group('FpdartSequenceIterableTaskEither', () {
    group('sequenceTaskEither', () {
      test('Right', () async {
        var sideEffect = 0;
        final list = [
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(1);
          }),
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(2);
          }),
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(3);
          }),
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(4);
          }),
        ];
        final traverse = list.sequenceTaskEither();
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestRight((t) {
          expect(t, [1, 2, 3, 4]);
        });
        expect(sideEffect, list.length);
      });

      test('Left', () async {
        var sideEffect = 0;
        final list = [
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(1);
          }),
          TaskEither(() async {
            sideEffect += 1;
            return left<String, int>("Error");
          }),
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(3);
          }),
          TaskEither(() async {
            sideEffect += 1;
            return right<String, int>(4);
          }),
        ];
        final traverse = list.sequenceTaskEither();
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
        expect(sideEffect, list.length);
      });
    });

    group('sequenceTaskEitherSeq', () {
      test('Right', () async {
        var sideEffect = 0;
        final list = [
          TaskEither(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 0;
            return right<String, int>(1);
          }),
          TaskEither(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 1;
            return right<String, int>(2);
          }),
          TaskEither(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 2;
            return right<String, int>(3);
          }),
          TaskEither(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 3;
            return right<String, int>(4);
          }),
        ];
        final traverse = list.sequenceTaskEitherSeq();
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestRight((t) {
          expect(t, [1, 2, 3, 4]);
        });
        expect(sideEffect, 3);
      });

      test('Left', () async {
        var sideEffect = 0;
        final list = [
          TaskEither(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 0;
            return right<String, int>(1);
          }),
          TaskEither(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 1;
            return left<String, int>("Error");
          }),
          TaskEither(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 2;
            return right<String, int>(3);
          }),
          TaskEither(() async {
            await AsyncUtils.waitFuture();
            sideEffect = 3;
            return right<String, int>(4);
          }),
        ];
        final traverse = list.sequenceTaskEitherSeq();
        expect(sideEffect, 0);
        final result = await traverse.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
        expect(sideEffect, 3);
      });
    });
  });

  group('FpdartSequenceIterableIOEither', () {
    group('sequenceIOEither', () {
      test('Right', () {
        var sideEffect = 0;
        final list = [
          IOEither(() {
            sideEffect += 1;
            return right<String, int>(1);
          }),
          IOEither(() {
            sideEffect += 1;
            return right<String, int>(2);
          }),
          IOEither(() {
            sideEffect += 1;
            return right<String, int>(3);
          }),
          IOEither(() {
            sideEffect += 1;
            return right<String, int>(4);
          }),
        ];
        final traverse = list.sequenceIOEither();
        expect(sideEffect, 0);
        final result = traverse.run();
        result.matchTestRight((t) {
          expect(t, [1, 2, 3, 4]);
        });
        expect(sideEffect, list.length);
      });

      test('Left', () {
        var sideEffect = 0;
        final list = [
          IOEither(() {
            sideEffect += 1;
            return right<String, int>(1);
          }),
          IOEither(() {
            sideEffect += 1;
            return left<String, int>("Error");
          }),
          IOEither(() {
            sideEffect += 1;
            return right<String, int>(3);
          }),
          IOEither(() {
            sideEffect += 1;
            return right<String, int>(4);
          }),
        ];
        final traverse = list.sequenceIOEither();
        expect(sideEffect, 0);
        final result = traverse.run();
        result.matchTestLeft((l) {
          expect(l, "Error");
        });
        expect(sideEffect, list.length);
      });
    });
  });
}
