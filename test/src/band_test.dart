import 'package:fpdart/src/band.dart';
import 'package:test/test.dart';

void main() {
  group('Band', () {
    test('combineN', () {
      final instance = Band.instance<int>((a1, a2) => a1 + a2);
      expect(instance.combineN(1, 1), 1);
      expect(instance.combineN(1, 10), 2);
    });
  });
}
