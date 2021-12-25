// ignore_for_file: avoid_print

import 'package:fpdart/fpdart.dart';

int sum(int param1, int param2) => param1 + param2;

double sumMultiplyDivide(int param1, int param2, int param3, int param4) =>
    (param1 + param2) * param3 / param4;

void main() {
  /// Convert a function with 2 parameters to a function that
  /// takes the first parameter and returns a function that takes
  /// the seconds parameter.
  final sumCurry = curry2(sum);
  final sumBy2 = sumCurry(2);
  final sumBy10 = sumCurry(10);
  print(sumBy2(10));
  print(sumBy10(2));

  /// Same as above but with 4 parameters.
  final sumMultiplyDivideCurry = curry4(sumMultiplyDivide);
  final sumBy5 = sumMultiplyDivideCurry(5);
  final multiplyBy2 = sumBy5(2);
  final divideBy3 = multiplyBy2(3);
  print(divideBy3(10));
  print(sumMultiplyDivideCurry(5)(2)(3)(10));

  /// Using the extension
  final sumBy2Extension = sum.curry(2);
  final sumBy10Extension = sum.curry(10);
  print(sumBy2Extension(10));
  print(sumBy10Extension(2));

  final fourParamsCurry = sumMultiplyDivide.curry;
  final fourParamsUncurry = fourParamsCurry.uncurry;
}
