import 'package:fpdart/src/reader.dart';
import 'package:test/test.dart';

void main() {
  group('Reader', () {
    test('map', () {
      final reader = Reader<String, int>((r) => r.length);
      final ap = reader.map((a) => a + 1);
      final result = ap.run('abc');
      expect(result, 4);
    });

    test('ap', () {
      final reader = Reader<String, int>((r) => r.length);
      final ap =
          reader.ap<double>(Reader((a) => (int n) => (n + a.length) / 2));
      final result = ap.run('abc');
      expect(result, 3.0);
    });

    test('flatMap', () {
      final reader = Reader<String, int>((r) => r.length);
      final ap =
          reader.flatMap((a) => Reader<String, int>((b) => a + b.length));
      final result = ap.run('abc');
      expect(result, 6);
    });
  });
}
