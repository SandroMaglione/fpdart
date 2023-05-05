import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  int x2(int a) => a * 2;
  int sub(int a, int b) => a - b;

  double div(int a) => a / 2;
  String full(int a, double b) => '$a-$b';

  group('Compose', () {
    test('call', () {
      final c = Compose(x2, 2);
      final c1 = Compose(div, 10);
      expect(c(), 4);
      expect(c1(), 5.0);
    });

    test('c1', () {
      final c = Compose(x2, 2).c1(x2);
      final c1 = Compose(x2, 2).c1(div);
      expect(c(), 8);
      expect(c1(), 2);
    });

    test('c2', () {
      final c = Compose(x2, 2).c2(sub, 1);
      expect(c(), 3);
    });

    test('*', () {
      final c = Compose(x2, 2) * x2.c;
      expect(c(), 8);
    });
  });

  group('Compose2', () {
    test('call', () {
      final c = Compose2(sub, 4, 2);
      final c1 = Compose2(full, 4, 2.0);
      expect(c(), 2);
      expect(c1(), '4-2.0');
    });

    test('c1', () {
      final c = Compose2(sub, 4, 2).c1(x2);
      expect(c(), 4);
    });

    test('c2', () {
      final c = Compose2(sub, 4, 2).c2(sub, 1);
      expect(c(), 1);
    });

    test('*', () {
      final c = Compose2(sub, 4, 2) * sub.c;
      expect(c(), 0);
    });
  });
}
