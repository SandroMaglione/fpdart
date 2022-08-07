import 'package:test/test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fpdart/src/typeclass/traversable.dart';

void main() {
  group('either', () {
    test('all rights', () {
      final listOfEithers = [Either.right(1), Either.right(2), Either.right(3)];
      final result = sequenceEither(listOfEithers);
      expect(result.isRight(), true);
      expect(result.getOrElse((l) => []), [1, 2, 3]);
    });
    test('one left', () {
      final listOfEithers = [Either.right(1), Either.left(2), Either.right(3)];
      final result = sequenceEither(listOfEithers);
      expect(result.isRight(), false);
      expect(result.getLeft(), Option.of(2));
    });
  });
}
