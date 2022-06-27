import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

void main() {
  group('Reader', () {
    group('is a', () {
      final reader = Reader<String, int>((r) => r.length);

      test('Monad', () {
        expect(reader, isA<Monad2>());
      });

      test('Applicative', () {
        expect(reader, isA<Applicative2>());
      });

      test('Functor', () {
        expect(reader, isA<Functor2>());
      });
    });

    test('map', () {
      final reader = Reader<String, int>((r) => r.length);
      final ap = reader.map((a) => a + 1);
      final result = ap.run('abc');
      expect(result, 4);
    });

    test('map2', () {
      final reader = Reader<String, int>((r) => r.length);
      final reader1 = Reader<String, int>((r) => r.length * 2);
      final ap = reader.map2<int, int>(reader1, (a, c) => a * c);
      final result = ap.run('abc');
      expect(result, 18);
    });

    test('map3', () {
      final reader = Reader<String, int>((r) => r.length);
      final reader1 = Reader<String, int>((r) => r.length * 2);
      final reader2 = Reader<String, int>((r) => r.length * 3);
      final ap =
          reader.map3<int, int, int>(reader1, reader2, (a, c, d) => a * c * d);
      final result = ap.run('ab');
      expect(result, 48);
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

    test('pure', () {
      final reader = Reader<String, int>((r) => r.length);
      final ap = reader.pure(10);
      final result = ap.run('abc');
      expect(result, 10);
    });

    test('andThen', () {
      final reader = Reader<String, int>((r) => r.length);
      final ap =
          reader.andThen(() => Reader<String, double>((r) => r.length / 2));
      final result = ap.run('abc');
      expect(result, 1.5);
    });

    test('call', () {
      final reader = Reader<String, int>((r) => r.length);
      final ap = reader(Reader<String, double>((r) => r.length / 2));
      final result = ap.run('abc');
      expect(result, 1.5);
    });

    test('compose', () {
      final reader = Reader<String, int>((r) => r.length);
      final ap = reader.compose(Reader<String, double>((r) => r.length / 2));
      final result = ap.run('abc');
      expect(result, 1.5);
    });

    test('local', () {
      final reader = Reader<String, int>((r) => r.length);
      final ap = reader.local<double>((context) => '$context');
      final result = ap.run(7.5);
      expect(result, 3);
    });

    test('ask', () {
      final reader = Reader<String, int>((r) => r.length);
      final ap = reader.ask();
      final result = ap.run('abc');
      expect(result, 'abc');
    });

    test('asks', () {
      final reader = Reader<String, int>((r) => r.length);
      final ap = reader.asks((r) => r.length * 2);
      final result = ap.run('abc');
      expect(result, 6);
    });

    test('flatten', () {
      final reader = Reader<String, Reader<String, int>>(
          (r) => Reader<String, int>((r) => r.length));
      final ap = Reader.flatten(reader);
      expect(ap, isA<Reader<String, int>>());
      final result = ap.run('abc');
      expect(result, 3);
    });
  });

  test('chainFirst', () async {
    final task = Reader<String, int>(((r) => r.length));
    var sideEffect = 10;
    final chain = task.chainFirst((b) {
      sideEffect = 100;
      return Reader<String, double>((r) => r.length / 2);
    });
    final r = await chain.run("abc");
    expect(r, 3);
    expect(sideEffect, 100);
  });
}
