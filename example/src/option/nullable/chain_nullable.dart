import 'dart:math';

import 'package:fpdart/fpdart.dart';

int? nullable() => Random().nextBool() ? 10 : null;

void main(List<String> args) {
  /// [Option] <-> `int?`
  int? value1 = 10.toOption().map((t) => t + 10).toNullable();

  bool? value2 = value1?.isEven;

  /// `bool?` -> [Either] -> `int?`
  int? value3 = value2
      .toEither(() => "Error")
      .flatMap((a) => a ? right<String, int>(10) : left<String, int>("None"))
      .toNullable();

  /// `int?` -> [Option]
  Option<int> value4 = (value3?.abs().round()).toOption().flatMap(Option.of);

  Option<int> value = (10
          .toOption()
          .map((t) => t + 10)
          .toNullable()

          /// Null safety 🎯
          ?.ceil()

          /// Null safety 🎯
          .isEven
          .toEither(() => "Error")
          .flatMap((a) => right<String, int>(10))
          .toNullable()

          /// Null safety 🎯
          ?.abs()

          /// Null safety 🎯
          .round())
      .toOption()
      .flatMap(Option.of);
}
