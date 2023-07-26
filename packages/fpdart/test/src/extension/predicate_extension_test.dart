import 'package:fpdart/fpdart.dart';
import 'package:glados/glados.dart';

void main() {
  group('Predicate extension', () {
    group('FpdartOnPredicate', () {
      Glados<bool>(any.bool).test('negate', (boolValue) {
        bool fun() => boolValue;
        expect(fun(), !fun.negate);
      });

      test('and', () {
        bool funTrue() => true;
        bool funFalse() => false;
        expect(funTrue.and(funTrue)(), true);
        expect(funTrue.and(funFalse)(), false);
        expect(funFalse.and(funTrue)(), false);
        expect(funFalse.and(funFalse)(), false);
      });

      test('or', () {
        bool funTrue() => true;
        bool funFalse() => false;
        expect(funTrue.or(funTrue)(), true);
        expect(funTrue.or(funFalse)(), true);
        expect(funFalse.or(funTrue)(), true);
        expect(funFalse.or(funFalse)(), false);
      });

      test('xor', () {
        bool funTrue() => true;
        bool funFalse() => false;
        expect(funTrue.xor(funTrue)(), false);
        expect(funTrue.xor(funFalse)(), true);
        expect(funFalse.xor(funTrue)(), true);
        expect(funFalse.xor(funFalse)(), false);
      });
    });

    group('FpdartOnPredicate1', () {
      Glados<int>(any.int).test('negate', (intValue) {
        bool fun(int n) => n % 2 == 0;
        expect(fun(intValue), !fun.negate(intValue));
      });

      test('and', () {
        bool fun2(int n) => n % 2 == 0;
        bool fun3(int n) => n % 3 == 0;
        expect(fun2.and(fun2)(4), true);
        expect(fun2.and(fun3)(4), false);
        expect(fun2.and(fun3)(6), true);
        expect(fun3.and(fun2)(4), false);
        expect(fun3.and(fun3)(3), true);
      });

      test('or', () {
        bool fun2(int n) => n % 2 == 0;
        bool fun3(int n) => n % 3 == 0;
        expect(fun2.or(fun2)(4), true);
        expect(fun2.or(fun3)(4), true);
        expect(fun2.or(fun3)(6), true);
        expect(fun3.or(fun2)(4), true);
        expect(fun3.or(fun2)(7), false);
        expect(fun3.or(fun3)(7), false);
      });

      test('xor', () {
        bool fun2(int n) => n % 2 == 0;
        bool fun3(int n) => n % 3 == 0;
        expect(fun2.xor(fun2)(4), false);
        expect(fun2.xor(fun3)(4), true);
        expect(fun2.xor(fun3)(6), false);
        expect(fun3.xor(fun2)(4), true);
        expect(fun3.xor(fun3)(3), false);
        expect(fun3.xor(fun2)(7), false);
      });

      test('contramap', () {
        bool even(int n) => n % 2 == 0;
        final evenLength = even.contramap<String>((a) => a.length);
        expect(evenLength("abc"), false);
        expect(evenLength("abcd"), true);
        expect(evenLength("a"), false);
        expect(evenLength("ab"), true);
        expect(evenLength("abcde"), false);
        expect(evenLength("abcdef"), true);
      });
    });
  });
}
