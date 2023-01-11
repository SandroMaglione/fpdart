import 'package:managing_imports/functional.dart';
import 'package:test/test.dart';

void main(List<String> arguments) {
  // borrow the flatMap test from state_test.dart
  test('flatMap', () {
    final state = FpState<List<int>, int>((s) => Tuple2(s.first, s.sublist(1)));
    final ap = state.flatMap<double>(
      (a) => FpState(
        (s) => Tuple2(a / 2, s.sublist(1)),
      ),
    );
    final result = ap.run([1, 2, 3, 4, 5]);
    expect(result.first, 0.5);
    expect(result.second, [3, 4, 5]);
  });

  test('Tuple2', () {
    const tuple = Tuple2(1, 2);
    // this is the item access syntax for the fpdart package
    expect(tuple.first, 1);
    expect(tuple.second, 2);
  });

  test('Tuple3', () {
    const tuple = Tuple3(1, 2, 3);
    // this is the item access syntax for the tuple package
    expect(tuple.item1, 1);
    expect(tuple.item2, 2);
    expect(tuple.item3, 3);
  });
}
