import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

extension EitherTest<L, R> on Either<L, R> {
  void expectLeft(Function(L value) onLeft) {
    switch (this) {
      case Right(value: final value):
        fail("Either expected to be Left, Right instead: $value");
      case Left(value: final value):
        onLeft(value);
    }
  }

  void expectRight(Function(R value) onRight) {
    switch (this) {
      case Right(value: final value):
        onRight(value);
      case Left(value: final value):
        fail("Either expected to be Right, Left instead: $value");
    }
  }
}
