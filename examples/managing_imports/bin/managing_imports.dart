import 'package:managing_imports/functional.dart';
import 'package:test/test.dart';

void main() {
  /// Borrow the `flatMap` test from `state_test.dart`
  test('flatMap', () {
    final state = FpState<List<int>, int>((s) => (s.first, s.sublist(1)));
    final ap = state.flatMap<double>(
      (a) => FpState(
        (s) => (a / 2, s.sublist(1)),
      ),
    );
    final result = ap.run([1, 2, 3, 4, 5]);
    expect(result.$1, 0.5);
    expect(result.$2, [3, 4, 5]);
  });
}
