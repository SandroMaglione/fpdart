import 'package:fpdart/fpdart.dart';

import '../utils/utils.dart';

void main() {
  group('FpdartOnList', () {
    test('foldRight', () {
      final list1 = [1, 2, 3];
      final ap = list1.foldRight(0.0, (t, b) => b - t);
      expect(ap, 2);
    });

    test('foldRightWithIndex', () {
      final list1 = [1, 2, 3];
      final ap = list1.foldRightWithIndex(0.0, (t, b, i) => b - t - i);
      expect(ap, 1);
    });

    test('takeWhileRight', () {
      final list1 = [1, 2, 3, 4];
      final ap = list1.takeWhileRight((t) => t > 2);
      expect(ap.length, 2);
      expect(ap.elementAt(0), 4);
      expect(ap.elementAt(1), 3);
    });

    test('dropWhileRight', () {
      final list1 = [1, 2, 3, 4];
      final ap = list1.dropWhileRight((t) => t > 2);
      expect(ap.length, 2);
      expect(ap.elementAt(0), 2);
      expect(ap.elementAt(1), 1);
    });
  });
}
