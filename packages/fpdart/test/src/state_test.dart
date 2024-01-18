import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('State', () {
    group('is a', () {
      final state = State<String, int>((s) => (s.length, '${s}a'));

      test('Monad', () {
        expect(state, isA<Monad2>());
      });

      test('Applicative', () {
        expect(state, isA<Applicative2>());
      });

      test('Functor', () {
        expect(state, isA<Functor2>());
      });
    });

    test('map', () {
      final state = State<String, int>((s) => (s.length, '${s}a'));
      final ap = state.map((a) => a + 1);
      final result = ap.run('aaa');
      expect(result.$1, 4);
      expect(result.$2, 'aaaa');
    });

    test('map2', () {
      final state = State<String, int>((s) => (s.length, '${s}a'));
      final state1 = State<String, double>(
        (s) => (s.length / 2, '${s}b'),
      );
      final ap = state.map2<double, double>(state1, (a, c) => c * a);
      final result = ap.run('aaa');
      expect(result.$1, 6);
      expect(result.$2, 'aaaab');
    });

    test('map3', () {
      final state = State<String, int>(
        (s) => (s.length, '${s}a'),
      );
      final state1 = State<String, double>(
        (s) => (s.length / 2, '${s}b'),
      );
      final state2 = State<String, String>(
        (s) => ('${s}aaa', '${s}b'),
      );
      final ap = state.map3<double, String, double>(
        state1,
        state2,
        (a, c, d) => d.length + (c * a),
      );
      final result = ap.run('aaa');
      expect(result.$1, 14);
      expect(result.$2, 'aaaabb');
    });

    test('ap', () {
      final state = State<String, int>(
        (s) => (s.length, '${s}a'),
      );
      final ap = state.ap<String>(
        State(
          (s) => ((int n) => '$n$s', s),
        ),
      );
      final result = ap.run('aaa');
      expect(result.$1, '3aaa');
      expect(result.$2, 'aaaa');
    });

    test('andThen', () {
      final state = State<String, int>(
        (s) => (s.length, '${s}a'),
      );
      final ap = state.andThen(
        () => State<String, double>(
          (s) => (s.length / 2, '${s}a'),
        ),
      );
      final result = ap.run('aaa');
      expect(result.$1, 2);
      expect(result.$2, 'aaaaa');
    });

    test('call', () {
      final state = State<String, int>(
        (s) => (s.length, '${s}a'),
      );
      final ap = state(
        State<String, double>(
          (s) => (s.length / 2, '${s}a'),
        ),
      );
      final result = ap.run('aaa');
      expect(result.$1, 2);
      expect(result.$2, 'aaaaa');
    });

    test('toStateAsync', () async {
      final state = State<String, int>((s) => (s.length, '${s}a'));
      final ap = state.toStateAsync();
      final result = await ap.run('aaa');
      expect(result.$1, 3);
      expect(result.$2, 'aaaa');
    });

    test('pure', () {
      final state = State<String, int>((s) => (s.length, '${s}a'));
      final ap = state.pure(10);
      final result = ap.run('aaa');
      expect(result.$1, 10);
      expect(result.$2, 'aaa');
    });

    test('flatMap', () {
      final state = State<List<int>, int>((s) => (s.first, s.sublist(1)));
      final ap = state.flatMap<double>(
        (a) => State(
          (s) => (a / 2, s.sublist(1)),
        ),
      );
      final result = ap.run([1, 2, 3, 4, 5]);
      expect(result.$1, 0.5);
      expect(result.$2, [3, 4, 5]);
    });

    test('get', () {
      final state = State<String, int>((s) => (s.length, '${s}a'));
      final ap = state.get();
      final result = ap.run('aaa');
      expect(result.$1, 'aaa');
      expect(result.$2, 'aaa');
    });

    test('gets', () {
      final state = State<String, int>((s) => (s.length, '${s}a'));
      final ap = state.gets((s) => s.length * 2);
      final result = ap.run('aaa');
      expect(result.$1, 6);
      expect(result.$2, 'aaa');
    });

    test('modify', () {
      final state = State<String, int>((s) => (s.length, '${s}a'));
      final ap = state.modify((state) => 'b$state');
      final result = ap.run('aaa');
      expect(result.$1, unit);
      expect(result.$2, 'baaa');
    });

    test('put', () {
      final state = State<String, int>((s) => (s.length, '${s}a'));
      final ap = state.put('b');
      final result = ap.run('aaa');
      expect(result.$2, 'b');
    });

    test('evaluate', () {
      final state = State<String, int>((s) => (s.length, '${s}a'));
      final result = state.evaluate('aaa');
      expect(result, 3);
    });

    test('execute', () {
      final state = State<String, int>((s) => (s.length, '${s}a'));
      final result = state.execute('aaa');
      expect(result, 'aaaa');
    });

    test('run', () {
      final state = State<String, int>((s) => (s.length, '${s}a'));
      final result = state.run('aaa');
      expect(result, isA<Record>());
      expect(result.$1, 3);
      expect(result.$2, 'aaaa');
    });

    test('flatten', () {
      final state = State<String, State<String, int>>(
        (s) => (
          State<String, int>(
            (s) => (s.length, '${s}a'),
          ),
          '${s}a',
        ),
      );
      final ap = State.flatten(state);
      expect(ap, isA<State<String, int>>());
      final result = ap.run('aaa');
      expect(result.$1, 4);
      expect(result.$2, 'aaaaa');
    });
  });

  test('chainFirst', () {
    final state = State<String, int>((s) => (s.length, '${s}a'));
    var sideEffect = 10;
    final chain = state.chainFirst((b) {
      sideEffect = 100;
      return State<String, double>((s) => (s.length / 2, 'z${s}'));
    });
    final result = chain.run('abc');
    expect(result.$1, 3);

    // It changes the value of `second`!
    expect(result.$2, 'zabca');
    expect(sideEffect, 100);
  });

  test('traverseListWithIndex', () {
    var sideEffect = 0;
    final list = ['a', 'b'];

    final traverse = State.traverseListWithIndex(
        list,
        (a, i) => State<int, String>((s) {
              sideEffect++;
              return (a + i.toString(), s);
            }));
    expect(sideEffect, 0);
    final (resultList, resultState) = traverse.run(1);
    expect(resultList, ['a0', 'b1']);
    expect(resultState, 1);
    expect(sideEffect, list.length);
  });

  test('traverseList', () {
    var sideEffect = 0;
    final list = ['a', 'b'];
    final traverse = State.traverseList(
        list,
        (a) => State<int, String>((s) {
              sideEffect++;
              return (a, s);
            }));
    expect(sideEffect, 0);
    final (resultList, resultState) = traverse.run(1);
    expect(resultList, ['a', 'b']);
    expect(resultState, 1);
    expect(sideEffect, list.length);
  });

  test('sequenceList', () {
    var sideEffect = 0;
    final list = [
      State<int, String>((s) {
        sideEffect++;
        return ('a', s);
      }),
      State<int, String>((s) {
        sideEffect++;
        return ('b', s);
      })
    ];
    final sequence = State.sequenceList(list);
    expect(sideEffect, 0);
    final (resultList, resultState) = sequence.run(1);
    expect(resultList, ['a', 'b']);
    expect(resultState, 1);
    expect(sideEffect, list.length);
  });
}
