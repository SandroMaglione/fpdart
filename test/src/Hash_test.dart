import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Hash', () {
    group('is a', () {
      final instance = Hash.fromUniversalHashCode<int>();

      test('Eq', () {
        expect(instance, isA<Eq>());
      });
    });

    test('.fromUniversalHashCode', () {
      const source1 = 1;
      const source2 = 1;
      final instance = Hash.fromUniversalHashCode<int>();
      expect(instance.hash(source1), source1.hashCode);
      expect(instance.eqv(source1, source2), true);
      expect(instance.hash(source1), instance.hash(source2));
    });
  });
}
