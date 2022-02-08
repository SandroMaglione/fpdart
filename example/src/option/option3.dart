// ignore_for_file: unused_local_variable

import 'package:fpdart/fpdart.dart';

int? stringToIntNull(String a) {
  if (a.isNotEmpty) {
    return a.length;
  } else {
    return null;
  }
}

double? intToDoubleNull(int a) {
  if (a != 0) {
    return a / 2;
  } else {
    return null;
  }
}

Option<int> stringToInt(String a) => Option.fromPredicateMap<String, int>(
      a,
      (str) => str.isNotEmpty,
      (str) => str.length,
    );

Option<double> intToDouble(int a) =>
    Option.fromPredicateMap<int, double>(a, (v) => v != 0, (v) => v / 2);

void main() {
  /// Using `null`, you are required to check that the value is not
  /// `null` every time you call a function.
  ///
  /// Furthermore, you left unspecified what will happen when one of the
  /// values is a `null` 🤦‍♂️
  const aNull = 'name';
  final intNull = stringToIntNull(aNull);
  if (intNull != null) {
    final doubleNull = intToDoubleNull(intNull);
  }

  /// Using `flatMap`, you can forget that the value may be missing and just
  /// use it as if it was there.
  ///
  /// In case one of the values is actually missing, you will get a [None]
  /// at the end of the chain ⛓
  final a = Option.of('name');
  final Option<double> result = a.flatMap(
    (s) => stringToInt(s).flatMap(
      (i) => intToDouble(i),
    ),
  );
}
