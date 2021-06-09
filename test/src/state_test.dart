import 'package:fpdart/src/state.dart';
import 'package:fpdart/src/tuple.dart';
import 'package:test/test.dart';

void main() {
  group('State', () {
    test('map', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final ap = state.map((a) => a + 1);
      final result = ap.run('aaa');
      expect(result.value1, 4);
      expect(result.value2, 'aaa');
    });

    test('ap', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final ap = state.ap<String>(State((s) => Tuple2((int n) => '$n$s', s)));
      final result = ap.run('aaa');
      expect(result.value1, '3aaa');
      expect(result.value2, 'aaa');
    });

    test('flatMap', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final ap =
          state.flatMap<double>((a) => State((s) => Tuple2(a / 2, '$a$s')));
      final result = ap.run('aaa');
      expect(result.value1, 1.5);
      expect(result.value2, '3aaa');
    });

    test('get', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final ap = state.get();
      final result = ap.run('aaa');
      expect(result.value1, 'aaa');
      expect(result.value2, 'aaa');
    });

    test('put', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final ap = state.put('b');
      final result = ap.run('aaa');
      expect(result.value2, 'b');
    });

    test('evalState', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final result = state.evalState('aaa');
      expect(result, 3);
    });

    test('execState', () {
      final state = State<String, int>((s) => Tuple2(s.length, '${s}a'));
      final result = state.execState('aaa');
      expect(result, 'aaaa');
    });
  });
}
