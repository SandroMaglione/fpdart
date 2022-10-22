import 'dart:math';

import 'package:fpdart/fpdart.dart';

int? nullable() => Random().nextBool() ? 10 : null;

void main(List<String> args) {
  final value = 10;
  // final either = value.toEither<String>();

  final nullableValue = nullable();
  nullableValue.toTaskEitherAsync(Task.of(10));
  // nullableValue.toEither();
}
