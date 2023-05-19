import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('StateAsync', () {
    group('is a', () {
      final state = StateAsync<String, int>((s) async => (s.length, '${s}a'));

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
      final state = StateAsync<String, int>((s) async => (s.length, '${s}a'));
      final ap = state.map((a) => a + 1);
      final result = await ap.run('aaa');
      expect(result.$1, 4);
      expect(result.$2, 'aaaa');
    });

    test('map2', () async {
      final state = StateAsync<String, int>((s) async => (s.length, '${s}a'));
      final state1 = StateAsync<String, double>(
        (s) async => (s.length / 2, '${s}b'),
      );
      final ap = state.map2<double, double>(state1, (a, c) => c * a);
      final result = await ap.run('aaa');
      expect(result.$1, 6);
      expect(result.$2, 'aaaab');
    });

    test('map3', () async {
      final state = StateAsync<String, int>(
        (s) async => (s.length, '${s}a'),
      );
      final state1 = StateAsync<String, double>(
        (s) async => (s.length / 2, '${s}b'),
      );
      final state2 = StateAsync<String, String>(
        (s) async => ('${s}aaa', '${s}b'),
      );
      final ap = state.map3<double, String, double>(
        state1,
        state2,
        (a, c, d) => d.length + (c * a),
      );
      final result = await ap.run('aaa');
      expect(result.$1, 14);
      expect(result.$2, 'aaaabb');
    });

    test('ap', () async {
      final state = StateAsync<String, int>(
        (s) async => (s.length, '${s}a'),
      );
      final ap = state.ap<String>(
        StateAsync(
          (s) async => ((int n) => '$n$s', s),
        ),
      );
      final result = await ap.run('aaa');
      expect(result.$1, '3aaa');
      expect(result.$2, 'aaaa');
    });

    test('andThen', () async {
      final state = StateAsync<String, int>(
        (s) async => (s.length, '${s}a'),
      );
      final ap = state.andThen(
        () => StateAsync<String, double>(
          (s) async => (s.length / 2, '${s}a'),
        ),
      );
      final result = await ap.run('aaa');
      expect(result.$1, 2);
      expect(result.$2, 'aaaaa');
    });

    test('call', () async {
      final state = StateAsync<String, int>(
        (s) async => (s.length, '${s}a'),
      );
      final ap = state(
        StateAsync<String, double>(
          (s) async => (s.length / 2, '${s}a'),
        ),
      );
      final result = await ap.run('aaa');
      expect(result.$1, 2);
      expect(result.$2, 'aaaaa');
    });

    test('fromState', () async {
      final state =
          StateAsync<String, int>.fromState(State((s) => (s.length, '${s}a')));
      final result = await state.run('aaa');
      expect(result.$1, 3);
      expect(result.$2, 'aaaa');
    });

    test('pure', () async {
      final state = StateAsync<String, int>((s) async => (s.length, '${s}a'));
      final ap = state.pure(10);
      final result = await ap.run('aaa');
      expect(result.$1, 10);
      expect(result.$2, 'aaa');
    });

    test('flatMap', () async {
      final state =
          StateAsync<List<int>, int>((s) async => (s.first, s.sublist(1)));
      final ap = state.flatMap<double>(
        (a) => StateAsync(
          (s) async => (a / 2, s.sublist(1)),
        ),
      );
      final result = await ap.run([1, 2, 3, 4, 5]);
      expect(result.$1, 0.5);
      expect(result.$2, [3, 4, 5]);
    });

    test('get', () async {
      final state = StateAsync<String, int>((s) async => (s.length, '${s}a'));
      final ap = state.get();
      final result = await ap.run('aaa');
      expect(result.$1, 'aaa');
      expect(result.$2, 'aaa');
    });

    test('gets', () async {
      final state = StateAsync<String, int>((s) async => (s.length, '${s}a'));
      final ap = state.gets((s) => s.length * 2);
      final result = await ap.run('aaa');
      expect(result.$1, 6);
      expect(result.$2, 'aaa');
    });

    test('modify', () async {
      final state = StateAsync<String, int>((s) async => (s.length, '${s}a'));
      final ap = state.modify((state) => 'b$state');
      final result = await ap.run('aaa');
      expect(result.$1, unit);
      expect(result.$2, 'baaa');
    });

    test('put', () async {
      final state = StateAsync<String, int>((s) async => (s.length, '${s}a'));
      final ap = state.put('b');
      final result = await ap.run('aaa');
      expect(result.$2, 'b');
    });

    test('evaluate', () async {
      final state = StateAsync<String, int>((s) async => (s.length, '${s}a'));
      final result = await state.evaluate('aaa');
      expect(result, 3);
    });

    test('execute', () async {
      final state = StateAsync<String, int>((s) async => (s.length, '${s}a'));
      final result = await state.execute('aaa');
      expect(result, 'aaaa');
    });

    test('run', () async {
      final state = StateAsync<String, int>((s) async => (s.length, '${s}a'));
      final result = await state.run('aaa');
      expect(result, isA<Record>());
      expect(result.$1, 3);
      expect(result.$2, 'aaaa');
    });

    test('flatten', () async {
      final state = StateAsync<String, StateAsync<String, int>>(
        (s) async => (
          StateAsync<String, int>(
            (s) async => (s.length, '${s}a'),
          ),
          '${s}a',
        ),
      );
      final ap = StateAsync.flatten(state);
      expect(ap, isA<StateAsync<String, int>>());
      final result = await ap.run('aaa');
      expect(result.$1, 4);
      expect(result.$2, 'aaaaa');
    });
  });

  test('chainFirst', () async {
    final state = StateAsync<String, int>((s) async => (s.length, '${s}a'));
    var sideEffect = 10;
    final chain = state.chainFirst((b) {
      sideEffect = 100;
      return StateAsync<String, double>((s) async => (s.length / 2, 'z${s}'));
    });
    final result = await chain.run('abc');
    expect(result.$1, 3);

    // It changes the value of `second`!
    expect(result.$2, 'zabca');
    expect(sideEffect, 100);
  });
}
