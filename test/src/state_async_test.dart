import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('StateAsync', () {
    group('is a', () {
      final state =
          StateAsync<String, int>((s) async => Tuple2(s.length, '${s}a'));

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

    test('map', () async {
      final state =
          StateAsync<String, int>((s) async => Tuple2(s.length, '${s}a'));
      final ap = state.map((a) => a + 1);
      final result = await ap.run('aaa');
      expect(result.first, 4);
      expect(result.second, 'aaaa');
    });

    test('map2', () async {
      final state =
          StateAsync<String, int>((s) async => Tuple2(s.length, '${s}a'));
      final state1 = StateAsync<String, double>(
        (s) async => Tuple2(s.length / 2, '${s}b'),
      );
      final ap = state.map2<double, double>(state1, (a, c) => c * a);
      final result = await ap.run('aaa');
      expect(result.first, 6);
      expect(result.second, 'aaaab');
    });

    test('map3', () async {
      final state = StateAsync<String, int>(
        (s) async => Tuple2(s.length, '${s}a'),
      );
      final state1 = StateAsync<String, double>(
        (s) async => Tuple2(s.length / 2, '${s}b'),
      );
      final state2 = StateAsync<String, String>(
        (s) async => Tuple2('${s}aaa', '${s}b'),
      );
      final ap = state.map3<double, String, double>(
        state1,
        state2,
        (a, c, d) => d.length + (c * a),
      );
      final result = await ap.run('aaa');
      expect(result.first, 14);
      expect(result.second, 'aaaabb');
    });

    test('ap', () async {
      final state = StateAsync<String, int>(
        (s) async => Tuple2(s.length, '${s}a'),
      );
      final ap = state.ap<String>(
        StateAsync(
          (s) async => Tuple2((int n) => '$n$s', s),
        ),
      );
      final result = await ap.run('aaa');
      expect(result.first, '3aaa');
      expect(result.second, 'aaaa');
    });

    test('andThen', () async {
      final state = StateAsync<String, int>(
        (s) async => Tuple2(s.length, '${s}a'),
      );
      final ap = state.andThen(
        () => StateAsync<String, double>(
          (s) async => Tuple2(s.length / 2, '${s}a'),
        ),
      );
      final result = await ap.run('aaa');
      expect(result.first, 2);
      expect(result.second, 'aaaaa');
    });

    test('call', () async {
      final state = StateAsync<String, int>(
        (s) async => Tuple2(s.length, '${s}a'),
      );
      final ap = state(
        StateAsync<String, double>(
          (s) async => Tuple2(s.length / 2, '${s}a'),
        ),
      );
      final result = await ap.run('aaa');
      expect(result.first, 2);
      expect(result.second, 'aaaaa');
    });

    test('fromState', () async {
      final state = StateAsync<String, int>.fromState(
          State((s) => Tuple2(s.length, '${s}a')));
      final result = await state.run('aaa');
      expect(result.first, 3);
      expect(result.second, 'aaaa');
    });

    test('pure', () async {
      final state =
          StateAsync<String, int>((s) async => Tuple2(s.length, '${s}a'));
      final ap = state.pure(10);
      final result = await ap.run('aaa');
      expect(result.first, 10);
      expect(result.second, 'aaa');
    });

    test('flatMap', () async {
      final state = StateAsync<List<int>, int>(
          (s) async => Tuple2(s.first, s.sublist(1)));
      final ap = state.flatMap<double>(
        (a) => StateAsync(
          (s) async => Tuple2(a / 2, s.sublist(1)),
        ),
      );
      final result = await ap.run([1, 2, 3, 4, 5]);
      expect(result.first, 0.5);
      expect(result.second, [3, 4, 5]);
    });

    test('get', () async {
      final state =
          StateAsync<String, int>((s) async => Tuple2(s.length, '${s}a'));
      final ap = state.get();
      final result = await ap.run('aaa');
      expect(result.first, 'aaa');
      expect(result.second, 'aaa');
    });

    test('gets', () async {
      final state =
          StateAsync<String, int>((s) async => Tuple2(s.length, '${s}a'));
      final ap = state.gets((s) => s.length * 2);
      final result = await ap.run('aaa');
      expect(result.first, 6);
      expect(result.second, 'aaa');
    });

    test('modify', () async {
      final state =
          StateAsync<String, int>((s) async => Tuple2(s.length, '${s}a'));
      final ap = state.modify((state) => 'b$state');
      final result = await ap.run('aaa');
      expect(result.first, unit);
      expect(result.second, 'baaa');
    });

    test('put', () async {
      final state =
          StateAsync<String, int>((s) async => Tuple2(s.length, '${s}a'));
      final ap = state.put('b');
      final result = await ap.run('aaa');
      expect(result.second, 'b');
    });

    test('evaluate', () async {
      final state =
          StateAsync<String, int>((s) async => Tuple2(s.length, '${s}a'));
      final result = await state.evaluate('aaa');
      expect(result, 3);
    });

    test('execute', () async {
      final state =
          StateAsync<String, int>((s) async => Tuple2(s.length, '${s}a'));
      final result = await state.execute('aaa');
      expect(result, 'aaaa');
    });

    test('run', () async {
      final state =
          StateAsync<String, int>((s) async => Tuple2(s.length, '${s}a'));
      final result = await state.run('aaa');
      expect(result, isA<Tuple2>());
      expect(result.first, 3);
      expect(result.second, 'aaaa');
    });

    test('flatten', () async {
      final state = StateAsync<String, StateAsync<String, int>>(
        (s) async => Tuple2(
          StateAsync<String, int>(
            (s) async => Tuple2(s.length, '${s}a'),
          ),
          '${s}a',
        ),
      );
      final ap = StateAsync.flatten(state);
      expect(ap, isA<StateAsync<String, int>>());
      final result = await ap.run('aaa');
      expect(result.first, 4);
      expect(result.second, 'aaaaa');
    });
  });

  test('chainFirst', () async {
    final state =
        StateAsync<String, int>((s) async => Tuple2(s.length, '${s}a'));
    var sideEffect = 10;
    final chain = state.chainFirst((b) {
      sideEffect = 100;
      return StateAsync<String, double>(
          (s) async => Tuple2(s.length / 2, 'z${s}'));
    });
    final result = await chain.run('abc');
    expect(result.first, 3);

    // It changes the value of `second`!
    expect(result.second, 'zabca');
    expect(sideEffect, 100);
  });
}
