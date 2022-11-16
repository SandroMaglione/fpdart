import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('State', () {
    group('is a', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));

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
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final ap = state.map((a) => a + 1);
      final result = ap.run('aaa');
      expect(result.first, 4);
      expect(result.second, 'aaaa');
    });

    test('map2', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final state1 = State<String, double>(
        (s) => Tuple2(s.length / 2, '${s}b'),
      );
      final ap = state.map2<double, double>(state1, (a, c) => c * a);
      final result = ap.run('aaa');
      expect(result.first, 6);
      expect(result.second, 'aaaab');
    });

    test('map3', () {
      final state = State<String, int>(
        (s) => Tuple2(s.length, '${s}a'),
      );
      final state1 = State<String, double>(
        (s) => Tuple2(s.length / 2, '${s}b'),
      );
      final state2 = State<String, String>(
        (s) => Tuple2('${s}aaa', '${s}b'),
      );
      final ap = state.map3<double, String, double>(
        state1,
        state2,
        (a, c, d) => d.length + (c * a),
      );
      final result = ap.run('aaa');
      expect(result.first, 14);
      expect(result.second, 'aaaabb');
    });

    test('ap', () {
      final state = State<String, int>(
        (s) => Tuple2(s.length, '${s}a'),
      );
      final ap = state.ap<String>(
        State(
          (s) => Tuple2((int n) => '$n$s', s),
        ),
      );
      final result = ap.run('aaa');
      expect(result.first, '3aaa');
      expect(result.second, 'aaaa');
    });

    test('andThen', () {
      final state = State<String, int>(
        (s) => Tuple2(s.length, '${s}a'),
      );
      final ap = state.andThen(
        () => State<String, double>(
          (s) => Tuple2(s.length / 2, '${s}a'),
        ),
      );
      final result = ap.run('aaa');
      expect(result.first, 2);
      expect(result.second, 'aaaaa');
    });

    test('call', () {
      final state = State<String, int>(
        (s) => Tuple2(s.length, '${s}a'),
      );
      final ap = state(
        State<String, double>(
          (s) => Tuple2(s.length / 2, '${s}a'),
        ),
      );
      final result = ap.run('aaa');
      expect(result.first, 2);
      expect(result.second, 'aaaaa');
    });

    test('toStateAsync', () async {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final ap = state.toStateAsync();
      final result = await ap.run('aaa');
      expect(result.first, 3);
      expect(result.second, 'aaaa');
    });

    test('pure', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final ap = state.pure(10);
      final result = ap.run('aaa');
      expect(result.first, 10);
      expect(result.second, 'aaa');
    });

    test('flatMap', () {
      final state = State<List<int>, int>((s) => Tuple2(s.first, s.sublist(1)));
      final ap = state.flatMap<double>(
        (a) => State(
          (s) => Tuple2(a / 2, s.sublist(1)),
        ),
      );
      final result = ap.run([1, 2, 3, 4, 5]);
      expect(result.first, 0.5);
      expect(result.second, [3, 4, 5]);
    });

    test('get', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final ap = state.get();
      final result = ap.run('aaa');
      expect(result.first, 'aaa');
      expect(result.second, 'aaa');
    });

    test('gets', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final ap = state.gets((s) => s.length * 2);
      final result = ap.run('aaa');
      expect(result.first, 6);
      expect(result.second, 'aaa');
    });

    test('modify', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final ap = state.modify((state) => 'b$state');
      final result = ap.run('aaa');
      expect(result.first, unit);
      expect(result.second, 'baaa');
    });

    test('put', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final ap = state.put('b');
      final result = ap.run('aaa');
      expect(result.second, 'b');
    });

    test('evaluate', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final result = state.evaluate('aaa');
      expect(result, 3);
    });

    test('execute', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final result = state.execute('aaa');
      expect(result, 'aaaa');
    });

    test('run', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final result = state.run('aaa');
      expect(result, isA<Tuple2>());
      expect(result.first, 3);
      expect(result.second, 'aaaa');
    });

    test('flatten', () {
      final state = State<String, State<String, int>>(
        (s) => Tuple2(
          State<String, int>(
            (s) => Tuple2(s.length, '${s}a'),
          ),
          '${s}a',
        ),
      );
      final ap = State.flatten(state);
      expect(ap, isA<State<String, int>>());
      final result = ap.run('aaa');
      expect(result.first, 4);
      expect(result.second, 'aaaaa');
    });
  });

  test('chainFirst', () {
    final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
    var sideEffect = 10;
    final chain = state.chainFirst((b) {
      sideEffect = 100;
      return State<String, double>((s) => Tuple2(s.length / 2, 'z${s}'));
    });
    final result = chain.run('abc');
    expect(result.first, 3);

    // It changes the value of `second`!
    expect(result.second, 'zabca');
    expect(sideEffect, 100);
  });
}
