import 'package:fpdart/fpdart.dart';
import 'package:glados/glados.dart';

void main() {
  group('Predicate extension', () {
    group('FpdartOnPredicate', () {
      Glados<bool>(any.bool).test('negate', (boolValue) {
        bool fun() => boolValue;
        expect(fun(), !fun.negate);
      });
    });

    group('FpdartOnPredicate1', () {
      Glados<int>(any.int).test('negate', (intValue) {
        bool fun(int n) => n % 2 == 0;
        expect(fun(intValue), !fun.negate(intValue));
      });
    });
  });
}
