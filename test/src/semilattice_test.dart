import 'package:fpdart/src/semilattice.dart';
import 'package:test/test.dart';

void main() {
  group('semilattice', () {
    test('combineN (from Band)', () {
      final instance = Semilattice.instance<int>((a1, a2) => a1 + a2);
      expect(instance.combineN(1, 1), 1);
      expect(instance.combineN(1, 10), 2);
    });
  });
}
