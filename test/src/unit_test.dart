import 'package:fpdart/src/unit.dart';
import 'package:test/test.dart';

void main() {
  group('Unit', () {
    test('only one instance', () {
      const unit1 = unit;
      const unit2 = unit;
      expect(unit1, unit2);
      expect(unit1.hashCode, unit2.hashCode);
    });
  });
}
