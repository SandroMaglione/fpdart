import 'package:fpdart/fpdart.dart';
import 'package:glados/glados.dart';

void main() {
  group('Curry/Uncarry extension', () {
    group('Curry/Uncarry (2)', () {
      int subtract(int n1, int n2) => n1 - n2;
      int Function(int) subtractCurried(int n1) => (n2) => n1 - n2;

      Glados2<int, int>(any.int, any.int).test('curryAll', (n1, n2) {
        expect(subtract(n1, n2), subtract.curry(n1)(n2));
      });

      Glados2<int, int>(any.int, any.int).test('uncurry', (n1, n2) {
        expect(subtractCurried(n1)(n2), subtractCurried.uncurry(n1, n2));
      });
    });

    group('Curry/Uncarry (3)', () {
      int subtract(int n1, int n2, int n3) => n1 - n2 - n3;
      int Function(int) Function(int) subtractCurriedAll(int n1) =>
          (n2) => (n3) => n1 - n2 - n3;

      Glados3<int, int, int>(any.int, any.int, any.int).test('curry',
          (n1, n2, n3) {
        expect(subtract(n1, n2, n3), subtract.curry(n1)(n2, n3));
      });

      Glados3<int, int, int>(any.int, any.int, any.int).test('curryAll',
          (n1, n2, n3) {
        expect(subtract(n1, n2, n3), subtract.curryAll(n1)(n2)(n3));
      });

      Glados3<int, int, int>(any.int, any.int, any.int).test('uncurry',
          (n1, n2, n3) {
        expect(subtractCurriedAll(n1)(n2)(n3),
            subtractCurriedAll.uncurry(n1, n2, n3));
      });
    });

    group('Curry/Uncarry (4)', () {
      int subtract(int n1, int n2, int n3, int n4) => n1 - n2 - n3 - n4;
      int Function(int) Function(int) Function(int) subtractCurriedAll(
              int n1) =>
          (n2) => (n3) => (n4) => n1 - n2 - n3 - n4;

      Glados3<int, int, int>(any.int, any.int, any.int).test('curry',
          (n1, n2, n3) {
        expect(subtract(n1, n2, n3, n1), subtract.curry(n1)(n2, n3, n1));
      });

      Glados3<int, int, int>(any.int, any.int, any.int).test('curryAll',
          (n1, n2, n3) {
        expect(subtract(n1, n2, n3, n1), subtract.curryAll(n1)(n2)(n3)(n1));
      });

      Glados3<int, int, int>(any.int, any.int, any.int).test('uncurry',
          (n1, n2, n3) {
        expect(subtractCurriedAll(n1)(n2)(n3)(n1),
            subtractCurriedAll.uncurry(n1, n2, n3, n1));
      });
    });

    group('Curry/Uncarry (5)', () {
      int subtract(int n1, int n2, int n3, int n4, int n5) =>
          n1 - n2 - n3 - n4 - n5;
      int Function(int) Function(int) Function(int) Function(int)
          subtractCurriedAll(int n1) =>
              (n2) => (n3) => (n4) => (n5) => n1 - n2 - n3 - n4 - n5;

      Glados3<int, int, int>(any.int, any.int, any.int).test('curry',
          (n1, n2, n3) {
        expect(
            subtract(n1, n2, n3, n1, n2), subtract.curry(n1)(n2, n3, n1, n2));
      });

      Glados3<int, int, int>(any.int, any.int, any.int).test('curryAll',
          (n1, n2, n3) {
        expect(subtract(n1, n2, n3, n1, n2),
            subtract.curryAll(n1)(n2)(n3)(n1)(n2));
      });

      Glados3<int, int, int>(any.int, any.int, any.int).test('uncurry',
          (n1, n2, n3) {
        expect(subtractCurriedAll(n1)(n2)(n3)(n1)(n2),
            subtractCurriedAll.uncurry(n1, n2, n3, n1, n2));
      });
    });
  });
}
