import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('PartialOrder', () {
    group('is a', () {
      final instance = PartialOrder.from((a1, a2) => 1);

      test('Eq', () {
        expect(instance, isA<Eq>());
      });
    });
  });
}
