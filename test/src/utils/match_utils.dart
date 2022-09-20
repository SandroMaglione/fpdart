import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

extension EitherMatch<L, R> on Either<L, R> {
  /// Run test on [Right], call `fail` if [Left].
  void matchTestRight(void Function(R r) testing) => match((l) {
        fail("should be right, found left ('$l')");
      }, testing);

  /// Run test on [Left], call `fail` if [Right].
  void matchTestLeft(void Function(L l) testing) => match(testing, (r) {
        fail("should be left, found right ('$r')");
      });
}
