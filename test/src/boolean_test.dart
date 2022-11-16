import 'package:test/test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('boolean', () {
    group('fold', () {
      test('true', () {
        final ap = true.fold<int>(() => -1, () => 1);
        expect(ap, 1);
      });

      test('false', () {
        final ap = false.fold<int>(() => -1, () => 1);
        expect(ap, -1);
      });
    });

    group('match', () {
      test('true', () {
        final ap = true.match<int>(() => -1, () => 1);
        expect(ap, 1);
      });

      test('false', () {
        final ap = false.match<int>(() => -1, () => 1);
        expect(ap, -1);
      });
    });
  });
}
