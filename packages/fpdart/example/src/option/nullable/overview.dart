import 'dart:math';

import 'package:fpdart/fpdart.dart';

int? nullable() => Random().nextBool() ? 10 : null;

String takesNullable(int? nullInt) => "$nullInt";

void main(List<String> args) {
  int noNull = 10;
  int? canBeNull = nullable();

  /// `bool`
  final noNullIsEven = noNull.isEven;

  /// final canBeNullIsEven = canBeNull.isEven; ⛔️

  /// `bool?`
  final canBeNullIsEven = canBeNull?.isEven;

  /// ☑️
  takesNullable(canBeNull);

  /// ☑️
  takesNullable(noNull);

  /// ☑️
  noNull.abs();

  /// ☑️
  canBeNull?.abs();

  Option<int> optionInt = Option.of(10);
  int? nullInt = nullable();

  nullInt?.abs();
  optionInt.map((t) => t.abs());

  nullInt?.isEven;
  optionInt.map((t) => t.isEven);

  takesNullable(nullInt);

  /// takesNullable(optionInt); ⛔️
  takesNullable(optionInt.toNullable());
}
