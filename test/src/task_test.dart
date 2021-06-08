import 'package:fpdart/src/task.dart';
import 'package:test/test.dart';

void main() {
  group('Task', () {
    test('map', () async {
      final task = Task(() async => 10);
      final ap = task.map((a) => a + 1);
      expect(ap, isA<Task>());
      final r = await ap.run();
      expect(r, 11);
    });

    test('ap', () async {
      final task = Task(() async => 10);
      final ap = task.ap(Task(() async => (int a) => a + 1));
      expect(ap, isA<Task>());
      final r = await ap.run();
      expect(r, 11);
    });

    test('flatMap', () async {
      final task = Task(() async => 10);
      final ap = task
          .flatMap((a) => Task(() async => '$a'))
          .flatMap((a) => Task(() async => a.length));
      expect(ap, isA<Task>());
      final r = await ap.run();
      expect(r, 2);
    });
  });
}
